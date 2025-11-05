#!/bin/bash
set -e # Exit immediately if a command exits.

# Paths to secret files
DB_ROOT_PASSWORD_FILE="/run/secrets/db_root_password"
DB_ADMIN_PASSWORD_FILE="/run/secrets/db_admin_password"
DB_USER_PASSWORD_FILE="/run/secrets/db_user_password"

# Read passwords from secrets
DB_ROOT_PASSWORD=$(cat "$DB_ROOT_PASSWORD_FILE")
DB_ADMIN_PASSWORD=$(cat "$DB_ADMIN_PASSWORD_FILE")
DB_USER_PASSWORD=$(cat "$DB_USER_PASSWORD_FILE")

# Check if database is already initialized
if [ -d "/var/lib/mysql/$DB_NAME" ]; then
    echo "Database '$DB_NAME' already exists. Skipping initialization."
else
    echo "Database '$DB_NAME' not found. Initializing..."

    # Initialize MariaDB data directory
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    
    # Create the /run/mysqld directory for the socket
    echo "Creating /run/mysqld directory..."
    mkdir -p /run/mysqld
    chown -R mysql:mysql /run/mysqld

    # Start MariaDB in the background temporarily
    mariadbd --user=mysql --datadir=/var/lib/mysql &
    pid="$!"

    # Wait for MariaDB to be ready
    echo "Waiting for MariaDB to start..."
    for i in {30..0}; do
        if mariadb-admin 'ping' --silent; then
            break
        fi
        echo -n '.'
        sleep 1
    done
    if [ "$i" = 0 ]; then
        echo "MariaDB failed to start."
        exit 1
    fi
    echo "MariaDB started."

    # Create database and users using SQL
    # Using environment variables from the .env file
    mysql <<-EOF
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
        CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_USER_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
        CREATE USER IF NOT EXISTS '${DB_ADMIN_USER}'@'%' IDENTIFIED BY '${DB_ADMIN_PASSWORD}';
        GRANT ALL PRIVILEGES ON *.* TO '${DB_ADMIN_USER}'@'%' WITH GRANT OPTION;
        FLUSH PRIVILEGES;
EOF

    echo "Database and users created."
    
    # Stop the temporary MariaDB server
    mariadb-admin -u root -p"${DB_ROOT_PASSWORD}" shutdown
    wait "$pid"
fi

echo "Handing over to CMD: $@"
# 'exec' replaces the shell with the CMD process,
# ensuring it's the main process (PID 1)
exec "$@"
