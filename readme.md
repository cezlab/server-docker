# Docker Development

## General

| Services      | Version                           |
| ------------- | ----------------------------------|
| MariaDB       | 10                                |
| Apache        | 2.4                               |
| Nginx         | 1.19.1                            |
| PHP - FPM     | 5.6 - 7.1 - 7.2 - 7.3 - 7.4 - 8.0 |
| Redis         | 4                                 |
| Mailhog       |                                   |
| Elasticsearch | 4                                 |
## Tools Requirement

| Name           | Version | URL                                           |
| -------------- | ------- | --------------------------------------------- |
| docker         | latest  | https://docs.docker.com/                      |
| docker-compose | latest  | https://docs.docker.com/compose/              |
| docker-sync    | latest  | https://docker-sync.readthedocs.io/en/latest/ |

## File Configuration

| Services         | Configuration                            |
| :----------------| ---------------------------------------- |
| Apache           | ./.docker/config/apache/default.conf     |
| Nginx            | ./.docker/config/nginx/default.conf      |
| PHP              | ./.docker/config/php/php.ini             |
| Mysql            | ./.docker/config/mysql/config/docker.cnf |
| Docker Sync      | ./docker-sync.yml                        |
| Docker Env       | ./.env                                   |
| Mailhog          | SMTP: 1025 | WEB: 8025                   |
| Redis            | Port: 6379                               |
| Redis-commander  |                                          |



## PHP FPM Ports

| PHP Version | Port Out | Port |
| ----------- | -------- | ---- |
| 5.6         | 9056     | 9000 |
| 7.1         | 9071     | 9000 |
| 7.2         | 9072     | 9000 |
| 7.3         | 9073     | 9000 |
| 7.4         | 9074     | 9000 |
| 8.0         | 9080     | 9000 |
## MARIADB Create Database Dumps

```shell
docker exec mariadb_service sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' > ./database/all-databases.sql
```

## Commands

### Initialize Configuration

```shell
make init 
```

### Destroy Configuration

```shell
make destroy
```

### Running Apache

```shell
make docker-up -e WEB=apache PHP=7.3 PHPMYADMIN=true
```

### Running Nginx

```shell
make docker-up -e PHP=7.3 PHPMYADMIN=true
```

### Running Search

```shell
make docker-up -e PHP=7.3 PHPMYADMIN=true SEARCH=true
```

### Other Commands:

1. destroy
2. volume-list
3. volume-destroy
4. docker-down
5. docker-sync-start
6. docker-sync-list
7. docker-sync-stop
8. docker-sync-clean

## Follow to start

**Here is example for running service with Nginx server and PHP 7.4.**

1. Run command initialize configuration 

```shell
make init 
```

2. Configure "**source-sync**" to Docker Sync (**docker-sync.yml**)

```yaml
version: 2
syncs:
  source-sync:
    src: './source'
    sync_excludes:
      - '.git'
      - '.idea'
      - '.docker'
  database-sync:
    src: './.docker/database'
  ssh-sync:
    src: './.docker/ssh'  
  ssl-sync:
    src: './.docker/config/ssl'
  mysql-init-data-sync:
    src: './.docker/config/mysql/docker-entrypoint-initdb.d'
```

3. Config nginx file on '**./.docker/config/nginx/default.conf**'

```nginx
server {
    listen 80;
    listen  [::]:80;
    index index.php index.html;
    server_name localhost;
    error_log /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/html/source;

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php-fpm:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    location ~ /\.ht {
        deny  all;
    }
}

server {
    listen 443 ssl;
    listen  [::]:443 ssl;
    index index.php index.html;
    server_name localhost;
    ssl_certificate /var/tmp/ssl/certificate.crt;
    ssl_certificate_key /var/tmp/ssl/certificate.key;
    error_log /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/html/source;

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php-fpm:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```

4. Sync data for docker-sync

```shell
make docker-sync-start
```

5. Running services

```shell
make docker-up -e PHP=7.4 PHPMYADMIN=true
```

## Note

### Override Config Docker

```shell
cp docker-compose.override.yml.dist docker-compose.override.yml
```

### Change PHP Version

PHP Version Default 7.2

```shell
make docker-up -e PHP=7.3 
```

