#!/bin/bash

# set -x
adb -s emulator-5556 shell kill $(adb -s emulator-5556 shell pidof lighttpd)
set -e
adb -s emulator-5556 shell "mkdir -p /data/local/tmp/conf"
adb -s emulator-5556 shell "mkdir -p /data/local/tmp/www"
adb -s emulator-5556 shell "mkdir -p /data/local/tmp/logs"
adb -s emulator-5556 shell "mkdir -p /data/local/tmp/run"
adb -s emulator-5556 shell "mkdir -p /data/local/tmp/upload"
adb -s emulator-5556 shell "mkdir -p /data/local/tmp/cache/compress"
# adb -s emulator-5556 shell "echo \"lighttpd test $(date)\" > /data/local/tmp/www/index.html"
adb -s emulator-5556 push share/doc/pcre/html/index.html /data/local/tmp/www/

adb -s emulator-5556 push lighttpd.conf /data/local/tmp/conf
adb -s emulator-5556 push lighttpd.pem /data/local/tmp/conf

adb -s emulator-5556 push sbin/lighttpd /data/local/
adb -s emulator-5556 shell /data/local/lighttpd -f /data/local/tmp/conf/lighttpd.conf

adb -s emulator-5556 forward --remove-all

adb -s emulator-5556 forward tcp:8080 tcp:80
adb -s emulator-5556 forward tcp:8443 tcp:443


# --compressed requests gzipped-compressed data and uncompresses it before writing to disk

# curl -v http://127.0.0.1:8080/ --compressed > /dev/null
curl -v https://127.0.0.1:8443/ --compressed -k > /dev/null

# curl -v -H "Accept-Encoding: gzip" http://127.0.0.1:8000/ --compressed
# curl -s -v -H "Accept-Encoding: deflate" http://127.0.0.1:8000/ --compressed


# curl -v http://127.0.0.1:8000/lighttpd-arm/

# curl -v http://127.0.0.1:8000/s?wd=abc


adb -s emulator-5556 forward --remove-all