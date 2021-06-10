#!/bin/bash -e

if [ $$ -eq 1 ] && ! [ -f  ~/.bash_history ]; then
    [ -d ~/.ssh ] || { mkdir ~/.ssh && chmod 0700 ~/.ssh; }
    [  -z "$SYNC_KNOWN_HOTS" ] || echo "$SYNC_KNOWN_HOTS" >> ~/.ssh/known_hosts
    [  -z "$SYNC_PRIVATE_KEY" ] || { echo "$SYNC_PRIVATE_KEY" >> ~/.ssh/id_rsa && chmod 0400 ~/.ssh/id_rsa; }

    cat >> ~/.bash_history <<< """$@"""
    if ! [ -z "$SYNC_SOURCE" ]; then
        C_HOST="${SYNC_SOURCE%%:*}"
        [ "${C_HOST%%@*}" != "$C_HOST" ] && {
            C_USER="${C_HOST%%@*}"
            C_HOST="${C_HOST#*@}"
        }
        CONFIG="$(printf "Host %s\n" "$C_HOST")"
        [ -z "$C_USER" ] || CONFIG="$(printf "%s     User %s\n" "$CONFIG" "$C_USER")"
        [ -z "$SYNC_SOURCE_PORT" ] || CONFIG="$(printf "%s     Port %d\n" "$CONFIG" "$SYNC_SOURCE_PORT")"

        echo "$CONFIG" >> ~/.ssh/config
        cat >> ~/.bash_history <<< """rsync -nv '$SYNC_SOURCE' '${SYNC_TARGET:-/data/}'"""
    fi
fi

if ! [ -z "$PUID" ] && [ "$PUID" != "$(id -u)" ] &&  ! [ -z "$PGID" ] && [ "$PGID" != "$(id -g)" ]; then
    UNAME="rsync"
    id -g "$UNAME" > /dev/null 2>&1 || {
        echo "Creating group '$UNAME' with GID=$PGID"
        groupadd --gid "$PGID" --non-unique "$UNAME"
    }
    id -u "$UNAME" > /dev/null 2>&1 || {
        echo "Creating user '$UNAME' with UID=$PUID"
        useradd --uid "$PUID" --gid "$UNAME" --non-unique --create-home --shell /usr/sbin/nologin "$UNAME"
    }
    exec gosu "$UNAME" "$BASH_SOURCE" "$@"
fi

if [ "$1" == "rsync" ]; then
    OPTS=( "$1" )
    shift
    if ! [ -z "$RSYNC_INCLUDE" ]; then
        echo "$RSYNC_INCLUDE" > ~/.rsync.includes
        OPTS=( "${OPTS[@]}" --includes-from=~/.rsync.includes )
    fi
    if ! [ -z "$RSYNC_EXCLUDE" ]; then
        echo "$RSYNC_EXCLUDE" > ~/.rsync.excludes
        OPTS=( "${OPTS[@]}" --exclude-from=~/.rsync.excludes )
    fi
    set -- "${OPTS[@]}" "$@"
fi

exec "$@"
