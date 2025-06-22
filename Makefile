.PHONY: help build run stop clean logs shell health install monitor quick-install

# Default target
help: ## Show this help message
	@echo "Pegascape Docker Management"
	@echo "=========================="
	@echo "🌟 Recommended for first-time users: make quick-install"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Run the installation script for first-time setup
	@chmod +x install.sh
	@./install.sh

quick-install: ## 🌟 Quick setup with current .env or default IP (recommended)
	@if [ ! -f .env ]; then \
		echo "Creating .env with default IP 192.168.1.100..."; \
		echo "# Pegascape Docker Configuration" > .env; \
		echo "HOST_IP=192.168.1.100" >> .env; \
		echo "NODE_ENV=production" >> .env; \
		echo "⚠️  Edit .env file to set your correct IP address"; \
	fi
	docker-compose build
	docker-compose up -d
	@echo "✅ Pegascape is starting! Check status with: make status"
	@echo "💡 Edit .env file with your actual IP if needed"

build: ## Build the Docker image
	docker build -t pegascape:local .

run: ## Run the container with Docker Compose
	@if [ ! -f .env ]; then \
		echo "Creating .env file from template..."; \
		cp .env.example .env; \
		echo "Please edit .env file with your HOST_IP before running again"; \
		exit 1; \
	fi
	docker-compose up -d

stop: ## Stop the running container
	docker-compose down

restart: stop run ## Restart the container

logs: ## Show container logs
	docker-compose logs -f pegascape

shell: ## Get a shell inside the running container
	docker-compose exec pegascape /bin/bash

health: ## Check container health
	docker-compose ps
	@echo "\nHealth status:"
	@docker inspect --format='{{.State.Health.Status}}' pegascape 2>/dev/null || echo "Container not running or no health check configured"

monitor: ## Start the monitoring script
	@chmod +x monitor.sh
	@./monitor.sh

clean: ## Remove containers and images
	docker-compose down -v
	docker rmi pegascape:local 2>/dev/null || true

update: ## Pull latest changes and rebuild
	git pull
	docker-compose down
	docker build --no-cache -t pegascape:local .
	docker-compose up -d

status: ## Show container status and useful information
	@echo "Container Status:"
	@docker-compose ps
	@echo "\nPort mappings:"
	@echo "Web interface: http://localhost:80"
	@echo "DNS server: localhost:53 (UDP)"
	@echo "Exploit server: localhost:8100"
	@echo "\nTo configure your Nintendo Switch:"
	@echo "Set DNS to your Docker host IP (check .env file)"
