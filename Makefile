# Basic inits
COMPOSE_FILE = srcs/docker-compose.yml
LOGIN = fras

# Paths for data
DATA_PATH = /home/$(LOGIN)/data
DB_PATH = $(DATA_PATH)/db
WP_PATH = $(DATA_PATH)/wp

# Path to secret setup script
SECRET_SCRIPT = srcs/requirements/tools/setup_secrets.sh

# Default target: check, setup, build, and run
all: .check_secrets .setup_dirs
	@echo "Building and starting Inception containers..."
	@docker compose -f $(COMPOSE_FILE) up --build -d
	
# Creates the host directories
.setup_dirs:
	@echo "Checking for host data directories..."
	@sudo mkdir -p $(DB_PATH)
	@sudo mkdir -p $(WP_PATH)

# Runs interactive script to create secrets
.check_secrets:
	@echo "Checking for secret files..."
	@chmod +x $(SECRET_SCRIPT)
	@./$(SECRET_SCRIPT)
	@echo "All secret files are present."

# Stop and remove the containers
down:
	@echo "Stopping and removing Inception containers..."
	@docker compose -f $(COMPOSE_FILE) down

# Stop, remove containers, and remove volumes
clean: down
	@echo "Removing Docker volumes..."
	@docker compose -f $(COMPOSE_FILE) down -v

# Full clean: remove containers, volumes, images, and data files
fclean: clean
	@echo "Removing all data from host volumes..."
	@if [ -d "$(DB_PATH)" ]; then sudo rm -rf $(DB_PATH); fi
	@if [ -d "$(WP_PATH)" ]; then sudo rm -rf $(WP_PATH); fi
	@echo "Removing Docker images..."
	@docker compose -f $(COMPOSE_FILE) down --rmi all
	@echo "Pruning Docker system..."
	@docker system prune -af

# Rebuild everything from scratch
re: fclean all

# Show logs
logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

.PHONY: all down clean fclean re logs .setup_dirs .check_secrets
