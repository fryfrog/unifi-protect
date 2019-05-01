# unifi-protect
An Ubuntu based Docker image for Unifi Protect

Visit http://localhost:7080 or http://<ip.address>:7080/ to start the Unifi Video wizard.

# Run it
```
docker run \
        --name unifi-protect \
        --cap-add SYS_ADMIN \
        --cap-add DAC_READ_SEARCH \
        -p 7080:7080 \
        -p 7442:7442 \
        -p 7443:7443 \
        -p 7444:7444 \
        -p 7447:7447 \
        -p 7550:7550 \
        -v <data dir>:/srv/unifi-protect \
        -e TZ=America/Los_Angeles \
        -e PUID=999 \
        -e PGID=999 \
        -e DEBUG=1 \
        fryfrog/unifi-protect
```

#  tmpfs mount error

```
mount: tmpfs is write-protected, mounting read-only
mount: cannot mount tmpfs read-only
```

If you get this tmpfs mount error, add `--security-opt apparmor:unconfined \` to your list of run options. This error has been seen on Ubuntu, but may occur on other platforms as well.
