.PHONY: migrations
migrations:
	docker compose exec air /bin/sh -c "go run migrations/migrations.go"

fixtures:
	docker compose exec air /bin/sh -c "go run seeders/seeders.go"
