#!/bin/bash

# Graceful shutdown, used by trapping SIGTERM
function graceful_shutdown {
  echo -n "Stopping unifi-protect... "
  if pkill node; then
    /usr/bin/pg_ctlcluster --skip-systemctl-redirect -m fast 10-main stop
    # Post stop
    /usr/share/unifi-protect/app/hooks/post-stop
    echo "done."
    exit 0
  else
    echo "failed."
    exit 1
  fi
}

# Trap SIGTERM for graceful exit
trap graceful_shutdown SIGTERM

# Change user nobody's UID to custom or match unRAID.
export PUID
PUID=$(echo "${PUID}" | sed -e 's/^[ \t]*//')
if [[ -n "${PUID}" ]]; then
  echo "[info] PUID defined as '${PUID}'" | ts '%Y-%m-%d %H:%M:%.S'
else
  echo "[warn] PUID not defined (via -e PUID), defaulting to '99'" | ts '%Y-%m-%d %H:%M:%.S'
  export PUID="999"
fi

# Set user unify-video to specified user id (non unique)
usermod -o -u "${PUID}" unifi-protect &>/dev/null

# Change group users to GID to custom or match unRAID.
export PGID
PGID=$(echo "${PGID}" | sed -e 's/^[ \t]*//')
if [[ -n "${PGID}" ]]; then
  echo "[info] PGID defined as '${PGID}'" | ts '%Y-%m-%d %H:%M:%.S'
else
  echo "[warn] PGID not defined (via -e PGID), defaulting to '100'" | ts '%Y-%m-%d %H:%M:%.S'
  export PGID="999"
fi

# Set group users to specified group id (non unique)
groupmod -o -g "${PGID}" unifi-protect &>/dev/null

# Environment variables
export $(grep -v '^#' /etc/default/unifi-protect | xargs)

UFP_BACKUPS_DIR=/etc/unifi-protect/backups
UFP_DATADIR=/srv/unifi-protect
UFP_TMPFS_DIR=/srv/unifi-protect/temp
UFP_TMPFS_SIZE=256m
MALLOC_ARENA_MAX=1
MALLOC_MMAP_THRESHOLD_=8192
MALLOC_TRIM_THRESHOLD_=1

cd /usr/share/unifi-protect

# Start posgresql
/usr/bin/pg_ctlcluster --skip-systemctl-redirect 10-main start

# Pre-start
/usr/share/unifi-protect/app/hooks/pre-start

# Run
su -c "/usr/bin/node --expose_gc --optimize_for_size --memory_reducer --max_old_space_size=512 /usr/share/unifi-protect/app/daemon.js" unifi-protect &

while true; do
  sleep 5
done
