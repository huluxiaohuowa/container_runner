#!/bin/bash

REGISTRY_ROOT=/home/docker/v/registry/docker/registry/v2/repositories
read -p "Input your images name(e.g. jecing/tf20): " IMG_NAME
read -p "Input your tag(e.g. 1.0.7): " TAG
`rm -f $REGISTRY_ROOT/$IMG_NAME/_manifests/tags/$TAG`
`docker exec -it registry /bin/registry garbage-collect  /etc/docker/registry/config.yml`