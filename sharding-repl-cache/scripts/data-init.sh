#!/bin/bash

###
# Загружаем данные
###
docker exec -i router01 mongosh --host 173.17.0.7 --port 27020 <<EOF

use somedb;

for (var i = 0; i < 1000; i++) db.helloDoc.insert({ age: i, name: "ly" + i });

db.helloDoc.countDocuments();
EOF
