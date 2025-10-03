#!/usr/bin/env node

/**
 * SwifMetro CLI
 * Choose between Terminal or Dashboard mode
 */

const { spawn } = require('child_process');
const path = require('path');

const args = process.argv.slice(2);
const mode = args[0] || 'terminal';

const packageDir = path.join(__dirname, '..');

console.log('');
console.log('🚀 SWIFMETRO');
console.log('='.repeat(50));

if (mode === 'dashboard' || mode === 'app') {
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
    console.log('');
    process.exit(0);
}
