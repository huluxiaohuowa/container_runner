#!/bin/bash
#created by jach(4@jach.vip)

YES=y

read -p "Do you want to delete this image after pushing it to the regestry?(y/n)" $K_DEL
if [ $# -eq 0 ]
then
    echo -e "\n\nUsage: pp image_version"
    echo "e.g. >> $ pp 1.0.7"
    read -p "Or you can input your version: " VERSION
else
    VERSION=$1
    `docker pull jecing/tf20:$VERSION && docker tag jecing/tf20:$VERSION 192.168.1.141:5000/jecing/tf20:$VERSION && docker push 192.168.1.141:5000/jecing/tf20:$VERSION`
    if [$K_DEL == $YES];then
        `docker rmi -f jecing/tf20:$VERSION`
    fi

fi