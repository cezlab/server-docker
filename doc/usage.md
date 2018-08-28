# USAGE

## Initialize Configuration

```shell
make init 
```

## Destroy Configuration

```shell
make destroy
```

## Running Apache

```shell
make docker-up -e WEB=apache PHP=7.3 PHPMYADMIN=true
```

## Running Nginx

```shell
make docker-up -e PHP=7.3 PHPMYADMIN=true
```

## Running Search

```shell
make docker-up -e PHP=7.3 PHPMYADMIN=true SEARCH=true
```

## Other Commands:

1. destroy
2. volume-list
3. volume-destroy
4. docker-down
5. docker-sync-start
6. docker-sync-list
7. docker-sync-stop
8. docker-sync-clean