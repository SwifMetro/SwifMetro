#!/usr/bin/env node

/**
 * SwifMetro Bundler
 * Hot reload server for native iOS development
 * 
 * Created by 72hConcept Team
 * Copyright © 2025 SwifMetro. All rights reserved.
 */

const net = require('net');
const fs = require('fs');
const path = require('path');
const chokidar = require('chokidar');
const { exec, spawn } = require('child_process');
const crypto = require('crypto');
const WebSocket = require('ws');

// Configuration
const config = {
  port: process.env.SWIFT_METRO_PORT || 8081,
  host: '0.0.0.0',
  watchPaths: ['./'],
  ignorePatterns: [
    '**/build/**',
    '**/DerivedData/**',
    '**/.build/**',
    '**/node_modules/**',
    '**/*.xcodeproj/**',
    '**/*.xcworkspace/**',
    '**/.git/**'
  ],
  compilerCache: new Map(),
  connections: new Set(),
  useWebSocket: false,
  verbose: process.env.SWIFT_METRO_DEBUG === 'true'
};

// Colors for terminal output
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

// Logging utilities
const log = {
  info: (msg) => console.log(`${colors.blue}ℹ${colors.reset}  ${msg}`),
  success: (msg) => console.log(`${colors.green}✓${colors.reset}  ${msg}`),
  warning: (msg) => console.log(`${colors.yellow}⚠${colors.reset}  ${msg}`),
  error: (msg) => console.error(`${colors.red}✗${colors.reset}  ${msg}`),
  debug: (msg) => config.verbose && console.log(`${colors.cyan}⦿${colors.reset}  ${msg}`)
};

// ASCII Art Banner
function showBanner() {
  console.log(`
${colors.cyan}╔═══════════════════════════════════════════════════╗
║                                                   ║
║   ${colors.bright}🔥 SwifMetro Bundler v1.0.0${colors.cyan}                   ║
║   ${colors.reset}Hot Reload for Native iOS Development${colors.cyan}          ║
║                                                   ║
╚═══════════════════════════════════════════════════╝${colors.reset}
`);
}

// Server class
class SwifMetroBundler {
  constructor() {
    this.server = null;
    this.watcher = null;
    this.connections = new Set();
    this.compileQueue = [];
    this.isCompiling = false;
    this.stats = {
      reloads: 0,
      compileTime: 0,
      connections: 0
    };
  }

  // Start the bundler
  async start() {
    showBanner();
    
    // Check for Swift compiler
    await this.checkSwiftCompiler();
    
    // Start server
    if (config.useWebSocket) {
      this.startWebSocketServer();
    } else {
      this.startTCPServer();
    }
    
    // Start file watcher
    this.startFileWatcher();
    
    // Handle process termination
    this.setupCleanup();
    
    log.success(`SwifMetro bundler running on port ${colors.bright}${config.port}${colors.reset}`);
    log.info('Waiting for iOS app connections...');
  }

  // Check if Swift compiler is available
  async checkSwiftCompiler() {
    return new Promise((resolve) => {
      exec('which swiftc', (error, stdout) => {
        if (error) {
          log.warning('Swift compiler not found in PATH');
          log.info('SwifMetro will monitor files but cannot compile');
        } else {
          log.success(`Swift compiler found at ${stdout.trim()}`);
        }
        resolve();
      });
    });
  }

  // Start TCP server
  startTCPServer() {
    this.server = net.createServer((socket) => {
      const clientId = `${socket.remoteAddress}:${socket.remotePort}`;
      log.success(`iOS device connected: ${colors.bright}${clientId}${colors.reset}`);
      
      this.connections.add(socket);
      this.stats.connections = this.connections.size;
      
      // Send welcome message
      this.sendMessage(socket, {
        type: 'connected',
        message: 'SwifMetro bundler connected',
        version: '1.0.0'
      });
      
      socket.on('data', (data) => {
        try {
          const message = JSON.parse(data);
          this.handleClientMessage(socket, message);
        } catch (e) {
          // Handle non-JSON messages
          log.debug(`Received: ${data.toString()}`);
        }
      });
      
      socket.on('error', (err) => {
        log.error(`Connection error: ${err.message}`);
      });
      
      socket.on('close', () => {
        log.info(`Device disconnected: ${clientId}`);
        this.connections.delete(socket);
        this.stats.connections = this.connections.size;
      });
    });
    
    this.server.listen(config.port, config.host);
  }

  // Start WebSocket server (alternative)
  startWebSocketServer() {
    const wss = new WebSocket.Server({ 
      port: config.port,
      host: config.host
    });
    
    wss.on('connection', (ws, req) => {
      const clientId = req.socket.remoteAddress;
      log.success(`iOS device connected via WebSocket: ${colors.bright}${clientId}${colors.reset}`);
      
      this.connections.add(ws);
      this.stats.connections = this.connections.size;
      
      ws.on('message', (data) => {
        try {
          const message = JSON.parse(data);
          this.handleClientMessage(ws, message);
        } catch (e) {
          log.debug(`Received: ${data.toString()}`);
        }
      });
      
      ws.on('close', () => {
        log.info(`Device disconnected: ${clientId}`);
        this.connections.delete(ws);
        this.stats.connections = this.connections.size;
      });
    });
    
    this.server = wss;
  }

  // Handle messages from clients
  handleClientMessage(connection, message) {
    switch (message.type) {
      case 'device_info':
        log.info(`Device: ${message.name} (${message.model} - iOS ${message.systemVersion})`);
        break;
      
      case 'console_log':
        const level = message.level || 'info';
        const prefix = level === 'error' ? colors.red : colors.cyan;
        console.log(`${prefix}[Device]${colors.reset} ${message.message}`);
        break;
      
      default:
        log.debug(`Unknown message type: ${message.type}`);
    }
  }

  // Start file watcher
  startFileWatcher() {
    const watchPaths = config.watchPaths.map(p => path.resolve(p));
    
    this.watcher = chokidar.watch(watchPaths, {
      ignored: config.ignorePatterns,
      persistent: true,
      ignoreInitial: true,
      awaitWriteFinish: {
        stabilityThreshold: 100,
        pollInterval: 100
      }
    });
    
    this.watcher.on('change', (filePath) => {
      if (filePath.endsWith('.swift')) {
        this.handleFileChange(filePath);
      }
    });
    
    log.success(`Watching for Swift file changes in ${colors.bright}${watchPaths.join(', ')}${colors.reset}`);
  }

  // Handle file changes
  async handleFileChange(filePath) {
    const relativePath = path.relative(process.cwd(), filePath);
    log.info(`File changed: ${colors.bright}${relativePath}${colors.reset}`);
    
    // Add to compile queue
    this.compileQueue.push(filePath);
    
    // Process queue
    if (!this.isCompiling) {
      this.processCompileQueue();
    }
  }

  // Process compile queue
  async processCompileQueue() {
    if (this.compileQueue.length === 0) {
      this.isCompiling = false;
      return;
    }
    
    this.isCompiling = true;
    const filePath = this.compileQueue.shift();
    
    const startTime = Date.now();
    
    // For now, just send hot reload signal
    // In production, this would compile the Swift file to a dynamic library
    await this.compileAndSend(filePath);
    
    const compileTime = Date.now() - startTime;
    this.stats.compileTime = compileTime;
    this.stats.reloads++;
    
    log.success(`Hot reload completed in ${colors.bright}${compileTime}ms${colors.reset}`);
    
    // Show stats periodically
    if (this.stats.reloads % 10 === 0) {
      this.showStats();
    }
    
    // Process next item in queue
    this.processCompileQueue();
  }

  // Compile and send update
  async compileAndSend(filePath) {
    const fileName = path.basename(filePath);
    
    // Check if Swift compiler is available
    const hasCompiler = await this.checkCompilerAvailable();
    
    if (hasCompiler) {
      // Try to compile to dynamic library
      const compiled = await this.compileSwiftFile(filePath);
      
      if (compiled) {
        // Send compiled code
        this.broadcast({
          type: 'code_update',
          file: fileName,
          data: compiled.toString('hex')
        });
        return;
      }
    }
    
    // Fallback: just send hot reload signal
    this.broadcast({
      type: 'hot_reload',
      file: fileName,
      timestamp: Date.now()
    });
  }

  // Check if compiler is available
  async checkCompilerAvailable() {
    return new Promise((resolve) => {
      exec('which swiftc', (error) => {
        resolve(!error);
      });
    });
  }

  // Compile Swift file to dynamic library
  async compileSwiftFile(filePath) {
    return new Promise((resolve) => {
      const outputPath = path.join(
        require('os').tmpdir(),
        `swift_metro_${Date.now()}.dylib`
      );
      
      const command = `swiftc -emit-library -o ${outputPath} ${filePath}`;
      
      log.debug(`Compiling: ${command}`);
      
      exec(command, (error, stdout, stderr) => {
        if (error) {
          log.error(`Compilation failed: ${stderr}`);
          resolve(null);
        } else {
          try {
            const data = fs.readFileSync(outputPath);
            fs.unlinkSync(outputPath); // Clean up
            resolve(data);
          } catch (e) {
            log.error(`Failed to read compiled output: ${e.message}`);
            resolve(null);
          }
        }
      });
    });
  }

  // Send message to a connection
  sendMessage(connection, data) {
    const json = JSON.stringify(data);
    
    if (connection instanceof WebSocket) {
      connection.send(json);
    } else {
      connection.write(json + '\n');
    }
  }

  // Broadcast to all connections
  broadcast(data) {
    const json = JSON.stringify(data);
    let sent = 0;
    
    this.connections.forEach(connection => {
      try {
        if (connection instanceof WebSocket) {
          if (connection.readyState === WebSocket.OPEN) {
            connection.send(json);
            sent++;
          }
        } else {
          connection.write(json + '\n');
          sent++;
        }
      } catch (e) {
        log.debug(`Failed to send to connection: ${e.message}`);
      }
    });
    
    if (sent > 0) {
      log.info(`Sent hot reload to ${colors.bright}${sent}${colors.reset} device(s)`);
    }
  }

  // Show statistics
  showStats() {
    console.log(`
${colors.cyan}📊 Statistics:${colors.reset}
   Reloads: ${this.stats.reloads}
   Avg compile time: ${this.stats.compileTime}ms
   Connected devices: ${this.stats.connections}
    `);
  }

  // Cleanup on exit
  setupCleanup() {
    process.on('SIGINT', () => {
      console.log('\n');
      log.info('Shutting down SwifMetro bundler...');
      
      // Close connections
      this.connections.forEach(conn => {
        try {
          if (conn instanceof WebSocket) {
            conn.close();
          } else {
            conn.end();
          }
        } catch (e) {}
      });
      
      // Stop watcher
      if (this.watcher) {
        this.watcher.close();
      }
      
      // Close server
      if (this.server) {
        this.server.close();
      }
      
      log.success('Goodbye! 👋');
      process.exit(0);
    });
  }
}

// CLI Commands
const commands = {
  serve: () => {
    const bundler = new SwifMetroBundler();
    bundler.start();
  },
  
  init: () => {
    log.info('Initializing SwifMetro in current project...');
    
    // Create config file
    const configContent = {
      server: {
        host: 'localhost',
        port: 8081
      },
      compiler: {
        cache: true
      },
      watcher: {
        paths: ['./'],
        ignore: ['build/', 'DerivedData/']
      }
    };
    
    fs.writeFileSync('swifmetro.json', JSON.stringify(configContent, null, 2));
    log.success('Created swifmetro.json configuration file');
    
    // Add to .gitignore
    if (fs.existsSync('.gitignore')) {
      const gitignore = fs.readFileSync('.gitignore', 'utf8');
      if (!gitignore.includes('swifmetro')) {
        fs.appendFileSync('.gitignore', '\n# SwifMetro\nswifmetro.cache/\n');
        log.success('Updated .gitignore');
      }
    }
    
    log.info('SwifMetro initialized! Run "swift-metro serve" to start bundler');
  },
  
  help: () => {
    console.log(`
${colors.bright}SwifMetro - Hot Reload for Native iOS${colors.reset}

${colors.cyan}Usage:${colors.reset}
  swift-metro <command> [options]

${colors.cyan}Commands:${colors.reset}
  ${colors.bright}serve${colors.reset}     Start the hot reload bundler
  ${colors.bright}init${colors.reset}      Initialize SwifMetro in current project
  ${colors.bright}help${colors.reset}      Show this help message

${colors.cyan}Environment Variables:${colors.reset}
  SWIFT_METRO_PORT     Port to run bundler (default: 8081)
  SWIFT_METRO_DEBUG    Enable debug logging (true/false)

${colors.cyan}Examples:${colors.reset}
  swift-metro serve
  SWIFT_METRO_PORT=3000 swift-metro serve
  SWIFT_METRO_DEBUG=true swift-metro serve
    `);
  }
};

// Main CLI entry point
function main() {
  const command = process.argv[2] || 'help';
  
  if (commands[command]) {
    commands[command]();
  } else {
    log.error(`Unknown command: ${command}`);
    commands.help();
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

module.exports = SwifMetroBundler;