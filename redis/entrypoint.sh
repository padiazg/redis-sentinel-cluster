#!/bin/sh
echo "Redis entrypoint"

if [ -f /run/secrets/redis-auth ]; then
	echo "Using password from secret"
	PASS=$(cat /run/secrets/redis-auth)
fi

# We are trying to start a MASTER node
if [ -z ${SLAVE+x} ] && [ -z ${SENTINEL+x} ]; then
	echo "It´s the master"

	sed -i "s/\$PORT/$PORT/g" /redis/redis-master.conf

	if [ -z ${PASS+x} ]; then
    	sed -i "s/requirepass/#requirepass/g" /redis/redis-master.conf
	else
		sed -i "s/\$PASS/$PASS/g" /redis/redis-master.conf
	fi

	## run redis as a master
	redis-server /redis/redis-master.conf
fi

# We are trying to start a SLAVE node
if [ ! -z ${SLAVE+x} ]; then
	echo "It´s a slave"

	sed -i "s/\$PORT/$PORT/g" /redis/redis-slave.conf
	sed -i "s/\$HOST_IP/$HOST_IP/g" /redis/redis-slave.conf
	sed -i "s/\$MASTER_PORT/$MASTER_PORT/g" /redis/redis-slave.conf

	if [ -z ${PASS+x} ]; then
    	sed -i "s/requirepass/#requirepass/g" /redis/redis-slave.conf
    	sed -i "s/masterauth/#masterauth/g" /redis/redis-slave.conf
	else
		sed -i "s/\$PASS/$PASS/g" /redis/redis-slave.conf
	fi

	## run redis as a slave
	redis-server /redis/redis-slave.conf
fi

# We are trying to start a SENTINEL node
if [ ! -z ${SENTINEL+x} ]; then
	echo "It´s a sentinel"

	sed -i "s/\$HOST_IP/$HOST_IP/g" /redis/sentinel.conf
	sed -i "s/\$PORT/$PORT/g" /redis/sentinel.conf
	sed -i "s/\$MASTER_PORT/$MASTER_PORT/g" /redis/sentinel.conf

	sed -i "s/\$SENTINEL_QUORUM/$SENTINEL_QUORUM/g" /redis/sentinel.conf
	sed -i "s/\$SENTINEL_DOWN_AFTER/$SENTINEL_DOWN_AFTER/g" /redis/sentinel.conf
	sed -i "s/\$SENTINEL_FAILOVER/$SENTINEL_FAILOVER/g" /redis/sentinel.conf

	# sed -i "s/\$ANNOUNCE_IP/$ANNOUNCE_IP/g" /redis/sentinel.conf
	# sed -i "s/\$ANNOUNCE_PORT/$ANNOUNCE_PORT/g" /redis/sentinel.conf

	if [ -z ${PASS+x} ]; then
    	sed -i "s/sentinel auth-pass/#sentinel auth-pass/g" /redis/sentinel.conf
	else
		sed -i "s/\$PASS/$PASS/g" /redis/sentinel.conf
	fi

	## run redis as a sentinel
	redis-server /redis/sentinel.conf --sentinel
fi
