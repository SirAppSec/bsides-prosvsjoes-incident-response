# Phase 1: Discovery & Initial Assessment

## Initial System Triage
```bash
# Check current user and privileges
whoami && id

# Check system info
uname -a
cat /etc/os-release

# Check uptime and load
uptime
w

# Check running processes
ps aux --forest
ps aux | grep -E "(nc|netcat|python|perl|bash|sh)" | grep -v grep
```

## Network Discovery
```bash
# Install network tools if missing
sudo apt install net-tools netcat nmap -y

# Check network interfaces
ip addr show
ifconfig -a

# Check routing table
ip route
route -n

# Check active connections
ss -tulpn
netstat -panut > netstat_$(date +%Y%m%d_%H%M).txt

# Check listening services
ss -tulpn | grep LISTEN
```

## User & Access Assessment
```bash
# List all users
cat /etc/passwd | cut -d: -f1

# Users with shell access
grep -E "/bin/(ba)?sh$" /etc/passwd

# Users with passwords set
sudo grep -v '*' /etc/shadow | grep -v '!' | cut -d: -f1

# Check for unauthorized users
cat /etc/passwd | grep -v -E "(root|daemon|bin|sys|sync|games|man|lp|mail|news|uucp|proxy|www-data|backup|list|irc|gnats|nobody|systemd|syslog)"

# Check sudo access
sudo cat /etc/sudoers
sudo cat /etc/sudoers.d/*

# Check SSH authorized keys
find /home -name ".ssh" -exec ls -la {} \; 2>/dev/null
find /home -name "authorized_keys" -exec cat {} \; 2>/dev/null
```

## File System Assessment
```bash
# Check for suspicious files
find / -name "*.php" -type f -exec grep -l "eval\|system\|exec\|shell_exec\|passthru" {} \; 2>/dev/null
find /var/www -name "*.php" -type f -mtime -1 2>/dev/null
find /tmp -type f -executable 2>/dev/null
find /dev/shm -type f 2>/dev/null

# Check for recently modified files
find / -type f -mtime -1 2>/dev/null | grep -v -E "(proc|sys|dev)" | head -20

# Check cron jobs
cat /etc/crontab
ls -la /etc/cron.*
crontab -l
sudo crontab -l
```

## Service Assessment
```bash
# Check enabled services
systemctl list-unit-files --state=enabled
service --status-all

# Check for web servers
ps aux | grep -E "(apache|nginx|httpd)" | grep -v grep
systemctl status apache2 nginx httpd 2>/dev/null

# Check for databases
ps aux | grep -E "(mysql|postgres|mongo)" | grep -v grep
systemctl status mysql postgresql mongodb 2>/dev/null

# Check for SSH service
systemctl status ssh sshd
ps aux | grep sshd | grep -v grep
```

## Log Analysis (Quick Check)
```bash
# Check recent auth logs
sudo tail -50 /var/log/auth.log
sudo tail -50 /var/log/secure

# Check system logs
sudo tail -50 /var/log/syslog
sudo tail -50 /var/log/messages

# Check for failed logins
sudo grep "Failed password" /var/log/auth.log | tail -10
sudo lastb | head -10

# Check successful logins
last | head -10
```

## Red Team Indicator Search
```bash
# Common backdoor ports
ss -tulpn | grep -E ":(4444|5555|6666|7777|8080|9999|31337)"

# Check for common reverse shell patterns
ps aux | grep -E "(nc|ncat|socat|bash.*tcp|python.*socket)" | grep -v grep

# Check for persistence mechanisms
cat /etc/rc.local
ls -la /etc/init.d/
systemctl list-unit-files | grep -v disabled | grep -v static
```