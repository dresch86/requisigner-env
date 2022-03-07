ARG TIMEZONE
ARG LINUX_USER_PASSWORD

FROM ubuntu:focal
LABEL description="A container for running OpenLiteSpeed web server."

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

# Update and install basic packages
RUN apt-get update && apt-get -y install git curl wget nano software-properties-common \
tzdata procps apt-utils unzip openssh-server supervisor

# Install OpenJDK Java
RUN add-apt-repository -y ppa:openjdk-r/ppa && apt-get update \
&& apt-get -y install openjdk-17-jdk

# Install Gradle
RUN wget https://services.gradle.org/distributions/gradle-7.3.3-bin.zip -P /tmp \
&& unzip -d /opt/gradle /tmp/gradle-7.3.3-bin.zip \
&& ln -s /opt/gradle/gradle-7.3.3 /opt/gradle/latest

# Set Gradle Home
ENV GRADLE_HOME=/opt/gradle/latest
ENV PATH="$PATH:/opt/gradle/latest/bin"

# Path to where app service will reside
RUN mkdir -p /opt/requisigner

# Logs for supervisor
RUN mkdir -p /var/log/supervisor

# Create user for running commands
RUN useradd -d /opt/requisigner -s /bin/bash requisigner && echo "root:Password123!" | chpasswd

# Copy supervisor config file
COPY jsvc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup OpenSSH
RUN mkdir -p /run/sshd
COPY jsvc/sshd_config /etc/ssh/sshd_config

CMD ["/usr/bin/supervisord"]