/**
 * SwifMetro Advanced Server
 * With Bonjour discovery, hot reload support, and cloud sync
 */

const WebSocket = require('ws');
const os = require('os');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// Try to load Bonjour (optional but recommended)
let bonjour;
try {
    bonjour = require('bonjour')();
} catch (e) {
    console.log('⚠️  Bonjour not installed. Run: npm install bonjour');
}

// Configuration
const CONFIG = {
    port: 8081,
    host: '0.0.0.0',
    serviceName: 'SwifMetro',
    serviceType: 'swifmetro',
    enableCloud: false, // Set to true for cloud features
    enableHotReload: false, // Experimental
    maxLogHistory: 10000,
    authToken: process.env.SWIFMETRO_TOKEN || null
};

// Server state
const state = {
    devices: new Map(),
    logs: [],
    startTime: new Date(),
    stats: {
        messagesReceived: 0,
        deviceConnections: 0,
        errors: 0
    }
};

// ANSI colors for terminal
const colors = {
    reset: '\x1b[0m',
    bright: '\x1b[1m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    magenta: '\x1b[35m',
    cyan: '\x1b[36m'
};

// Display startup banner
function displayBanner() {
    console.log('');
    console.log(colors.bright + colors.cyan + '╔══════════════════════════════════════════════╗' + colors.reset);
    console.log(colors.bright + colors.cyan + '║' + colors.reset + '            🚀 SWIFMETRO SERVER              ' + colors.cyan + '║' + colors.reset);
    console.log(colors.bright + colors.cyan + '║' + colors.reset + '    Terminal Logging for Native iOS          ' + colors.cyan + '║' + colors.reset);
    console.log(colors.bright + colors.cyan + '║' + colors.reset + '    Created: September 30, 2025              ' + colors.cyan + '║' + colors.reset);
    console.log(colors.bright + colors.cyan + '╚══════════════════════════════════════════════╝' + colors.reset);
    console.log('');
}

// Get network interfaces
function getNetworkInfo() {
    const interfaces = os.networkInterfaces();
    const ips = [];
    
    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            if (iface.family === 'IPv4' && !iface.internal) {
                ips.push({
                    name: name,
                    ip: iface.address,
                    netmask: iface.netmask
                });
            }
        }
    }
    
    return ips;
}

// Display server info
function displayServerInfo() {
    console.log(colors.green + '✅ Server Configuration:' + colors.reset);
    console.log(`   Port: ${colors.bright}${CONFIG.port}${colors.reset}`);
    console.log(`   Cloud Sync: ${CONFIG.enableCloud ? colors.green + 'Enabled' : colors.yellow + 'Disabled'}${colors.reset}`);
    console.log(`   Hot Reload: ${CONFIG.enableHotReload ? colors.green + 'Enabled' : colors.yellow + 'Disabled'}${colors.reset}`);
    console.log(`   Auth: ${CONFIG.authToken ? colors.green + 'Required' : colors.yellow + 'Open'}${colors.reset}`);
    console.log('');
    
    console.log(colors.blue + '📱 Connect your iPhone to one of these IPs:' + colors.reset);
    console.log('─'.repeat(50));
    
    const ips = getNetworkInfo();
    ips.forEach(({name, ip}) => {
        console.log(`   ${colors.bright}${ip}${colors.reset} (${name})`);
    });
    
    console.log('─'.repeat(50));
    console.log('');
}

// Create WebSocket server
const wss = new WebSocket.Server({ 
    port: CONFIG.port,
    host: CONFIG.host,
    verifyClient: (info, cb) => {
        // Optional authentication
        if (CONFIG.authToken) {
            const token = info.req.headers['authorization'];
            if (token !== `Bearer ${CONFIG.authToken}`) {
                cb(false, 401, 'Unauthorized');
                return;
            }
        }
        cb(true);
    }
});

// Broadcast via Bonjour
if (bonjour) {
    const service = bonjour.publish({ 
        name: CONFIG.serviceName,
        type: CONFIG.serviceType,
        port: CONFIG.port,
        txt: {
            version: '1.0.0',
            platform: 'iOS',
            capabilities: 'logging,hotreload,commands'
        }
    });
    
    console.log(colors.green + '✅ Broadcasting via Bonjour as:' + colors.reset);
    console.log(`   ${colors.bright}_${CONFIG.serviceType}._tcp${colors.reset}`);
    console.log('');
}

// Handle new connections
wss.on('connection', function connection(ws, req) {
    const clientIP = req.socket.remoteAddress;
    const deviceId = crypto.randomBytes(8).toString('hex');
    const timestamp = new Date().toLocaleTimeString();
    
    // Store device info
    const device = {
        id: deviceId,
        ip: clientIP,
        ws: ws,
        connectedAt: new Date(),
        info: {},
        logCount: 0
    };
    
    state.devices.set(deviceId, device);
    state.stats.deviceConnections++;
    
    // Fancy connection notification
    console.log('');
    console.log(colors.bright + colors.green + '🔥'.repeat(15) + colors.reset);
    console.log(colors.bright + colors.green + `🔥 iPHONE CONNECTED at ${timestamp}!` + colors.reset);
    console.log(`${colors.cyan}📱 Device ID:${colors.reset} ${deviceId}`);
    console.log(`${colors.cyan}🌐 From IP:${colors.reset} ${clientIP}`);
    console.log(colors.bright + colors.green + '🔥'.repeat(15) + colors.reset);
    console.log('');
    
    // Send welcome message
    ws.send(JSON.stringify({
        type: 'welcome',
        message: '🎉 Connected to SwifMetro!',
        deviceId: deviceId,
        serverTime: new Date().toISOString(),
        capabilities: {
            logging: true,
            hotReload: CONFIG.enableHotReload,
            commands: true,
            screenshots: true
        }
    }));
    
    // Handle incoming messages
    ws.on('message', function incoming(message) {
        try {
            state.stats.messagesReceived++;
            device.logCount++;
            
            const timestamp = new Date().toLocaleTimeString();
            let data;
            
            // Try to parse as JSON first
            try {
                data = JSON.parse(message.toString());
                handleStructuredMessage(device, data, timestamp);
            } catch {
                // Plain text message
                handlePlainMessage(device, message.toString(), timestamp);
            }
            
            // Store in history
            if (state.logs.length >= CONFIG.maxLogHistory) {
                state.logs.shift();
            }
            
            state.logs.push({
                deviceId: deviceId,
                timestamp: new Date(),
                message: message.toString()
            });
            
            // Broadcast to other connected clients (for team sharing)
            broadcastToOthers(deviceId, message.toString());
            
        } catch (error) {
            console.log(colors.red + `❌ Error processing message: ${error.message}` + colors.reset);
            state.stats.errors++;
        }
    });
    
    // Handle disconnection
    ws.on('close', function() {
        const device = state.devices.get(deviceId);
        const sessionTime = ((new Date() - device.connectedAt) / 1000).toFixed(1);
        
        console.log('');
        console.log(colors.yellow + `⚠️  Device ${deviceId} disconnected` + colors.reset);
        console.log(`   Session duration: ${sessionTime}s`);
        console.log(`   Logs received: ${device.logCount}`);
        console.log('');
        
        state.devices.delete(deviceId);
    });
    
    // Handle errors
    ws.on('error', function(error) {
        console.log(colors.red + `❌ WebSocket error: ${error.message}` + colors.reset);
        state.stats.errors++;
    });
    
    // Setup heartbeat
    const heartbeat = setInterval(() => {
        if (ws.readyState === WebSocket.OPEN) {
            ws.ping();
        } else {
            clearInterval(heartbeat);
        }
    }, 30000);
});

// Handle structured messages
function handleStructuredMessage(device, data, timestamp) {
    // Store device info if provided
    if (data.device || data.model || data.os) {
        device.info = {
            name: data.device,
            model: data.model,
            os: data.os,
            app: data.app
        };
        
        console.log(`${colors.cyan}📱 Device Info:${colors.reset}`);
        console.log(`   Name: ${device.info.name}`);
        console.log(`   Model: ${device.info.model}`);
        console.log(`   OS: ${device.info.os}`);
        console.log(`   App: ${device.info.app}`);
        console.log('');
        return;
    }
    
    // Handle different message types
    if (data.event) {
        // Structured log
        const icon = getIconForEvent(data.event);
        console.log(`[${timestamp}] ${icon} ${colors.bright}${data.event}${colors.reset}`);
        if (data.data) {
            console.log(`   ${JSON.stringify(data.data, null, 2)}`);
        }
    } else {
        // Generic structured data
        console.log(`[${timestamp}] 📊 ${JSON.stringify(data, null, 2)}`);
    }
}

// Handle plain text messages
function handlePlainMessage(device, message, timestamp) {
    // Color code based on content
    let color = colors.reset;
    let icon = '📱';
    
    if (message.includes('❌') || message.includes('Error') || message.includes('error')) {
        color = colors.red;
        icon = '❌';
    } else if (message.includes('✅') || message.includes('Success') || message.includes('success')) {
        color = colors.green;
        icon = '✅';
    } else if (message.includes('⚠️') || message.includes('Warning') || message.includes('warning')) {
        color = colors.yellow;
        icon = '⚠️';
    } else if (message.includes('ℹ️') || message.includes('Info')) {
        color = colors.cyan;
        icon = 'ℹ️';
    } else if (message.includes('🔍') || message.includes('Debug')) {
        color = colors.magenta;
        icon = '🔍';
    }
    
    console.log(`[${timestamp}] ${icon} ${color}${message}${colors.reset}`);
}

// Get icon for event type
function getIconForEvent(event) {
    const icons = {
        'tap': '👆',
        'swipe': '👉',
        'network': '🌐',
        'navigation': '📍',
        'error': '❌',
        'success': '✅',
        'warning': '⚠️',
        'performance': '📊',
        'memory': '💾',
        'screenshot': '📸'
    };
    
    for (const [key, icon] of Object.entries(icons)) {
        if (event.toLowerCase().includes(key)) {
            return icon;
        }
    }
    
    return '📝';
}

// Broadcast to other connected devices
function broadcastToOthers(senderId, message) {
    if (!CONFIG.enableCloud) return;
    
    for (const [deviceId, device] of state.devices) {
        if (deviceId !== senderId && device.ws.readyState === WebSocket.OPEN) {
            device.ws.send(JSON.stringify({
                type: 'broadcast',
                from: senderId,
                message: message
            }));
        }
    }
}

// Handle server commands
wss.on('listening', function() {
    displayBanner();
    displayServerInfo();
    
    console.log(colors.green + '✅ Server is running!' + colors.reset);
    console.log(`📝 Press ${colors.bright}Ctrl+C${colors.reset} to stop`);
    console.log('');
    console.log(colors.yellow + '⏳ Waiting for iPhone connections...' + colors.reset);
    console.log('═'.repeat(50));
});

// Error handling
wss.on('error', function(error) {
    console.log(colors.red + `❌ Server error: ${error.message}` + colors.reset);
    
    if (error.code === 'EADDRINUSE') {
        console.log(colors.yellow + '💡 Port 8081 is already in use.' + colors.reset);
        console.log('   Kill the other process:');
        console.log(colors.bright + '   lsof -ti:8081 | xargs kill -9' + colors.reset);
    }
});

// Graceful shutdown
process.on('SIGINT', function() {
    console.log('');
    console.log(colors.yellow + '👋 Shutting down SwifMetro server...' + colors.reset);
    
    // Display session stats
    const uptime = ((new Date() - state.startTime) / 1000).toFixed(1);
    console.log('');
    console.log(colors.cyan + '📊 Session Statistics:' + colors.reset);
    console.log(`   Uptime: ${uptime}s`);
    console.log(`   Messages received: ${state.stats.messagesReceived}`);
    console.log(`   Total connections: ${state.stats.deviceConnections}`);
    console.log(`   Errors: ${state.stats.errors}`);
    console.log('');
    
    // Close connections
    for (const [deviceId, device] of state.devices) {
        device.ws.close();
    }
    
    wss.close(() => {
        if (bonjour) {
            bonjour.unpublishAll();
        }
        process.exit(0);
    });
});

// API endpoints (optional web dashboard)
if (CONFIG.enableCloud) {
    const http = require('http');
    const apiServer = http.createServer((req, res) => {
        res.setHeader('Content-Type', 'application/json');
        
        if (req.url === '/api/stats') {
            res.end(JSON.stringify({
                devices: state.devices.size,
                logs: state.logs.length,
                stats: state.stats
            }));
        } else if (req.url === '/api/logs') {
            res.end(JSON.stringify(state.logs.slice(-100)));
        } else {
            res.statusCode = 404;
            res.end('{"error": "Not found"}');
        }
    });
    
    apiServer.listen(8082, () => {
        console.log(colors.cyan + `📊 API Dashboard available at:${colors.reset}`);
        console.log(`   ${colors.bright}http://localhost:8082/api/stats${colors.reset}`);
        console.log('');
    });
}