const { app, BrowserWindow, dialog } = require('electron');
const { spawn, execSync } = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');
const crypto = require('crypto');

let mainWindow;
let serverProcess;

const gotTheLock = app.requestSingleInstanceLock();

if (!gotTheLock) {
    app.quit();
} else {
    app.on('second-instance', () => {
        if (mainWindow) {
            if (mainWindow.isMinimized()) mainWindow.restore();
            mainWindow.focus();
        }
    });
}

function getHardwareId() {
    try {
        // Get Mac's hardware UUID (permanent, survives reinstalls)
        const uuid = execSync('system_profiler SPHardwareDataType | grep "Hardware UUID"').toString();
        const hardwareId = uuid.split(':')[1].trim();
        return crypto.createHash('sha256').update(hardwareId).digest('hex').substring(0, 16);
    } catch (err) {
        console.error('Failed to get hardware ID:', err);
        // Fallback to machine serial number
        try {
            const serial = execSync('system_profiler SPHardwareDataType | grep "Serial Number"').toString();
            const serialNumber = serial.split(':')[1].trim();
            return crypto.createHash('sha256').update(serialNumber).digest('hex').substring(0, 16);
        } catch (err2) {
            // Last resort: use MAC address
            const interfaces = os.networkInterfaces();
            const mac = Object.values(interfaces).flat().find(i => !i.internal && i.mac !== '00:00:00:00:00:00')?.mac || 'unknown';
            return crypto.createHash('sha256').update(mac).digest('hex').substring(0, 16);
        }
    }
}

function checkLicense() {
    const licensePath = path.join(os.homedir(), '.swifmetro', 'license');
    const hardwareId = getHardwareId();
    const trialPath = path.join(os.homedir(), '.swifmetro', `trial_${hardwareId}`);
    
    try {
        if (fs.existsSync(licensePath)) {
            const licenseKey = fs.readFileSync(licensePath, 'utf8').trim();
            
            // Check if it's the demo/trial key
            if (licenseKey === 'SWIF-DEMO-DEMO-DEMO') {
                // Check trial expiration (tied to hardware ID)
                if (fs.existsSync(trialPath)) {
                    const trialData = JSON.parse(fs.readFileSync(trialPath, 'utf8'));
                    const now = Date.now();
                    const daysElapsed = (now - trialData.start) / (1000 * 60 * 60 * 24);
                    
                    if (daysElapsed > 7) {
                        console.log('❌ Trial expired (7 days)');
                        fs.unlinkSync(licensePath); // Remove expired trial key
                        return false;
                    }
                    
                    console.log(`✅ Trial active: ${Math.floor(7 - daysElapsed)} days remaining`);
                    console.log(`🔒 Hardware ID: ${hardwareId}`);
                    return true;
                } else {
                    // First time using trial - record start date with hardware ID
                    const dir = path.dirname(trialPath);
                    if (!fs.existsSync(dir)) {
                        fs.mkdirSync(dir, { recursive: true });
                    }
                    const trialData = {
                        start: Date.now(),
                        hardwareId: hardwareId
                    };
                    fs.writeFileSync(trialPath, JSON.stringify(trialData));
                    console.log('✅ Trial started: 7 days remaining');
                    console.log(`🔒 Hardware ID: ${hardwareId}`);
                    return true;
                }
            }
            
            // Validate real license format: SWIF-XXXX-XXXX-XXXX
            const pattern = /^SWIF-.{4}-.{4}-.{4}$/;
            if (pattern.test(licenseKey)) {
                console.log('✅ Valid license found:', licenseKey);
                return true;
            }
        }
    } catch (err) {
        console.error('❌ License check error:', err);
    }
    
    return false;
}

function showLicensePrompt() {
    // Create a simple window for license input
    const licenseWindow = new BrowserWindow({
        width: 600,
        height: 450,
        title: 'SwifMetro - License Key Required',
        resizable: false,
        minimizable: false,
        maximizable: false,
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false
        }
    });
    
    const html = `
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                display: flex;
                align-items: center;
                justify-content: center;
                height: 100vh;
                padding: 20px;
            }
            .card {
                background: white;
                border-radius: 20px;
                padding: 40px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                max-width: 500px;
                width: 100%;
            }
            h1 {
                font-size: 28px;
                margin-bottom: 10px;
                background: linear-gradient(135deg, #FF6B6B, #4ECDC4);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
            }
            p {
                color: #666;
                margin-bottom: 20px;
                line-height: 1.6;
            }
            .input-group {
                margin-bottom: 20px;
            }
            label {
                display: block;
                font-weight: 600;
                margin-bottom: 8px;
                color: #333;
            }
            input {
                width: 100%;
                padding: 12px;
                border: 2px solid #ddd;
                border-radius: 8px;
                font-size: 16px;
                font-family: 'Courier New', monospace;
                transition: border 0.3s;
            }
            input:focus {
                outline: none;
                border-color: #667eea;
            }
            .buttons {
                display: flex;
                gap: 10px;
                margin-top: 25px;
            }
            button {
                flex: 1;
                padding: 12px;
                border: none;
                border-radius: 8px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: transform 0.2s, box-shadow 0.2s;
            }
            button:hover {
                transform: translateY(-2px);
            }
            .btn-primary {
                background: linear-gradient(135deg, #667eea, #764ba2);
                color: white;
            }
            .btn-secondary {
                background: #f0f0f0;
                color: #666;
            }
            .trial-note {
                background: #f0f9ff;
                border: 1px solid #b3e0ff;
                border-radius: 8px;
                padding: 12px;
                margin-top: 20px;
                font-size: 14px;
                color: #0066cc;
            }
            .error {
                color: #dc2626;
                font-size: 14px;
                margin-top: 8px;
                display: none;
            }
        </style>
    </head>
    <body>
        <div class="card">
            <h1>🔑 SwifMetro License</h1>
            <p>Enter your license key to start using SwifMetro.</p>
            
            <div class="input-group">
                <label for="licenseKey">License Key</label>
                <input 
                    type="text" 
                    id="licenseKey" 
                    placeholder="SWIF-XXXX-XXXX-XXXX"
                >
                <div class="error" id="error">Invalid license key format</div>
            </div>
            
            <div class="trial-note">
                💡 <strong>Want to try it first?</strong><br>
                Use the free 7-day trial key: <code>SWIF-DEMO-DEMO-DEMO</code>
            </div>
            
            <div class="buttons">
                <button class="btn-secondary" onclick="quit()">Quit</button>
                <button class="btn-primary" onclick="saveLicense()">Activate License</button>
            </div>
        </div>
        
        <script>
            const { ipcRenderer } = require('electron');
            
            // Submit on Enter
            document.getElementById('licenseKey').addEventListener('keypress', (e) => {
                if (e.key === 'Enter') saveLicense();
            });
            
            function saveLicense() {
                const key = document.getElementById('licenseKey').value.trim().toUpperCase();
                const pattern = /^SWIF-.{4}-.{4}-.{4}$/;
                
                if (!pattern.test(key)) {
                    document.getElementById('error').style.display = 'block';
                    document.getElementById('error').textContent = 'Invalid format. Should be: SWIF-XXXX-XXXX-XXXX';
                    return;
                }
                
                ipcRenderer.send('save-license', key);
            }
            
            function quit() {
                ipcRenderer.send('quit-app');
            }
            
            // Focus input on load
            setTimeout(() => {
                document.getElementById('licenseKey').focus();
            }, 100);
        </script>
    </body>
    </html>
    `;
    
    licenseWindow.loadURL('data:text/html;charset=utf-8,' + encodeURIComponent(html));
    
    licenseWindow.webContents.on('did-finish-load', () => {
        licenseWindow.show();
        licenseWindow.focus();
    });
    
    return new Promise((resolve) => {
        const { ipcMain } = require('electron');
        
        ipcMain.once('save-license', (event, key) => {
            const licensePath = path.join(os.homedir(), '.swifmetro', 'license');
            const dir = path.dirname(licensePath);
            
            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir, { recursive: true });
            }
            
            fs.writeFileSync(licensePath, key);
            licenseWindow.close();
            resolve(true);
        });
        
        ipcMain.once('quit-app', () => {
            licenseWindow.close();
            app.quit();
            resolve(false);
        });
    });
}

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1400,
        height: 900,
        title: 'SwifMetro - iOS Logging',
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            enableRemoteModule: false,
            sandbox: true,
            webSecurity: true,
            allowRunningInsecureContent: false,
            experimentalFeatures: false
        },
        titleBarStyle: 'hiddenInset',
        backgroundColor: '#0a0a0a'
    });

    // Load the dashboard
    mainWindow.loadFile('swifmetro-dashboard.html');

    // Prevent navigation to external URLs
    mainWindow.webContents.on('will-navigate', (event, url) => {
        if (!url.startsWith('file://')) {
            event.preventDefault();
        }
    });

    // Prevent opening new windows
    mainWindow.webContents.setWindowOpenHandler(() => {
        return { action: 'deny' };
    });

    mainWindow.on('closed', () => {
        mainWindow = null;
    });
}

function startServer() {
    console.log('🚀 Starting SwifMetro server...');
    
    const serverPath = path.join(__dirname, 'swifmetro-server.js');
    
    serverProcess = spawn('node', [serverPath], {
        stdio: 'inherit'
    });

    serverProcess.on('error', (err) => {
        console.error('❌ Server error:', err);
    });
}

app.whenReady().then(async () => {
    // Check license first
    if (!checkLicense()) {
        const activated = await showLicensePrompt();
        if (!activated) {
            return; // User quit
        }
    }
    
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
