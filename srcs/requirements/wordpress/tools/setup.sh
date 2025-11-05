#!/bin/bash
set -e

# Read passwords from secrets
WP_ADMIN_PASSWORD=$(cat "/run/secrets/wp_admin_password")
WP_USER_PASSWORD=$(cat "/run/secrets/wp_user_password")
DB_ADMIN_PASSWORD=$(cat "/run/secrets/db_admin_password")

# Wait for MariaDB to be available
echo "Waiting for MariaDB at host 'mariadb'..."
# We use 'mariadb-admin' to ping the db
# 'mariadb' is the service name from docker-compose
while ! mariadb-admin ping -h"mariadb" -u"${DB_ADMIN_USER}" -p"${DB_ADMIN_PASSWORD}" --silent; do
    echo -n '.'
    sleep 1
done
echo "MariaDB is up!"

# Check if WordPress is already installed
if [ -f "/var/www/html/wp-config.php" ]; then
    echo "WordPress is already installed. Skipping setup."
else
    echo "WordPress not found. Installing..."
    
    # Download WordPress core files
    wp core download --allow-root
    
    # Create wp-config.php
    wp config create --allow-root \
        --dbname="${DB_NAME}" \
        --dbuser="${DB_ADMIN_USER}" \
        --dbpass="${DB_ADMIN_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --skip-check

    # Install WordPress
    wp core install --allow-root \
        --url="https://"${DOMAIN_NAME} \
        --title="${WP_TITLE}" \
        --admin_user="${DB_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}"

    # Create the second user
    wp user create --allow-root \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role="author" \
        --user_pass="${WP_USER_PASSWORD}"

    echo "WordPress installation complete."
fi

# Change ownership of web files to the user PHP-FPM runs as
chown -R nobody:nobody /var/www/html

echo "Handing over to CMD: $@"
exec "$@"
