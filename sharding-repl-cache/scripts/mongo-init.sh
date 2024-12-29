#!/bin/bash

# Инициализация config server
CONFIG_CONTAINER_NAME="configSrv01"
CONFIG_HOST="173.17.0.10:27017"

CONFIG_INIT=$(cat <<EOF
rs.initiate({
    _id: "config_server",
    configsvr: true,
    members: [
        { _id: 0, host: "$CONFIG_HOST" }
    ]
});
EOF
)

echo "Initializing Config Server Replica Set..."
docker exec -it $CONFIG_CONTAINER_NAME mongosh --eval "$CONFIG_INIT"
echo "Config Server Replica Set initialized successfully."

# Инициализация shard01
SHARD01_CONTAINER_NAME="shard01-01"
SHARD01_HOST_0="173.17.0.9:27018"
SHARD01_HOST_1="173.17.0.11:27021"
SHARD01_HOST_2="173.17.0.12:27022"

SHARD01_INIT=$(cat <<EOF
rs.initiate({
    _id: "shard01",
    members: [
        { _id: 0, host: "$SHARD01_HOST_0" },
        { _id: 1, host: "$SHARD01_HOST_1" },
        { _id: 2, host: "$SHARD01_HOST_2" }
    ]
});
EOF
)

echo "Initializing Shard01 Replica Set..."
docker exec -it $SHARD01_CONTAINER_NAME mongosh --host 173.17.0.9 --port 27018 --eval "$SHARD01_INIT"
echo "Shard01 Replica Set initialized successfully."

# Инициализация shard02
SHARD02_CONTAINER_NAME="shard02-01"
SHARD02_HOST_0="173.17.0.8:27019"
SHARD02_HOST_1="173.17.0.13:27023"
SHARD02_HOST_2="173.17.0.14:27024"

SHARD02_INIT=$(cat <<EOF
rs.initiate({
    _id: "shard02",
    members: [
        { _id: 0, host: "$SHARD02_HOST_0" },
        { _id: 1, host: "$SHARD02_HOST_1" },
        { _id: 2, host: "$SHARD02_HOST_2" }
    ]
});
EOF
)

echo "Initializing Shard02 Replica Set..."
docker exec -it $SHARD02_CONTAINER_NAME mongosh --host 173.17.0.8 --port 27019 --eval "$SHARD02_INIT"
echo "Shard02 Replica Set initialized successfully."

echo "Router setup is starting..."
sleep 10

# Настройка router01
ROUTER_CONTAINER_NAME="router01"
ROUTER_HOST="173.17.0.7"
ROUTER_PORT="27020"

echo "Configuring Router01..."
docker exec -i $ROUTER_CONTAINER_NAME mongosh --host $ROUTER_HOST --port $ROUTER_PORT <<EOF
sh.addShard("shard01/173.17.0.9:27018");
sh.addShard("shard02/173.17.0.8:27019");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name": "hashed" });
EOF
echo "Router01 configured successfully."

echo "All MongoDB replica sets and sharding configured!"
