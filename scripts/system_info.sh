#!/bin/bash

# Script Start Date and Time (for use in file name)
date=`date +"%m-%d-%y_%H-%M-%S"`

# Ask what the user wants to name the files
echo ""
read -p "What do you want to name the files (default is perf_platform_date.txt): " filename

# Setting default value
if [ "$filename" = "" ]; then
	filename=perf_${1}_sys_info_report_${date}
fi


mkdir Results/${filename}/
file=Results/${filename}/${filename}.txt

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


# Call the perl script to convert the txt report file to an excel file that is easier to read
perl scripts/excel_conv.pl "$file" "" "$filename" "$date"

# Deleting the temp files needed for the excel files after they are inserted
rm sys_topo_${date}.png

