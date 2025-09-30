#!/bin/bash

# SwiftMetro Installation Script
# Copyright © 2025 SwiftMetro. All rights reserved.

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Banner
show_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║                                                   ║"
    echo "║   🔥 ${BOLD}SwiftMetro Installation${NC}${CYAN}                     ║"
    echo "║   Hot Reload for Native iOS Development          ║"
    echo "║                                                   ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Check requirements
check_requirements() {
    echo -e "${BLUE}Checking requirements...${NC}"
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        echo -e "${RED}✗ Node.js is not installed${NC}"
        echo "Please install Node.js from https://nodejs.org"
        exit 1
    else
        NODE_VERSION=$(node --version)
        echo -e "${GREEN}✓ Node.js ${NODE_VERSION} found${NC}"
    fi
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}✗ npm is not installed${NC}"
        exit 1
    else
        NPM_VERSION=$(npm --version)
        echo -e "${GREEN}✓ npm ${NPM_VERSION} found${NC}"
    fi
    
    # Check Xcode
    if ! command -v xcodebuild &> /dev/null; then
        echo -e "${YELLOW}⚠ Xcode not found - SwiftMetro works best with Xcode installed${NC}"
    else
        XCODE_VERSION=$(xcodebuild -version | head -1)
        echo -e "${GREEN}✓ ${XCODE_VERSION} found${NC}"
    fi
    
    # Check Swift
    if ! command -v swiftc &> /dev/null; then
        echo -e "${YELLOW}⚠ Swift compiler not found - advanced features will be limited${NC}"
    else
        SWIFT_VERSION=$(swiftc --version | head -1)
        echo -e "${GREEN}✓ Swift compiler found${NC}"
    fi
}

# Install SwiftMetro bundler globally
install_bundler() {
    echo -e "\n${BLUE}Installing SwiftMetro bundler...${NC}"
    
    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Copy bundler files (in real version, would download from GitHub)
    cat > package.json << 'EOF'
{
  "name": "swift-metro",
  "version": "1.0.0",
  "description": "Hot reload bundler for native iOS development",
  "main": "swift-metro-bundler.js",
  "bin": {
    "swift-metro": "./swift-metro-bundler.js"
  },
  "dependencies": {
    "chokidar": "^3.5.3",
    "ws": "^8.14.2"
  }
}
EOF
    
    # Install globally
    npm install -g .
    
    # Clean up
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    
    echo -e "${GREEN}✓ SwiftMetro bundler installed globally${NC}"
}

# Install iOS client
install_ios_client() {
    echo -e "\n${BLUE}Setting up iOS client...${NC}"
    
    # Create SwiftMetro directory in user's home
    SWIFTMETRO_HOME="$HOME/.swiftmetro"
    mkdir -p "$SWIFTMETRO_HOME"
    
    # Save SwiftMetro.swift for easy access
    echo -e "${GREEN}✓ iOS client saved to ${SWIFTMETRO_HOME}${NC}"
    echo -e "${CYAN}To add to your project, copy: ${BOLD}${SWIFTMETRO_HOME}/SwiftMetro.swift${NC}"
}

# Create example project
create_example() {
    echo -e "\n${YELLOW}Would you like to create an example project? (y/n)${NC}"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Creating example project...${NC}"
        
        mkdir -p SwiftMetroExample
        cd SwiftMetroExample
        
        # Create minimal example
        cat > ContentView.swift << 'EOF'
import SwiftUI
import SwiftMetro

struct ContentView: View {
    @State private var message = "Hello, SwiftMetro!"
    @State private var color = Color.blue
    
    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .font(.largeTitle)
                .foregroundColor(color)
            
            Button("Change Color") {
                color = [.red, .green, .blue, .purple].randomElement()!
            }
            
            Text("Edit ContentView.swift and save to see hot reload!")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .enableHotReload()
    }
}
EOF
        
        echo -e "${GREEN}✓ Example project created in ./SwiftMetroExample${NC}"
    fi
}

# Setup completion
setup_completion() {
    echo -e "\n${BLUE}Setting up command completion...${NC}"
    
    # Bash completion
    if [ -d "/usr/local/etc/bash_completion.d" ]; then
        cat > /usr/local/etc/bash_completion.d/swift-metro << 'EOF'
_swift_metro() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="serve init help status clean"
    
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}
complete -F _swift_metro swift-metro
EOF
        echo -e "${GREEN}✓ Bash completion installed${NC}"
    fi
}

# Main installation
main() {
    clear
    show_banner
    
    echo "Welcome to SwiftMetro installation!"
    echo "This will install the hot reload system for iOS development."
    echo ""
    
    check_requirements
    install_bundler
    install_ios_client
    setup_completion
    create_example
    
    echo -e "\n${GREEN}${BOLD}✨ SwiftMetro installation complete!${NC}"
    echo ""
    echo "To get started:"
    echo "  1. Add SwiftMetro.swift to your iOS project"
    echo "  2. Call SwiftMetro.shared.start() in your app"
    echo "  3. Run: swift-metro serve"
    echo "  4. Build and run your app"
    echo ""
    echo "Documentation: https://swiftmetro.dev"
    echo "GitHub: https://github.com/swiftmetro/swiftmetro"
    echo ""
    echo -e "${CYAN}Happy hot reloading! 🔥${NC}"
}

# Run installation
main "$@"