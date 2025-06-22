#!/bin/bash
# Pegascape Docker Installation Script
# This script helps set up Pegascape Docker on a new system

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "=================================="
echo "Pegascape Docker Installation"
echo "=================================="
echo

# Check prerequisites
print_status "Checking prerequisites..."

if ! command_exists docker; then
    print_error "Docker is not installed. Please install Docker first:"
    echo "  - Windows/Mac: https://www.docker.com/products/docker-desktop"
    echo "  - Linux: https://docs.docker.com/engine/install/"
    exit 1
fi

if ! command_exists docker-compose; then
    print_warning "docker-compose not found. Checking for 'docker compose' (newer version)..."
    if ! docker compose version >/dev/null 2>&1; then
        print_error "Docker Compose is not available. Please install Docker Compose."
        exit 1
    else
        print_success "Found 'docker compose' (newer version)"
        COMPOSE_CMD="docker compose"
    fi
else
    print_success "Found docker-compose"
    COMPOSE_CMD="docker-compose"
fi

# Get network information
print_status "Detecting network configuration..."

# Try to detect the host IP
# For WSL environments, try to get Windows host IP first
if command_exists powershell.exe; then
    print_status "Detected WSL environment, getting Windows host IP..."
    HOST_IP=$(powershell.exe "(Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias 'Wi-Fi*', 'Ethernet*' | Where-Object {$_.IPAddress -like '192.168.*' -or $_.IPAddress -like '10.*' -or ($_.IPAddress -like '172.*' -and $_.IPAddress -notlike '172.17.*')} | Select-Object -First 1).IPAddress" 2>/dev/null | tr -d '\r\n' || echo "")
fi

# Fallback to Linux methods if no IP found
if [ -z "$HOST_IP" ]; then
    if command_exists ip; then
        # Try to get a local network IP (avoid docker and WSL IPs)
        HOST_IP=$(ip route get 8.8.8.8 | awk '{print $7; exit}' 2>/dev/null || echo "")
        # If it's a docker or WSL IP, try another method
        if echo "$HOST_IP" | grep -E '^(172\.17\.|172\.18\.|172\.19\.|127\.)' >/dev/null; then
            HOST_IP=$(ip addr show | grep -E 'inet.*192\.168\.|inet.*10\.' | head -n1 | awk '{print $2}' | cut -d'/' -f1 2>/dev/null || echo "")
        fi
    elif command_exists ifconfig; then
        HOST_IP=$(ifconfig | grep -E "inet.*192\.168\.|inet.*10\." | head -n1 | awk '{print $2}' | sed 's/addr://' 2>/dev/null || echo "")
    elif command_exists hostname; then
        HOST_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "")
    fi
fi

# Create .env file
print_status "Creating configuration file..."

# Skip interactive prompts if running in CI or non-interactive mode
if [ "$CI" = "true" ] || [ ! -t 0 ]; then
    print_status "Non-interactive mode detected, using default IP"
    if [ -z "$HOST_IP" ]; then
        HOST_IP="192.168.1.100"
    fi
else
    # Interactive mode with improved IP detection
    if [ -z "$HOST_IP" ]; then
        print_warning "Could not automatically detect host IP address"
        echo "For Windows/WSL users: Please find your Windows IP address by running 'ipconfig' in Command Prompt"
        echo "Look for 'IPv4 Address' under your active network adapter (Wi-Fi or Ethernet)"
        read -p "Please enter your computer's IP address on the local network: " HOST_IP
    else
        # Check if it's a WSL/Docker internal IP
        if echo "$HOST_IP" | grep -E '^(172\.17\.|172\.18\.|172\.19\.|127\.)' >/dev/null; then
            print_warning "Detected internal IP ($HOST_IP) - this may not work for Nintendo Switch"
            echo "For Windows/WSL users: Please use your Windows host IP instead"
            echo "Run 'ipconfig' in Windows Command Prompt to find your actual network IP"
            read -p "Enter the correct IP address, or press Enter to use $HOST_IP: " NEW_IP
            if [ -n "$NEW_IP" ]; then
                HOST_IP="$NEW_IP"
            fi
        else
            print_success "Detected host IP: $HOST_IP"
            echo "Press Enter to continue with $HOST_IP, or type a different IP:"
            read -p "IP address [$HOST_IP]: " NEW_IP
            if [ -n "$NEW_IP" ]; then
                HOST_IP="$NEW_IP"
            fi
        fi
    fi
fi

# Validate IP format
if ! echo "$HOST_IP" | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$' >/dev/null; then
    print_error "Invalid IP address format: $HOST_IP"
    exit 1
fi

cat > .env << EOF
# Pegascape Docker Configuration
# Generated on $(date)

# The IP address of your Docker host
# This should be the IP address that your Nintendo Switch can reach
HOST_IP=$HOST_IP

# Node.js environment (production/development)
NODE_ENV=production
EOF

print_success "Created .env file with HOST_IP=$HOST_IP"

# Build and start
print_status "Building and starting Pegascape container..."

if $COMPOSE_CMD build; then
    print_success "Container built successfully"
else
    print_error "Failed to build container"
    exit 1
fi

if $COMPOSE_CMD up -d; then
    print_success "Container started successfully"
else
    print_error "Failed to start container"
    exit 1
fi

# Wait for container to be healthy
print_status "Waiting for container to be ready..."
sleep 10

# Check status
if $COMPOSE_CMD ps | grep -q "Up"; then
    print_success "Pegascape is running!"
    echo
    echo "=================================="
    echo "Setup Complete!"
    echo "=================================="
    echo
    echo "Web interface: http://$HOST_IP:80"
    echo "DNS server: $HOST_IP:53 (UDP)"
    echo "Exploit server: $HOST_IP:8100"
    echo
    echo "Next steps:"
    echo "1. Configure your Nintendo Switch DNS settings:"
    echo "   - Go to System Settings → Internet"
    echo "   - Select your connection → Change Settings"
    echo "   - Set DNS to Manual"
    echo "   - Set Primary and Secondary DNS to: $HOST_IP"
    echo
    echo "2. Test the connection on your Switch"
    echo "3. Navigate to System Settings → Internet to trigger the exploit"
    echo
    echo "Useful commands:"
    echo "  $COMPOSE_CMD logs -f    # View logs"
    echo "  $COMPOSE_CMD ps         # Check status"
    echo "  $COMPOSE_CMD down       # Stop container"
    echo "  make status             # Show detailed status (if make is available)"
else
    print_error "Container failed to start properly"
    echo "Check logs with: $COMPOSE_CMD logs"
    exit 1
fi
