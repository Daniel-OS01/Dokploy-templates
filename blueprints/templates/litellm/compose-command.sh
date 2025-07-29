export MAIN_DOMAIN="litellm.example.com" POSTGRES_PASSWORD="$(openssl rand -base64 24)" && docker compose --file docker-compose.yml config && docker compose up -d && docker compose ps
