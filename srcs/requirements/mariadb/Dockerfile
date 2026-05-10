FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/apt/lists/*

EXPOSE 3306

COPY tools/mariadb.sh /mariadb.sh
RUN chmod +x /mariadb.sh

# On utilise ENTRYPOINT pour que le script soit le processus principal
ENTRYPOINT [ "/mariadb.sh" ]
