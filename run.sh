#!/bin/bash

# Graceful shutdown, used by trapping SIGTERM
function graceful_shutdown {
  echo -n "Stopping unifi-protect... "
  if pkill node; then
    /usr/bin/pg_ctlcluster --skip-systemctl-redirect -m fast 10-main stop
    # Post stop
    echo "done."
    exit 0
  else
    echo "failed."
    exit 1
  fi
}

# Trap SIGTERM for graceful exit
trap graceful_shutdown SIGTERM

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
