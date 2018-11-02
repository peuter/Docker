Abstract base docker container for the CometVisu
================================================

This container can be used as a base for own Docker containers that contain the CometVisu.
It contains a Apache / PHP combo with the knxd (0.0.5.1).

 Environment parameters:
------------------------

|Parameter              |Default                  |Description|
|-----------------------|-------------------------|-----------|
|KNX_INTERFACE          |iptn:172.17.0.1:3700     |Setting this to empty string, will prevent the knxd from beeing startet|
|KNX_PA                 |1.1.238                  ||
|KNXD_PARAMETERS        |-u -d/var/log/eibd.log -c||
|CGI_URL_PATH           |/cgi-bin/                |Set the URL prefix to find the `cgi-bin `ressources|
|BACKEND_PROXY_SOURCE   |                         |Proxy paths starting with this value, e.g. `/rest` for openHAB backend|
|BACKEND_PROXY_TARGET   |                         |Target URL for proxying the requests to BACKEND_PROXY_SOURCE, e.g. `http://<openhab-server-ip-address>:8080/rest` for openHAB backend|

Example configuration for an openHAB backend (running on host `192.168.0.10`):

```
KNX_INTERFACE=
CGI_URL_PATH=/rest/cv/
BACKEND_PROXY_SOURCE=/rest
BACKEND_PROXY_TARGET=http://192.168.0.10:8080/rest
```
