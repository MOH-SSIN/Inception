
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

RUN echo "<h1>I LOVE YOU <3 </h1>" > /var/www/html/wlcm.html

CMD ["nginx", "-g", "daemon off;"]
# ENTRYPOINT ["nginx", "-g", "daemon off;"]
