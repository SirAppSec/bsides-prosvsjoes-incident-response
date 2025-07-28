# Phase 2: Linux Host Containment & Eradiation

## Emergency Access Control

#### Linux Administration

1. **Change admin password**
   ```sh
      passwd
         ```

2. **Run netstat and save output to a file**
```sh

sudo apt install net-tools -y
sudo netstat -panut > netstat.txt
```

3. **Identify listening services**
```sh
grep LISTEN netstat.txt
```

4. **Identify accounts on scored services**
```sh
ps aux | grep SCORED_SERVICE | grep -v grep
```

5. **Identify dependent services**
```sh
grep ESTABLISHED netstat.txt
```

6. **Identify accounts for dependent services**
```sh
ps aux | grep DEPENDENT_SERVICE | grep -v grep
```

7. **Change passwords for accounts on dependent services**
```sh
passwd ACCOUNT
```

8. **Change passwords for accounts on scored services**
```sh
passwd ACCOUNT
```

9. **Identify accessible accounts**
```sh
sudo grep -v '*' /etc/shadow | grep -v '!' > users-with-logins.txt
```

10. **Change the passwords for all accessible accounts**
```sh
passwd ACCOUNT
```

11. **Remove shell access from service accounts**
```sh
chsh ACCOUNT
# Change shell to /bin/false
```

12. **Fix outages caused by hardening or changes**
```sh
# Access services or use netcat to verify
nc ADDRESS PORT
```

13. **Validate dependent and scored services are still reachable and working**
```sh
# Access services or use netcat to verify
nc ADDRESS PORT
```

#### Web Applications

1. **Identify and document web-apps**
```sh
ls -l /etc/apache2/sites-enabled
ls /etc/nginx/sites-enabled
ls /etc/httpd/conf/vhosts
```

2. **Change admin passwords on web-apps**
```sh
# Login through browser and update password
```

3. **Prevent writes to the web directory**
```sh
chmod 750 -R DIRECTORY
chown root:WEB_GROUP -R DIRECTORY
```

4. **Find and remove webshells**
```sh
# Use your preferred method to scan and remove webshells
```

5. **Update web apps with new database passwords**
```sh
# Update configuration files with new passwords
```

#### Database Management

1. **Identify user accounts on the database server**
```sql
SELECT User,Host,Password FROM mysql.user;
```

2. **Change admin passwords on databases**
```sql
UPDATE mysql.user SET Password=PASSWORD('NEW_PASSWORD') WHERE User='USERNAME';
```

3. **Delete blank (anonymous) accounts and remove remote access**
```sql
DELETE FROM mysql.user WHERE User='';
# Update my.cnf to bind database server to localhost
```

4. **Bind database server to localhost**
```sh
# Edit /etc/mysql/my.cnf
bind-address = 127.0.0.1
```

5. **Remove MySQL remote root access**
```sql
DELETE FROM mysql.user WHERE User='root' AND Host != 'localhost';
```

6. **Restart database service**
```sh
service mysql restart
/etc/init.d/mysql restart
systemctl restart mysqld
```

7. **Dump the database onto the filesystem**
```sh
mysqldump --all-databases -u root -p > databasedump.sql
```

8. **Identify the databases used by web apps**
```sql
SHOW DATABASES;
```

9. **Look at Netstat and identify database/web server relationships**
```sh
netstat -panut
```

10. **Change the password for the web applications that use the database**
```sql
# Update web application configuration files
```

11. **Validate all databases are locked down and accessible to apps**
```sh
# Ensure only necessary applications have access
```

---

## Emergency Process Management
```bash
# Kill all processes by name
pkill -f "malicious_process"
killall -9 nc netcat python perl

# Kill processes by user
pkill -u suspicious_user

# Kill processes on specific ports
fuser -k 4444/tcp
fuser -k 5555/tcp

# Monitor for new processes
watch -n 1 'ps aux --sort=-%cpu | head -10'
```

## Network Isolation
```bash
# Block specific IPs with iptables
iptables -I INPUT -s MALICIOUS_IP -j DROP
iptables -I OUTPUT -d MALICIOUS_IP -j DROP

# Block port ranges
iptables -I INPUT -p tcp --dport 4444:9999 -j DROP
iptables -I OUTPUT -p tcp --dport 4444:9999 -j DROP

# Save iptables rules
iptables-save > /etc/iptables/rules.v4
```

---

**Variables to replace:** IP, PORT, DIRECTORY, SCORED_SERVICE, DEPENDENT_SERVICE, ACCOUNT, ADDRESS, NEW_PASSWORD, USERNAME, WEB_GROUP, MALICIOUS_IP
