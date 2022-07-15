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
	sh sensor_data.sh &
	sensor_process=$!
fi

# Script Start Date and Time (for use in file name)
date=`date +"%m-%d-%y_%T"`
file=Results/sys_info_report_${date}.txt

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


# Call the perl script to convert the txt report file to an excel file that is easier to read
perl excel_conv.pl "$file" "" "$date"

# Deleting the temp files needed for the excel files after they are inserted
rm sys_topo_${date}.png

# Ending sensor data collection
if [ "$sensors" = "yes" ]; then
	sudo kill $sensor_process
fi
