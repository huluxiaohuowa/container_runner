#!/bin/bash
#created by jach(4@jach.vip)

`curl -XGET http://192.168.1.141:5000/v2/jecing/tf20/tags/list > ~/docker_latest_temp.txt`
LATEST=`cat ~/docker_latest_temp.txt | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+"`


if [ $# -eq 0 ]
then
    echo -e "\n\nUsage: docstart image_version"
    echo "e.g. >> $ sudo docstart 1.0.4"
else
    case $1 in
    $LATEST)
        VERSION=$LATEST
        ;;
    *)
    echo -e "\nYour version $1 does not match the newest version: $LATEST"
    read -p "Use the latest image version? (y/n): " U_LATEST

        case $U_LATEST in
            [yY][eE][sS]|[yY])
                VERSION=$LATEST
                ;;
            [nN][oO]|[nN])
                VERSION=$1
                ;;
            *)
        esac
    esac




    echo -e "\n\n\nWho are you?\n\n0.chem(chem)\n1.胡建星(jhu)\n2.王铎行(hhhh)\n3.赖俊勇(wllg)\n4.夏虓林(ex2l)\n5.杜子腾(streamer)\n6.其他\n"
    read -p "Type your index and press enter: " IDX_USER
    case $IDX_USER in
    0)
        P_TENSORBOARD=2206
        P_SSH=2222
        P_JUPYTER=2288
        USER_NAME="chem"
        ;;
    1)
        P_TENSORBOARD=11106
        P_SSH=11122
        P_JUPYTER=11188
        USER_NAME="jhu"
        ;;
    2)
        P_TENSORBOARD=17022
        P_SSH=17020
        P_JUPYTER=17021
        USER_NAME="hhhh"
        ;;
    3)
        P_TENSORBOARD=16022
        P_SSH=16020
        P_JUPYTER=16021
        USER_NAME="wllg"
        ;;
    4)
        P_TENSORBOARD=18022
        P_SSH=18020
        P_JUPYTER=18021
        USER_NAME="ex2l"
        ;;
    5)
        P_TENSORBOARD=15022
        P_SSH=15020
        P_JUPYTER=15021
        USER_NAME="streamer"
        ;;    
    *)
    read -p "Type in your container name and press enter: " USER_NAME
    read -p "Type in your SSH port in this host and press enter: " P_SSH
    read -p "Type in your Jupyter port in this host and press enter: " P_JUPYTER
    read -p "Type in your Tensorboard port in this host and press enter: " P_TENSORBOARD
    esac

    HOST=`hostname`
    CON=$USER_NAME
    NUM_CON=`docker ps -a --format "{{.Names}}" | grep -w $CON -c`
    RUN="nvidia-docker run -d --restart=always -v /home/docker/v/$USER_NAME:/root/jupyter -p $P_TENSORBOARD:6006 -p $P_SSH:22 -p $P_JUPYTER:8888 --name $USER_NAME -h $USER_NAME-$HOST 192.168.1.141:5000/jecing/tf20:$VERSION /entrypoint.sh"
    
    if [ $NUM_CON -ne 0 ]
    then
        echo "Container $CON exists, please delete it before running this script"
        read -p "Delete the container with the same name? (y/n): " E_DEL
        case $E_DEL in
        [yY][eE][sS]|[yY])
            echo "Deleting container $CON"
            docker rm -f $CON
            echo "Done."
            echo "Starting the new container $CON"
            echo "$RUN"
            $RUN
            ;;
        [nN][oO]|[nN])
            echo "fuck!"
            ;;
        *)
        esac
    else
        echo "Starting container $CON"
        $RUN
    fi
fi

    
    
