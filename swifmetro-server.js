/**
 * SwifMetro Server
 * Created: September 30, 2025
 * The first Metro-style terminal logging for native iOS
 */

const WebSocket = require('ws');
const os = require('os');

// Configuration
const PORT = 8081;
const HOST = '0.0.0.0'; // Listen on all interfaces

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

// Track connected clients (iPhone + Dashboard)
let clients = new Set();

wss.on('connection', function connection(ws, req) {
    const clientIP = req.socket.remoteAddress;
    const timestamp = new Date().toLocaleTimeString();
    
    // Add client to set
    clients.add(ws);
    
    console.log('🔥'.repeat(10));
    console.log(`🔥 CLIENT CONNECTED at ${timestamp}!`);
    console.log(`📱 From IP: ${clientIP}`);
    console.log(`📊 Total clients: ${clients.size}`);
    console.log('🔥'.repeat(10));
    console.log('');
    
    // Send welcome message
    ws.send('🎉 Welcome to SwifMetro! You are now connected.');
    
    // Handle incoming messages from iPhone
    ws.on('message', function incoming(message) {
        const timestamp = new Date().toLocaleTimeString();
        const msgString = message.toString();
        
        // Broadcast to ALL OTHER clients (not back to sender)
        clients.forEach(client => {
            if (client !== ws && client.readyState === WebSocket.OPEN) {
                client.send(`[${timestamp}] 📱 ${msgString}`);
            }
        });
        
        // Color-code different message types in terminal
        if (msgString.includes('❌') || msgString.includes('Error') || msgString.includes('error')) {
            console.log(`[${timestamp}] 📱 \x1b[31m${msgString}\x1b[0m`); // Red
        } else if (msgString.includes('✅') || msgString.includes('Success')) {
            console.log(`[${timestamp}] 📱 \x1b[32m${msgString}\x1b[0m`); // Green
        } else if (msgString.includes('⚠️') || msgString.includes('Warning')) {
            console.log(`[${timestamp}] 📱 \x1b[33m${msgString}\x1b[0m`); // Yellow
        } else if (msgString.includes('ℹ️') || msgString.includes('Info')) {
            console.log(`[${timestamp}] 📱 \x1b[36m${msgString}\x1b[0m`); // Cyan
        } else {
            console.log(`[${timestamp}] 📱 ${msgString}`);
        }
    });
    
    // Handle disconnection
    ws.on('close', function() {
        const timestamp = new Date().toLocaleTimeString();
        clients.delete(ws);
        console.log('');
        console.log(`❌ Client disconnected at ${timestamp}`);
        console.log(`📊 Total clients: ${clients.size}`);
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
            ws.send('💓 Heartbeat');
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
    wss.close(() => {
        process.exit(0);
    });
});

console.log('✅ Server is running!');
console.log('📝 Press Ctrl+C to stop');
console.log('='.repeat(50));