#!/bin/bash
# get this servers instanceid from cloud-init

REDIS_CLI="redli -u rediss://$REDISUSER:$REDISPW@$REDISURL --certfile=/root/da4adf1d-5570-4714-b526-f6d3e202e02e"
q1="queue"

push="${REDIS_CLI} RPUSH $q1 $1"
echo $push
MSG=$($push)
