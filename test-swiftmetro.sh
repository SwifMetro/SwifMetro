#!/bin/bash

echo ""
echo "🧪 SWIFTMETRO VERIFICATION TEST"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

# Test 1: Node.js installed
echo "Test 1: Node.js Installation"
if command -v node &> /dev/null; then
    echo -e "${GREEN}✅ PASS${NC} - Node.js $(node -v) installed"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAIL${NC} - Node.js not found"
    ((TESTS_FAILED++))
fi

# Test 2: ws package installed
echo ""
echo "Test 2: WebSocket Package"
if [ -d "node_modules/ws" ]; then
    echo -e "${GREEN}✅ PASS${NC} - ws package installed"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⚠️  WARN${NC} - ws package not installed (run: npm install ws)"
    ((TESTS_FAILED++))
fi

# Test 3: Server file exists
echo ""
echo "Test 3: Server File"
if [ -f "swiftmetro-server.js" ]; then
    echo -e "${GREEN}✅ PASS${NC} - swiftmetro-server.js exists"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAIL${NC} - swiftmetro-server.js not found"
    ((TESTS_FAILED++))
fi

# Test 4: iOS client file exists
echo ""
echo "Test 4: iOS Client File"
if [ -f "SimpleMetroClient.swift" ]; then
    echo -e "${GREEN}✅ PASS${NC} - SimpleMetroClient.swift exists"
    ((TESTS_PASSED++))
    
    # Check if IP is configured
    if grep -q "YOUR_MAC_IP_HERE" SimpleMetroClient.swift; then
        echo -e "${YELLOW}⚠️  WARN${NC} - IP not configured in SimpleMetroClient.swift"
        echo "         Run: ./setup.sh to auto-configure"
    else
        echo -e "${GREEN}✅ PASS${NC} - IP address configured"
        ((TESTS_PASSED++))
    fi
else
    echo -e "${RED}❌ FAIL${NC} - SimpleMetroClient.swift not found"
    ((TESTS_FAILED++))
fi

# Test 5: Port availability
echo ""
echo "Test 5: Port 8081 Availability"
if lsof -i:8081 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  WARN${NC} - Port 8081 is in use"
    echo "         Kill process: lsof -ti:8081 | xargs kill -9"
else
    echo -e "${GREEN}✅ PASS${NC} - Port 8081 is available"
    ((TESTS_PASSED++))
fi

# Test 6: Network connectivity
echo ""
echo "Test 6: Network Configuration"
IP_COUNT=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | wc -l)
if [ $IP_COUNT -gt 0 ]; then
    echo -e "${GREEN}✅ PASS${NC} - Network interfaces found"
    echo "         Your IPs:"
    ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print "         → " $2}'
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAIL${NC} - No network interfaces found"
    ((TESTS_FAILED++))
fi

# Test 7: Server can start
echo ""
echo "Test 7: Server Startup Test"
timeout 2 node swiftmetro-server.js > /tmp/swiftmetro-test.log 2>&1 &
TEST_PID=$!
sleep 1

if ps -p $TEST_PID > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PASS${NC} - Server starts successfully"
    kill $TEST_PID 2>/dev/null
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAIL${NC} - Server failed to start"
    echo "         Check: cat /tmp/swiftmetro-test.log"
    ((TESTS_FAILED++))
fi

# Summary
echo ""
echo "=================================="
echo "TEST SUMMARY"
echo "=================================="
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
    echo "SwiftMetro is ready to use!"
    echo ""
    echo "Next steps:"
    echo "1. Start server: ./start-swiftmetro.sh"
    echo "2. Add SimpleMetroClient.swift to your iOS app"
    echo "3. Call SimpleMetroClient.shared.connect() in AppDelegate"
else
    echo -e "${YELLOW}⚠️  Some tests failed${NC}"
    echo "Run ./setup.sh to fix issues"
fi
echo ""