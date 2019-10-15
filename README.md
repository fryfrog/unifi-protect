# This image works w/ a macvlan network

You'll need to run this image on your lan w/ a real IP, using Docker's [macvlan](https://docs.docker.com/network/macvlan/). It doesn't use dhcp and it doesn't watch for ip address conflicts, so be sure to account for that like the example below.

```
docker network create -d macvlan \
    --subnet 192.168.1.1/24 \
    --gateway 192.168.1.1 \
    --ip-range 192.168.1.16/28 \
    -o parent=eth0 lan
```

Note that you'll *need* to use the correct subnet, gateway, ip-range and network interface for *your* network and server. These example IPs may or may not be correct.

# unifi-protect
An Ubuntu based Docker image for Unifi Protect

Visit http://<ip.address>:7080/ to start the Unifi Protect wizard.

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
    fryfrog/unifi-protect
```

# Example folder structure for the data, db and db-config folders.

```
storage/unifi-protect
├ data
├ db
└ db-config
```

#  tmpfs mount error

```
mount: tmpfs is write-protected, mounting read-only
mount: cannot mount tmpfs read-only
```

If you get this tmpfs mount error, add `--security-opt apparmor:unconfined \` to your list of run options. This error has been seen on Ubuntu, but may occur on other platforms as well.
