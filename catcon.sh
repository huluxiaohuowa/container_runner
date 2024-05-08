#!/bin/bash
#created by jach(4@jach.vip)

docker ps --no-trunc | grep $(cat /proc/$1/cgroup | grep -oE '[0-9a-f]{64}' | head -1) | sed 's/^.* //'
