
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

# image_1 [https://localhost:8000/ docker run -it --name web2 -p 8000:443 image_1:latest bash ]
# image_2 [https://localhost:4000/ et docker run -it --name web2 -p 4000:443 image_2:latest bash ]
# COPY conf/nginx.conf /etc/nginx/nginx.conf

# RUN echo "<h1>Hello mez-zahi, Inception Nginx est OK !</h1>" > /var/www/html/index.html

# RUN echo "<h1>HALO IKRAM, ICH LIEBE DICK <3 </h1>" > /var/www/html/mohcine.html

#wakha dartha kib9a itl3e welcome to nginx !!
# RUN rm -rf /var/www/html/index.nginx-debian.html