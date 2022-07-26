#!/bin/bash

# date is part of the coreutils package
if command -v date >/dev/null 2>&1 ; then
	echo "date found"
else
	echo "date not found, installing now"
	sudo apt-get -y install coreutils
fi

# Script Start Date and Time (for use in file name)
date=`date +"%m-%d-%y_%T"`
has_multi="true"


# Create log file
echo "Dependency Check" > log/dependency_log_file_$date.txt
echo "Date: $date\n" >> log/dependency_log_file_$date.txt


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


# Function to check if a certain file that is needed is available
checkforfile() {
	if [ -f $2 ]; then
		echo "$1 found"
		echo "$1 found\n" >> log/dependency_log_file_$date.txt
	else
		echo "$1 not found, must be installed"
		echo "$1 not found, must be installed\n" >> log/dependency_log_file_$date.txt
		has_multi="false"
	fi		
}


# Usually there

# cat is part of the coreutils package
if command -v cat >/dev/null 2>&1 ; then
	echo "cat found"
	echo "cat found\n" >> log/dependency_log_file_$date.txt
else
	echo "cat not found, installing now"
	echo "cat not found, installing now" >> log/dependency_log_file_$date.txt
	sudo apt-get -y install coreutils >> log/dependency_log_file_$date.txt
	echo "\n" >> log/dependency_log_file_$date.txt
fi

# Lscpu is part of the util-linux package
if command -v lscpu >/dev/null 2>&1 ; then
	echo "lscpu found"
	echo "lscpu found\n" >> log/dependency_log_file_$date.txt
else
	echo "lscpu not found, installing now"
	echo "lscpu not found, installing now" >> log/dependency_log_file_$date.txt
	sudo apt-get -y install util-linux >> log/dependency_log_file_$date.txt
	echo "\n" >> log/dependency_log_file_$date.txt
fi

# nproc is part of the coreutils package
if command -v nproc >/dev/null 2>&1 ; then
	echo "nproc found"
	echo "nproc found\n" >> log/dependency_log_file_$date.txt
else
	echo "nproc not found, installing now"
	echo "nproc not found, installing now" >> log/dependency_log_file_$date.txt
	sudo apt-get -y install coreutils >> log/dependency_log_file_$date.txt
	echo "\n" >> log/dependency_log_file_$date.txt
fi

# uname is part of the coreutils package
if command -v uname >/dev/null 2>&1 ; then
	echo "uname found"
	echo "uname found\n" >> log/dependency_log_file_$date.txt
else
	echo "uname not found, installing now"
	echo "uname not found, installing now" >> log/dependency_log_file_$date.txt
	sudo apt-get -y install coreutils >> log/dependency_log_file_$date.txt
	echo "\n" >> log/dependency_log_file_$date.txt
fi

# sleep is part of the coreutils package
if command -v sleep >/dev/null 2>&1 ; then
	echo "sleep found"
	echo "sleep found\n" >> log/dependency_log_file_$date.txt
else
	echo "sleep not found, installing now"
	echo "sleep not found, installing now" >> log/dependency_log_file_$date.txt
	sudo apt-get -y install coreutils >> log/dependency_log_file_$date.txt
	echo "\n" >> log/dependency_log_file_$date.txt
fi

checkfor "lshw"
checkfor "dmidecode"
checkfor "wget"

# Numastat and Numactl come together in a package called numactl
checkfor "numactl"


# Commonly missing packages

# Lstopo is installed using hwloc instead of its name 
if command -v lstopo >/dev/null 2>&1 ; then
	echo "lstopo found"
	echo "lstopo found\n" >> log/dependency_log_file_$date.txt
else
	echo "lstopo not found, installing now"
	echo "lstopo not found, installing now" >> log/dependency_log_file_$date.txt
	sudo apt-get -y install hwloc >> log/dependency_log_file_$date.txt
	echo "\n" >> log/dependency_log_file_$date.txt
fi

# Cpanm is installed using cpanminus instead of its name 
if command -v cpanm >/dev/null 2>&1 ; then
	echo "cpanm found"
	echo "cpanm found\n" >> log/dependency_log_file_$date.txt
else
	echo "cpanm not found, installing now"
	echo "cpanm not found, installing now" >> log/dependency_log_file_$date.txt
	sudo apt-get -y install cpanminus >> log/dependency_log_file_$date.txt
	echo "\n" >> log/dependency_log_file_$date.txt
fi

# sensors is installed using lm-sensors instead of its name 
if command -v sensors >/dev/null 2>&1 ; then
	echo "sensors found"
	echo "sensors found\n" >> log/dependency_log_file_$date.txt
else
	echo "sensors not found, installing now"
	echo "sensors not found, installing now" >> log/dependency_log_file_$date.txt
	sudo apt-get -y install lm-sensors >> log/dependency_log_file_$date.txt
	echo "\n" >> log/dependency_log_file_$date.txt
fi

# All these have the same package name as command
checkfor "stressapptest"
checkfor "fio"
checkfor "gcc"
checkfor "perl"
checkfor "make"
checkfor "git"
checkfor "ipmitool"


# Checking for Stream files
if [ -f "src/Stream/stream" ]; then
	echo "stream found, still must be recompiled"
	echo "stream found, still must be recompiled\n" >> log/dependency_log_file_$date.txt
else
	echo "stream not found, must be manually installed"
	echo "stream not found, must be manually installed\n" >> log/dependency_log_file_$date.txt
	mkdir src/Stream >> log/dependency_log_file_$date.txt
	
	if [ ! -f "src/Stream/stream.c" ]
	then
		wget -q -P src/Stream cs.virginia.edu/stream/FTP/Code/stream.c >> log/dependency_log_file_$date.txt
	fi
fi	

# Recompiling stream with the gcc compiler on the system (precompiled does not work)
echo "compiling stream"
gcc -fopenmp -D_OPENMP src/Stream/stream.c -o src/Stream/stream >> log/dependency_log_file_$date.txt


# Checking for multichase files
checkforfile "multichase main" "src/multichase/multichase"
checkforfile "multichase multiload" "src/multichase/multiload"
checkforfile "multichase fairness" "src/multichase/fairness"
checkforfile "multichase pingpong" "src/multichase/pingpong"

if [ $has_multi = "false" ]; then
	echo "multichase needs to be reinstalled, doing that now"
	echo "doing multichase reinstall" >> log/dependency_log_file_$date.txt
	rm -rf "src/multichase" >> log/dependency_log_file_$date.txt
	git clone https://github.com/google/multichase.git src/multichase >> log/dependency_log_file_$date.txt
	make -C src/multichase >> log/dependency_log_file_$date.txt
	echo "\n" >> log/dependency_log_file_$date.txt
fi
	

# Excel::Writer::XLSX
echo "Checking for Excel::Writer::XLSX" >> log/dependency_log_file_$date.txt
sudo cpanm Excel::Writer::XLSX


# Lmbench

echo "Removing old lmbench and installing the newest version"
echo "Removing old lmbench and installing the newest version\n" >> log/dependency_log_file_$date.txt 

if [ -d "src/lmbench/" ]; then
	rm -rf "src/lmbench/"
fi

git clone https://github.com/zoybai/lmbench.git src/lmbench >> log/dependency_log_file_$date.txt


# MLC

if [ -f "src/mlc_v3.9a/Linux/mlc" ]; then
	echo "mlc found"
	echo "mlc found\n" >> log/dependency_log_file_$date.txt
else
	echo "mlc not found, must be manually installed"
	echo "mlc not found, must be manually installed\n" >> log/dependency_log_file_$date.txt
	
	# Removing folder if already there
	if [ -d "src/mlc_v3.9a/" ]; then
		rm -rf "src/mlc_v3.9a/"
	fi
	
	mkdir src/mlc_v3.9a >> log/dependency_log_file_$date.txt
	
	wget -q -P src/ downloadmirror.intel.com/736634/mlc_v3.9a.tgz
	tar -xf src/mlc_v3.9a.tgz -C src/mlc_v3.9a/
	
	rm src/mlc_v3.9a.tgz 
fi	

chmod +x "src/mlc_v3.9a/Linux/mlc"



