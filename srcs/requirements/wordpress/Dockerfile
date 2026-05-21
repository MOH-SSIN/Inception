FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    wget \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

COPY tools/setup.sh /usr/local/bin/

RUN mkdir -p /var/www/html /run/php && \
    chown www-data:www-data /run/php

RUN chmod +x /usr/local/bin/setup.sh

RUN sed -i 's/listen = \/run\/php\/php8.2-fpm.sock/listen = 0.0.0.0:9000/' /etc/php/8.2/fpm/pool.d/www.conf

EXPOSE 9000

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/setup.sh"]