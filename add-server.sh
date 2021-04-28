#!/bin/bash
# get this servers instanceid from cloud-init

REDIS_CLI="redli -u rediss://$REDISUSER:$REDISPW@$REDISURL --certfile=$REDIS_CACERT"
q1="queue"

push="${REDIS_CLI} RPUSH $q1 $1"
echo $push
MSG=$($push)
