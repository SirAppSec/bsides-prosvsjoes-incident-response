# pfSense back up
Use the pfsenes_backup.sh script or:
```bash
# Download the config.xml file from pfSense
scp admin@100.80.4.30:/cf/conf/config.xml ~/bsides-prosvsjoes-incident-response/FreeBSD/config.xml
scp admin@100.80.4.30:/etc/pf.conf ~/bsides-prosvsjoes-incident-response/FreeBSD/pf.conf
/etc/pf.conf
kp

# Modify the config.xml as needed locally

# Upload the modified config.xml file back to pfSense
jscp ~/bsides-prosvsjoes-incident-response/FreeBSD/config.xml admin@100.80.4.30:/cf/conf/config.xml
scp ~/bsides-prosvsjoes-incident-response/FreeBSD/pf.conf admin@pfsense:/etc/pf.conf

# SSH into the pfSense box and reload the configuration
ssh admin@100.80.4.30
chmod 444 /cf/conf/config.xml
pfSsh.php playback config reload

```
