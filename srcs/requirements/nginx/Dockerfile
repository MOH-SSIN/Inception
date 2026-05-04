FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    apt-utils \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=CA/ST=QC/L=Quebec/O=42/OU=42/CN=mez-zahi.42.fr"

COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /var/www/html

RUN echo "<html><body><h1>Bienvenue sur mon site Inception</h1></body></html>" > /var/www/html/index.html

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

#regarder le lien de gemini ok https://gemini.google.com/app/b24d02b14a9785fa [je dois comprendre toute les chose ok]
