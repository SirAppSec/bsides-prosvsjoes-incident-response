
PFSENSE_USER=""
PFSENSE_HOST=""
NEW_PFSENSE_USER=""
NEW_PFSENSE_HOST=""
LOCAL_BACKUP_DIR="/home/$(whoami)/pfsense_backup"
REMOTE_CONFIG_PATH="/cf/conf/config.xml"
REMOTE_ROUTING_RULES_PATH="/cf/conf/rules.xml"
REMOTE_SETTINGS_PATH="/cf/conf/settings.xml"

Functions

show_help() {
echo "Usage: $0 [option]"
echo "Options:"
echo "  -b, --backup               Backup pfSense configuration, routing rules, and settings"
echo "  -r, --restore              Restore pfSense configuration, routing rules, and settings"
echo "  -v, --verify               Verify the backup and restore processes"
echo "  -h, --help                 Show this help message"
}

backup() {
echo "Starting backup process..."

# Ensure the backup directory exists
mkdir -p ${LOCAL_BACKUP_DIR}

# Copy configuration, routing rules, and settings from pfSense to local machine
scp ${PFSENSE_USER}@${PFSENSE_HOST}:${REMOTE_CONFIG_PATH} ${LOCAL_BACKUP_DIR}/config.xml
scp ${PFSENSE_USER}@${PFSENSE_HOST}:${REMOTE_ROUTING_RULES_PATH} ${LOCAL_BACKUP_DIR}/rules.xml
scp ${PFSENSE_USER}@${PFSENSE_HOST}:${REMOTE_SETTINGS_PATH} ${LOCAL_BACKUP_DIR}/settings.xml

if [ $? -eq 0 ]; then
echo "Backup successful. Files saved to ${LOCAL_BACKUP_DIR}"
else
echo "Backup failed."
exit 1
fi
}

restore() {
echo "Starting restore process..."

# Copy configuration, routing rules, and settings from local machine to new pfSense server
scp ${LOCAL_BACKUP_DIR}/config.xml ${NEW_PFSENSE_USER}@${NEW_PFSENSE_HOST}:${REMOTE_CONFIG_PATH}
scp ${LOCAL_BACKUP_DIR}/rules.xml ${NEW_PFSENSE_USER}@${NEW_PFSENSE_HOST}:${REMOTE_ROUTING_RULES_PATH}
scp ${LOCAL_BACKUP_DIR}/settings.xml ${NEW_PFSENSE_USER}@${NEW_PFSENSE_HOST}:${REMOTE_SETTINGS_PATH}

if [ $? -eq 0 ]; then
echo "Restore successful. Files copied to ${NEW_PFSENSE_HOST}"
else
echo "Restore failed."
exit 1
fi

# SSH into the new pfSense server and apply the changes
ssh ${NEW_PFSENSE_USER}@${NEW_PFSENSE_HOST} << 'EOF'
echo "Rebooting pfSense to apply configuration changes..."
# /sbin/reboot
EOF
}

verify() {
echo "Verifying backup and restore..."

# Check if files exist locally
if [ -f "${LOCAL_BACKUP_DIR}/config.xml" ] && [ -f "${LOCAL_BACKUP_DIR}/rules.xml" ] && [ -f "${LOCAL_BACKUP_DIR}/settings.xml" ]; then
echo "Backup files exist locally."
else
echo "Backup files are missing locally."
exit 1
fi

# Check if files exist on the new pfSense server
ssh ${NEW_PFSENSE_USER}@${NEW_PFSENSE_HOST} << 'EOF'
if [ -f "${REMOTE_CONFIG_PATH}" ] && [ -f "${REMOTE_ROUTING_RULES_PATH}" ] && [ -f "${REMOTE_SETTINGS_PATH}" ]; then
echo "Restore files exist on the new pfSense server."
else
echo "Restore files are missing on the new pfSense server."
exit 1
fi
EOF
}

# Main
while [[ "$#" -gt 0 ]]; do
case $1 in
-b|--backup) backup; shift ;;
-r|--restore) restore; shift ;;
-v|--verify) verify; shift ;;
-h|--help) show_help; exit 0 ;;
*) echo "Unknown parameter passed: $1"; show_help; exit 1 ;;
esac
shift
done

if [ "$#" -eq 0 ]; then
show_help
fi
}
}
}
}
