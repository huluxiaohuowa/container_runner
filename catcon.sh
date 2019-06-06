#!/bin/bash
#created by jach(4@jach.vip)

containerid=`cat /proc/$1/cgroup | head -n 1 | cut -d "/" -f3`
docker inspect --format '{{.Name}}' "${containerid}" | sed 's/^\///'

