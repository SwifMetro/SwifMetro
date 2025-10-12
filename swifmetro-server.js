/**
 * SwifMetro Server
 * Created: September 30, 2025
 * The first Metro-style terminal logging for native iOS
 */

const WebSocket = require('ws');
const os = require('os');
const https = require('https');
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, 'CONFIDENTIAL', '.env') });
const { execSync } = require('child_process');
const crypto = require('crypto');
const { Pool } = require('pg');
const bonjour = require('bonjour')();

// Configuration
const PORT = 8081;
const HOST = '0.0.0.0'; // Listen on all interfaces
const LICENSE_SERVER = 'http://localhost:8082'; // License validation server
const FREE_DEVICE_LIMIT = 999; // TESTING: Allow unlimited devices for now

// PostgreSQL connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: {
        rejectUnauthorized: false
    }
});

// Initialize database tables
async function initDatabase() {
    const client = await pool.connect();
    try {
        await client.query(`
            CREATE TABLE IF NOT EXISTS trials (
                hardware_id VARCHAR(16) PRIMARY KEY,
                start_date BIGINT NOT NULL,
                expired BOOLEAN DEFAULT false,
                created_at TIMESTAMP DEFAULT NOW()
            )
        `);
        
        await client.query(`
            CREATE TABLE IF NOT EXISTS licenses (
                license_key VARCHAR(19) PRIMARY KEY,
                email VARCHAR(255),
                tier VARCHAR(20) DEFAULT 'pro',
                active BOOLEAN DEFAULT true,
                created_at TIMESTAMP DEFAULT NOW()
            )
        `);
        
        console.log('✅ Database tables initialized');
    } catch (err) {
        console.error('❌ Database init error:', err);
    } finally {
        client.release();
    }
}

initDatabase();

// Get hardware ID (same as Electron app)
function getHardwareId() {
    try {
        const uuid = execSync('system_profiler SPHardwareDataType | grep "Hardware UUID"').toString();
        const hardwareId = uuid.split(':')[1].trim();
        return crypto.createHash('sha256').update(hardwareId).digest('hex').substring(0, 16);
    } catch (err) {
        try {
            const serial = execSync('system_profiler SPHardwareDataType | grep "Serial Number"').toString();
            const serialNumber = serial.split(':')[1].trim();
            return crypto.createHash('sha256').update(serialNumber).digest('hex').substring(0, 16);
        } catch (err2) {
            const interfaces = os.networkInterfaces();
            const mac = Object.values(interfaces).flat().find(i => !i.internal && i.mac !== '00:00:00:00:00:00')?.mac || 'unknown';
            return crypto.createHash('sha256').update(mac).digest('hex').substring(0, 16);
        }
    }
}

// Check if trial is expired (using PostgreSQL)
async function checkTrialExpiration(licenseKey) {
    if (licenseKey !== 'SWIF-DEMO-DEMO-DEMO') {
        return { expired: false }; // Real license, no expiration
    }
    
    const hardwareId = getHardwareId();
    const client = await pool.connect();
    
    try {
        // Check if trial exists in database
        const result = await client.query(
            'SELECT start_date, expired FROM trials WHERE hardware_id = $1',
            [hardwareId]
        );
        
        if (result.rows.length === 0) {
            // No trial started yet - create it
            await client.query(
                'INSERT INTO trials (hardware_id, start_date) VALUES ($1, $2)',
                [hardwareId, Date.now()]
            );
            console.log(`✅ Trial started for hardware: ${hardwareId}`);
            return { expired: false, daysRemaining: 7 };
        }
        
        const trial = result.rows[0];
        const now = Date.now();
        const daysElapsed = (now - trial.start_date) / (1000 * 60 * 60 * 24);
        
        if (daysElapsed > 7) {
            // Mark as expired in database
            await client.query(
                'UPDATE trials SET expired = true WHERE hardware_id = $1',
                [hardwareId]
            );
            return { expired: true, daysRemaining: 0 };
        }
        
        return { expired: false, daysRemaining: Math.floor(7 - daysElapsed) };
    } catch (err) {
        console.error('Error checking trial:', err);
        return { expired: false };
    } finally {
        client.release();
    }
}

// Auto-load default license from ~/.swifmetro/license
async function getDefaultLicense() {
    const licensePath = path.join(os.homedir(), '.swifmetro', 'license');
    if (fs.existsSync(licensePath)) {
        const license = fs.readFileSync(licensePath, 'utf8').trim();
        
        // Check trial expiration
        const trialStatus = await checkTrialExpiration(license);
        if (trialStatus.expired) {
            console.log(`❌ Trial expired! Please upgrade to Pro: https://swifmetro.dev/pricing`);
            return null;
        }
        
        if (license === 'SWIF-DEMO-DEMO-DEMO') {
            console.log(`🔑 Found trial license: ${trialStatus.daysRemaining} days remaining`);
        } else {
            console.log(`🔑 Found license in ~/.swifmetro/license: ${license}`);
        }
        return license;
    }
    if (process.env.SWIFMETRO_LICENSE_KEY) {
        console.log(`🔑 Found license in env: ${process.env.SWIFMETRO_LICENSE_KEY}`);
        return process.env.SWIFMETRO_LICENSE_KEY;
    }
    console.log('🆓 No license found - Trial expired or not started');
    return null;
}

let DEFAULT_LICENSE = null;
getDefaultLicense().then(license => {
    DEFAULT_LICENSE = license;
});

console.log('');
console.log('🚀 SWIFMETRO SERVER');
console.log('='.repeat(50));
console.log(`📡 Starting on port ${PORT}...`);
console.log('');

// Get all network interfaces
function getNetworkIPs() {
    const interfaces = os.networkInterfaces();
    const ips = [];
    
    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            // Skip internal and non-IPv4 addresses
            if (iface.family === 'IPv4' && !iface.internal) {
                ips.push({name: name, ip: iface.address});
            }
        }
    }
    return ips;
}

// Display available IPs
console.log('📱 Your iPhone should connect to one of these IPs:');
console.log('-'.repeat(50));
const ips = getNetworkIPs();
ips.forEach(({name, ip}) => {
    console.log(`   ${ip} (${name})`);
});
console.log('-'.repeat(50));
console.log('');
console.log('💡 Add your Mac\'s IP to SimpleMetroClient.swift');
console.log('   Example: private let HOST_IP = "' + (ips[0]?.ip || '192.168.0.100') + '"');
console.log('');
console.log('⏳ Waiting for iPhone connections...');
console.log('');

// Create WebSocket server
const wss = new WebSocket.Server({ 
    port: PORT,
    host: HOST 
});

// Track connected devices with metadata
let devices = new Map();
let dashboards = new Set();

// Device class to track individual iOS devices
class Device {
    constructor(ws, deviceId, deviceName, licenseKey = null) {
        this.ws = ws;
        this.deviceId = deviceId;
        this.deviceName = deviceName;
        this.licenseKey = licenseKey;
        this.licenseTier = 'free';
        this.connectedAt = new Date();
        this.lastActivity = new Date();
        this.logCount = 0;
    }
}

// License validation cache
const licenseCache = new Map();

// Validate license key with server
async function validateLicense(key) {
    if (!key) return { valid: false, tier: 'free' };
    
    // Check cache first
    if (licenseCache.has(key)) {
        const cached = licenseCache.get(key);
        if (Date.now() - cached.timestamp < 3600000) { // 1 hour cache
            return cached.data;
        }
    }
    
    try {
        const response = await fetch(`${LICENSE_SERVER}/validate`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ key })
        });
        
        const data = await response.json();
        
        // Cache result
        licenseCache.set(key, {
            timestamp: Date.now(),
            data
        });
        
        return data;
    } catch (error) {
        console.log(`⚠️ License validation failed: ${error.message}`);
        return { valid: false, tier: 'free' };
    }
}

wss.on('connection', function connection(ws, req) {
    const clientIP = req.socket.remoteAddress;
    const timestamp = new Date().toLocaleTimeString();
    
    // Client will identify itself as device or dashboard
    let clientType = null;
    let deviceId = null;
    
    console.log('🔥'.repeat(10));
    console.log(`🔥 CLIENT CONNECTED at ${timestamp}!`);
    console.log(`📱 From IP: ${clientIP}`);
    console.log('🔥'.repeat(10));
    console.log('');
    
    // Send welcome message
    ws.send(JSON.stringify({
        type: 'welcome',
        message: '🎉 Welcome to SwifMetro! Identify yourself (device or dashboard)'
    }));
    
    // Handle incoming messages
    ws.on('message', function incoming(message) {
        const timestamp = new Date().toLocaleTimeString();
        const msgString = message.toString();
        
        // DEBUG: Log all incoming messages
        console.log(`📨 [${timestamp}] Received from ${clientIP}:`, msgString.substring(0, 200));
        
        // Try to parse as JSON (for structured messages)
        let parsed;
        try {
            parsed = JSON.parse(msgString);
        } catch (e) {
            // Plain text message (backward compatible)
            console.log(`⚠️ Failed to parse JSON, treating as plain text log`);
            parsed = { type: 'log', message: msgString };
        }
        
        // Handle different message types
        if (parsed.type === 'identify') {
            // Client identifying itself
            if (parsed.clientType === 'device') {
                deviceId = parsed.deviceId || `device_${Date.now()}`;
                const deviceName = parsed.deviceName || 'Unknown iPhone';
                const licenseKey = parsed.licenseKey || DEFAULT_LICENSE;
                
                // Validate license
                validateLicense(licenseKey).then(licenseData => {
                    const device = new Device(ws, deviceId, deviceName, licenseKey);
                    device.licenseTier = licenseData.tier || 'free';
                    
                    // Check device limit for free tier
                    if (device.licenseTier === 'free' && devices.size >= FREE_DEVICE_LIMIT) {
                        console.log(`❌ Device limit reached for free tier: ${deviceName}`);
                        ws.send(JSON.stringify({
                            type: 'error',
                            message: `Free tier limited to ${FREE_DEVICE_LIMIT} device. Upgrade to Pro for multiple devices: https://swifmetro.dev/pricing`
                        }));
                        ws.close();
                        return;
                    }
                    
                    devices.set(deviceId, device);
                    clientType = 'device';
                    
                    const tierEmoji = device.licenseTier === 'pro' ? '💎' : device.licenseTier === 'enterprise' ? '👑' : '🆓';
                    console.log(`📱 Device registered: ${deviceName} (${deviceId}) ${tierEmoji} ${device.licenseTier.toUpperCase()}`);
                    console.log(`📊 Total devices: ${devices.size}`);
                    console.log('');
                    
                    // Send device list to all dashboards
                    broadcastDeviceList();
                    
                    // Send welcome message with tier info
                    ws.send(JSON.stringify({
                        type: 'welcome',
                        tier: device.licenseTier,
                        features: licenseData.features || [],
                        message: `Connected as ${device.licenseTier.toUpperCase()} tier`
                    }));
                });
                
            } else if (parsed.clientType === 'dashboard') {
                dashboards.add(ws);
                clientType = 'dashboard';
                
                console.log(`💻 Dashboard connected`);
                console.log(`📊 Total dashboards: ${dashboards.size}`);
                console.log('');
                
                // Send current device list to new dashboard
                ws.send(JSON.stringify({
                    type: 'device_list',
                    devices: Array.from(devices.values()).map(d => ({
                        deviceId: d.deviceId,
                        deviceName: d.deviceName,
                        connectedAt: d.connectedAt,
                        logCount: d.logCount
                    }))
                }));
            }
            return;
        }
        
        // Handle log messages from devices
        if (parsed.type === 'log' || !parsed.type) {
            const logMessage = parsed.message || msgString;
            
            // Update device last activity
            if (deviceId && devices.has(deviceId)) {
                const device = devices.get(deviceId);
                device.lastActivity = new Date();
                device.logCount++;
            }
            
            // Broadcast to all dashboards
            const payload = JSON.stringify({
                type: 'log',
                deviceId: deviceId || 'unknown',
                deviceName: devices.get(deviceId)?.deviceName || 'Unknown Device',
                message: logMessage,
                timestamp: timestamp
            });
            
            dashboards.forEach(dashboard => {
                if (dashboard.readyState === WebSocket.OPEN) {
                    dashboard.send(payload);
                }
            });
            
            // Color-code in terminal
            const deviceLabel = deviceId ? `[${devices.get(deviceId)?.deviceName || deviceId}]` : '[Unknown]';
            if (logMessage.includes('❌') || logMessage.includes('Error') || logMessage.includes('error')) {
                console.log(`[${timestamp}] ${deviceLabel} \x1b[31m${logMessage}\x1b[0m`);
            } else if (logMessage.includes('✅') || logMessage.includes('Success')) {
                console.log(`[${timestamp}] ${deviceLabel} \x1b[32m${logMessage}\x1b[0m`);
            } else if (logMessage.includes('⚠️') || logMessage.includes('Warning')) {
                console.log(`[${timestamp}] ${deviceLabel} \x1b[33m${logMessage}\x1b[0m`);
            } else if (logMessage.includes('ℹ️') || logMessage.includes('Info')) {
                console.log(`[${timestamp}] ${deviceLabel} \x1b[36m${logMessage}\x1b[0m`);
            } else {
                console.log(`[${timestamp}] ${deviceLabel} ${logMessage}`);
            }
        }
        
        // Handle network request logs
        if (parsed.type === 'network') {
            // Update device activity
            if (deviceId && devices.has(deviceId)) {
                devices.get(deviceId).lastActivity = new Date();
            }
            
            // Broadcast to dashboards
            const payload = JSON.stringify({
                type: 'network',
                deviceId: deviceId || 'unknown',
                deviceName: devices.get(deviceId)?.deviceName || 'Unknown Device',
                method: parsed.method,
                url: parsed.url,
                statusCode: parsed.statusCode,
                duration: parsed.duration,
                timestamp: timestamp
            });
            
            dashboards.forEach(dashboard => {
                if (dashboard.readyState === WebSocket.OPEN) {
                    dashboard.send(payload);
                }
            });
            
            // Log to terminal
            const deviceLabel = deviceId ? `[${devices.get(deviceId)?.deviceName || deviceId}]` : '[Unknown]';
            console.log(`[${timestamp}] ${deviceLabel} 🌐 ${parsed.method} ${parsed.url} - ${parsed.statusCode} (${parsed.duration}ms)`);
        }
    });
    
    // Helper function to broadcast device list
    function broadcastDeviceList() {
        const payload = JSON.stringify({
            type: 'device_list',
            devices: Array.from(devices.values()).map(d => ({
                deviceId: d.deviceId,
                deviceName: d.deviceName,
                connectedAt: d.connectedAt,
                logCount: d.logCount
            }))
        });
        
        dashboards.forEach(dashboard => {
            if (dashboard.readyState === WebSocket.OPEN) {
                dashboard.send(payload);
            }
        });
    }
    
    // Handle disconnection
    ws.on('close', function() {
        const timestamp = new Date().toLocaleTimeString();
        
        console.log(`🔌 Connection closed from ${clientIP} at ${timestamp}`);
        console.log(`   Client type: ${clientType || 'UNKNOWN (never identified!)'}`);
        console.log(`   Device ID: ${deviceId || 'N/A'}`);
        
        if (clientType === 'device' && deviceId) {
            devices.delete(deviceId);
            console.log('');
            console.log(`❌ Device disconnected at ${timestamp}: ${deviceId}`);
            console.log(`📊 Total devices: ${devices.size}`);
            console.log('');
            
            // Notify dashboards
            broadcastDeviceList();
            
        } else if (clientType === 'dashboard') {
            dashboards.delete(ws);
            console.log('');
            console.log(`❌ Dashboard disconnected at ${timestamp}`);
            console.log(`📊 Total dashboards: ${dashboards.size}`);
            console.log('');
        }
        
        console.log('⏳ Waiting for reconnection...');
        console.log('');
    });
    
    // Handle errors
    ws.on('error', function(error) {
        console.log('❌ WebSocket error:', error.message);
    });
    
    // Send periodic heartbeat
    const heartbeat = setInterval(() => {
        if (ws.readyState === WebSocket.OPEN) {
            ws.send(JSON.stringify({ type: 'heartbeat', timestamp: Date.now() }));
        } else {
            clearInterval(heartbeat);
        }
    }, 30000); // Every 30 seconds
});

// Handle server errors
wss.on('error', function(error) {
    console.log('❌ Server error:', error.message);
    if (error.code === 'EADDRINUSE') {
        console.log('💡 Port 8081 is already in use. Kill the other process:');
        console.log('   lsof -ti:8081 | xargs kill -9');
    }
});

// Graceful shutdown
process.on('SIGINT', function() {
    console.log('\n👋 Shutting down SwifMetro server...');
    bonjour.unpublishAll(() => {
        console.log('📡 Stopped broadcasting Bonjour service');
    });
    wss.close(() => {
        process.exit(0);
    });
});

console.log('✅ Server is running!');
console.log('📝 Press Ctrl+C to stop');
console.log('='.repeat(50));

// Broadcast Bonjour service for auto-discovery
const service = bonjour.publish({
    name: 'SwifMetro',
    type: 'swifmetro',
    port: PORT,
    txt: {
        version: '1.0',
        platform: 'mac'
    }
});

console.log('📡 Broadcasting Bonjour service: _swifmetro._tcp');
console.log('📱 Physical devices can now auto-discover this server!');