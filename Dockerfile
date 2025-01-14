FROM debian:12.8
ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt dist-upgrade -y && apt autoremove -y \
	&& apt install --yes --no-install-recommends \
	apache2 \
	php \
	php-mysql \
	php-ldap \
	php-xmlrpc \
	php-imap \
	curl \
	php-curl \
	php-gd \
	php-mbstring \
	php-xml \
	php-apcu \
	php-apcu-all-dev \
	php-cas \
	php-intl \
	php-zip \
	php-bz2 \
	cron \
	wget \
	ca-certificates \
	jq \
	libldap-2.5-0 \
	libldap-common \
	libsasl2-2 \
	libsasl2-modules \
	libsasl2-modules-db

RUN apt-get clean all && \
	rm -rf /var/lib/apt/lists/* && \
	ln -sf /dev/stdout /var/log/apache2/access.log && \
	ln -sf /dev/stderr /var/log/apache2/error.log && \
	sed -i "s/#AddDefaultCharset/AddDefaultCharset/g" /etc/apache2/conf-enabled/charset.conf && \
	echo "ServerSignature Off" >> /etc/apache2/apache2.conf && \
	echo "LoadModule rewrite_module /usr/lib/apache2/modules/mod_rewrite.so" >> /etc/apache2/apache2.conf && \
	rm -f /var/www/html/index.html

COPY glpi.sh change_upload_max_filesize.php default_upload_max_filesize.php /opt/
COPY glpi.conf /etc/apache2/conf-enabled/
RUN chmod +x /opt/glpi.sh

ENV APACHE_LOCK_DIR="/var/lock"
ENV APACHE_PID_FILE="/var/run/apache2.pid"
ENV APACHE_RUN_DIR="/var/run/apache2"
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

WORKDIR /root

ENTRYPOINT ["/opt/glpi.sh"]

EXPOSE 80
VOLUME ["/var/www/html"]
