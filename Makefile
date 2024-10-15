help:
	@echo ""
	@echo "usage: make COMMAND"
	@echo ""
	@echo "Commands:"
	@echo "  start	      				Start application"
	@echo "  stop	      				Stop application"
	@echo "  connect	      			Connect to php container"
	@echo "  connect_root    			Connect to php container as root"
	@echo "  generate-traefik-cert	  		Generate traefik development certificate"
	@echo "  logs	  	  			Follog container logs"

start:
	docker compose --env-file ./.env.docker -f docker-compose-dev.yml up -d

stop:
	docker compose --env-file ./.env.docker -f docker-compose-dev.yml down

connect:
	docker exec -it test-php-container-dev bash

connect_root:
	docker exec --user root -it test-php-container-dev bash

generate-traefik-cert:
	docker run --rm -v $(shell pwd)/docker/development/ssl:/certificates -e "SERVER=localhost" -e "SUBJECT=/C=CA/ST=Canada/L=Canada/O=IT" jacoelho/generate-certificate

test:
	php -d memory_limit=256M artisan test

logs:
	docker compose logs -f
