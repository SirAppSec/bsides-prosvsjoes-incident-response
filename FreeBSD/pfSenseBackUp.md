# pfSense back up
Use the pfsenes_backup.sh script or:
```bash
# Download the config.xml file from pfSense
scp admin@pfsense:/cf/conf/config.xml /path/to/backup/config.xml

# Modify the config.xml as needed locally

# Upload the modified config.xml file back to pfSense
scp /path/to/backup/config.xml admin@pfsense:/cf/conf/config.xml

# SSH into the pfSense box and reload the configuration
ssh admin@pfsense
pfSsh.php playback config reload
```
