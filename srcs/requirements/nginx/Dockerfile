openssl \
&& rm -rf /var/lib/apt/lists/*

EXPOSE 443

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=CA/ST=QC/L=Quebec/O=42/OU=42/CN=mez-zahi.42.fr" 

# AJOUTE CETTE LIGNE ICI :

# image_1 [https://localhost:8000/ docker run -it --name web2 -p 8000:443 image_1:latest bash ]
# COPY nginx.conf /etc/nginx/sites-available/default 

# image_2 [https://localhost:4000/ et docker run -it --name web2 -p 4000:443 image_2:latest bash ]
COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN echo "<h1>Hello mez-zahi, Inception Nginx est OK !</h1>" > /var/www/html/index.html

RUN echo "HALO IKRAM, ICH LIEBE DICK <3 </h1>" > /var/www/html/mohcine.html

# une fois ajouter '\' avant CMD il faire une error
CMD ["nginx", "-g", "daemon off;"]
