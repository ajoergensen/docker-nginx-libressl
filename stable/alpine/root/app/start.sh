#!/bin/sh

: ${PUID:=911}
: ${PGID:=911}

if [ ! -z "$PUID" ]
 then
        if [ ! "$(id -u nginx)" -eq "$PUID" ]; then usermod -o -u "$PUID" nginx ; fi
fi

if [ ! -z "$PGID" ]
 then
        if [ ! "$(id -g nginx)" -eq "$PGID" ]; then groupmod -o -g "$PGID" nginx ; fi
fi

echo "
-----------------------------------
GID/UID
-----------------------------------
User uid:    $(id -u nginx)
User gid:    $(id -g nginx)
-----------------------------------
"


# Set worker_processes
: ${WORKER_PROCESSES:="auto"}

grep -q "@@WORKER_PROCESSES@@" /etc/nginx/nginx.conf

if [[ $? -eq 0 ]] && [[ -w /etc/nginx/nginx.conf ]]
 then
	sed -i "s|@@WORKER_PROCESSES@@|$WORKER_PROCESSES|" /etc/nginx/nginx.conf

fi

# Set client_max_body_size
: ${NGINX_CLIENT_MAX_BODY_SIZE:="50M"}

grep -q "@@NGINX_CLIENT_MAX_BODY_SIZE@@" /etc/nginx/nginx.conf

if [[ $? -eq 0 ]] && [[ -w /etc/nginx/nginx.conf ]]
 then
        sed -i "s|@@NGINX_CLIENT_MAX_BODY_SIZE@@|$NGINX_CLIENT_MAX_BODY_SIZE|" /etc/nginx/nginx.conf
fi

# chown'ning the entire /var/www may not be desireable

: ${CHOWN_WWWDIR:="TRUE"}

[ -w /var/www ] || CHOWN_WWWDIR="FALSE"

if [[ $CHOWN_WWWDIR == "TRUE" ]]
 then
	chown -R nginx:nginx /var/www
fi

: ${SERVER_TOKENS:="off"}

grep -q "@@SERVER_TOKENS@@" /etc/nginx/nginx.conf

if [[ $? -eq 0 ]] && [[ -w /etc/nginx/nginx.conf ]]
 then
        sed -i "s|@@SERVER_TOKENS@@|$SERVER_TOKENS|" /etc/nginx/nginx.conf
fi

if [[ "x$CUSTOM_SERVER" != "x" ]]
 then
	echo "more_set_headers \"Server: $CUSTOM_SERVER\";" > /etc/nginx/conf.d/custom_server.conf
fi

# Make sure the app user is able to write to nginx directories
chown -R nginx:nginx /var/log/nginx /var/cache/nginx 

exec nginx -g 'daemon off;'
