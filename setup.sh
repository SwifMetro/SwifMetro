#!/bin/bash

echo ""
echo "🚀 SWIFMETRO SETUP WIZARD"
echo "=================================="
echo "Setting up SwifMetro for iOS terminal logging"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Check Node.js
echo "📦 Checking Node.js installation..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    echo -e "${GREEN}✅ Node.js installed: $NODE_VERSION${NC}"
else
    echo -e "${RED}❌ Node.js not found${NC}"
    echo ""
    echo "Install Node.js with one of these methods:"
    echo "  1. brew install node"
    echo "  2. Download from https://nodejs.org"
    echo ""
    exit 1
fi

# Step 2: Install ws package
echo ""
echo "📦 Installing WebSocket package..."
if [ -f "package.json" ]; then
    echo "package.json exists, updating..."
    npm install ws
else
    echo "Creating package.json..."
    cat > package.json << 'EOF'
{
  "name": "swifmetro-server",
  "version": "1.0.0",
  "description": "SwifMetro Server - Terminal logging for iOS",
  "dependencies": {
    "ws": "^8.14.2"
  }
}
EOF
    npm install
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ WebSocket package installed${NC}"
else
    echo -e "${RED}❌ Failed to install packages${NC}"
    exit 1
fi

# Step 3: Find IP addresses
echo ""
echo "🌐 Finding your network IP addresses..."
echo "=================================="

# macOS specific
if [[ "$OSTYPE" == "darwin"* ]]; then
    IPS=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')
else
    # Linux
    IPS=$(hostname -I | tr ' ' '\n')
fi

echo "Your Mac's IP addresses:"
echo ""
FIRST_IP=""
for ip in $IPS; do
    echo -e "${GREEN}  → $ip${NC}"
    if [ -z "$FIRST_IP" ]; then
        FIRST_IP=$ip
    fi
done

echo ""
echo -e "${YELLOW}📱 Use one of these IPs in SimpleMetroClient.swift${NC}"
echo ""

# Step 4: Create Info.plist addition file
echo "📝 Creating Info.plist requirements..."
cat > Info.plist.addition << 'EOF'
<!-- Add this to your Info.plist to allow local network access -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
EOF
echo -e "${GREEN}✅ Created Info.plist.addition${NC}"

# Step 5: Update SimpleMetroClient.swift with detected IP
echo ""
echo "📱 Configuring SimpleMetroClient.swift..."
if [ -n "$FIRST_IP" ]; then
    if [ -f "SimpleMetroClient.swift" ]; then
        # Update the IP in the Swift file
        sed -i.bak "s/YOUR_MAC_IP_HERE/$FIRST_IP/g" SimpleMetroClient.swift
        echo -e "${GREEN}✅ Updated SimpleMetroClient.swift with IP: $FIRST_IP${NC}"
        echo -e "${YELLOW}   (Backup saved as SimpleMetroClient.swift.bak)${NC}"
    else
        echo -e "${YELLOW}⚠️  SimpleMetroClient.swift not found in current directory${NC}"
    fi
fi

# Step 6: Test server startup
echo ""
echo "🧪 Testing server startup..."
timeout 2 node swifmetro-server.js > /dev/null 2>&1 &
SERVER_PID=$!
sleep 1

if ps -p $SERVER_PID > /dev/null; then
    echo -e "${GREEN}✅ Server can start successfully${NC}"
    kill $SERVER_PID 2>/dev/null
else
    echo -e "${RED}❌ Server failed to start${NC}"
    echo "   Check swifmetro-server.js exists"
fi

# Step 7: Create start script
echo ""
echo "📝 Creating start script..."
cat > start-swifmetro.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting SwifMetro Server..."
node swifmetro-server.js
EOF
chmod +x start-swifmetro.sh
echo -e "${GREEN}✅ Created start-swifmetro.sh${NC}"

# Step 8: Instructions
echo ""
echo "=================================="
echo -e "${GREEN}✅ SETUP COMPLETE!${NC}"
echo "=================================="
echo ""
echo "📋 NEXT STEPS:"
echo ""
echo "1. Add SimpleMetroClient.swift to your iOS project"
echo ""
echo "2. Update Info.plist with contents from Info.plist.addition"
echo ""
echo "3. In AppDelegate.swift, add:"
echo "   SimpleMetroClient.shared.connect()"
echo ""
echo "4. Start the server:"
echo -e "${GREEN}   ./start-swifmetro.sh${NC}"
echo ""
echo "5. Build and run your iOS app"
echo ""
echo "6. Use anywhere in your app:"
echo "   SimpleMetroClient.shared.log(\"Your message\")"
echo ""
echo "=================================="
echo -e "${YELLOW}💡 Your IP for iOS app: $FIRST_IP${NC}"
echo "=================================="
echo ""