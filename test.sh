#!/bin/bash

# set -x
adb shell kill $(adb shell pidof lighttpd)
set -e
adb shell "mkdir -p /data/local/tmp/conf"
adb shell "mkdir -p /data/local/tmp/www"
adb shell "mkdir -p /data/local/tmp/logs"
adb shell "mkdir -p /data/local/tmp/run"
adb shell "mkdir -p /data/local/tmp/upload"
adb shell "mkdir -p /data/local/tmp/cache/compress"
# adb shell "echo \"lighttpd test $(date)\" > /data/local/tmp/www/index.html"
adb push share/doc/pcre/html/index.html /data/local/tmp/www/

adb push lighttpd.conf /data/local/tmp/conf
adb push sbin/lighttpd /system/bin
adb shell /system/bin/lighttpd -f /data/local/tmp/conf/lighttpd.conf
adb forward tcp:8000 tcp:80


# --compressed requests gzipped-compressed data and uncompresses it before writing to disk

# curl -v http://127.0.0.1:8000/ --compressed

curl -v -H "Accept-Encoding: gzip" http://127.0.0.1:8000/ --compressed
curl -s -v -H "Accept-Encoding: deflate" http://127.0.0.1:8000/ --compressed


# curl -v http://127.0.0.1:8000/lighttpd-arm/

# curl -v http://127.0.0.1:8000/s?wd=abc