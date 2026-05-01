#!/bin/bash
# This tells system to run the script using bash shell

# receive.sh - This script decrypts a file and checks if it is correct

# Usage: ./receive.sh <encrypted_file.age> <expected_checksum>
# This shows how to run the script (2 inputs needed)

set -e
# If any error happens, the script will stop immediately

if [ $# -ne 2 ]; then
# $# = number of inputs
# If inputs are not equal to 2

    echo "ERROR: Wrong number of arguments"
    # Show error message

    echo "Usage: $0 <encrypted_file.age> <expected_checksum>"
    # Show correct usage

    echo "Example: $0 notes.txt.age a3f1b2c3..."
    # Show example

    exit 1
    # Stop script
fi

ENCRYPTED="$1"
# First input → encrypted file name

EXPECTED_CHECKSUM="$2"
# Second input → expected checksum value

# Check if encrypted file exists
if [ ! -f "$ENCRYPTED" ]; then
# If file does NOT exist

    echo "ERROR: Encrypted file '$ENCRYPTED' not found"
    # Show error

    exit 1
    # Stop script
fi

# Decrypt using private age key
DECRYPTED="${ENCRYPTED%.age}"
# Remove ".age" from file name to get original file name

echo "Decrypting $ENCRYPTED to $DECRYPTED ..."
# Show message

age -d -i ~/.age_key -o "$DECRYPTED" "$ENCRYPTED"
# Decrypt file using your private key
# -d → decrypt
# -i → identity (private key)
# -o → output file

if [ $? -ne 0 ]; then
# $? checks last command status
# If not 0 → error happened

    echo "ERROR: Decryption failed – wrong private key or corrupted file"
    # Show error

    exit 1
    # Stop script
fi

# Compute checksum of decrypted file
ACTUAL_CHECKSUM=$(sha256sum "$DECRYPTED" | cut -d' ' -f1)
# Generate hash (unique code) of decrypted file
# cut takes only the checksum part

# Verify against expected checksum
if [ "$ACTUAL_CHECKSUM" = "$EXPECTED_CHECKSUM" ]; then
# Compare actual checksum with expected checksum

    echo " INTEGRITY CHECK PASSED"
    # File is correct

    echo "File '$DECRYPTED' matches the original."
    # Show success message

else
    echo " INTEGRITY CHECK FAILED"
    # File is not correct

    echo "Expected: $EXPECTED_CHECKSUM"
    # Show expected value

    echo "Got:      $ACTUAL_CHECKSUM"
    # Show actual value

    echo "WARNING: File may have been tampered with or corrupted."
    # Warning message

    exit 1
    # Stop script
fi

echo "Successfully received and verified: $DECRYPTED"
# Final success message
