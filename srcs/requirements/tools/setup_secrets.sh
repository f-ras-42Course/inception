#!/bin/bash

# This script interactively asks for passwords if they are missing.
# Using 'read -s' to hide the password input.

# Create the secrets directory if it doesn't exist
mkdir -p secrets

# Define the secret files we need
declare -a SECRET_FILES=(
    "secrets/db_root_password.txt"
    "secrets/db_admin_password.txt"
    "secrets/db_user_password.txt"
    "secrets/wp_admin_password.txt"
    "secrets/wp_user_password.txt"
)

# Function to prompt for a password
prompt_for_password() {
    local prompt_message=$1
    local secret_file=$2
    local password

    while true; do
        echo -n "$prompt_message"
        read -s password
        echo

        if [ -z "$password" ]; then
            echo "Password cannot be empty. Please try again."
        else
            echo "$password" > "$secret_file"
            echo "Password for '$secret_file' saved."
            break
        fi
    done
}

# Check each secret file
for file in "${SECRET_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "WARNING: Secret file not found: $file"
        prompt_for_password "Please enter new $file: " "$file"
    fi
done

echo "All secret files are present."
