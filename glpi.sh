#!/bin/bash

[[ ! "$VERSION" ]] \
	&& VERSION=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/latest | grep tag_name | cut -d '"' -f 4)

if [[ -z "$TIMEZONE" ]]; then echo "O TIMEZONE nao esta definido"; 
	else 
		echo "date.timezone = \"$TIMEZONE\"" > /etc/php/8.2/apache2/conf.d/timezone.ini;
		echo "date.timezone = \"$TIMEZONE\"" > /etc/php/8.2/cli/conf.d/timezone.ini;
		rm /etc/localtime && ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime
fi

if [[ -z "$UPLOAD_MAX_FILESIZE" ]];
then 
		sleep 2 && php /opt/default_upload_max_filesize.php

	else
		sed -i "s/2M/$UPLOAD_MAX_FILESIZE/" /etc/php/8.2/apache2/php.ini \
		&& sed -i "s/2M/$UPLOAD_MAX_FILESIZE/" /etc/php/8.2/cli/php.ini \
		&& sed -i "s/2M/$UPLOAD_MAX_FILESIZE/" /usr/lib/php/8.2/php.ini-development \
		&& sed -i "s/2M/$UPLOAD_MAX_FILESIZE/" /usr/lib/php/8.2/php.ini-production \
		&& sed -i "s/2M/$UPLOAD_MAX_FILESIZE/" /usr/lib/php/8.2/php.ini-production.cli 
		sleep 2 && php /opt/change_upload_max_filesize.php
fi

if [[ -z "$POST_MAX_FILESIZE" ]]; then echo "O POST_MAX_FILESIZE nao esta definido";
	else
		sed -i "s/post_max_size = 8M/post_max_size = $POST_MAX_FILESIZE/" /etc/php/8.2/apache2/php.ini \
		&& sed -i "s/post_max_size = 8M/post_max_size = $POST_MAX_FILESIZE/" /etc/php/8.2/cli/php.ini \
		&& sed -i "s/post_max_size = 8M/post_max_size = $POST_MAX_FILESIZE/" /usr/lib/php/8.2/php.ini-development \
		&& sed -i "s/post_max_size = 8M/post_max_size = $POST_MAX_FILESIZE/" /usr/lib/php/8.2/php.ini-production \
		&& sed -i "s/post_max_size = 8M/post_max_size = $POST_MAX_FILESIZE/" /usr/lib/php/8.2/php.ini-production.cli
fi

LINK_GLPI=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/tags/$VERSION | jq .assets[0].browser_download_url | tr -d \")

## Ajustando TLS LDAP
if !(grep -q "TLS_REQCERT" /etc/ldap/ldap.conf)
then
    echo -e "TLS_REQCERT\tnever" >> /etc/ldap/ldap.conf
fi

## Extraindo o instalador do GLPI
if [ -z "$(ls -A /var/www/html)" ]; then
	wget -q $LINK_GLPI --output-document=/tmp/glpi.tar.gz
	tar -zxf /tmp/glpi.tar.gz -C /tmp
	mv /tmp/glpi/{.[!.],}* /var/www/html/
	rm -rf /tmp/glp*
	chown -R www-data:www-data /var/www/html/
else
	echo "O GLPI ja se encontra instalado"
fi

echo "session.cookie_httponly = On" >> /etc/php/8.2/apache2/php.ini
echo "session.cookie_httponly = On" >> /etc/php/8.2/cli/php.ini
echo "session.cookie_httponly = On" >> /usr/lib/php/8.2/php.ini-development
echo "session.cookie_httponly = On" >> /usr/lib/php/8.2/php.ini-production
echo "session.cookie_httponly = On" >> /usr/lib/php/8.2/php.ini-production.cli

## Adicionando regra no crontab para forcar o script php a rodar
echo '*/2 * * * * www-data /usr/bin/php /var/www/html/front/cron.php 2>&- 1>&-' >> /etc/cron.d/glpi

## Subindo o crontrab
service cron start

## Subindo o apache
/usr/sbin/apache2ctl -D FOREGROUND
