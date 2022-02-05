#!/bin/bash
set -e

# Make sure web user's home directory exists
mkdir --parents /srv/quillsigner.io

# Reset web server user's home directory
usermod -d /srv/quillsigner.io quillsigner
chown --recursive quillsigner:quillsigner /srv/quillsigner.io

# Make sure OLS log directory exists
mkdir --parents /var/log/openlitespeed

# Adjust permissions on web server directories
chown --recursive quillsigner:quillsigner /var/log/openlitespeed

# Update the credentials
if [ -n "${OLS_ADMIN_PASSWORD}" ] 
then
	ENCRYPT_PASSWORD="$(/usr/local/lsws/admin/fcgi-bin/admin_php -q '/usr/local/lsws/admin/misc/htpasswd.php' "${OLS_ADMIN_PASSWORD}")"
	echo "${OLS_ADMIN_USERNAME}:${ENCRYPT_PASSWORD}" > '/usr/local/lsws/admin/conf/htpasswd'
	echo "WebAdmin user/password is ${OLS_ADMIN_USERNAME}/${OLS_ADMIN_PASSWORD}" > '/usr/local/lsws/adminpasswd'
fi

# Start Openlitespeed
/usr/local/lsws/bin/lswsctrl start

while true; do
	if ! /usr/local/lsws/bin/lswsctrl status | grep 'litespeed is running with PID *' > /dev/null; then
		break
	fi
	sleep 60
done