#!/bin/bash

# Basic Update
sudo apt update

# Install Pip
sudo apt install python3-pip

# Install needed utilities
sudo apt install cmake make git libopenblas-dev

# Get Anaconda installer and install it
wget -p /tmp https://repo.anaconda.com/archive/Anaconda3_2020.02-Linux-x64_64.sh
bash /tmp/Anaconda3_2020.02-Linux-x64_64.sh

# Restart the terminal
source ~/.bashrc

# Install fbgemm dependencies into anaconda
conda install scikit-build ninja jinja2 cmake
conda install hypothesis
conda install pytorch torchvision torchaudio cpuonly -c pytorch

# Move into the src directory
cd src/

# Clone the main directory from its github repo
git clone --recursive https://github.com/pytorch/FBGEMM.git
cd FBGEMM/

# Build + Install Process
git submodule sync
git submodule update --init --recusive
cmake -B build
make -C build

# Install Needed gpu_cpu dependency
pip install fbgemm_gpu_cpu

# Run benchmark
python3 fbgemm_gpu/bench/split_table_batched_embeddings_benchmark.py nbit-cpu --num-embeddings 100000 --batch-size 128 --bag-size 40 --num-tables 800 --embedding-dim 240 --iters 10 --weights-precision int4 --alpha 1.0

# Move back into start directory
cd ..
cd ..

