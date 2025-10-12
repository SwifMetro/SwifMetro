#!/usr/bin/env node

/**
 * SwifMetro CLI
 * Choose between Terminal or Dashboard mode
 */

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');
const express = require('express');

const args = process.argv.slice(2);
const mode = args[0] || 'terminal';

const packageDir = path.join(__dirname, '..');
const configDir = path.join(os.homedir(), '.swifmetro');
const licensePath = path.join(configDir, 'license');

// Ensure config directory exists
if (!fs.existsSync(configDir)) {
    fs.mkdirSync(configDir, { recursive: true });
}

console.log('');
console.log('🚀 SWIFMETRO');
console.log('='.repeat(50));

if (mode === 'login') {
    // Browser-based login
    console.log('🔐 Starting login flow...');
    console.log('');
    
    // Start local callback server
    const app = express();
    const callbackPort = 9876;
    
    app.get('/auth', (req, res) => {
        const { token, email, tier } = req.query;
        
        if (!token) {
            res.send('❌ No license key received');
            return;
        }
        
        // Save license
        fs.writeFileSync(licensePath, token);
        
        // Save metadata
        const meta = { email, tier, activatedAt: new Date().toISOString() };
        fs.writeFileSync(path.join(configDir, 'meta.json'), JSON.stringify(meta, null, 2));
        
        res.send(`
            <html>
            <head>
                <style>
                    body { 
                        font-family: -apple-system, sans-serif; 
                        display: flex; 
                        align-items: center; 
                        justify-content: center; 
                        min-height: 100vh; 
                        background: linear-gradient(135deg, #667eea, #764ba2);
                        color: white;
                    }
                    .success { 
                        text-align: center; 
                        background: rgba(255,255,255,0.1); 
                        padding: 40px; 
                        border-radius: 20px;
                        backdrop-filter: blur(10px);
                    }
                    .success h1 { font-size: 48px; margin-bottom: 20px; }
                    .success p { font-size: 18px; opacity: 0.9; }
                    .key { 
                        background: rgba(255,255,255,0.2); 
                        padding: 10px 20px; 
                        border-radius: 8px; 
                        margin: 20px 0;
                        font-family: monospace;
                        font-size: 16px;
                    }
                </style>
            </head>
            <body>
                <div class="success">
                    <h1>✅ Success!</h1>
                    <p>SwifMetro ${tier.toUpperCase()} activated</p>
                    <div class="key">${token}</div>
                    <p>You can close this window</p>
                </div>
            </body>
            </html>
        `);
        
        console.log('');
        console.log('✅ License activated!');
        console.log(`📧 Email: ${email}`);
        console.log(`💎 Tier: ${tier.toUpperCase()}`);
        console.log(`🔑 License: ${token}`);
        console.log(`💾 Saved to: ${licensePath}`);
        console.log('');
        console.log('🚀 Run "swifmetro dashboard" to start using Pro features!');
        console.log('');
        
        setTimeout(() => process.exit(0), 2000);
    });
    
    app.listen(callbackPort, () => {
        console.log(`🔗 Callback server running on http://localhost:${callbackPort}`);
        
        // Open browser
        const loginUrl = `http://localhost:8083/login?callback_port=${callbackPort}`;
        console.log(`🌐 Opening browser to: ${loginUrl}`);
        console.log('');
        console.log('💡 Note: Using localhost for testing');
        console.log('   When live, this will be: https://swifmetro.dev/login');
        console.log('');
        
        // Open browser (cross-platform)
        const open = process.platform === 'darwin' ? 'open' : 
                     process.platform === 'win32' ? 'start' : 'xdg-open';
        spawn(open, [loginUrl], { stdio: 'ignore' });
    });
    
} else if (mode === 'logout') {
    // Remove license
    if (fs.existsSync(licensePath)) {
        fs.unlinkSync(licensePath);
        console.log('✅ Logged out successfully');
        console.log('🆓 Switched to Free tier');
    } else {
        console.log('ℹ️  Not logged in');
    }
    console.log('');
    process.exit(0);
    
} else if (mode === 'status') {
    // Show license status
    if (fs.existsSync(licensePath)) {
        const license = fs.readFileSync(licensePath, 'utf8').trim();
        const metaPath = path.join(configDir, 'meta.json');
        
        console.log('📊 License Status:');
        console.log('');
        
        if (fs.existsSync(metaPath)) {
            const meta = JSON.parse(fs.readFileSync(metaPath, 'utf8'));
            console.log(`📧 Email: ${meta.email}`);
            console.log(`💎 Tier: ${meta.tier.toUpperCase()}`);
            console.log(`🔑 License: ${license}`);
            console.log(`📅 Activated: ${new Date(meta.activatedAt).toLocaleDateString()}`);
        } else {
            console.log(`🔑 License: ${license}`);
        }
    } else {
        console.log('🆓 Free Tier (1 device limit)');
        console.log('');
        console.log('💡 Run "swifmetro login" to upgrade to Pro');
    }
    console.log('');
    process.exit(0);
    
} else if (mode === 'dashboard' || mode === 'app') {
    // Launch Electron app
    console.log('📊 Starting SwifMetro Dashboard App...');
    console.log('');
    
    const app = spawn('npm', ['start'], {
        cwd: packageDir,
        stdio: 'inherit'
    });
    
    app.on('error', (err) => {
        console.error('❌ Error starting dashboard:', err.message);
        process.exit(1);
    });
} else if (mode === 'terminal' || mode === 'server') {
    // Terminal-only mode
    console.log('📱 Starting SwifMetro Terminal Logging...');
    console.log('💡 Tip: Run "swifmetro dashboard" to use GUI mode');
    console.log('');
    
    const server = spawn('node', [path.join(packageDir, 'swifmetro-server.js')], {
        stdio: 'inherit',
        cwd: packageDir
    });
    
    server.on('error', (err) => {
        console.error('❌ Error starting server:', err.message);
        process.exit(1);
    });
} else {
    console.log('Usage:');
    console.log('  swifmetro           - Start terminal logging (default)');
    console.log('  swifmetro terminal  - Start terminal logging');
    console.log('  swifmetro dashboard - Start dashboard app');
    console.log('  swifmetro login     - Sign in to activate Pro');
    console.log('  swifmetro logout    - Sign out (switch to Free)');
    console.log('  swifmetro status    - Show license status');
    console.log('');
    process.exit(0);
}
