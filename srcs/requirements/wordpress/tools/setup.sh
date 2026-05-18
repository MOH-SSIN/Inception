#!/bin/bash

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

until mysql -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1; do
    echo "MariaDB not ready, waiting..."
    sleep 1
done
echo "MariaDB is ready!"

if [ ! -f "/var/www/html/wp-config.php" ]; then

    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp
    chmod +x /usr/local/bin/wp
    cd /var/www/html
    wp core download --allow-root 
    mv wp-config-sample.php wp-config.php
    wp config set DB_NAME "${MYSQL_DATABASE}" --allow-root
    wp config set DB_USER "${MYSQL_USER}" --allow-root
    wp config set DB_PASSWORD "${MYSQL_PASSWORD}" --allow-root
    wp config set DB_HOST "mariadb" --allow-root

    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root

    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root
fi

chown -R www-data:www-data /var/www/html

exec php-fpm8.2 -F