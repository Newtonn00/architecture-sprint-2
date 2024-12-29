#!/bin/bash

###
# Инициализируем конфигурационный сервер
###
docker exec -it configSrv01 mongosh --eval "
if (!rs.status().ok) {
    rs.initiate({
        _id: 'config_server',
        configsvr: true,
        members: [
            { _id: 0, host: '173.17.0.10:27017' }
        ]
    });
} else {
    print('config_server уже инициализирован.');
}
"
sleep 5

###
# Инициализируем shard01
###
docker exec -i shard01 mongosh <<EOF
if (!rs.status().ok) {
    rs.initiate({
        _id: "shard01",
        members: [
            { _id: 0, host: "173.17.0.9:27018" }
        ]
    });
} else {
    print("shard01 уже инициализирован.");
}
EOF

sleep 5

###
# Инициализируем shard02
###
docker exec -i shard02 mongosh --host 173.17.0.8 --port 27019 <<EOF
if (!rs.status().ok) {
    rs.initiate({
        _id: "shard02",
        members: [
            { _id: 1, host: "173.17.0.8:27019" }
        ]
    });
} else {
    print("shard02 уже инициализирован.");
}
EOF

sleep 5

###
# Инициализируем роутер
###
docker exec -i router01 mongosh --host 173.17.0.7 --port 27020 <<EOF
sh.addShard("shard01/173.17.0.9:27018");
sh.addShard("shard02/173.17.0.8:27019");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name": "hashed" });

use somedb;

for (var i = 0; i < 1000; i++) db.helloDoc.insert({ age: i, name: "ly" + i });

db.helloDoc.countDocuments();
EOF
