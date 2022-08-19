#!/bin/bash

# Ask if the user wants to collect sensor data
echo ""
read -p "Do you want to collect sensor data? (yes or no, default is yes): " sensors

# Setting default value
if [ "$sensors" = "" ]; then
	sensors="yes"
fi

# Starting sensor data collection
if [ "$sensors" = "yes" ]; then
	sh scripts/sensor_data.sh &
	sensor_process=$!
fi


# Script Start Date and Time (for use in file name)
date=`date +"%m-%d-%y_%H-%M-%S"`
mkdir Results/perf_$1_functional_report_${date}/
file=Results/perf_$1_functional_report_${date}/perf_$1_functional_report_${date}.txt

# System Information
echo "CPU INFO:\n\n" > $file

# CPU INFO
echo "cat (cat /proc/cpuinfo):\n" >> $file
cat /proc/cpuinfo >> $file

# LSCPU INFO
echo "\nlscpu (lscpu):\n" >> $file
lscpu >> $file

# Memory Info
echo "\n\n\n\nMEMORY INFO (sudo lshw -C memory):" >> $file
sudo lshw -C memory >> $file

# PCI Info
echo "\n\n\n\nPCI INFO (sudo lspci):" >> $file
sudo lspci >> $file

# OS Info
echo "\n\n\n\nOS INFO (cat /etc/lsb-release, uname -r):" >> $file
uname -a >> $file
echo "" >> $file
cat /etc/lsb-release >> $file
echo "kernel=`uname -r`" >> $file

#BIOS Info
echo "\n\n\n\nBIOS INFO (sudo dmidecode --type bios):" >> $file
sudo dmidecode --type bios >> $file

# BMC Info
echo "\n\n\n\nBMC INFO (sudo ipmitool bmc info, sudo ipmitool lan print | grep \"IP Address\"):" >> $file
sudo ipmitool bmc info >> $file
sudo ipmitool lan print | grep "IP Address" >> $file

# Numastat
echo "\n\n\n\nNumastat (numastat -n):\n" >> $file
numastat -n >> $file

# Numactl
echo "\n\n\n\nNumactl:\n\n" >> $file
echo "Numa Hardware Info (numactl --hardware):\n" >> $file
numactl --hardware >> $file
echo "\n\nNuma Policy Info (numactl --show):\n" >> $file
numactl --show >> $file

# Numa maps
echo "\n\n\n\nNuma Maps (cat /proc/self/numa_maps):\n" >> $file
cat /proc/self/numa_maps >> $file

# System Topology (lstopo-no-graphics):
echo "\n\n\n\nSystem Topology (lstopo-no-graphics):\n" >> $file
lstopo-no-graphics >> $file
lstopo sys_topo_${date}.png
	
	
# Workloads	


# Ask how long the user wants to stress the machine (short and long)
echo ""
read -p "How long do you want to run StressAppTest for a short amount of time (default is 2, with the input as the # of minutes): " short_time
short_time=$((short_time * 60))
read -p "How long do you want to run StressAppTest for a long amount of time (default is 20, with the input as the # of minutes): " long_time
long_time=$((long_time * 60))

if [ "$short_time" = "" ]; then
	short_time="120"
fi

if [ "$long_time" = "" ]; then
	long_time="1200"
fi


# Get number of threads for StressAppTest
echo ""
read -p "How many threads do you want to use for StressAppTest (default is 31, enter -1 to use all the machines threads): " stressthreadvar
read -p "How much memory do you want to use for StressAppTest (default is 40000 -> 40gb the format is the # of megabytes): " stressmemvar

if [ "$stressmemvar" = "" ]; then
	stressmemvar="40000"
fi

# StressAppTest Short
echo "\n\n\n\nStressAppTest (Memory Bandwidth and Latency) Short:\n" >> $file

if [ "$stressthreadvar" = "-1" ]; then
	echo "stressapptest -s $short_time -M $stressmemvar -W -v 4" >> $file
	stressapptest -s $short_time -M $stressmemvar -W -v 4 >> $file

elif [ "$stressthreadvar" = "" ]; then
	echo "stressapptest -s $short_time -M $stressmemvar -W -m 31 -v 4" >> $file
	stressapptest -s $short_time -M $stressmemvar -W -m 31 -v 4 >> $file

else
	echo "stressapptest -s $short_time -M $stressmemvar -W -m $stressthreadvar" >> $file
	stressapptest -s $short_time -M $stressmemvar -W -m $stressthreadvar -v 4 >> $file
	
fi

# StressAppTest Long
echo "\n\n\n\nStressAppTest (Memory Bandwidth and Latency) Long:\n" >> $file

if [ "$stressthreadvar" = "-1" ]; then
	echo "stressapptest -s $long_time -M $stressmemvar -W -v 4" >> $file
	stressapptest -s $long_time -M $stressmemvar -W -v 4 >> $file

elif [ "$stressthreadvar" = "" ]; then
	echo "stressapptest -s $long_time -M $stressmemvar -W -m 31 -v 4" >> $file
	stressapptest -s $long_time -M $stressmemvar -W -m 31 -v 4 >> $file

else
	echo "stressapptest -s $long_time -M $stressmemvar -W -m $stressthreadvar" >> $file
	stressapptest -s $long_time -M $stressmemvar -W -m $stressthreadvar -v 4 >> $file
	
fi

		
# Call the perl script to convert the txt report file to an excel file that is easier to read
perl scripts/func_conv.pl "$file" "$date" "$1"

# Deleting the temp files needed for the excel files after they are inserted
rm sys_topo_${date}.png


# Ending sensor data collection
if [ "$sensors" = "yes" ]; then
	sudo kill $sensor_process
fi

