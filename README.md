# Pegascape Docker

A Docker container for [Pegascape](https://github.com/Ramzus/pegascape), enabling easy self-hosting of the Nintendo Switch deja-vu exploit.

## Why Use Docker for Pegascape?

- **Reliability**: Host your own instance when the public Pegascape service is unavailable
- **Performance**: Faster and more stable exploit execution from a local network
- **Future-proofing**: Maintain access even if public services go offline
- **Easy deployment**: Simple setup with Docker and Docker Compose

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Your computer and Nintendo Switch on the same network
- Knowledge of your computer's IP address on the local network

### 🌟 Recommended: Quick Install

```bash
# Clone and setup in one command
git clone <your-repo-url>
cd pegascape-docker
make quick-install
```

This will:
- Create a default `.env` file
- Build the container
- Start Pegascape
- Show you the next steps

### Alternative: Using Docker Compose

1. **Clone this repository**:
   ```bash
   git clone <your-repo-url>
   cd pegascape-docker
   ```

2. **Set up environment**:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` and set `HOST_IP` to your computer's IP address (e.g., `192.168.1.100`)

3. **Start the service**:
   ```bash
   docker-compose up -d
   ```

4. **Check status**:
   ```bash
   docker-compose ps
   docker-compose logs -f pegascape
   ```

### Using Make (Alternative)

This project includes a Makefile for easy management:

```bash
make help           # Show available commands
make quick-install  # 🌟 Fast, non-interactive setup
make install        # Interactive setup with IP detection
make run            # Start the service
make logs           # View logs
make stop           # Stop the service
make status         # Show container status
```

### Manual Docker Run

```bash
docker build -t pegascape:local .
docker run -p 80:80 -p 53:53/udp -p 8100:8100 \
  -e HOST_IP=<YOUR_IP_ADDRESS> \
  --name pegascape -d \
  pegascape:local
```

## Configuration

### Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `HOST_IP` | IP address of your Docker host | `192.168.1.100` | Yes |
| `NODE_ENV` | Node.js environment | `production` | No |

### Ports

The container exposes three essential ports:

- **80**: Web interface (frontend)
- **53/udp**: DNS server (blocks Nintendo services, redirects to container)
- **8100**: Exploit server

## Nintendo Switch Configuration

1. Go to **System Settings** → **Internet** on your Switch
2. Select your current internet connection
3. Click **Change Settings**
4. Set **DNS Settings** to **Manual**
5. Set both **Primary DNS** and **Secondary DNS** to your computer's IP address (the `HOST_IP` value)
6. Save the configuration

⚠️ **Note**: With this DNS configuration, your Switch won't have internet access, but Pegascape will be available for the deja-vu exploit.

## Usage

1. Ensure the container is running: `docker-compose ps`
2. On your Switch, navigate to **System Settings** → **Internet**
3. Test your internet connection (this will trigger the DNS redirect)
4. Follow the on-screen instructions for the deja-vu exploit

## Troubleshooting

### Container Behavior
- **Container shows "Restarting" status**: This is normal behavior. Pegascape runs in an interactive mode and Docker's restart policy keeps it running. The application starts correctly and initializes all services.

### Common Issues

1. **`make install` hangs**: Use `make quick-install` instead for non-interactive setup.

2. **Switch can't connect**: 
   - Verify the `HOST_IP` in `.env` is your actual network IP (not 127.0.0.1 or docker IP)
   - Check both devices are on the same network
   - For Windows/WSL: Use `ipconfig` in Command Prompt to find your Windows IP

3. **DNS not working**: Ensure port 53/udp is not blocked by your firewall

4. **Web interface not loading**: Check if port 80 is available and not used by other services

### Installation Methods

1. **Quick Install (Recommended)**: `make quick-install` - Non-interactive setup
2. **Interactive Install**: `make install` - Interactive setup with IP detection  
3. **Manual Setup**: Edit `.env` file with your IP, then `make run`

## Project Improvements

This project has been enhanced with modern DevOps practices while maintaining full compatibility with the original Pegascape implementation:

### Infrastructure
- ✅ Multi-stage Docker build for optimized images
- ✅ Node.js 14.21.3 maintained for Pegascape compatibility
- ✅ Security hardening (non-root user, proper permissions)
- ✅ Health checks for container monitoring

### Management & Deployment
- ✅ Docker Compose configuration for simple deployment
- ✅ 15 management commands via Makefile
- ✅ Automated installation scripts
- ✅ Environment configuration with `.env` support
- ✅ Real-time monitoring functionality

### Enhanced Features
- ✅ Custom health check script
- ✅ Container resource monitoring
- ✅ Multi-architecture support (amd64, arm64)
- ✅ Improved CI/CD with GitHub Actions

## Project Structure

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Container orchestration configuration |
| `Dockerfile` | Multi-stage Docker build definition |
| `Makefile` | Management commands and automation |
| `.env.example` | Environment configuration template |
| `pegascape.sh` | Container startup script with validation |
| `healthcheck.sh` | Container health validation script |
| `install.sh` | Automated setup and installation |
| `monitor.sh` | Real-time monitoring script |
| `test.sh` | Project validation test suite |

## Development

### Building from Source

```bash
make build
# or
docker build -t pegascape:local .
```

### Updating

```bash
make update
# or manually:
git pull
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Security Considerations

- The container runs as a non-root user for security
- Only essential ports are exposed
- The image uses security best practices including read-only filesystem options
- Health checks ensure the service is running properly

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `docker-compose up`
5. Submit a pull request

## License

This project follows the same license as the original Pegascape project.

## Support

- Check the [Issues](../../issues) page for common problems
- Review Docker and Docker Compose logs for debugging
- Ensure your network configuration allows communication between devices