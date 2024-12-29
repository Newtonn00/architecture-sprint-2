# pymongo-api

## Как запустить

### разворачиваем контейнеры стенда

```shell
docker-compose up -d
```

### инициализируем Mongo: конфигурационный сервер, шарды с репликами и роутер

```shell
./scripts/mongo-init.sh
```

### Заполняем mongodb данными

```shell
./scripts/data-init.sh
```

## Как проверить

### проверка общей работоспособности стенда

Откройте в браузере http://localhost:8080

### запускаем запрос данных коллекции helloDoc
```shell
curl -X GET "http://localhost:8080/helloDoc/users"
```
### проверяем скорость возврата данных с использованием Redis
```shell
curl -o /dev/null -s -w "Time: %{time_total}s\n" -X GET "http://localhost:8080/helloDoc/users"

```