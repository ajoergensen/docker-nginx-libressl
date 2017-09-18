#!/bin/sh

: ${PUID:=911}
: ${PGID:=911}

if [ ! -z "$PUID" ]
 then
        if [ ! "$(id -u app)" -eq "$PUID" ]; then usermod -o -u "$PUID" app ; fi
fi

if [ ! -z "$PGID" ]
 then
        if [ ! "$(id -g app)" -eq "$PGID" ]; then groupmod -o -g "$PGID" app ; fi
fi

echo "
-----------------------------------
GID/UID
-----------------------------------
User uid:    $(id -u app)
User gid:    $(id -g app)
-----------------------------------
"


# Set worker_processes
: ${WORKER_PROCESSES:="auto"}

grep -q "@@WORKER_PROCESSES@@" /etc/nginx/nginx.conf

if [[ $? -eq 0 ]] && [[ -w /etc/nginx/nginx.conf ]]
 then
	sed -i "s|@@WORKER_PROCESSES@@|$WORKER_PROCESSES|" /etc/nginx/nginx.conf
fi

# chown'ning the entire /var/www may not be desireable

: ${CHOWN_WWWDIR:="TRUE"}

[ -w /var/www ] || CHOWN_WWWDIR="FALSE"

if [[ $CHOWN_WWWDIR == "TRUE" ]]
 then
	chown -R app:app /var/www
fi

# Make sure the app user is able to write to nginx directories
chown -R app:app /var/log/nginx /var/cache/nginx 

exec nginx -g 'daemon off;'
