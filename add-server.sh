#!/bin/bash
# get this servers instanceid from cloud-init

REDIS_CLI="redli -u rediss://$REDISUSER:$REDISPW@25a8ac71-9f05-4ddf-9768-e5546ab67dbb.bsbaodss0vb4fikkn2bg.private.databases.appdomain.cloud:30129/0 --certfile=/root/da4adf1d-5570-4714-b526-f6d3e202e02e"
q1="queue"

push="${REDIS_CLI} RPUSH $q1 $1"
echo $push
MSG=$($push)
