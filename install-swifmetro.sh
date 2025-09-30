#!/bin/bash

# SwifMetro Installation Script
# The fastest way to get started

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║         🚀 SWIFMETRO INSTALLER              ║"
echo "║     Terminal Logging for Native iOS         ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check Node.js
echo "📦 Checking requirements..."
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js not installed${NC}"
    echo ""
    echo "Install Node.js first:"
    echo "  brew install node"
    echo "  or download from https://nodejs.org"
    exit 1
fi

echo -e "${GREEN}✅ Node.js $(node -v) found${NC}"

# Install dependencies
echo ""
echo "📦 Installing SwifMetro server..."
npm install

# Find IP
echo ""
echo "🌐 Finding your network configuration..."
IP=$(ipconfig getifaddr en0 || ipconfig getifaddr en1)

if [ -z "$IP" ]; then
    echo -e "${YELLOW}⚠️  Could not detect IP automatically${NC}"
    echo "Run this command to find your IP:"
    echo "  ifconfig | grep 'inet ' | grep -v 127.0.0.1"
else
    echo -e "${GREEN}✅ Your IP: $IP${NC}"
    
    # Update SwifMetroClient.swift with IP
    if [ -f "SimpleMetroClient.swift" ]; then
        sed -i.bak "s/YOUR_MAC_IP_HERE/$IP/g" SimpleMetroClient.swift
        echo -e "${GREEN}✅ Updated SimpleMetroClient.swift with your IP${NC}"
    fi
fi

# Create start script
cat > start.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting SwifMetro Server..."
node swifmetro-advanced-server.js
EOF
chmod +x start.sh

# Create Xcode integration script
cat > add-to-xcode.sh << 'EOF'
#!/bin/bash
echo ""
echo "📱 Add SwifMetro to your Xcode project:"
echo ""
echo "1. Drag SwifMetroClient.swift into Xcode"
echo "2. In AppDelegate.swift, add:"
echo "   SwifMetroClient.shared.start()"
echo ""
echo "3. Update Info.plist:"
echo "   <key>NSAppTransportSecurity</key>"
echo "   <dict>"
echo "       <key>NSAllowsArbitraryLoads</key>"
echo "       <true/>"
echo "   </dict>"
echo ""
echo "4. Use anywhere:"
echo "   SwifMetroClient.shared.log(\"Hello!\")"
echo ""
EOF
chmod +x add-to-xcode.sh

# Success
echo ""
echo "═══════════════════════════════════════════════"
echo -e "${GREEN}✅ SWIFMETRO INSTALLED SUCCESSFULLY!${NC}"
echo "═══════════════════════════════════════════════"
echo ""
echo "📋 Quick Start:"
echo ""
echo "1. Start the server:"
echo -e "   ${GREEN}./start.sh${NC}"
echo ""
echo "2. Add to Xcode:"
echo -e "   ${GREEN}./add-to-xcode.sh${NC}"
echo ""
echo "3. Build and run your app!"
echo ""
echo "═══════════════════════════════════════════════"
echo ""

# Test server
echo "🧪 Testing server startup..."
timeout 2 node swifmetro-advanced-server.js > /dev/null 2>&1 &
TEST_PID=$!
sleep 1

if ps -p $TEST_PID > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Server test successful!${NC}"
    kill $TEST_PID 2>/dev/null
else
    echo -e "${YELLOW}⚠️  Server test failed - check installation${NC}"
fi

echo ""
echo "Ready to revolutionize your iOS debugging! 🔥"
echo ""