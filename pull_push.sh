#!/bin/bash
#created by jach(4@jach.vip)

VALID=`wget -q https://registry.hub.docker.com/v1/repositories/jecing/tf20/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}' | sort -rV`
LATEST=`wget -q https://registry.hub.docker.com/v1/repositories/jecing/tf20/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}' | sort -rV | head -n 1`

echo -e "\n\nAvailable versions of images are: \n$VALID\n"
read -p "Do you want to delete this image after pushing it to the regestry?(y/n)" K_DEL

if [ $# -eq 0 ]
then
    echo -e "\nThe latest version of image is $LATEST\n"
    echo -e "Usage: ppp image_version"
    echo "e.g. >> $ sudo ppp $LATEST"
    read -p "or you can input your version and press ENTER: " V_IN
else
    V_IN=$1
fi

case $V_IN in
$LATEST)
    VERSION=$LATEST
    ;;
*)
echo -e "\nYour version $V_IN does not match the newest version: $LATEST"
read -p "Use the latest image version? (y/n): " U_LATEST

    case $U_LATEST in
        [yY][eE][sS]|[yY])
            VERSION=$LATEST
            ;;
        [nN][oO]|[nN])
            VERSION=$V_IN
            ;;
        *)
    esac
esac



docker pull jecing/tf20:$VERSION
docker tag jecing/tf20:$VERSION 192.168.1.141:5000/jecing/tf20:$VERSION
docker push 192.168.1.141:5000/jecing/tf20:$VERSION
# if [ "$K_DEL" == "$YES" ];then
#     docker rmi -f jecing/tf20:$VERSION
# fi

case $K_DEL in
    [yY][eE][sS]|[yY])
        docker rmi -f jecing/tf20:$VERSION
        docker rmi -f 192.168.1.141:5000/jecing/tf20:$VERSION
        ;;
    [nN][oO]|[nN])
        echo "FUCK!"
        ;;
    *)
esac