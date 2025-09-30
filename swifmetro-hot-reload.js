/**
 * SwifMetro Hot Reload Server
 * Revolutionary hot reload for native iOS development
 * Created: September 30, 2025
 */

const WebSocket = require('ws');
const fs = require('fs');
const path = require('path');
const chokidar = require('chokidar');
const { exec } = require('child_process');
const os = require('os');

// Configuration
const CONFIG = {
    port: 8082,
    watchDir: process.cwd(),
    xcodeProject: null, // Auto-detected
    enableAutoRebuild: true,
    enableViewReload: true,
    enableStatePreservation: true
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

// Server state
const state = {
    devices: new Map(),
    fileWatcher: null,
    lastBuildTime: null,
    buildInProgress: false,
    changedFiles: new Set(),
    viewHierarchy: {},
    appState: {}
};

// Display banner
function displayBanner() {
    console.log('');
    console.log(colors.bright + colors.magenta + '╔══════════════════════════════════════════════╗' + colors.reset);
    console.log(colors.bright + colors.magenta + '║' + colors.reset + '       🔥 SWIFMETRO HOT RELOAD              ' + colors.magenta + '║' + colors.reset);
    console.log(colors.bright + colors.magenta + '║' + colors.reset + '    Live Updates Without Rebuilding          ' + colors.magenta + '║' + colors.reset);
    console.log(colors.bright + colors.magenta + '╚══════════════════════════════════════════════╝' + colors.reset);
    console.log('');
}

// Find Xcode project
function findXcodeProject() {
    const files = fs.readdirSync(CONFIG.watchDir);
    const xcodeproj = files.find(f => f.endsWith('.xcodeproj'));
    const xcworkspace = files.find(f => f.endsWith('.xcworkspace'));
    
    if (xcworkspace) {
        CONFIG.xcodeProject = xcworkspace;
        console.log(colors.green + `✅ Found workspace: ${xcworkspace}` + colors.reset);
    } else if (xcodeproj) {
        CONFIG.xcodeProject = xcodeproj;
        console.log(colors.green + `✅ Found project: ${xcodeproj}` + colors.reset);
    } else {
        console.log(colors.yellow + '⚠️  No Xcode project found in current directory' + colors.reset);
    }
    
    return CONFIG.xcodeProject;
}

// Setup file watcher
function setupFileWatcher(wss) {
    const watchPaths = [
        path.join(CONFIG.watchDir, '**/*.swift'),
        path.join(CONFIG.watchDir, '**/*.storyboard'),
        path.join(CONFIG.watchDir, '**/*.xib'),
        path.join(CONFIG.watchDir, '**/*.xcassets'),
        path.join(CONFIG.watchDir, '**/*.plist')
    ];
    
    console.log(colors.blue + '👁️  Watching for changes:' + colors.reset);
    console.log(`   ${watchPaths[0]}`);
    console.log('');
    
    state.fileWatcher = chokidar.watch(watchPaths, {
        ignored: /(^|[\/\\])\../, // Ignore dotfiles
        persistent: true,
        ignoreInitial: true
    });
    
    // File change handler
    state.fileWatcher.on('change', (filePath) => {
        handleFileChange(filePath, wss);
    });
    
    state.fileWatcher.on('add', (filePath) => {
        console.log(colors.green + `➕ File added: ${path.basename(filePath)}` + colors.reset);
        handleFileChange(filePath, wss);
    });
    
    state.fileWatcher.on('unlink', (filePath) => {
        console.log(colors.red + `➖ File deleted: ${path.basename(filePath)}` + colors.reset);
        handleFileChange(filePath, wss);
    });
}

// Handle file changes
function handleFileChange(filePath, wss) {
    const fileName = path.basename(filePath);
    const fileExt = path.extname(filePath);
    const timestamp = new Date().toLocaleTimeString();
    
    console.log(`[${timestamp}] 📝 Changed: ${fileName}`);
    
    state.changedFiles.add(filePath);
    
    // Determine change type
    let changeType = 'unknown';
    let requiresRebuild = false;
    
    if (fileExt === '.swift') {
        // Swift file changed
        const content = fs.readFileSync(filePath, 'utf8');
        
        if (content.includes('struct ContentView') || content.includes('class ViewController')) {
            changeType = 'view';
            requiresRebuild = false; // Can hot reload views
        } else if (content.includes('@Published') || content.includes('@State')) {
            changeType = 'state';
            requiresRebuild = false; // Can preserve state
        } else {
            changeType = 'logic';
            requiresRebuild = true; // Needs rebuild
        }
    } else if (fileExt === '.storyboard' || fileExt === '.xib') {
        changeType = 'interface';
        requiresRebuild = false; // Can reload interface
    } else if (fileName === 'Info.plist') {
        changeType = 'config';
        requiresRebuild = true; // Needs rebuild
    } else if (filePath.includes('.xcassets')) {
        changeType = 'assets';
        requiresRebuild = false; // Can reload assets
    }
    
    // Send update to devices
    const update = {
        type: 'hot-reload',
        changeType: changeType,
        file: fileName,
        requiresRebuild: requiresRebuild,
        timestamp: new Date().toISOString()
    };
    
    broadcastToDevices(wss, update);
    
    // Handle based on change type
    if (requiresRebuild && CONFIG.enableAutoRebuild) {
        triggerRebuild(wss);
    } else {
        triggerHotReload(wss, changeType, filePath);
    }
}

// Trigger hot reload
function triggerHotReload(wss, changeType, filePath) {
    console.log(colors.cyan + `🔥 Hot reloading ${changeType}...` + colors.reset);
    
    const reloadCommand = {
        type: 'reload-command',
        target: changeType,
        file: path.basename(filePath),
        preserveState: CONFIG.enableStatePreservation,
        state: state.appState,
        timestamp: new Date().toISOString()
    };
    
    // Special handling for different types
    switch (changeType) {
        case 'view':
            reloadCommand.action = 'reload-view';
            reloadCommand.viewData = extractViewChanges(filePath);
            break;
            
        case 'state':
            reloadCommand.action = 'update-state';
            reloadCommand.stateData = extractStateChanges(filePath);
            break;
            
        case 'interface':
            reloadCommand.action = 'reload-interface';
            break;
            
        case 'assets':
            reloadCommand.action = 'reload-assets';
            break;
    }
    
    broadcastToDevices(wss, reloadCommand);
    
    console.log(colors.green + `✅ Hot reload sent!` + colors.reset);
}

// Extract view changes
function extractViewChanges(filePath) {
    const content = fs.readFileSync(filePath, 'utf8');
    
    // Parse Swift view code
    const viewChanges = {
        hasStructuralChanges: false,
        hasStyleChanges: false,
        hasDataChanges: false
    };
    
    // Detect structural changes (new views, removed views)
    if (content.match(/\+\s*(VStack|HStack|ZStack|List|ScrollView)/)) {
        viewChanges.hasStructuralChanges = true;
    }
    
    // Detect style changes (colors, fonts, modifiers)
    if (content.match(/\.(foregroundColor|background|font|padding|frame)/)) {
        viewChanges.hasStyleChanges = true;
    }
    
    // Detect data changes (bindings, state)
    if (content.match(/@(State|Binding|ObservedObject|EnvironmentObject)/)) {
        viewChanges.hasDataChanges = true;
    }
    
    return viewChanges;
}

// Extract state changes
function extractStateChanges(filePath) {
    const content = fs.readFileSync(filePath, 'utf8');
    
    // Parse state variables
    const stateVars = [];
    const stateRegex = /@(State|Published)\s+(?:private\s+)?var\s+(\w+)/g;
    let match;
    
    while ((match = stateRegex.exec(content)) !== null) {
        stateVars.push({
            type: match[1],
            name: match[2]
        });
    }
    
    return { stateVars };
}

// Trigger rebuild
function triggerRebuild(wss) {
    if (state.buildInProgress) {
        console.log(colors.yellow + '⏳ Build already in progress...' + colors.reset);
        return;
    }
    
    if (!CONFIG.xcodeProject) {
        console.log(colors.red + '❌ No Xcode project found for rebuild' + colors.reset);
        return;
    }
    
    state.buildInProgress = true;
    const startTime = Date.now();
    
    console.log(colors.yellow + '🔨 Triggering rebuild...' + colors.reset);
    
    // Build command
    const buildCmd = `xcodebuild -workspace ${CONFIG.xcodeProject} -scheme ${getScheme()} -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build`;
    
    exec(buildCmd, { maxBuffer: 1024 * 1024 * 10 }, (error, stdout, stderr) => {
        const buildTime = ((Date.now() - startTime) / 1000).toFixed(1);
        state.buildInProgress = false;
        state.lastBuildTime = new Date();
        
        if (error) {
            console.log(colors.red + `❌ Build failed (${buildTime}s)` + colors.reset);
            console.log(stderr);
            
            // Send failure to devices
            broadcastToDevices(wss, {
                type: 'build-failed',
                error: stderr,
                duration: buildTime
            });
        } else {
            console.log(colors.green + `✅ Build succeeded (${buildTime}s)` + colors.reset);
            
            // Send success to devices
            broadcastToDevices(wss, {
                type: 'build-success',
                duration: buildTime,
                changedFiles: Array.from(state.changedFiles)
            });
            
            state.changedFiles.clear();
            
            // Trigger app restart
            setTimeout(() => {
                broadcastToDevices(wss, {
                    type: 'restart-app'
                });
            }, 500);
        }
    });
}

// Get scheme name
function getScheme() {
    // Try to detect scheme from project
    if (CONFIG.xcodeProject) {
        const projectName = CONFIG.xcodeProject.replace(/\.(xcworkspace|xcodeproj)$/, '');
        return projectName;
    }
    return 'MyApp';
}

// Broadcast to all connected devices
function broadcastToDevices(wss, message) {
    const jsonMessage = JSON.stringify(message);
    
    wss.clients.forEach((client) => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(jsonMessage);
        }
    });
}

// Create WebSocket server
function createHotReloadServer() {
    displayBanner();
    findXcodeProject();
    
    const wss = new WebSocket.Server({ 
        port: CONFIG.port,
        host: '0.0.0.0'
    });
    
    // Setup file watcher
    setupFileWatcher(wss);
    
    // Handle connections
    wss.on('connection', function(ws, req) {
        const deviceId = Date.now().toString();
        const clientIP = req.socket.remoteAddress;
        
        state.devices.set(deviceId, {
            ws: ws,
            ip: clientIP,
            connectedAt: new Date()
        });
        
        console.log('');
        console.log(colors.bright + colors.magenta + '🔥 HOT RELOAD CLIENT CONNECTED!' + colors.reset);
        console.log(`${colors.cyan}📱 Device:${colors.reset} ${deviceId}`);
        console.log(`${colors.cyan}🌐 IP:${colors.reset} ${clientIP}`);
        console.log('');
        
        // Send capabilities
        ws.send(JSON.stringify({
            type: 'capabilities',
            features: {
                hotReload: true,
                viewReload: CONFIG.enableViewReload,
                statePreservation: CONFIG.enableStatePreservation,
                autoRebuild: CONFIG.enableAutoRebuild,
                assetReload: true,
                interfaceReload: true
            }
        }));
        
        // Handle messages from device
        ws.on('message', function(message) {
            try {
                const data = JSON.parse(message.toString());
                
                if (data.type === 'state-snapshot') {
                    // Store app state for preservation
                    state.appState = data.state;
                    console.log(colors.blue + '💾 State snapshot saved' + colors.reset);
                } else if (data.type === 'view-hierarchy') {
                    // Store view hierarchy
                    state.viewHierarchy = data.hierarchy;
                    console.log(colors.blue + '🎨 View hierarchy updated' + colors.reset);
                } else if (data.type === 'reload-complete') {
                    console.log(colors.green + `✅ Reload complete on device ${deviceId}` + colors.reset);
                }
            } catch (error) {
                console.log(`Device ${deviceId}: ${message.toString()}`);
            }
        });
        
        // Handle disconnect
        ws.on('close', function() {
            console.log(colors.yellow + `⚠️  Device ${deviceId} disconnected` + colors.reset);
            state.devices.delete(deviceId);
        });
    });
    
    wss.on('listening', function() {
        console.log(colors.green + '✅ Hot Reload Server Configuration:' + colors.reset);
        console.log(`   Port: ${colors.bright}${CONFIG.port}${colors.reset}`);
        console.log(`   Watch: ${colors.bright}${CONFIG.watchDir}${colors.reset}`);
        console.log(`   Auto-rebuild: ${CONFIG.enableAutoRebuild ? colors.green + 'Enabled' : colors.yellow + 'Disabled'}${colors.reset}`);
        console.log(`   State preservation: ${CONFIG.enableStatePreservation ? colors.green + 'Enabled' : colors.yellow + 'Disabled'}${colors.reset}`);
        console.log('');
        
        const ips = getNetworkIPs();
        console.log(colors.blue + '📱 Configure your app to connect to:' + colors.reset);
        console.log('─'.repeat(50));
        ips.forEach(ip => {
            console.log(`   ${colors.bright}ws://${ip}:${CONFIG.port}/hot-reload${colors.reset}`);
        });
        console.log('─'.repeat(50));
        console.log('');
        
        console.log(colors.magenta + '🔥 Hot reload server is running!' + colors.reset);
        console.log('');
        console.log(colors.yellow + '⏳ Waiting for connections...' + colors.reset);
        console.log('═'.repeat(50));
    });
}

// Get network IPs
function getNetworkIPs() {
    const interfaces = os.networkInterfaces();
    const ips = [];
    
    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            if (iface.family === 'IPv4' && !iface.internal) {
                ips.push(iface.address);
            }
        }
    }
    
    return ips;
}

// Graceful shutdown
process.on('SIGINT', function() {
    console.log('');
    console.log(colors.yellow + '👋 Shutting down hot reload server...' + colors.reset);
    
    if (state.fileWatcher) {
        state.fileWatcher.close();
    }
    
    process.exit(0);
});

// Start server
createHotReloadServer();