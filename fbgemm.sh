#!/bin/bash

# Function to check if a certain needed command is available, installing it if not there
checkfor() {
	if command -v $1 >/dev/null 2>&1 ; then
		echo "$1 found"
		echo "$1 found\n" >> log/dependency_log_file_$date.txt
	else
		echo "$1 not found, installing now"
		echo "$1 not found, installing now" >> log/dependency_log_file_$date.txt
		sudo apt-get -y install $1 >> log/dependency_log_file_$date.txt
		echo "\n" >> log/dependency_log_file_$date.txt
	fi
}


read -p "Do you want to run the installation process? " install

if [ "$install" = "yes" ]; then

	# Basic Update
	sudo apt update

	# Install Pip
	if command -v pip >/dev/null 2>&1 ; then
		echo "pip found"
		echo "pip found\n" >> log/dependency_log_file_$date.txt
	else
		echo "pip not found, installing now"
		echo "pip not found, installing now" >> log/dependency_log_file_$date.txt
		sudo apt-get -y install python3-pip >> log/dependency_log_file_$date.txt
		echo "\n" >> log/dependency_log_file_$date.txt	
	fi

	# Install needed utilities
	checkfor "cmake"
	checkfor "make"
	checkfor "git"
	
	sudo apt-get -y install libopenblas-dev

	# Get Anaconda installer and install it
	if command -v conda >/dev/null 2>&1 ; then
		echo "conda found"
		echo "conda found\n" >> log/dependency_log_file_$date.txt
	else
		echo "conda not found, installing now"
		echo "conda not found, installing now" >> log/dependency_log_file_$date.txt
		wget -P /tmp https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh
		bash /tmp/Anaconda3-2020.05-Linux-x86_64.sh
		echo "\n" >> log/dependency_log_file_$date.txt
		
		# Restart the terminal
		source ~/.bashrc	
	fi

	# Install fbgemm dependencies into anaconda
	conda install scikit-build ninja jinja2 cmake
	conda install hypothesis
	conda install pytorch torchvision torchaudio cpuonly -c pytorch

	# Move into the src directory
	cd src/

	# Clone the main directory from its github repo
	if [ -d "src/FBGEMM/" ]; then
		rm -rf "src/FBGEMM/"
	fi
	
	git clone --recursive https://github.com/pytorch/FBGEMM.git
	cd FBGEMM/

	# Build + Install Process
	git submodule sync
	git submodule update --init --recusive
	cmake -B build
	make -C build

	# Install Needed gpu_cpu dependency
	pip install fbgemm_gpu_cpu

else
	cd src/FBGEMM/
	
fi

# Run benchmark
python3 fbgemm_gpu/bench/split_table_batched_embeddings_benchmark.py nbit-cpu --num-embeddings 100000 --batch-size 128 --bag-size 40 --num-tables 800 --embedding-dim 240 --iters 10 --weights-precision int4 --alpha 1.0

# Move back into start directory
cd ..
cd ..

