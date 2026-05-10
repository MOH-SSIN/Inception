#!/bin/bash

# Démarrer MariaDB en arrière-plan pour la configuration
mysqld_safe --datadir=/var/lib/mysql &

# Attendre que MariaDB soit prêt (on vérifie s'il répond au ping)
until mysqladmin ping -h "127.0.0.1" --silent; do
    echo "Attente de MariaDB..."
    sleep 1
done

# Configuration initiale (seulement si la DB n'existe pas déjà)
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Configuration de la base de données..."

    # 1. Créer la database
    mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"

    # 2. Créer l'utilisateur SQL pour WordPress
    mysql -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

    # 3. Donner les droits
    mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"

fi

echo "MariaDB est prêt et configuré !"

# Arrêter proprement le service temporaire
# mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
mysqladmin shutdown

# Relancer MariaDB au premier plan (pour garder le conteneur ouvert)
# Le bind-address=0.0.0.0 permet aux autres conteneurs de se connecter
exec mysqld_safe --datadir=/var/lib/mysql --bind-address=0.0.0.0