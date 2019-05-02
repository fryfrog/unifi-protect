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

# Change unifi-protect UID to custom or match protect default
export PUID
PUID=$(echo "${PUID}" | sed -e 's/^[ \t]*//')
if [[ -n "${PUID}" ]]; then
  echo "[info] PUID defined as '${PUID}'" | ts '%Y-%m-%d %H:%M:%.S'
else
  echo "[warn] PUID not defined (via -e PUID), defaulting to '999'" | ts '%Y-%m-%d %H:%M:%.S'
  export PUID="999"
fi

# Set user unify-video to specified user id (non unique)
usermod -o -u "${PUID}" unifi-protect &>/dev/null

# Change postgres UID to custom or match protect default
export PUID_POSTGRES
PUID_POSTGRES=$(echo "${PUID_POSTGRES}" | sed -e 's/^[ \t]*//')
if [[ -n "${PUID_POSTGRES}" ]]; then
  echo "[info] PUID_POSTGRES defined as '${PUID_POSTGRES}'" | ts '%Y-%m-%d %H:%M:%.S'
else
  echo "[warn] PUID_POSTGRES not defined (via -e PUID_POSTGRES), defaulting to '102'" | ts '%Y-%m-%d %H:%M:%.S'
  export PUID_POSTGRES="102"
fi

# Set user postgres to specified user id (non unique)
usermod -o -u "${PUID_POSTGRES}" postgres &>/dev/null

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

# Change group users to GID to custom or match unRAID.
export PGID_POSTGRES
PGID_POSTGRES=$(echo "${PGID_POSTGRES}" | sed -e 's/^[ \t]*//')
if [[ -n "${PGID_POSTGRES}" ]]; then
  echo "[info] PGID_POSTGRES defined as '${PGID_POSTGRES}'" | ts '%Y-%m-%d %H:%M:%.S'
else
  echo "[warn] PGID_POSTGRES not defined (via -e PGID_POSTGRES), defaulting to '104'" | ts '%Y-%m-%d %H:%M:%.S'
  export PGID_POSTGRES="104"
fi

# Set group users to specified group id (non unique)
groupmod -o -g "${PGID_POSTGRES}" postgres &>/dev/null

# Fix ownership of internal postgres config
chown -R postgres:postgres /etc/postgresql/10 /var/lib/postgresql/10

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
