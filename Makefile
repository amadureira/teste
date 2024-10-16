DJANGO_PROJECT=deploy-prod
POSTGRES_DATA_PATh=/opt/postgres/data
POSTGRES_VOLUME=db-volume
DJANGO_VOLUME=app-volume
APP_CONTAINER_NAME="django2"
DB_CONTAINER_NAME="postgres2"

deploy-prod: up

up: volume script run

volume:
	docker volume create ${POSTGRES_VOLUME}
	docker volume create ${DJANGO_VOLUME}
script:
	echo '#!/bin/bash'>  /tmp/start.sh
	echo 'django-admin startproject hellloworld' >>  /tmp/start.sh
	echo 'cd /opt/helloworld/app/hellloworld' >>  /tmp/start.sh
	echo '/usr/local/bin/python3 manage.py runserver 0.0.0.0:8081' >>  /tmp/start.sh
	
${python_bin} manage.py runserver 0.0.0.0:8080

run:
	docker  run --rm -itd -p 8081:8081 -v /tmp/start.sh:/tmp/start.sh -v ${DJANGO_VOLUME}:/opt/helloworld/app  \
		--name=${APP_CONTAINER_NAME} django:latest  bash /tmp/start.sh
	docker  run --rm -itd -p 5433:5432 -v ${POSTGRES_VOLUME}:/opt/postgres/data -e POSTGRES_PASSWORD=postgres -e  PGDATA=/opt/postgres/data --name=${DB_CONTAINER_NAME} postgres:latest
clean: down
	docker volume rm  app-volume
	docker volume rm  db-volume
down:
	docker kill ${APP_CONTAINER_NAME}
	docker kill ${DB_CONTAINER_NAME} 
