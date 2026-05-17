
FROM debian:bookworm

RUN apt-get update && apt-get install -y \
nginx \
openssl \
&& rm -rf /var/lib/apt/lists/*

EXPOSE 443

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=CA/ST=QC/L=Quebec/O=42/OU=42/CN=mez-zahi.42.fr" 

RUN rm -f /etc/nginx/sites-enabled/default

COPY conf/nginx.conf /etc/nginx/sites-available/default 

RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

CMD ["nginx", "-g", "daemon off;"]
