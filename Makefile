.PHONY: up
up:
	docker-compose up -d

.PHONY: down
down:
	docker-compose down

restart:
	docker-compose restart

client:
	docker exec -it clickhouse-blue-1 clickhouse-client

logs:
	docker logs -f clickhouse-blue-1 --tail=1000

ps:
	docker-compose ps
	
.PHONY: keeper-check
keeper-check:
	echo ruok | nc 127.0.0.1 9181
	@printf "\n"
	echo ruok | nc 127.0.0.2 9181
	@printf "\n"
	echo ruok | nc 127.0.0.3 9181
	@printf "\n"
	echo ruok | nc 127.0.0.4 9181
	@printf "\n"

