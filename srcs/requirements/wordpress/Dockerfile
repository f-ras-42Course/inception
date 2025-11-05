# Penultimate stable Alpine
FROM alpine:3.21

# Install PHP-FPM and required extensions for WordPress
# Using php83 packages, as that's what's in Alpine 3.21
# We also install 'mysql-client' (for 'wait-for-it') and 'bash' 
RUN apk update && apk add --no-cache \
    php83 php83-fpm php83-mysqlnd php83-mysqli php83-json php83-curl \
    php83-dom php83-exif php83-fileinfo php83-intl php83-mbstring \
    php83-opcache php83-xml php83-zip php83-phar \
    mysql-client bash wget

# Download and install wp-cli (WordPress Command Line)
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Configure PHP-FPM to listen on a network port (9000)
# Note the path includes 'php83'
COPY conf/www.conf /etc/php83/php-fpm.d/www.conf

# Copy custom config to increase memory.
# Naming it 'zz-custom.ini' ensures it loads last.
COPY conf/custom.ini /etc/php83/conf.d/zz-custom.ini

# Copy the setup script
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Create the web root
RUN mkdir -p /var/www/html
WORKDIR /var/www/html

# This script will run on start
ENTRYPOINT ["/usr/local/bin/setup.sh"]

# This is the command that runs PHP-FPM in the foreground
# Avoids "hacky patches" like 'sleep infinity'
CMD ["/usr/sbin/php-fpm83", "-F"]
