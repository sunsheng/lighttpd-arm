#!/bin/bash

# set -x
adb shell kill $(adb shell pidof lighttpd)
set -e
adb shell "mkdir -p /data/local/tmp/conf"
adb shell "mkdir -p /data/local/tmp/www"
adb shell "mkdir -p /data/local/tmp/logs"
adb shell "mkdir -p /data/local/tmp/run"
adb shell "mkdir -p /data/local/tmp/cache/compress"
adb shell "echo \"lighttpd test $(date)\" > /data/local/tmp/www/index.html"

adb push lighttpd.conf /data/local/tmp/conf
adb push sbin/lighttpd /system/bin
adb shell /system/bin/lighttpd -f /data/local/tmp/conf/lighttpd.conf
adb forward tcp:8000 tcp:80
curl -H "Accept-Encoding: gzip" http://127.0.0.1:8000/index.html -v
