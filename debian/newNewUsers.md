tep-by-Step Guide to Remove the Ability to Add Users
1. Disable the systemd-sysusers.service

First, disable the systemd-sysusers.service to prevent it from running.

sh

sudo systemctl disable systemd-sysusers.service
sudo systemctl stop systemd-sysusers.service

2. Edit the systemd-sysusers.service File

Remove or comment out the suspicious LoadCredential lines in the systemd-sysusers.service file.

sh

sudo nano /lib/systemd/system/systemd-sysusers.service

Locate the lines that contain LoadCredential and comment them out by adding a # at the beginning of each line:

plaintext

# LoadCredential=passwd.hashed-password.root
# LoadCredential=passwd.plaintext-password.root
# LoadCredential=passwd.shell.root

Save and exit the editor (CTRL+O, ENTER, CTRL+X for nano).
3. Reload Systemd Configuration

After making changes to the service file, reload the systemd configuration to apply the changes.

sh

sudo systemctl daemon-reload

4. Verify the Service is Disabled

Ensure that the service is no longer active and has been disabled.

sh

sudo systemctl status systemd-sysusers.service

The output should show that the service is inactive and disabled.
Additional Security Measures

    Audit User Management Commands:
    To further secure the system, you can audit commands that add or modify users. Install and configure auditd.

    sh

sudo apt-get install auditd -y
sudo systemctl enable auditd
sudo systemctl start auditd

Add rules to audit useradd, usermod, and passwd commands.

sh

sudo auditctl -a always,exit -F arch=b64 -S execve -F exe=/usr/sbin/useradd -k useradd
sudo auditctl -a always,exit -F arch=b64 -S execve -F exe=/usr/sbin/usermod -k usermod
sudo auditctl -a always,exit -F arch=b64 -S execve -F exe=/usr/bin/passwd -k passwd

Check the audit logs regularly:

sh

sudo ausearch -k useradd
sudo ausearch -k usermod
sudo ausearch -k passwd

Restrict Access to User Management Binaries:

Change the permissions of the binaries to restrict access.

sh

sudo chmod 750 /usr/sbin/useradd
sudo chmod 750 /usr/sbin/usermod
sudo chmod 750 /usr/bin/passwd

Remove Unnecessary Sudo Privileges:

Ensure that only necessary accounts have sudo privileges.

sh

sudo visudo

Remove any unnecessary users or groups from the sudoers file.

Monitor and Secure Sensitive Files:

Set up monitoring for changes to sensitive files.

sh

    sudo apt-get install inotify-tools -y
    sudo inotifywait -m /etc/passwd /etc/shadow /etc/group /etc/gshadow

    This will alert you to any changes made to these files in real-time.
