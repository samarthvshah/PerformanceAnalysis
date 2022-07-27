#!/bin/bash

# Function for creating the csv files
fio_csv_creation() {
		# Run and output to json+ for chart conversion later on
		fio --output=fio_json_${date}.output --output-format=json+ --name=readlatency-test-job --rw=randread --bs=4k --iodepth=1 --direct=1 --ioengine=libaio --group_reporting --time_based --runtime=10 --size=128M --numjobs=1
		
		# Convert to csv and delete the json+ and job files
		fio_jsonplus_clat2csv fio_json_${date}.output fio_csv_${date}.csv
		created_csv=true
		rm fio_json_${date}.output
		rm readlatency-test-job.0.0
}

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
date=`date +"%m-%d-%y_%T"`
file=Results/performance_report_${date}.txt

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

# Main loop
OIFS=$IFS
IFS=","

# States for later deletion if created
created_csv=false

# Initialize what workloads to run
if [ "$1" = "all" ]; then
	workloads="multichase,stress,stream,fio,mlc,lmbench"
else
	workloads=$1
fi

# Main loop
for workload in $workloads
do
	if [ "$workload" = "stress" ]; then
	
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
			stressapptest -s 1200 -M $stressmemvar -W  -v 4 >> $file

		elif [ "$stressthreadvar" = "" ]; then
			stressapptest -s 1200 -M $stressmemvar -W -m 31 -v 4  >> $file

		else
			stressapptest -s 1200 -M $stressmemvar -W -m "$stressthreadvar" -v 4  >> $file
			
		fi
		
	elif [ "$workload" = "stream" ]; then
	
		# STREAM
		echo "\n\n\n\nSTREAM (Memory Bandwidth):\n" >> $file
		sudo ./src/Stream/stream >> $file
		
	elif [ "$workload" = "fio" ]; then
	
		# Flexible I/O tester (Latency Test)
		echo "\n\n\n\nFlexible I/O Tester:\n\n" >> $file
		echo "Latency Test:\n" >> $file
		
		# Create a csv version of the timing data
#		fio_csv_creation
		
		# Run and output to report file
		fio --name=readlatency-test-job --rw=randread --bs=4k --iodepth=1 --direct=1 --ioengine=libaio --group_reporting --time_based --runtime=120 --size=128M --numjobs=1 >> $file
#		fio_generate_plots "Read Test" 800 600
		
		# Delete job file
		rm readlatency-test-job.0.0
		
	elif [ "$workload" = "multichase" ]; then
	
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
	
		# Multichase tests
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

	elif [ "$workload" = "lmbench" ]; then
		
		cd src/lmbench/
		
		make results
		
		cd ..
		cd ..
			
	elif [ "$workload" = "mlc" ]; then
	
		echo "\n\n\n\nIntel Memory Latency Checker (MLC):\n\n" >> $file
		sudo ./src/mlc_v3.9a/Linux/mlc >> $file
	
	else
		echo "Invalid Parameter $workload"
	fi
done

# Call the perl script to convert the txt report file to an excel file that is easier to read
perl scripts/excel_conv.pl "$file" "$workloads" "$date"

# Deleting the temp files needed for the excel files after they are inserted
rm sys_topo_${date}.png

if [ "$created_csv" = true ] ; then
	rm fio_csv_${date}_job0.csv
fi

IFS=$OIFS


# Ending sensor data collection
if [ "$sensors" = "yes" ]; then
	sudo kill $sensor_process
fi


