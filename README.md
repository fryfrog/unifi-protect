# THIS DOES NOT WORK YET

See [issue 1](https://github.com/fryfrog/unifi-protect/issues/1) for progress or to provide assistance.

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
        -v <db dir>:/var/lib/postgresql/10/main \
        -v <db config dir>:/etc/postgresql/10/main \
        -e TZ=America/Los_Angeles \
        -e PUID=999 \
        -e PGID=999 \
        -e PUID_POSTGRES=102 \
        -e PGID_POSTGRES=104 \
        -e VERSION=<file|url> \
        fryfrog/unifi-protect
```

The `VERSION=` variable *requires* a `.deb` via `file:///srv/unifi-protect/package.deb` (available *inside* the container) or a url like `http://domain.com/package.deb`.

Example:
```
        -e VERSION="file:///srv/unifi-protect/unifi-protect.jessie~stretch~xenial~bionic_amd64.v1.10.0-beta.7.deb"
```

The needed `.deb` file is *not* included, until Ubiquity clarifies its opinion of Docker images using it.

#  tmpfs mount error

```
mount: tmpfs is write-protected, mounting read-only
mount: cannot mount tmpfs read-only
```

If you get this tmpfs mount error, add `--security-opt apparmor:unconfined \` to your list of run options. This error has been seen on Ubuntu, but may occur on other platforms as well.
