#!/bin/bash
# Quick test script for Pegascape Docker setup

echo "🧪 Pegascape Docker Test Suite"
echo "=============================="

# Check Docker
echo "1. Checking Docker..."
if command -v docker >/dev/null 2>&1; then
    echo "   ✅ Docker installed: $(docker --version)"
else
    echo "   ❌ Docker not found"
    exit 1
fi

# Check Docker Compose
echo "2. Checking Docker Compose..."
if command -v docker-compose >/dev/null 2>&1; then
    echo "   ✅ docker-compose found: $(docker-compose --version)"
    COMPOSE_CMD="docker-compose"
elif docker compose version >/dev/null 2>&1; then
    echo "   ✅ docker compose found: $(docker compose version)"
    COMPOSE_CMD="docker compose"
else
    echo "   ❌ Docker Compose not found"
    exit 1
fi

# Validate docker-compose.yml
echo "3. Validating docker-compose.yml..."
if $COMPOSE_CMD config >/dev/null 2>&1; then
    echo "   ✅ docker-compose.yml is valid"
else
    echo "   ❌ docker-compose.yml has errors:"
    $COMPOSE_CMD config
    exit 1
fi

# Check if containers are running
echo "4. Checking container status..."
if $COMPOSE_CMD ps | grep -q "Up"; then
    echo "   ✅ Container is running"
    $COMPOSE_CMD ps
else
    echo "   ℹ️  No containers running"
fi

# Test build
echo "5. Testing Docker build..."
if docker build -t pegascape:test . >/dev/null 2>&1; then
    echo "   ✅ Docker build successful"
    docker rmi pegascape:test >/dev/null 2>&1
else
    echo "   ❌ Docker build failed"
    exit 1
fi

# Check network configuration
echo "6. Network configuration..."
if command -v powershell.exe >/dev/null 2>&1; then
    echo "   ℹ️  WSL environment detected"
    WIN_IP=$(powershell.exe "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {\$_.InterfaceAlias -like '*Wi-Fi*' -or \$_.InterfaceAlias -like '*Ethernet*'} | Where-Object {\$_.IPAddress -like '192.168.*' -or \$_.IPAddress -like '10.*'} | Select-Object -First 1).IPAddress" 2>/dev/null | tr -d '\r\n' || echo "")
    if [ -n "$WIN_IP" ]; then
        echo "   💡 Suggested HOST_IP for Nintendo Switch: $WIN_IP"
    else
        echo "   ⚠️  Could not detect Windows host IP"
    fi
else
    echo "   ℹ️  Linux/Mac environment detected"
fi

echo ""
echo "🎯 Test Summary:"
echo "   All core components are working!"
echo "   You can now run:"
echo "   - make run    (start container)"
echo "   - make logs   (view logs)"
echo "   - make status (show status)"
