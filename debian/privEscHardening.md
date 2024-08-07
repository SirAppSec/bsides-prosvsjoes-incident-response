
w are the detailed commands to harden a Debian/Linux system and disable privilege escalation based on your requirements. This guide assumes you have root or sudo access to perform these actions.

### Step-by-Step Guide
 #### 0. run PEAS linux
https://github.com/peass-ng/PEASS-ng/blob/master/linPEAS/README.md
```sh
curl -L https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh | sh
```

#### 1. Ensure All Other Users' PPIDs Are Not Root (Except "ir")

To ensure that all other users' parent process IDs are not root, you will need to check the running processes and kill those that don't belong to "ir".

```sh
# List processes and filter out those with root PPID, excluding the user "ir"

sudo ps -eo user,ppid,pid,cmd | grep -v "ir" | awk '$2==1 {print $3}' | xargs -r kill
```

#### 2. Remove Root User Permissions from /var/mail/root and /var/spool/mail/root

```sh
# Remove root user permissions
sudo chown ir:ir /var/mail/root /var/spool/mail/root
sudo chmod 600 /var/mail/root /var/spool/mail/root
```

#### 3. Remove All .profile or .bashrc Files Not in /home/ir/

```sh
# Find and remove .profile and .bashrc files not in /home/ir/
sudo find / -type f \( -name ".profile" -o -name ".bashrc" \) ! -path "/home/ir/*" -exec rm -f {} \;
```

#### 4. Remove All Options to Use ssh_config

To enforce the use of `sshd_config` only, you need to remove any additional configuration files:

```sh
# Remove all files in ssh_config.d
sudo rm -f /etc/ssh/ssh_config.d/*.conf

# Ensure only sshd_config is used
sudo echo "Include /etc/ssh/sshd_config" > /etc/ssh/ssh_config
```

#### 5. Remove All Files Ending in .pub

```sh
# Find and remove all .pub files
sudo find / -type f -name "*.pub" -exec rm -f {} \;
```

#### 6. Add a Cron Job to Remove Every User That Is Not "ir" from TTY Logons

Create a cron job to enforce this periodically:

```sh
# Open crontab for editing
crontab -e

# Add the following line to the crontab
* * * * * /usr/bin/env bash -c 'for user in $(who | awk '\''{print $1}'\''); do if [[ "$user" != "ir" ]]; then pkill -KILL -u "$user"; fi; done'
```

#### 7. Change the Shell to /bin/false for Every User Except "ir"
prepare the ability by disabling password prompt for sudoers:
```sh

sudo visudo

ir ALL=(ALL) NOPASSWD: ALL
```
```sh
sudo bash -c 'for user in $(awk -F: "{if (\$1 != \"ir\" && \$7 != \"/bin/false\") print \$1}" /etc/passwd); do chsh -s /bin/false $user; done'
```
```sh
# Change shell to /bin/false for every user except "ir"

for user in $(awk -F: '{if ($1 != "ir" && $7 != "/bin/false") print $1}' /etc/passwd); do
  sudo chsh -s /bin/false $user

done
```

