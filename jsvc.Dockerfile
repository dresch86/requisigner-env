FROM ubuntu:focal
LABEL description="A container for running OpenLiteSpeed web server."

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update and install basic packages
RUN apt-get update && apt-get -y install git curl wget nano software-properties-common \
tzdata procps apt-utils unzip

# Install OpenJDK Java
RUN add-apt-repository -y ppa:openjdk-r/ppa && apt-get update \
&& apt-get -y install openjdk-17-jdk

# Install Gradle
RUN wget https://services.gradle.org/distributions/gradle-7.3.3-bin.zip -P /tmp \
&& unzip -d /opt/gradle /tmp/gradle-7.3.3-bin.zip \
&& ln -s /opt/gradle/gradle-7.3.3 /opt/gradle/latest

# Set Gradle Home
ENV GRADLE_HOME=/opt/gradle/latest

# Path to where app service will reside
RUN mkdir -p /opt/quillsigner

# Create user for running commands
RUN useradd -d /opt/quillsigner -s /bin/bash quillsigner

# Setup Docker entry point
COPY jsvc/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x "/docker-entrypoint.sh"

ENTRYPOINT ./docker-entrypoint.sh