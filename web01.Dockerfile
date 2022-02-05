FROM ubuntu:focal
LABEL description="A container for running OpenLiteSpeed web server."

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update and install basic packages
RUN apt-get update && apt-get -y install git curl wget nano software-properties-common \
tzdata procps apt-utils unzip

# Install NodeJS
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | /bin/bash - && \
apt-get update && apt-get -y install nodejs

# Point python to python3
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install OpenLiteSpeed
RUN wget -O - http://rpms.litespeedtech.com/debian/enable_lst_debian_repo.sh | /bin/bash \
&& apt-get update && apt-get -y install openlitespeed \
&& apt-get -y install lsphp80 lsphp80-igbinary lsphp80-imagick lsphp80-imap lsphp80-intl \
lsphp80-memcached lsphp80-msgpack lsphp80-mysql lsphp80-opcache lsphp80-pear lsphp80-pspell \
lsphp80-tidy lsphp80-curl php-pear

# Install PHP-FPM for background services
RUN add-apt-repository -y ppa:ondrej/php && apt-get update \
&& apt-get install -y php8.1-cli php8.1-mysql php8.1-xml php8.1-curl php8.1-gd php8.1-imagick \
php8.1-imap php8.1-mbstring php8.1-opcache php8.1-soap php8.1-zip php8.1-msgpack

# Install Composer for PHP
COPY common/composer-installer.sh /composer-installer.sh
RUN chmod +x "/composer-installer.sh" && /composer-installer.sh && mv composer.phar /usr/local/bin/composer

# Remove unnecessary Example vhost
RUN rm -rf /usr/local/lsws/Example

# Create necessary users for lsphp suexec
RUN useradd -M -s /bin/bash quillsigner

# Create Litespeed required directories
RUN mkdir --parents \
	"/tmp/lshttpd/gzcache" \
	"/tmp/lshttpd/pagespeed" \
	"/tmp/lshttpd/stats" \
	"/tmp/lshttpd/swap" \
	"/tmp/lshttpd/upload"

# Fix ownership on OpenLiteSpeed directories
RUN chown --recursive "lsadm:root" "/usr/local/lsws/conf"
RUN chown --recursive "quillsigner:quillsigner" "/tmp/lshttpd"
RUN chown --recursive "quillsigner:quillsigner" "/usr/local/lsws/logs"

# Fix permissions on OpenLiteSpeed
RUN chmod 750 "/usr/local/lsws/conf"

# Setup Docker entry point
COPY web01/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x "/docker-entrypoint.sh"

ENTRYPOINT ./docker-entrypoint.sh

# Setup the health checking
HEALTHCHECK \
	--start-period=15s \
	--interval=1m \
	--timeout=3s \
	--retries=3 \
	CMD /usr/local/lsws/bin/lswsctrl 'status' | grep -Ee '^litespeed is running with PID [0-9]+.$'