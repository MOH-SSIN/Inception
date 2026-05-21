all: up

up:
	mkdir -p /home/mez-zahi/data/mariadb
	mkdir -p /home/mez-zahi/data/wordpress
	docker compose -f srcs/docker-compose.yml up -d --build

status :
	docker compose -f srcs/docker-compose.yml ps

logs :
	docker compose -f srcs/docker-compose.yml logs

down:
	docker compose -f srcs/docker-compose.yml down

fclean:
	docker compose -f srcs/docker-compose.yml down -v
	docker system prune -af
	sudo rm -rf /home/mez-zahi/data

re: fclean all