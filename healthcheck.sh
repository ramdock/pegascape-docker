#!/bin/bash
# Health check script for Pegascape container

set -e

# Check if the web interface is responding
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:80/ || echo "000")

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✓ Web interface is healthy (HTTP $HTTP_STATUS)"
    exit 0
elif [ "$HTTP_STATUS" -eq 000 ]; then
    echo "✗ Web interface is not responding"
    exit 1
else
    echo "✗ Web interface returned HTTP $HTTP_STATUS"
    exit 1
fi
