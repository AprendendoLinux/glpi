#!/bin/bash

[[ ! "$VERSION" ]] \
	&& VERSION=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/latest | grep tag_name | cut -d '"' -f 4)

if [[ -z "$TIMEZONE" ]]; then echo "O TIMEZONE nao esta definido"; 
	else 
		echo "date.timezone = \"$TIMEZONE\"" > /etc/php/7.4/apache2/conf.d/timezone.ini;
		echo "date.timezone = \"$TIMEZONE\"" > /etc/php/7.4/cli/conf.d/timezone.ini;
		rm /etc/localtime && ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime
fi


if [[ -z "$UPLOAD_MAX_FILESIZE" ]];
then 
		echo "O UPLOAD_MAX_FILESIZE nao esta definido"
		export dbhost=$(cat /var/www/html/config/config_db.php | grep dbhost | awk '{print $4}' | cut -d"'" -f2)
		export dbuser=$(cat /var/www/html/config/config_db.php | grep dbuser | awk '{print $4}' | cut -d"'" -f2)
		export dbpassword=$(cat /var/www/html/config/config_db.php | grep dbpassword | awk '{print $4}' | cut -d"'" -f2)
		export dbdefault=$(cat /var/www/html/config/config_db.php | grep dbdefault | awk '{print $4}' | cut -d"'" -f2)
		mysql -h''$dbhost'' -u''$dbuser'' -p''$dbpassword'' -e "UPDATE $dbdefault.glpi_configs SET value = 2 WHERE glpi_configs.id = 220"

	else
		sed -i "s/2M/$UPLOAD_MAX_FILESIZE/" /etc/php/7.4/apache2/php.ini \
		&& sed -i "s/2M/$UPLOAD_MAX_FILESIZE/" /etc/php/7.4/cli/php.ini \
		&& sed -i "s/2M/$UPLOAD_MAX_FILESIZE/" /usr/lib/php/7.4/php.ini-development \
		&& sed -i "s/2M/$UPLOAD_MAX_FILESIZE/" /usr/lib/php/7.4/php.ini-production \
		&& sed -i "s/2M/$UPLOAD_MAX_FILESIZE/" /usr/lib/php/7.4/php.ini-production.cli \
		&& sed -i "s/2M/$UPLOAD_MAX_FILESIZE/" /usr/lib/php/7.4/php.ini-production.cli
		export dbhost=$(cat /var/www/html/config/config_db.php | grep dbhost | awk '{print $4}' | cut -d"'" -f2)
		export dbuser=$(cat /var/www/html/config/config_db.php | grep dbuser | awk '{print $4}' | cut -d"'" -f2)
		export dbpassword=$(cat /var/www/html/config/config_db.php | grep dbpassword | awk '{print $4}' | cut -d"'" -f2)
		export dbdefault=$(cat /var/www/html/config/config_db.php | grep dbdefault | awk '{print $4}' | cut -d"'" -f2)
		export valor=$(cat /etc/php/7.4/apache2/php.ini | grep max_filesize | awk '{print $3}' | cut -d'M' -f1)
		mysql -h''$dbhost'' -u''$dbuser'' -p''$dbpassword'' -e "UPDATE $dbdefault.glpi_configs SET value = $valor WHERE glpi_configs.id = 220"
fi

if [[ -z "$POST_MAX_FILESIZE" ]]; then echo "O POST_MAX_FILESIZE nao esta definido";
	else
		sed -i "s/post_max_size = 8M/post_max_size = $POST_MAX_FILESIZE/" /etc/php/7.4/apache2/php.ini \
		&& sed -i "s/post_max_size = 8M/post_max_size = $POST_MAX_FILESIZE/" /etc/php/7.4/cli/php.ini \
		&& sed -i "s/post_max_size = 8M/post_max_size = $POST_MAX_FILESIZE/" /usr/lib/php/7.4/php.ini-development \
		&& sed -i "s/post_max_size = 8M/post_max_size = $POST_MAX_FILESIZE/" /usr/lib/php/7.4/php.ini-production \
		&& sed -i "s/post_max_size = 8M/post_max_size = $POST_MAX_FILESIZE/" /usr/lib/php/7.4/php.ini-production.cli \
		&& sed -i "s/post_max_size = 8M/post_max_size = $POST_MAX_FILESIZE/" /usr/lib/php/7.4/php.ini-production.cli
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

## Adicionando regra no crontab para forcar o script php a rodar
echo '*/2 * * * * www-data /usr/bin/php /var/www/html/front/cron.php 2>&- 1>&-' >> /etc/cron.d/glpi

## Subindo o crontrab
service cron start

## Subindo o apache
/usr/sbin/apache2ctl -D FOREGROUND
