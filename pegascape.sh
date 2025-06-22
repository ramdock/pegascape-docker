#!/bin/bash
set -e

# Validate required environment variables
if [ -z "$HOST_IP" ]; then
    echo "Error: HOST_IP environment variable is required"
    exit 1
fi

# Validate IP format (basic check)
if ! echo "$HOST_IP" | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$' > /dev/null; then
    echo "Warning: HOST_IP ($HOST_IP) doesn't appear to be a valid IPv4 address"
fi

echo "Starting Pegascape with HOST_IP: $HOST_IP"
echo "Pegascape will be available on:"
echo "  - Web interface: http://$HOST_IP:80"
echo "  - DNS server: $HOST_IP:53 (UDP)"
echo "  - Exploit server: $HOST_IP:8100"

# Start the Pegascape Node.js applet
node start.js --webapplet --ip "$HOST_IP"