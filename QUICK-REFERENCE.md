# BSides LV Pros vs Joes - Quick Reference

## Critical First Actions (First 5 Minutes)
```bash
# 1. Change your password immediately
passwd

# 2. Check who's logged in
w
who
last | head -5

# 3. Kill suspicious processes
ps aux | grep -E "(nc|netcat|python.*socket|perl.*socket)" | grep -v grep
pkill -f "nc -l"
killall -9 nc netcat

# 4. Block common reverse shell ports
iptables -I INPUT -p tcp --dport 4444 -j DROP
iptables -I OUTPUT -p tcp --dport 4444 -j DROP

# 5. Save network state
netstat -panut > netstat_$(date +%Y%m%d_%H%M).txt
```

## Essential Commands by Platform

### Linux Host Commands
```bash
# User management
passwd USERNAME
usermod -L USERNAME                    # Lock user
chsh -s /bin/false USERNAME           # Remove shell

# Process management  
ps aux --forest
pkill -f "process_name"
fuser -k PORT/tcp

# Network analysis
ss -tulpn | grep LISTEN
iptables -I INPUT -s MALICIOUS_IP -j DROP

# File permissions
chmod 750 -R /var/www/html
find /var/www -name "*.php" -exec grep -l "eval\|system" {} \;
```

### pfSense Commands
```bash
# Emergency firewall control
pfctl -F all                          # Flush all rules
pfctl -t blocked_ips -T add IP         # Block IP
pfctl -s state | grep IP              # Check connections

# Configuration
scp admin@IP:/cf/conf/config.xml ./    # Backup config
pfSsh.php playback config reload      # Apply changes

# Monitoring
tail -f /var/log/filter.log           # Monitor firewall
tcpdump -i em0 -n host IP             # Traffic analysis
```

## Emergency Response Workflow

### 1. Initial Assessment (2-3 minutes)
- Change passwords
- Check active users
- Save network state
- Identify suspicious processes

### 2. Immediate Containment (5-10 minutes) 
- Kill malicious processes
- Block suspicious IPs
- Lock compromised accounts
- Isolate affected systems

### 3. Eradication (10-15 minutes)
- Remove malicious files
- Close security holes
- Update configurations
- Restart services

### 4. Recovery & Monitoring (Ongoing)
- Restore from clean backups
- Implement monitoring
- Validate service functionality
- Document changes

## Common Threat Indicators
```bash
# Reverse shells
ps aux | grep -E "nc.*-l|python.*socket|perl.*socket"

# Webshells  
find /var/www -name "*.php" -exec grep -l "eval\|base64_decode" {} \;

# Suspicious network
ss -tulpn | grep -E ":(4444|5555|6666|7777|8080|9999|31337)"

# Unauthorized users
grep -v -E "(root|daemon|bin|sys|www-data)" /etc/passwd
```

## Service Recovery Checklist
- [ ] SSH: Update sshd_config, restart service
- [ ] Web: Check for webshells, update passwords
- [ ] Database: Change passwords, remove anonymous users
- [ ] Firewall: Block malicious IPs, update rules
- [ ] System: Update packages, restart services

## Competition-Specific Variables
Replace these placeholders in commands:
- `PFSENSE_IP`: pfSense management IP
- `MALICIOUS_IP`: Attacker IP addresses  
- `USERNAME`: User accounts to modify
- `SCORED_SERVICE`: Services being scored
- `IR_USERNAME`: Your incident response account