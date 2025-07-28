# Phase 2: Containment & Eradication

## Immediate Threat Containment
```bash
# Kill all suspicious processes immediately
pkill -f "nc -l"
pkill -f "python.*socket"
pkill -f "perl.*socket"
pkill -f "/tmp/"
killall -9 nc netcat socat

# Kill processes by suspicious users
pkill -u attacker_user
pkill -u www-data python
pkill -u nobody perl

# Kill processes on common backdoor ports
fuser -k 4444/tcp 5555/tcp 6666/tcp 7777/tcp 8080/tcp 9999/tcp 31337/tcp
```

## Network Isolation
```bash
# Block known malicious IPs immediately
iptables -I INPUT -s MALICIOUS_IP -j DROP
iptables -I OUTPUT -d MALICIOUS_IP -j DROP

# Block common reverse shell ports
for port in 4444 5555 6666 7777 8080 9999 31337; do
    iptables -I INPUT -p tcp --dport $port -j DROP
    iptables -I OUTPUT -p tcp --dport $port -j DROP
done

# Block outbound connections to suspicious networks
iptables -I OUTPUT -d 10.0.0.0/8 -j DROP
iptables -I OUTPUT -d 192.168.0.0/16 -j DROP

# Save firewall rules
iptables-save > /etc/iptables/rules.v4
```

## User Account Lockdown
```bash
# Change all user passwords immediately
for user in $(cut -d: -f1 /etc/passwd | grep -v -E "^(root|daemon|bin|sys|sync|games|man|lp|mail|news|uucp|proxy|www-data|backup|list|irc|gnats|nobody|systemd)$"); do
    echo "TempPass123!" | passwd --stdin $user 2>/dev/null || echo "TempPass123!" | chpasswd <<< "$user:TempPass123!" 2>/dev/null
done

# Lock suspicious accounts
usermod -L suspicious_user
usermod -s /bin/false suspicious_user

# Remove shell access from service accounts
chsh -s /bin/false www-data
chsh -s /bin/false mysql
chsh -s /bin/false apache

# Clear all SSH authorized keys
find /home -name "authorized_keys" -exec cp /dev/null {} \;
find /root -name "authorized_keys" -exec cp /dev/null {} \;
```

## File System Eradication
```bash
# Remove malicious files from common locations
rm -rf /tmp/.*
rm -rf /tmp/*
rm -rf /dev/shm/*
rm -rf /var/tmp/*

# Find and remove webshells
find /var/www -name "*.php" -exec grep -l "eval\|system\|exec\|shell_exec\|passthru\|base64_decode" {} \; | xargs rm -f

# Remove suspicious files by pattern
find / -name "*.jsp" -path "*/webapps/*" -exec grep -l "Runtime.getRuntime" {} \; | xargs rm -f
find / -name "*.asp*" -exec grep -l "eval\|execute" {} \; | xargs rm -f

# Remove recently created executable files
find /tmp /var/tmp /dev/shm -type f -executable -newer /var/log/wtmp -delete 2>/dev/null
```

## Service Hardening
```bash
# Stop and disable unnecessary services
systemctl stop telnet
systemctl disable telnet
systemctl stop rsh
systemctl disable rsh
systemctl stop rlogin
systemctl disable rlogin

# Restart critical services with clean configurations
systemctl restart ssh
systemctl restart apache2
systemctl restart nginx
systemctl restart mysql

# Kill all user sessions except current
who | grep -v $(whoami) | awk '{print $2}' | xargs -I {} pkill -t {}
```

## Database Containment
```bash
# Change all database passwords
mysql -u root -p -e "UPDATE mysql.user SET Password=PASSWORD('NewStrongPass123!') WHERE User='root';"
mysql -u root -p -e "DELETE FROM mysql.user WHERE User='';"
mysql -u root -p -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -u root -p -e "FLUSH PRIVILEGES;"

# Bind MySQL to localhost only
sed -i 's/^bind-address.*/bind-address = 127.0.0.1/' /etc/mysql/my.cnf
systemctl restart mysql
```

## Web Application Containment
```bash
# Set restrictive permissions on web directories
chmod 750 -R /var/www/html
chown root:www-data -R /var/www/html
find /var/www/html -type f -exec chmod 644 {} \;

# Remove write permissions from web files
find /var/www -type f -name "*.php" -exec chmod 644 {} \;
find /var/www -type f -name "*.html" -exec chmod 644 {} \;
find /var/www -type f -name "*.js" -exec chmod 644 {} \;

# Check for recently modified web files
find /var/www -type f -mtime -1 -ls

# Remove upload directories that shouldn't exist
rm -rf /var/www/html/uploads
rm -rf /var/www/html/files
rm -rf /var/www/html/tmp
```

## SSH Hardening
```bash
# Backup and harden SSH configuration
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Apply restrictive SSH settings
cat > /etc/ssh/sshd_config << 'EOF'
Port 22
Protocol 2
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
AllowUsers YOUR_IR_USERNAME
EOF

systemctl restart ssh
```

## Log Analysis for Eradication
```bash
# Check for persistence mechanisms
grep -r "* * * * *" /var/spool/cron/
ls -la /etc/cron.*
cat /etc/rc.local
systemctl list-unit-files | grep enabled | grep -v -E "(systemd|network|dbus)"

# Remove malicious cron jobs
crontab -r
rm -f /var/spool/cron/crontabs/*
```

## Process Validation
```bash
# Verify no malicious processes remain
ps aux | grep -E "(nc|netcat|python.*socket|perl.*socket|bash.*tcp)" | grep -v grep

# Check for processes listening on suspicious ports
ss -tulpn | grep -E ":(4444|5555|6666|7777|8080|9999|31337)"

# Monitor for new suspicious processes
watch -n 5 'ps aux --sort=-%cpu | head -10'
```

## Network Validation
```bash
# Verify network isolation
netstat -panut | grep ESTABLISHED | grep -v -E ":(22|80|443|53)"

# Check firewall rules are active
iptables -L -n | head -20

# Monitor network connections
watch -n 5 'ss -tulpn | grep LISTEN'
```