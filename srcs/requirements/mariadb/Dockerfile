# Penultimate stable Alpine
FROM alpine:3.21

# Install MariaDB and bash
RUN apk update && apk add --no-cache mariadb mariadb-client bash

# Copy custom MariaDB configuration
COPY conf/my.cnf /etc/my.cnf.d/my.cnf

# Copy the setup script
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Expose the default MySQL port
EXPOSE 3306

# Run the setup script, which will then start the server
ENTRYPOINT ["/usr/local/bin/setup.sh"]

# This is the command that setup.sh will run in the end.
# It starts MariaDB in the console (foreground), which is
# the correct way to run a daemon in Docker.
CMD ["mariadbd", "--user=mysql", "--console"]
