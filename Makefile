all: up

up:
	mkdir -p /home/mez-zahi/data/mariadb
	mkdir -p /home/mez-zahi/data/wordpress
	docker compose -f srcs/docker-compose.yml up -d --build

down:
	docker compose -f srcs/docker-compose.yml down

fclean:
	docker compose -f srcs/docker-compose.yml down
	docker system prune -af
	sudo rm -rf /home/mez-zahi/data

re: fclean all