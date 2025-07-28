# pfSense Emergency Response Commands

## Configuration Backup & Restore
```bash
# Download current config from pfSense
scp admin@PFSENSE_IP:/cf/conf/config.xml ~/bsides-prosvsjoes-incident-response/FreeBSD/config-current.xml

# Download firewall rules
scp admin@PFSENSE_IP:/etc/pf.conf ~/bsides-prosvsjoes-incident-response/FreeBSD/pf.conf

# Upload hardened config to pfSense
scp ~/bsides-prosvsjoes-incident-response/FreeBSD/config-hardened.xml admin@PFSENSE_IP:/cf/conf/config.xml

# SSH into pfSense and apply changes
ssh admin@PFSENSE_IP
chmod 444 /cf/conf/config.xml
pfSsh.php playback config reload
```

## Emergency Firewall Commands (on pfSense console)
```bash
# Block all traffic immediately
pfctl -e
pfctl -F all
pfctl -f /dev/null

# Block specific IP addresses
pfctl -t blocked_ips -T add MALICIOUS_IP
echo "table <blocked_ips> { MALICIOUS_IP }" >> /etc/pf.conf
echo "block in quick from <blocked_ips>" >> /etc/pf.conf
pfctl -f /etc/pf.conf

# Enable logging for all blocked traffic
pfctl -e -f /etc/pf.conf -v

# View active states and connections
pfctl -s state
pfctl -s state | grep MALICIOUS_IP

# Monitor real-time traffic
tcpdump -i em0 -n host SUSPICIOUS_IP
```

## System Status & Monitoring
```bash
# Check pfSense system status
pfSsh.php playback showstatus

# View system information
pfSsh.php playback showsystem

# Check interface status
pfctl -s interfaces

# View routing table
netstat -rn

# Check active connections
sockstat -4 -l
```

## Log Analysis
```bash
# Monitor firewall logs in real-time
tail -f /var/log/filter.log

# Search for specific IP in logs
grep "MALICIOUS_IP" /var/log/filter.log

# View blocked connections
grep "block" /var/log/filter.log | tail -20

# Check system logs
tail -f /var/log/system.log
```

## User & Access Control
```bash
# Change admin password (via console)
passwd

# Check logged-in users
who
w

# View SSH login attempts
grep "ssh" /var/log/auth.log

# Disable SSH access temporarily
pfSsh.php playback exec "killall sshd"
```

## Network Interface Management
```bash
# Show interface configuration
ifconfig

# Disable interface temporarily
ifconfig em1 down

# Enable interface
ifconfig em1 up

# Reset interface
ifconfig em1 down && ifconfig em1 up

# Check interface statistics
netstat -i
```

## Emergency Recovery Commands
```bash
# Restore from backup config
cp /cf/conf/config.xml /cf/conf/config.xml.backup
cp ~/config-backup.xml /cf/conf/config.xml
pfSsh.php playback config reload

# Factory reset (DANGER - last resort)
# rm /cf/conf/config.xml
# reboot

# Reboot system
shutdown -r now

# Emergency shell access
pfSsh.php
```

## Traffic Analysis
```bash
# Monitor bandwidth usage
pfSsh.php playback exec "top -d1"

# View connection states by protocol
pfctl -s state | awk '{print $3}' | sort | uniq -c

# Monitor specific port
tcpdump -i em0 port 80

# Check for suspicious outbound connections
pfctl -s state | grep -E "(4444|5555|6666|7777|8080|9999|31337)"
```
