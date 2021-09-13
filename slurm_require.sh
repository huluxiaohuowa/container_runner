#!/bin/bash
# by Jianxing Hu

echo -e "\n\nAvailable versions of images are: \n"

sinfo | awk '{print $1}'

read -p "Input your Partition and press ENTER: " PART
read -p "Input task num and press ENTER: " TASK
read -p "Input GPU num and press ENTER: " GPU

CMD="srun -n $TASK -p $PART --gres gpu:$GPU -x bd-compute10 --pty bash"
$CMD
