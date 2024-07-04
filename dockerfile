# Use the official MariaDB image as the base image
FROM mariadb:latest


ENV MYSQL_ROOT_PASSWORD=root
ENV MYSQL_DATABASE=mariadb
ENV MYSQL_USER=1234
ENV MYSQL_PASSWORD=1234

# install mysql client
RUN apt-get update && apt-get install -y mariadb-client

COPY ./data/data.sql /docker-entrypoint-initdb.d/

EXPOSE 3306