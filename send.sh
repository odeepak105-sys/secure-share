#!/bin/bash
# This tells the system to run the script using bash shell

# send.sh - This script encrypts a file, sends it to another user, and saves a log

# Usage: ./send.sh <file> <recipient_user@host> <recipient_age_public_key>
# This shows how to run the script with 3 inputs

# Check arguments
if [ $# -ne 3 ]; then
# $# = number of inputs given
# -ne 3 means "not equal to 3"
# If user does not give exactly 3 inputs

    echo "ERROR: Wrong number of arguments"
    # Print error message

    echo "Usage: $0 <file> <recipient_user@host> <recipient_age_public_key>"
    # Show correct way to run script

    echo "Example: $0 notes.txt bob@192.168.1.10 \"age1qy...\""
    # Show example

    exit 1
    # Stop the script with error
fi

FILE="$1"
# First input → file name

RECIPIENT="$2"
# Second input → user@host (receiver)

RECIPIENT_PUBKEY="$3"
# Third input → receiver's age public key

# Check if file exists
if [ ! -f "$FILE" ]; then
# If file does NOT exist

    echo "ERROR: File '$FILE' not found"
    # Show error

    exit 1
    # Stop script
fi

# Generate checksum of original file
CHECKSUM=$(sha256sum "$FILE" | cut -d' ' -f1)
# Create hash (unique code) of file using sha256
# cut command takes only the hash part

echo "Original checksum: $CHECKSUM"
# Print checksum

# Encrypt file using age with recipient's public key
ENCRYPTED_FILE="${FILE}.age"
# New encrypted file name (example: file.txt.age)

echo "Encrypting to $ENCRYPTED_FILE ..."
# Show message

echo "$RECIPIENT_PUBKEY" | age -r - -o "$ENCRYPTED_FILE" "$FILE"
# Encrypt file using age
# -r → recipient public key
# -o → output file
# "$FILE" → original file

if [ $? -ne 0 ]; then
# $? checks last command status
# If not 0 → means error happened

    echo "ERROR: Encryption failed"
    # Show error

    echo "$(date -Iseconds) | $(whoami) | $RECIPIENT | $FILE | $CHECKSUM | FAILED (encryption)" >> transfer.log
    # Save failure details in log file

    exit 1
    # Stop script
fi

# Transfer encrypted file via scp (using SSH key authentication)
echo "Transferring $ENCRYPTED_FILE to $RECIPIENT ..."
# Show message

scp -o BatchMode=yes "$ENCRYPTED_FILE" "$RECIPIENT:~/"
# Send file using scp (secure copy)
# BatchMode=yes → no password prompt (uses SSH key)

if [ $? -ne 0 ]; then
# If transfer failed

    echo "ERROR: SCP transfer failed. Check SSH key setup and host reachability."
    # Show error

    echo "$(date -Iseconds) | $(whoami) | $RECIPIENT | $FILE | $CHECKSUM | FAILED (transfer)" >> transfer.log
    # Save failure in log

    rm -f "$ENCRYPTED_FILE"
    # Delete encrypted file from local system

    exit 1
    # Stop script
fi

# Log success
echo "$(date -Iseconds) | $(whoami) | $RECIPIENT | $FILE | $CHECKSUM | SUCCESS" >> transfer.log
# Save success info in log file

echo "SUCCESS: $FILE encrypted and sent to $RECIPIENT"
# Show success message

echo "Encrypted file is saved as $ENCRYPTED_FILE (you may delete it locally after confirmation)"
# Inform user about saved encrypted file

# Optional: remove encrypted file after successful transfer (uncomment if desired)
# rm -f "$ENCRYPTED_FILE"
# If you remove #, it will delete encrypted file automatically
