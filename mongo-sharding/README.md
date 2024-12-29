# pymongo-api

## Как запустить

## инициализируем конфигурационный сервер

```shell
docker exec -it configSrv01 mongosh

rs.initiate({
    _id: "config_server",
    configsvr: true,
    members: [
        { _id: 0, host: "173.17.0.10:27017" }
    ]
});

exit();

```

## инициализируем шард №1

```shell
docker exec -it shard01 mongosh --host 173.17.0.9 --port 27018

rs.initiate({
    _id: "shard01",
    members: [
        { _id: 0, host: "173.17.0.9:27018" }
    ]
});

exit();

```
## инициализируем шард №2

```shell

docker exec -it shard02 mongosh --host 173.17.0.8 --port 27019

rs.initiate({
    _id: "shard02",
    members: [
        { _id: 1, host: "173.17.0.8:27019" }
    ]
});

exit();

```

## Инициализируем роутер

```shell
docker exec -it router01 mongosh --host 173.17.0.7 --port 27020 

sh.addShard("shard01/173.17.0.9:27018");
sh.addShard("shard02/173.17.0.8:27019");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name": "hashed" });

```
## Заполняем mongodb данными

```shell
./scripts/mongo-init.sh
```

## Как проверить

### Если вы запускаете проект на локальной машине

Откройте в браузере http://localhost:8080

### Если вы запускаете проект на предоставленной виртуальной машине

Узнать белый ip виртуальной машины

```shell
curl --silent http://ifconfig.me
```

Откройте в браузере http://<ip виртуальной машины>:8080

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://<ip виртуальной машины>:8080/docs