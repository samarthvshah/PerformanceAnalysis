#!/bin/bash

# Script Start Date and Time (for use in file name)
date=`date +"%m-%d-%y_%T"`
file=Results/functional_report_${date}.txt

# System Information
echo "CPU INFO:\n\n" > $file

# CPU INFO
echo "cat:\n" >> $file
cat /proc/cpuinfo >> $file

# LSCPU INFO
echo "\nlscpu:\n" >> $file
lscpu >> $file

# Memory Info
echo "\n\n\n\nMEMORY INFO:" >> $file
sudo lshw -C memory >> $file

# OS Info
echo "\n\n\n\nOS INFO:" >> $file
uname -a >> $file
echo "" >> $file
cat /etc/lsb-release >> $file
echo "kernel=`uname -r`" >> $file

#BIOS Info
echo "\n\n\n\nBIOS INFO:" >> $file
sudo dmidecode --type bios >> $file
#echo "bios version=`sudo dmidecode -s bios-version`" >> $file
#echo "bios release date=`sudo dmidecode -s bios-release date`" >> $file

# BMC Info
echo "\n\n\n\nBMC INFO:" >> $file
sudo ipmitool bmc info >> $file
sudo ipmitool lan print | grep "IP Address" >> $file

# Numastat
echo "\n\n\n\nNumastat:\n" >> $file
numastat -n >> $file

# Numactl
echo "\n\n\n\nNumactl:\n\n" >> $file
echo "Numa Hardware Info:\n" >> $file
numactl --hardware >> $file
echo "\n\nNuma Policy Info:\n" >> $file
numactl --show >> $file

# Numa maps
echo "\n\n\n\nNuma Maps:\n" >> $file
cat /proc/self/numa_maps >> $file

# Lstopo-no-graphics (System Topology):
echo "\n\n\n\nLstopo-no-graphics (System Topology):\n" >> $file
lstopo-no-graphics >> $file
lstopo sys_topo_${date}.png
	
	
# Workloads	
	
# StressAppTest
echo "\n\n\n\nStressAppTest (Memory Bandwidth and Latency):\n" >> $file

# Get number of threads for StressAppTest
echo ""
read -p "How many threads do you want to use for StressAppTest (default is 31, enter -1 to use all the machines threads): " stressthreadvar
read -p "How much memory do you want to use for StressAppTest (default is 40000 -> 40gb the format is the # of megabytes): " stressmemvar

if [ "$stressmemvar" = "" ]; then
	stressmemvar="40000"
fi

if [ "$stressthreadvar" = "-1" ]; then
	stressapptest -s 20 -M $stressmemvar -W >> $file

elif [ "$stressthreadvar" = "" ]; then
	stressapptest -s 20 -M $stressmemvar -W -m 31 >> $file

else
	stressapptest -s 20 -M $stressmemvar -W -m "$stressthreadvar" >> $file
	
fi	
		

# Multichase
echo "\n\n\n\nFull Multichase and Multiload:\n\n" >> $file

# Get number of threads for multichase
echo ""
read -p "How many threads do you want to use for multichase (default is 8, enter -1 to use all the machines threads): " threadvar

if [ "$threadvar" = "-1" ]; then
	threads=`nproc`

elif [ "$threadvar" = "" ]; then
	threads=8

else
	threads=$threadvar

fi

echo "Pointer Chase:\n" >> $file
./src/multichase/multichase -a -s 256 -m 1g -c simple -n 30 >> $file
echo "\n\nMultiload Latency:\n" >> $file
./src/multichase/multiload >> $file
echo "\n\nMultiload Loaded Latency:\n" >> $file
./src/multichase/multiload -s 16 -n 5 -t "${threads}" -m 512M -c chaseload -l stream-sum >> $file
echo "\n\nMultiload Bandwidth:\n" >> $file
./src/multichase/multiload -a -c chaseload -l memcpy-libc -m 1g -s 256 -n 30 -t "${threads}" >> $file
echo "\n\nFairness Latency:\n" >> $file
./src/multichase/fairness >> $file
#echo "\n\nPingpong Latency:\n" >> $file
#./src/multichase-master/pingpong -u >> $file



# Call the perl script to convert the txt report file to an excel file that is easier to read
perl excel_conv.pl "$file" "stress,multichase" "$date"

# Deleting the temp files needed for the excel files after they are inserted
rm sys_topo_${date}.png

