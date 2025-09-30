/**
 * SwifMetro Secure Server (WSS)
 * WebSocket server with TLS/SSL encryption support
 * Created: September 30, 2025
 */

const WebSocket = require('ws');
const https = require('https');
const fs = require('fs');
const path = require('path');
const os = require('os');

// Try to load Bonjour
let bonjour;
try {
    bonjour = require('bonjour')();
} catch (e) {
    console.log('⚠️  Bonjour not installed. Run: npm install bonjour');
}

// Configuration
const CONFIG = {
    port: 8443, // Standard WSS port
    host: '0.0.0.0',
    serviceName: 'SwifMetro-Secure',
    serviceType: 'swifmetro-secure',
    enableSelfSigned: true, // Use self-signed certs for development
    certPath: process.env.SWIFMETRO_CERT || path.join(__dirname, 'certs', 'server.crt'),
    keyPath: process.env.SWIFMETRO_KEY || path.join(__dirname, 'certs', 'server.key'),
    requireAuth: false, // Optional token authentication
    authToken: process.env.SWIFMETRO_TOKEN || null
};

// ANSI colors
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

// Generate self-signed certificate if needed
function generateSelfSignedCert() {
    const { execSync } = require('child_process');
    const certsDir = path.join(__dirname, 'certs');
    
    if (!fs.existsSync(certsDir)) {
        fs.mkdirSync(certsDir);
    }
    
    if (!fs.existsSync(CONFIG.certPath) || !fs.existsSync(CONFIG.keyPath)) {
        console.log(colors.yellow + '🔐 Generating self-signed certificate...' + colors.reset);
        
        try {
            // Generate private key and certificate in one command
            execSync(`openssl req -x509 -newkey rsa:4096 -keyout ${CONFIG.keyPath} -out ${CONFIG.certPath} -days 365 -nodes -subj "/CN=SwifMetro-Local"`, {
                stdio: 'ignore'
            });
            
            console.log(colors.green + '✅ Self-signed certificate generated!' + colors.reset);
            console.log(`   Certificate: ${CONFIG.certPath}`);
            console.log(`   Private Key: ${CONFIG.keyPath}`);
            console.log('');
        } catch (error) {
            console.log(colors.red + '❌ Failed to generate certificate. Please install OpenSSL.' + colors.reset);
            console.log('   On macOS: brew install openssl');
            process.exit(1);
        }
    }
}

// Display banner
function displayBanner() {
    console.log('');
    console.log(colors.bright + colors.cyan + '╔══════════════════════════════════════════════╗' + colors.reset);
    console.log(colors.bright + colors.cyan + '║' + colors.reset + '       🔒 SWIFMETRO SECURE SERVER           ' + colors.cyan + '║' + colors.reset);
    console.log(colors.bright + colors.cyan + '║' + colors.reset + '    Encrypted Terminal Logging for iOS       ' + colors.cyan + '║' + colors.reset);
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
                    ip: iface.address
                });
            }
        }
    }
    
    return ips;
}

// Display server info
function displayServerInfo() {
    console.log(colors.green + '✅ Secure Server Configuration:' + colors.reset);
    console.log(`   Port: ${colors.bright}${CONFIG.port}${colors.reset} (WSS)`);
    console.log(`   Encryption: ${colors.green}TLS/SSL Enabled${colors.reset}`);
    console.log(`   Certificate: ${CONFIG.enableSelfSigned ? colors.yellow + 'Self-Signed' : colors.green + 'Custom'}${colors.reset}`);
    console.log(`   Auth: ${CONFIG.requireAuth ? colors.green + 'Required' : colors.yellow + 'Open'}${colors.reset}`);
    console.log('');
    
    console.log(colors.blue + '📱 Connect your iPhone using WSS:' + colors.reset);
    console.log('─'.repeat(50));
    
    const ips = getNetworkInfo();
    ips.forEach(({name, ip}) => {
        console.log(`   ${colors.bright}wss://${ip}:${CONFIG.port}${colors.reset} (${name})`);
    });
    
    console.log('─'.repeat(50));
    console.log('');
    
    if (CONFIG.enableSelfSigned) {
        console.log(colors.yellow + '⚠️  Using self-signed certificate.' + colors.reset);
        console.log('   Your app needs to allow arbitrary loads in Info.plist');
        console.log('');
    }
}

// Main server setup
function startSecureServer() {
    displayBanner();
    
    // Generate cert if needed
    if (CONFIG.enableSelfSigned) {
        generateSelfSignedCert();
    }
    
    // Load certificate and key
    let serverOptions;
    try {
        serverOptions = {
            cert: fs.readFileSync(CONFIG.certPath),
            key: fs.readFileSync(CONFIG.keyPath)
        };
    } catch (error) {
        console.log(colors.red + '❌ Failed to load certificates.' + colors.reset);
        console.log(`   Make sure files exist at:`);
        console.log(`   - ${CONFIG.certPath}`);
        console.log(`   - ${CONFIG.keyPath}`);
        process.exit(1);
    }
    
    // Create HTTPS server
    const server = https.createServer(serverOptions);
    
    // Create WebSocket server
    const wss = new WebSocket.Server({ 
        server,
        verifyClient: (info, cb) => {
            // Optional authentication
            if (CONFIG.requireAuth && CONFIG.authToken) {
                const token = info.req.headers['authorization'];
                if (token !== `Bearer ${CONFIG.authToken}`) {
                    cb(false, 401, 'Unauthorized');
                    return;
                }
            }
            cb(true);
        }
    });
    
    // Connection tracking
    const devices = new Map();
    let messageCount = 0;
    
    // Handle connections
    wss.on('connection', function(ws, req) {
        const clientIP = req.socket.remoteAddress;
        const deviceId = Date.now().toString();
        const timestamp = new Date().toLocaleTimeString();
        
        devices.set(deviceId, {
            ws: ws,
            ip: clientIP,
            connectedAt: new Date()
        });
        
        // Connection notification
        console.log('');
        console.log(colors.bright + colors.green + '🔐 SECURE CONNECTION ESTABLISHED!' + colors.reset);
        console.log(`${colors.cyan}📱 Device:${colors.reset} ${deviceId}`);
        console.log(`${colors.cyan}🌐 IP:${colors.reset} ${clientIP}`);
        console.log(`${colors.cyan}🔒 Encryption:${colors.reset} Active`);
        console.log(colors.green + '─'.repeat(50) + colors.reset);
        console.log('');
        
        // Send welcome
        ws.send(JSON.stringify({
            type: 'welcome',
            message: '🔒 Connected to SwifMetro Secure!',
            deviceId: deviceId,
            encryption: 'TLS/SSL',
            serverTime: new Date().toISOString()
        }));
        
        // Handle messages
        ws.on('message', function(message) {
            messageCount++;
            const timestamp = new Date().toLocaleTimeString();
            
            try {
                const data = JSON.parse(message.toString());
                
                if (data.device) {
                    // Device info
                    console.log(`${colors.cyan}📱 Device Info:${colors.reset}`);
                    console.log(`   Name: ${data.device}`);
                    console.log(`   Model: ${data.model}`);
                    console.log(`   OS: ${data.os}`);
                    console.log('');
                } else {
                    // Log message
                    handleLogMessage(data, timestamp);
                }
            } catch {
                // Plain text message
                console.log(`[${timestamp}] 🔐 ${message.toString()}`);
            }
        });
        
        // Handle disconnect
        ws.on('close', function() {
            const device = devices.get(deviceId);
            const sessionTime = ((new Date() - device.connectedAt) / 1000).toFixed(1);
            
            console.log('');
            console.log(colors.yellow + `⚠️  Device ${deviceId} disconnected` + colors.reset);
            console.log(`   Session: ${sessionTime}s`);
            console.log('');
            
            devices.delete(deviceId);
        });
        
        // Handle errors
        ws.on('error', function(error) {
            console.log(colors.red + `❌ Connection error: ${error.message}` + colors.reset);
        });
    });
    
    // Start server
    server.listen(CONFIG.port, CONFIG.host, () => {
        displayServerInfo();
        
        // Broadcast via Bonjour
        if (bonjour) {
            bonjour.publish({ 
                name: CONFIG.serviceName,
                type: CONFIG.serviceType,
                port: CONFIG.port,
                txt: {
                    encryption: 'required',
                    protocol: 'wss'
                }
            });
            
            console.log(colors.green + '✅ Broadcasting secure service via Bonjour' + colors.reset);
            console.log('');
        }
        
        console.log(colors.green + '🔒 Secure server is running!' + colors.reset);
        console.log(`📝 Press ${colors.bright}Ctrl+C${colors.reset} to stop`);
        console.log('');
        console.log(colors.yellow + '⏳ Waiting for secure connections...' + colors.reset);
        console.log('═'.repeat(50));
    });
}

// Handle log messages
function handleLogMessage(data, timestamp) {
    let color = colors.reset;
    let icon = '📱';
    
    const message = data.message || JSON.stringify(data);
    
    // Color coding
    if (message.includes('Error') || message.includes('❌')) {
        color = colors.red;
        icon = '❌';
    } else if (message.includes('Success') || message.includes('✅')) {
        color = colors.green;
        icon = '✅';
    } else if (message.includes('Warning') || message.includes('⚠️')) {
        color = colors.yellow;
        icon = '⚠️';
    }
    
    console.log(`[${timestamp}] ${icon} ${color}${message}${colors.reset}`);
}

// Graceful shutdown
process.on('SIGINT', function() {
    console.log('');
    console.log(colors.yellow + '👋 Shutting down secure server...' + colors.reset);
    console.log(`   Total messages: ${messageCount}`);
    
    if (bonjour) {
        bonjour.unpublishAll();
    }
    
    process.exit(0);
});

// Error handling
process.on('uncaughtException', function(error) {
    console.log(colors.red + `❌ Fatal error: ${error.message}` + colors.reset);
    process.exit(1);
});

// Start the server
startSecureServer();