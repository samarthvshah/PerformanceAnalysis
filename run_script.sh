#!/bin/bash

# Script Start Date and Time (for use in file name)
date=`date +"%m-%d-%y_%T"`

# System Information
echo "CPU INFO:\n\n" > Results/report_${date}.txt

# CPU INFO
echo "cat:\n" >> Results/report_${date}.txt
cat /proc/cpuinfo >> Results/report_${date}.txt

# LSCPU INFO
echo "\nlscpu:\n" >> Results/report_${date}.txt
lscpu >> Results/report_${date}.txt

# Memory Info
echo "\n\n\n\nMEMORY INFO:" >> Results/report_${date}.txt
sudo lshw -C memory >> Results/report_${date}.txt

# OS Info
echo "\n\n\n\nOS INFO:" >> Results/report_${date}.txt
uname -a >> Results/report_${date}.txt
echo "" >> Results/report_${date}.txt
cat /etc/lsb-release >> Results/report_${date}.txt

# Numastat
echo "\n\n\n\nNumastat:\n" >> Results/report_${date}.txt
numastat -n >> Results/report_${date}.txt

# Numactl
echo "\n\n\n\nNumactl:\n\n" >> Results/report_${date}.txt
echo "Numa Hardware Info:\n" >> Results/report_${date}.txt
numactl --hardware >> Results/report_${date}.txt
echo "\n\nNuma Policy Info:\n" >> Results/report_${date}.txt
numactl --show >> Results/report_${date}.txt

# Numa maps
echo "\n\n\n\nNuma Maps:\n" >> Results/report_${date}.txt
cat /proc/self/numa_maps >> Results/report_${date}.txt

# Lstopo-no-graphics (System Topology):
echo "\n\n\n\nLstopo-no-graphics (System Topology):\n" >> Results/report_${date}.txt
lstopo-no-graphics >> Results/report_${date}.txt
lstopo sys_topo_${date}.png

# Main loop
OIFS=$IFS
IFS=","

# States for later deletion if created
created_csv=false

# Initialize what workloads to run
if [ "$1" = "all" ]; then
	workloads="multichase,stress,stream,fio"
else
	workloads=$1
fi

# Main loop
for workload in $workloads
do
	if [ "$workload" = "stress" ]; then
	
		# StressAppTest
		echo "\n\n\n\nStressAppTest (Memory Bandwidth and Latency):\n" >> Results/report_${date}.txt
		stressapptest -s 20 -M 256 -W >> Results/report_${date}.txt
		
	elif [ "$workload" = "stream" ]; then
	
		# STREAM
		echo "\n\n\n\nSTREAM (Memory Bandwidth):\n" >> Results/report_${date}.txt
		./src/Stream/stream >> Results/report_${date}.txt
		
	elif [ "$workload" = "fio" ]; then
	
		# Flexible I/O tester (Latency Test)
		echo "\n\n\n\nFlexible I/O Tester:\n\n" >> Results/report_${date}.txt
		echo "Latency Test:\n" >> Results/report_${date}.txt
		
		# Run and output to json+ for chart conversion later on
		fio --output=fio_json_${date}.output --output-format=json+ --name=readlatency-test-job --rw=randread --bs=4k --iodepth=1 --direct=1 --ioengine=libaio --group_reporting --time_based --runtime=120 --size=128M --numjobs=1
		
		# Convert to csv and delete the json+ and job files
		python3 src/fio/fio_jsonplus_clat2csv fio_json_${date}.output fio_csv_${date}.csv
#		fio_jsonplus_clat2csv fio_json_${date}.output fio_csv_${date}.csv
		created_csv=true
		rm fio_json_${date}.output
		rm readlatency-test-job.0.0
		
		# Run and output to report file
		fio --name=readlatency-test-job --rw=randread --bs=4k --iodepth=1 --direct=1 --ioengine=libaio --group_reporting --time_based --runtime=120 --size=128M --numjobs=1 >> Results/report_${date}.txt
		
		# Delete job file
		rm readlatency-test-job.0.0
		
	elif [ "$workload" = "multichase" ]; then
	
		# Get number of threads for multichase
		threads=`nproc` 
	
		# Multichase
		echo "\n\n\n\nFull Multichase and Multiload:\n\n" >> Results/report_${date}.txt
		echo "Pointer Chase:\n" >> Results/report_${date}.txt
		./src/multichase-master/multichase -t "${threads}" >> Results/report_${date}.txt
		echo "\n\nMultiload Latency:\n" >> Results/report_${date}.txt
		./src/multichase-master/multiload >> Results/report_${date}.txt
		echo "\n\nMultiload Loaded Latency:\n" >> Results/report_${date}.txt
		./src/multichase-master/multiload -s 16 -n 5 -t "${threads}" -m 512M -c chaseload -l stream-sum >> Results/report_${date}.txt
		echo "\n\nMultiload Bandwidth:\n" >> Results/report_${date}.txt
		./src/multichase-master/multiload -n 5 -t "${threads}" -m 512M -l memcpy-libc >> Results/report_${date}.txt
		echo "\n\nFairness Latency:\n" >> Results/report_${date}.txt
		./src/multichase-master/fairness >> Results/report_${date}.txt
		echo "\n\nPingpong Latency:\n" >> Results/report_${date}.txt
		./src/multichase-master/pingpong -u >> Results/report_${date}.txt

	else
		echo "Invalid Parameter $workload"
	fi
done

# Call the perl script to convert the txt report file to an excel file that is easier to read
perl excel_conv.pl "Results/report_${date}.txt" "$workloads" "$date"

# Deleting the temp files needed for the excel files after they are inserted
rm sys_topo_${date}.png

if [ "$created_csv" = true ] ; then
	rm fio_csv_${date}_job0.csv
fi

IFS=$OIFS

