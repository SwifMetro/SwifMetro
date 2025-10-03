const { app, BrowserWindow } = require('electron');
const { spawn } = require('child_process');
const path = require('path');

let mainWindow;
let serverProcess;

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1400,
        height: 900,
        title: 'SwifMetro - iOS Logging',
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true
        },
        titleBarStyle: 'hiddenInset',
        backgroundColor: '#0a0a0a'
    });

    // Load the dashboard
    mainWindow.loadFile('swifmetro-dashboard.html');

    mainWindow.on('closed', () => {
        mainWindow = null;
    });
}

function startServer() {
    console.log('🚀 Starting SwifMetro server...');
    
    serverProcess = spawn('node', ['swifmetro-server.js'], {
        cwd: __dirname,
        stdio: 'inherit'
    });

    serverProcess.on('error', (err) => {
        console.error('❌ Server error:', err);
    });
}

app.whenReady().then(() => {
    startServer();
    
    // Give server a moment to start
    setTimeout(() => {
        createWindow();
    }, 1000);

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createWindow();
        }
    });
});

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('will-quit', () => {
    if (serverProcess) {
        console.log('👋 Stopping SwifMetro server...');
        serverProcess.kill();
    }
});
