Secure File Sharing Tool

This is a simple command-line tool.
It helps people (like human rights groups) send important and private files safely.

It uses:

SSH (for secure connection)
age (for encryption)
checksum (to check file is not changed)

Features
Encrypt file using receiver’s public key
Send only encrypted .age files (not original file)
Check file using SHA256 (to make sure file is safe)
Keep simple log of all transfers
Show errors if something goes wrong

Setup (do only one time)
1. Install age (if not installed)
    sudo apt install age
2. Create your keys
    ./setup_keys.sh

This will create:

SSH key → ~/.ssh/id_ed25519 (for login)
Age key → ~/.age_key (for decrypt file)

=> Public keys will be shown on screen
=> Share your age public key with others (so they can send files to you)
3. Add SSH key to remote machine
    ssh-copy-id user@remote_host
OR ask admin to add your key manually to:
    ~/.ssh/authorized_keys


How to Send a File

./send.sh <filename> <user@host> "<age_public_key>"

Example:

./send.sh notes.txt bob@192.168.1.10 "age1abcd..."


What this script does:
Create SHA256 checksum
Encrypt file → notes.txt.age
Send file using scp
Save details in transfer.log


How to Receive and Decrypt

=> First, ask sender for checksum

Then run:
      ./receive.sh <file.age> <checksum>

Example:
       ./receive.sh notes.txt.age a1b2c3d4...


What this does:
Decrypt file
Check if file is same (using checksum)

If correct, you will see:
 INTEGRITY CHECK PASSED


Important Rules

 Share your age public key (starts with age1...)

 Never share:

~/.age_key
~/.ssh/id_ed25519

 Use transfer.log to see history

 Never send original file directly
=>Always use send.sh


Common Errors
Error	                      Reason	                     Fix

Encryption failed	 Wrong public key	        Ask correct key
SCP failed	         SSH not set	                Run ssh-copy-id
Decryption failed	 Wrong key / file problem	Use correct key
Integrity check failed	 File changed	                 Ask to resend
