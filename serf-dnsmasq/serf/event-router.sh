#!/bin/sh
HANDLER_DIR="/etc/serf/handlers"

if [ "$SERF_EVENT" = "user" ]; then
    EVENT="user-$SERF_USER_EVENT"
elif [ "$SERF_EVENT" = "query" ]; then
    EVENT="query-$SERF_QUERY_NAME"
else
    EVENT=$SERF_EVENT
fi

HANDLER="$HANDLER_DIR/$EVENT"
[ -f "$HANDLER" -a -x "$HANDLER" ] && exec "$HANDLER" || :
