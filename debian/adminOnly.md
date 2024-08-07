Step-by-Step Guide for Changing the Root/Admin Password and Restricting Access to Only the Incident Response Account

#### 1. Create an Incident Response Account

First, you need to create a new user account specifically for incident response purposes.

```sh
# Create a new user account named 'incidentresponse'
sudo useradd -m -s /bin/bash ir

# Set a password for the 'incidentresponse' account
sudo passwd ir

```

#### 2. Grant the Incident Response Account Sudo Privileges

Add the incident response account to the sudoers file to ensure it has administrative privileges.

```sh
# Add 'incidentresponse' to the sudo group
sudo usermod -aG sudo ir

# Alternatively, add directly to the sudoers file
echo "ir ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/incidentresponse
```

#### 3. Change the Root Password

It's crucial to change the root password to ensure that unauthorized users cannot access the system.

```sh
# Change the root password

sudo passwd root
```

#### 4. Lock All Other User Accounts

To enhance security, lock all other user accounts except for the `incidentresponse` account.

```sh
# Get a list of all user accounts
cut -d: -f1 /etc/passwd

# Lock all user accounts except 'root' and 'incidentresponse'
for user in $(cut -d: -f1 /etc/passwd); do
    if [ "$user" != "root" ] && [ "$user" != "ir" ]; then
        sudo usermod -L "$user"
    fi
done
```

#### 5. Verify No Other Users Can Access the System

Ensure that all other user accounts are locked and cannot log in.

```sh
# Check the status of user accounts
sudo passwd -S $user
```

#### 6. Look for Places That Might Alter User Passwords

To maintain security, monitor and secure places that could potentially alter user passwords.

- **Cron Jobs:**
```sh

sudo crontab -l
sudo ls /var/spool/cron/crontabs
```
        
- **Configuration Files:**
```sh
# Check for scripts and commands in common cron directories
sudo grep -r 'passwd' /etc/cron.*

# Check for scripts in /etc/profile.d, /etc/bash.bashrc, ~/.bashrc, ~/.bash_profile
sudo grep -r 'passwd' /etc/profile.d/*
sudo grep -r 'passwd' /etc/bash.bashrc
sudo grep -r 'passwd' ~/.bashrc
sudo grep -r 'passwd' ~/.bash_profile
```

- **Sudoers File:**
```sh
sudo visudo
```

- **Custom Scripts:**
```sh
# Check for custom scripts in /usr/local/bin, /usr/local/sbin, /opt, etc.
sudo find /usr/local/bin /usr/local/sbin /opt -type f -exec grep -H 'passwd' {} \;
```

- **Systemd Services:**
```sh
# Check for systemd service files that might alter passwords
sudo grep -r 'passwd' /etc/systemd/system/
sudo grep -r 'passwd' /lib/systemd/system/
```

#### 7. Secure and Monitor the System

- **Enable Audit Logging:**
```sh
sudo apt-get install auditd
sudo systemctl enable auditd
sudo systemctl start auditd

# Add rules to log password changes
echo "-w /etc/passwd -p wa -k passwd_changes" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /etc/shadow -p wa -k shadow_changes" | sudo tee -a /etc/audit/rules.d/audit.rules
sudo systemctl restart auditd
```

- **Regularly Review Logs:**
```sh
sudo ausearch -k passwd_changes
sudo ausearch -k shadow_changes
```

By following these steps, you can effectively change the root/admin password, restrict access to only the `incidentresponse` account, and monitor for any unauthorized changes to user passwords. This approach ensures a secure and controlled environment during an incident response.
