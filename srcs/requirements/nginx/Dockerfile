FROM alpine:3.21

# Install NGINX and OpenSSL
RUN apk update && apk add --no-cache nginx openssl

# Copy NGINX configuration
COPY conf/nginx.conf /etc/nginx/http.d/default.conf

# Modifies the main config file to change the run-user
# from 'nginx' to 'nobody'
RUN sed -i 's/user nginx;/user nobody;/g' /etc/nginx/nginx.conf

# Create directory for SSL certificates
RUN mkdir -p /etc/nginx/ssl

# Generate a self-signed SSL certificate for TLS
# We use the $DOMAIN_NAME from the .env file (passed as an ARG)
ARG DOMAIN_NAME
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/fras.key \
    -out /etc/nginx/ssl/fras.crt \
    -subj "/C=NL/ST=North-Holland/L=Amsterdam/O=42/CN=${DOMAIN_NAME}"

# Expose the HTTPS port
EXPOSE 443

# Start NGINX in the foreground
# "daemon off;" is the correct Docker way
CMD ["nginx", "-g", "daemon off;"]
