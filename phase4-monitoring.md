# Phase 4: Monitoring & Prevention

## Continuous Monitoring Setup
```bash
# Monitor active connections
watch -n 5 'ss -tulpn | grep LISTEN'

# Monitor process activity
watch -n 5 'ps aux --sort=-%cpu | head -10'

# Monitor failed login attempts
watch -n 10 'tail -5 /var/log/auth.log | grep "Failed password"'

# Monitor file changes in web directory
inotifywait -m /var/www/html -e create,modify,delete --format '%w%f %e %T' --timefmt '%Y-%m-%d %H:%M:%S'
```

## Log Monitoring
```bash
# Set up real-time log monitoring
tail -f /var/log/auth.log | grep --line-buffered "Failed password\|Invalid user"
tail -f /var/log/apache2/access.log | grep --line-buffered -E "(POST|PUT|\.php)"

# Monitor system logs for anomalies
journalctl -f | grep -E "(error|fail|denied|invalid)"

# Check for new user creation
tail -f /var/log/auth.log | grep --line-buffered "new user"
```

## Network Monitoring
```bash
# Monitor network connections
watch -n 5 'netstat -panut | grep ESTABLISHED | wc -l'

# Monitor for suspicious outbound connections
netstat -panut | grep ESTABLISHED | grep -v -E "(80|443|53|22)"

# Monitor bandwidth usage
iftop -i eth0
nethogs

# Monitor for port scans
tcpdump -i any -nn 'tcp[tcpflags] & (tcp-syn) != 0 and tcp[tcpflags] & (tcp-ack) = 0'
```

## File Integrity Monitoring
```bash
# Create baseline of critical files
find /etc /var/www /usr/local -type f -exec md5sum {} \; > /tmp/baseline.md5

# Check for changes
find /etc /var/www /usr/local -type f -exec md5sum {} \; > /tmp/current.md5
diff /tmp/baseline.md5 /tmp/current.md5

# Monitor web directory for changes
find /var/www -newer /tmp/webdir_baseline -type f 2>/dev/null

# Set up AIDE (Advanced Intrusion Detection Environment)
apt install aide -y
aideinit
mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
aide --check
```

## Process Monitoring
```bash
# Monitor for suspicious processes
ps aux | grep -E "(nc|netcat|python.*socket|perl.*socket|bash.*tcp)" | grep -v grep

# Monitor for privilege escalation attempts
ps aux | grep -E "(sudo|su|pkexec)" | grep -v grep

# Check for processes running as different users
ps -eo pid,user,cmd | grep -v "^[[:space:]]*[0-9]*[[:space:]]*root"
```

## Service Health Monitoring
```bash
# Check critical service status
for service in ssh apache2 mysql; do
    systemctl is-active $service || echo "$service is DOWN"
done

# Monitor resource usage
top -bn1 | head -5
df -h
free -h

# Monitor disk I/O
iostat -x 1 3
```

## Automated Alerting Scripts
```bash
# Create monitoring script
cat > /usr/local/bin/security_monitor.sh << 'EOF'
#!/bin/bash
LOG_FILE="/var/log/security_monitor.log"

# Check for failed logins
FAILED_LOGINS=$(grep "Failed password" /var/log/auth.log | wc -l)
if [ $FAILED_LOGINS -gt 10 ]; then
    echo "$(date): High number of failed logins: $FAILED_LOGINS" >> $LOG_FILE
fi

# Check for new users
NEW_USERS=$(find /home -maxdepth 1 -type d -newer /tmp/user_baseline 2>/dev/null | wc -l)
if [ $NEW_USERS -gt 0 ]; then
    echo "$(date): New user directories detected" >> $LOG_FILE
fi

# Check for suspicious processes
SUSPICIOUS_PROCS=$(ps aux | grep -E "(nc|netcat|python.*socket)" | grep -v grep | wc -l)
if [ $SUSPICIOUS_PROCS -gt 0 ]; then
    echo "$(date): Suspicious processes detected" >> $LOG_FILE
fi
EOF

chmod +x /usr/local/bin/security_monitor.sh

# Add to crontab to run every 5 minutes
echo "*/5 * * * * /usr/local/bin/security_monitor.sh" | crontab -
```

## pfSense Monitoring
```bash
# Monitor pfSense logs (run on pfSense box)
tail -f /var/log/filter.log | grep -E "(BLOCK|DROP)"

# Check pfSense status
pfSsh.php playback showstatus

# Monitor active states
pfctl -s state | wc -l

# Check firewall rules
pfctl -sr
```

## Incident Response Preparation
```bash
# Create incident response directory
mkdir -p /opt/ir/{logs,tools,evidence}

# Collect system state
ps aux > /opt/ir/evidence/processes_$(date +%Y%m%d_%H%M).txt
netstat -panut > /opt/ir/evidence/network_$(date +%Y%m%d_%H%M).txt
ls -la /tmp > /opt/ir/evidence/tmp_files_$(date +%Y%m%d_%H%M).txt

# Set up log rotation for monitoring
cat > /etc/logrotate.d/security_monitor << 'EOF'
/var/log/security_monitor.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
}
EOF
```

## Quick Threat Hunting
```bash
# Search for indicators of compromise
grep -r "eval(" /var/www/ 2>/dev/null
grep -r "base64_decode" /var/www/ 2>/dev/null
grep -r "system(" /var/www/ 2>/dev/null

# Check for unusual network activity
ss -tulpn | grep -E ":(4444|5555|6666|7777|8080|9999|31337)"

# Look for persistence mechanisms
find /etc -name "*rc*" -exec grep -l "unusual_command" {} \; 2>/dev/null
systemctl list-unit-files | grep enabled | grep -v "systemd\|dbus\|network"
```