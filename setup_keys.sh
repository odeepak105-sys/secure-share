#!/bin/bash
# This tells the system to run the script using bash shell

# setup_keys.sh - This script creates SSH keys and age keys for security

set -e  
# If any error happens, the script will stop immediately

echo "=== Secure File Sharing Tool - Key Setup ==="
# This prints a heading on the screen

# 1. Generate SSH key pair (ed25519) if not exists
# Check if SSH key already exists or not

if [ ! -f ~/.ssh/id_ed25519 ]; then
# If the SSH key file does NOT exist

    echo "Generating new SSH key (ed25519)..."
    # Print message

    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
    # Create a new SSH key
    # -t ed25519 → type of key
    # -f → file location
    # -N "" → no password (empty)

else
    echo "SSH key already exists at ~/.ssh/id_ed25519"
    # If key already exists, print message
fi

# 2. Generate age key pair for file encryption
# This creates age key for encrypting files

if [ ! -f ~/.age_key ]; then
# If age key file does NOT exist

    echo "Generating age key pair..."
    # Print message

    age-keygen -o ~/.age_key
    # Generate age key and save it in file

else
    echo "Age key already exists at ~/.age_key"
    # If already exists, print message
fi

# 3. Show public keys for sharing
# Now show public keys (these can be shared)

echo ""
# Print empty line

echo "=== Your Public Keys (share these with others) ==="
# Print heading

echo "SSH public key (for login):"
# Label for SSH public key

cat ~/.ssh/id_ed25519.pub
# Display SSH public key on screen

echo ""
# Empty line

echo "Age public key (for encrypting files to you):"
# Label for age public key

age-keygen -y ~/.age_key
# Generate and show public key from private age key

echo ""
# Empty line

echo "=== Instructions ==="
# Print instructions heading

echo "1. Give your age public key to anyone who wants to send you encrypted files."
# Share age public key with others

echo "2. To allow remote login, ask admin to add your SSH public key to ~/.ssh/authorized_keys."
# For login access, admin must add your SSH public key

echo "3. Keep ~/.age_key and ~/.ssh/id_ed25519 private – never share them."
# Never share private keys, keep them safe
