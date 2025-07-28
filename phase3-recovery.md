# Phase 3: Recovery & Hardening

## System Recovery
```bash
# Kill suspicious processes
kill -9 PID
pkill -f "suspicious_process"

# Remove malicious files
rm -f /path/to/malicious/file
shred -vfz -n 3 /path/to/sensitive/file

# Clean temporary directories
rm -rf /tmp/*
rm -rf /dev/shm/*
rm -rf /var/tmp/*
```

## Service Hardening
```bash
# Restart critical services
systemctl restart ssh
systemctl restart apache2
systemctl restart mysql

# Disable unnecessary services
systemctl disable SERVICE_NAME
systemctl stop SERVICE_NAME

# Update service configurations
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
# Edit sshd_config with hardened settings
systemctl restart ssh
```

## User Account Recovery
```bash
# Reset all user passwords
for user in $(cut -d: -f1 /etc/passwd); do
    echo "NewStrongPass123!" | passwd --stdin $user 2>/dev/null
done

# Lock down service accounts
chsh -s /bin/false www-data
chsh -s /bin/false mysql
chsh -s /bin/false daemon

# Remove unauthorized SSH keys
find /home -name "authorized_keys" -exec cp /dev/null {} \;
```

## File System Hardening
```bash
# Set proper permissions on web directories
chmod 755 -R /var/www/html
chown root:www-data -R /var/www/html
find /var/www/html -type f -exec chmod 644 {} \;

# Secure configuration files
chmod 600 /etc/ssh/sshd_config
chmod 600 /etc/mysql/my.cnf
chmod 640 /etc/shadow

# Remove world-writable files
find / -type f -perm -002 -exec chmod o-w {} \; 2>/dev/null
```

## Network Hardening
```bash
# Block suspicious IPs with iptables
iptables -I INPUT -s MALICIOUS_IP -j DROP
iptables -I OUTPUT -d MALICIOUS_IP -j DROP

# Save iptables rules
iptables-save > /etc/iptables/rules.v4

# Configure basic firewall
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
```

## Database Recovery
```bash
# Secure MySQL installation
mysql_secure_installation

# Remove anonymous users
mysql -u root -p -e "DELETE FROM mysql.user WHERE User='';"

# Remove remote root access
mysql -u root -p -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"

# Flush privileges
mysql -u root -p -e "FLUSH PRIVILEGES;"

# Restart MySQL
systemctl restart mysql
```

## Web Application Recovery
```bash
# Update web application passwords
# WordPress
wp user update admin --user_pass=NewStrongPass123! --path=/var/www/html

# Check for malicious uploads
find /var/www -name "*.php" -newer /var/log/apache2/access.log -exec grep -l "eval\|base64_decode\|system" {} \;

# Remove identified webshells
rm -f /var/www/html/suspicious_file.php

# Update .htaccess for security
echo "Options -Indexes" >> /var/www/html/.htaccess
echo "ServerTokens Prod" >> /etc/apache2/apache2.conf
```

## SSH Hardening
```bash
# Backup original config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig

# Apply hardened SSH config
cat > /etc/ssh/sshd_config << 'EOF'
Port 22
Protocol 2
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
AllowUsers IR_USERNAME
EOF

# Restart SSH
systemctl restart ssh
```

## System Updates
```bash
# Update package lists
apt update

# Apply security updates only
apt list --upgradable | grep -i security

# Install updates (be careful not to break services)
apt upgrade -y

# Clean package cache
apt autoremove -y
apt autoclean
```