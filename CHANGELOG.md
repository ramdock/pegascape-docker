# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Docker Compose support for easier deployment
- Comprehensive Makefile with 15 management commands
- `make quick-install` - Non-interactive setup command
- Environment variable validation in startup script
- Health checks for container monitoring
- Comprehensive documentation with troubleshooting guide
- `.env.example` template for configuration
- Security improvements (non-root user, proper signal handling)
- Multi-architecture support (amd64, arm64) in CI/CD
- Installation script for automated setup (`install.sh`)
- Monitoring script for real-time container status (`monitor.sh`)
- Custom health check script (`healthcheck.sh`)
- Test suite for project validation (`test.sh`)

### Changed
- Maintained Node.js version 14.21.3 for Pegascape compatibility
- Improved Dockerfile with multi-stage build for better security and smaller images
- Enhanced startup script with better error handling, validation, and logging
- Updated GitHub Actions workflow with modern practices, caching, and testing
- Improved docker-compose.yml with security options and health checks
- Enhanced README with step-by-step instructions and troubleshooting

### Fixed
- Interactive installation script hanging issue by adding `make quick-install`
- IP detection for WSL/Windows environments
- Container restart behavior documentation (normal behavior explained)
- Docker health check implementation using custom script
- Improved Dockerfile with multi-stage build and security best practices
- Enhanced GitHub Actions workflow with better caching and testing
- Startup script now uses bash with proper error handling and validation
- README completely rewritten with better structure and examples

### Fixed
- Container now properly handles signals for graceful shutdown
- Removed unnecessary TTY requirement in container startup
- Improved logging and error messages

### Security
- Container now runs as non-root user
- Added security options in Docker Compose
- Updated base images to latest secure versions
- Implemented proper file permissions

## [1.0.0] - Previous Version

### Added
- Initial Docker container for Pegascape
- Basic GitHub Actions for building and pushing images
- Simple README with basic instructions
