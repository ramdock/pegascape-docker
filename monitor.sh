#!/bin/bash
# Monitoring script for Pegascape Docker container
# Usage: ./monitor.sh [interval_seconds]

INTERVAL=${1:-30}
CONTAINER_NAME="pegascape"

echo "Pegascape Container Monitor"
echo "==========================="
echo "Monitoring interval: ${INTERVAL}s"
echo "Press Ctrl+C to stop"
echo

while true; do
    clear
    echo "$(date): Pegascape Status Report"
    echo "=================================="
    
    # Container status
    if docker ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -q "$CONTAINER_NAME"; then
        echo "✓ Container is running"
        docker ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    else
        echo "✗ Container is not running"
    fi
    
    echo
    
    # Health status
    HEALTH=$(docker inspect --format='{{.State.Health.Status}}' $CONTAINER_NAME 2>/dev/null)
    if [ "$HEALTH" = "healthy" ]; then
        echo "✓ Health: $HEALTH"
    elif [ "$HEALTH" = "unhealthy" ]; then
        echo "✗ Health: $HEALTH"
    elif [ "$HEALTH" = "starting" ]; then
        echo "⏳ Health: $HEALTH"
    else
        echo "? Health: Unknown or no health check"
    fi
    
    echo
    
    # Resource usage
    echo "Resource Usage:"
    docker stats $CONTAINER_NAME --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" 2>/dev/null || echo "Unable to get stats"
    
    echo
    
    # Recent logs (last 5 lines)
    echo "Recent Logs:"
    docker logs --tail 5 $CONTAINER_NAME 2>/dev/null | sed 's/^/  /' || echo "  Unable to get logs"
    
    echo
    echo "Next update in ${INTERVAL}s..."
    
    sleep $INTERVAL
done
