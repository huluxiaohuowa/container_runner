#!/bin/bash
#created by jach(4@jach.vip)

srun -n $1 -p aidd --gres gpu:$2 --pty bash
