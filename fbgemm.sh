#!/bin/bash

sudo apt update
sudo apt install python3-pip
sudo apt install cmake make git libopenblas-dev
wget -p /tmp https://repo.anaconda.com/archive/Anaconda3_2020.02-Linux-x64_64.sh
bash /tmp/Anaconda3_2020.02-Linux-x64_64.sh
source ~/.bashrc
conda install scikit-build ninja jinja2 cmake
conda install hypothesis
conda install pytorch torchvision torchaudio cpuonly -c pytorch

cd src/

git clone --recursive https://github.com/pytorch/FBGEMM.git
git submodule sync
git submodule update --init --recusive
cmake -B build
make -C build
pip install fbgemm_gpu_cpu
python3 fbgemm_gpu/bench/split_table_batched_embeddings_benchmark.py nbit-cpu --num-embeddings 100000 --batch-size 128 --bag-size 40 --num-tables 800 --embedding-dim 240 --iters 10 --weights-precision int4 --alpha 1.0

