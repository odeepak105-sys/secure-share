#!/bin/bash
# send.sh - Encrypt file, send via SCP, and log transfer

set -e

LOGFILE="transfer.log"

# Check arguments
if [ $# -ne 3 ]; then
    echo "ERROR: Wrong number of arguments"
    echo "Usage: $0 <file> <recipient_user@host> <recipient_age_public_key>"
    exit 1
fi

FILE="$1"
RECIPIENT="$2"
RECIPIENT_PUBKEY="$3"

# Check if file exists
if [ ! -f "$FILE" ]; then
    echo "ERROR: File '$FILE' not found"
    exit 1
fi

# Generate checksum
CHECKSUM=$(sha256sum "$FILE" | cut -d' ' -f1)

# Encrypt file (FIXED LINE ✅)
ENCRYPTED_FILE="$(basename "$FILE").age"
echo "Encrypting $FILE ..."
age -r "$RECIPIENT_PUBKEY" -o "$ENCRYPTED_FILE" "$FILE"

if [ $? -ne 0 ]; then
    echo "ERROR: Encryption failed"
    echo "$(date -Iseconds) | $(whoami) | $RECIPIENT | $FILE | $CHECKSUM | FAILED (encryption)" >> "$LOGFILE"
    exit 1
fi

# Transfer file
echo "Sending $ENCRYPTED_FILE to $RECIPIENT ..."
scp -o BatchMode=yes "$ENCRYPTED_FILE" "$RECIPIENT:~/"

if [ $? -ne 0 ]; then
    echo "ERROR: Transfer failed"
    echo "$(date -Iseconds) | $(whoami) | $RECIPIENT | $FILE | $CHECKSUM | FAILED (transfer)" >> "$LOGFILE"
    rm -f "$ENCRYPTED_FILE"
    exit 1
fi

# Log success
echo "$(date -Iseconds) | $(whoami) | $RECIPIENT | $FILE | $CHECKSUM | SUCCESS" >> "$LOGFILE"

echo "SUCCESS: File encrypted and sent"
