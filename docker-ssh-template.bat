REM DO NOT CHANGE, JUST COPY THIS
docker-compose --env-file ./.env.<PROJECT_NAME> up -d
docker exec -e "TERM=xterm-256color" -it frappe-<PROJECT_NAME> bash