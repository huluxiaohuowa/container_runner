#!/bin/bash
#created by jach(4@jach.vip)


VALID=`curl -XGET http://192.168.1.141:5000/v2/jecing/tf20/tags/list | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+" | sort -rV`
LATEST=`curl -XGET http://192.168.1.141:5000/v2/jecing/tf20/tags/list | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+" | sort -rV | head -n 1`

echo -e "\n\nAvailable versions of images are: \n$VALID\n"

if [ $# -eq 0 ]
then
    echo -e "\nThe latest version of image is $LATEST\n"
    echo -e "Usage: docstart image_version"
    echo "e.g. >> $ sudo docstart $LATEST"
    read -p "Or you can input your version and press ENTER: " V_IN
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


read -p "Would you like nvidia-smi to be seen in your container? (y/n): " SEEN



echo -e "\n\n\nWho are you?\n\n0.chem(chem)\n1.胡建星(jhu)\n2.王铎行(hhhh)\n3.赖俊勇(wllg)\n4.夏虓林(ex2l)\n5.杜子腾(streamer)\n6.其他\n"
read -p "Type your index and press enter: " IDX_USER
case $IDX_USER in
0)
    P_CON=2206
    P_SSH=2222
    P_JUPYTER=2288
    # P_CON=2289
    USER_NAME="chem"
    ;;
1)
    P_CON=10402
    P_SSH=10400
    P_JUPYTER=10401
    # P_CON=10405
    USER_NAME="jhu"
    ;;
2)
    P_CON=17022
    P_SSH=17020
    P_JUPYTER=17021
    # P_CON=17023
    USER_NAME="hhhh"
    ;;
3)
    P_CON=16022
    P_SSH=16020
    P_JUPYTER=16021
    # P_CON=16023
    USER_NAME="wllg"
    ;;
4)
    P_CON=18022
    P_SSH=18020
    P_JUPYTER=18021
    # P_CON=18023
    USER_NAME="ex2l"
    ;;
5)
    P_CON=15022
    P_SSH=15020
    P_JUPYTER=15021
    # P_CON=15023
    USER_NAME="streamer"
    ;;    
*)
read -p "Type in your container name and press enter: " USER_NAME
read -p "Type in your SSH port in this host and press enter: " P_SSH
read -p "Type in your Jupyter port in this host and press enter: " P_JUPYTER
read -p "Type in your anaconda port in this host and press enter: " P_CON
# read -p "Type in your Tensorboard port in this host and press enter: " P_CON
# read -p "Type in your PyCharm Jupyter port in this host and press enter: " P_PCJ
esac

HOST=`hostname`
CON=$USER_NAME
NUM_CON=`docker ps -a --format "{{.Names}}" | grep -w $CON -c`


case $SEEN in
    [yY][eE][sS]|[yY])
        RUN="nvidia-docker run -d --pid=host --restart=always -v /home/docker/v/$USER_NAME:/root/jupyter -v /etc/localtime:/etc/localtime:ro -p $P_CON:9999 -p $P_SSH:22 -p $P_JUPYTER:8888 --name $USER_NAME -h $USER_NAME-$HOST 192.168.1.141:5000/jecing/tf20:$VERSION /entrypoint.sh"
        ;;
    [nN][oO]|[nN])
        RUN="nvidia-docker run -d --restart=always -v /home/docker/v/$USER_NAME:/root/jupyter -v /etc/localtime:/etc/localtime:ro -p $P_CON:9999 -p $P_SSH:22 -p $P_JUPYTER:8888 --name $USER_NAME -h $USER_NAME-$HOST 192.168.1.141:5000/jecing/tf20:$VERSION /entrypoint.sh"
        ;;
    *)
esac

# RUN="nvidia-docker run -d --restart=always -v /home/docker/v/$USER_NAME:/root/jupyter -v /etc/localtime:/etc/localtime:ro -p $P_CON:6006  -p $P_SSH:22 -p $P_JUPYTER:8888 --name $USER_NAME -h $USER_NAME-$HOST 192.168.1.141:5000/jecing/tf20:$VERSION /entrypoint.sh"

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


    
