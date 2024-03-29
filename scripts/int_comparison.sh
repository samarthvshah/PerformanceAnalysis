#!/bin/bash

# Script Start Date and Time (for use in file name)
date=`date +"%m-%d-%y_%H-%M-%S"`

# Ask if the user wants to collect sensor data
echo ""
read -p "Do you want to collect sensor data? (yes or no, default is no): " sensors

# Setting default value
if [ "$sensors" = "" ]; then
	sensors="no"
fi

# Ask what the user wants to name the files
echo ""
read -p "What do you want to name the files (default is perf_platform_date.txt): " filename

# Setting default value
if [ "$filename" = "" ]; then
	filename=perf_intel_comparison_report_${date}
fi

mkdir Results/${filename}/
file=Results/${filename}/${filename}.txt


# Showing system Numa information
echo ""
numactl --hardware

echo "Shown above is the NUMA information for the system, you will now be asked about which nodes do you want to compare"

# Get the control node info
echo ""
read -p "What is the control node that you would like to compare to? (Default is 0): " control_node

# Setting default value
if [ "$control_node" = "" ]; then
	control_node="0"
fi

# Get the interest node info
echo ""
read -p "What is the node of which the performance is of interest? (Default is 1): " interest_node

# Setting default value
if [ "$interest_node" = "" ]; then
	interest_node="1"
fi

# Initialize what workloads to run
if [ "$1" = "all" ]; then
	workloads="multichase,stress,stream,fio,mlc"
else
	workloads=$1
fi

# Starting sensor data collection
if [ "$sensors" = "yes" ]; then
	sh scripts/sensor_data.sh Results/${filename}/sensor_data.txt &
	sensor_process=$!
fi

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

OIFS=$IFS
IFS=","

# Main loop
for workload in $workloads
do
	if [ "$workload" = "stress" ]; then

		# Get number of threads for StressAppTest
		echo ""
		read -p "How many threads do you want to use for StressAppTest (default is 31, enter -1 to use all the machines threads): " stressthreadvar
		read -p "How much memory do you want to use for StressAppTest (default is 40000 -> 40gb the format is the # of megabytes): " stressmemvar
		read -p "How long do you want to run StressAppTest (default is 20, with the input as the # of minutes): " time_to_run

		if [ "$time_to_run" = "" ]; then
			time_to_run="1200"
		else 	
			time_to_run=$((time_to_run * 60))
		fi

		if [ "$stressmemvar" = "" ]; then
			stressmemvar="40000"
		fi
		
		
		# StressAppTest for the control node
		echo "\n\n\n\nStressAppTest (Memory Bandwidth and Latency) for the control node $control_node:\n" >> $file

		
		if [ "$stressthreadvar" = "-1" ]; then
			echo "numactl -m $control_node stressapptest -s $time_to_run -M $stressmemvar -W -v 4" >> $file
			numactl -m $control_node stressapptest -s $time_to_run -M $stressmemvar -W -v 4 >> $file

		elif [ "$stressthreadvar" = "" ]; then
			echo "numactl -m $control_node stressapptest -s $time_to_run -M $stressmemvar -W -m 31 -v 4" >> $file
			numactl -m $control_node stressapptest -s $time_to_run -M $stressmemvar -W -m 31 -v 4  >> $file

		else
			echo "numactl -m $control_node stressapptest -s $time_to_run -M $stressmemvar -W -m "$stressthreadvar" -v 4" >> $file
			numactl -m $control_node stressapptest -s $time_to_run -M $stressmemvar -W -m "$stressthreadvar" -v 4  >> $file
			
		fi
		
		
		# StressAppTest for the interest node
		echo "\n\n\n\nStressAppTest (Memory Bandwidth and Latency) for the interest node $interest_node:\n" >> $file
		
		if [ "$stressthreadvar" = "-1" ]; then
			echo "numactl -m $interest_node stressapptest -s $time_to_run -M $stressmemvar -W -v 4" >> $file
			numactl -m $interest_node stressapptest -s $time_to_run -M $stressmemvar -W -v 4 >> $file

		elif [ "$stressthreadvar" = "" ]; then
			echo "numactl -m $interest_node stressapptest -s $time_to_run -M $stressmemvar -W -m 31 -v 4" >> $file
			numactl -m $interest_node stressapptest -s $time_to_run -M $stressmemvar -W -m 31 -v 4  >> $file

		else
			echo "numactl -m $interest_node stressapptest -s $time_to_run -M $stressmemvar -W -m "$stressthreadvar" -v 4" >> $file
			numactl -m $interest_node stressapptest -s $time_to_run -M $stressmemvar -W -m "$stressthreadvar" -v 4  >> $file
			
		fi
		
	elif [ "$workload" = "stream" ]; then
	
		# STREAM on the control node
		echo "\n\n\n\nSTREAM for the control node $control_node:\n" >> $file
		echo "numactl -m $control_node ./src/Stream/stream" >> $file
		numactl -m $control_node ./src/Stream/stream >> $file
		
		# STREAM interest node
		echo "\n\n\n\nSTREAM for the interest node $interest_node:\n" >> $file
		echo "numactl -m $interest_node ./src/Stream/stream" >> $file
		numactl -m $interest_node ./src/Stream/stream >> $file
		
	elif [ "$workload" = "fio" ]; then
	
		# Flexible I/O tester (Latency Test) on the control node
		echo "\n\n\n\nFlexible I/O Tester for the control node $control_node:\n\n" >> $file
		echo "numactl -m $control_node fio --name=readlatency-test-job --rw=randread --bs=4k --iodepth=1 --direct=1 --ioengine=libaio --group_reporting --time_based --runtime=120 --size=128M --numjobs=1" >> $file
		echo "Latency Test:\n" >> $file
		
		# Run and output to report file
		numactl -m $control_node fio --name=readlatency-test-job --rw=randread --bs=4k --iodepth=1 --direct=1 --ioengine=libaio --group_reporting --time_based --runtime=120 --size=128M --numjobs=1 >> $file
#		fio_generate_plots "Read Test" 800 600
		
		# Delete job file
		rm readlatency-test-job.0.0
		
		# Flexible I/O tester (Latency Test) on the interest node
		echo "\n\n\n\nFlexible I/O Tester for the interest node $interest_node:\n\n" >> $file
		echo "numactl -m $interest_node fio --name=readlatency-test-job --rw=randread --bs=4k --iodepth=1 --direct=1 --ioengine=libaio --group_reporting --time_based --runtime=120 --size=128M --numjobs=1" >> $file
		echo "Latency Test:\n" >> $file
		
		# Run and output to report file
		numactl -m $interest_node fio --name=readlatency-test-job --rw=randread --bs=4k --iodepth=1 --direct=1 --ioengine=libaio --group_reporting --time_based --runtime=120 --size=128M --numjobs=1 >> $file
#		fio_generate_plots "Read Test" 800 600
		
		# Delete job file
		rm readlatency-test-job.0.0
		
	elif [ "$workload" = "multichase" ]; then
	
		# Get number of threads for multichase
		echo ""
		read -p "How many threads do you want to use for multichase (default is 1, enter -1 to attempt usage of all the machines threads): " threadvar
		
		if [ "$threadvar" = "-1" ]; then
			threads=`nproc`
		elif [ "$threadvar" = "" ]; then
			threads=1
		else
			threads=$threadvar
		fi
		
		
		echo "\n\n\n\nFull Multichase and Multiload for the control node $control_node:\n\n" >> $file
	
		# Multichase tests
		echo "Pointer Chase (numactl -m $control_node ./src/multichase/multichase -a -s 256 -m 1g -c simple -n 30):\n" >> $file
		numactl -m $control_node ./src/multichase/multichase -a -s 256 -m 1g -c simple -n 30 >> $file
		echo "\n\nMultiload Latency (numactl -m $control_node ./src/multichase/multiload):\n" >> $file
		numactl -m $control_node ./src/multichase/multiload >> $file
		echo "\n\nMultiload Loaded Latency (numactl -m $control_node ./src/multichase/multiload -s 16 -n 5 -t ${threads} -m 512M -c chaseload -l stream-sum):\n" >> $file
		numactl -m $control_node ./src/multichase/multiload -s 16 -n 5 -t ${threads} -m 512M -c chaseload -l stream-sum >> $file
		echo "\n\nMultiload Bandwidth (numactl -m $control_node ./src/multichase/multiload -a -l memcpy-libc -m 1g -s 256 -n 30 -t ${threads}):\n" >> $file
		numactl -m $control_node ./src/multichase/multiload -a -l memcpy-libc -m 1g -s 256 -n 30 -t ${threads} >> $file
		echo "\n\nFairness Latency (numactl -m $control_node ./src/multichase/fairness):\n" >> $file
		numactl -m $control_node ./src/multichase/fairness >> $file
		#echo "\n\nPingpong Latency:\n" >> $file
		#numactl --cpunodebind=$control_node ./src/multichase-master/pingpong -u >> $file
		
		
		echo "\n\n\n\nFull Multichase and Multiload for the interest node $interest_node:\n\n" >> $file
	
		# Multichase tests
		echo "Pointer Chase (numactl -m $interest_node ./src/multichase/multichase -a -s 256 -m 1g -c simple -n 30):\n" >> $file
		numactl -C 0 -m $interest_node ./src/multichase/multichase -a -s 256 -m 1g -c simple -n 30 >> $file
		echo "\n\nMultiload Latency (numactl -m $interest_node ./src/multichase/multiload):\n" >> $file
		numactl -m $interest_node ./src/multichase/multiload >> $file
		echo "\n\nMultiload Loaded Latency (numactl -m $interest_node ./src/multichase/multiload -s 16 -n 5 -t ${threads} -m 512M -c chaseload -l stream-sum):\n" >> $file
		numactl -m $interest_node ./src/multichase/multiload -s 16 -n 5 -t ${threads} -m 512M -c chaseload -l stream-sum >> $file
		echo "\n\nMultiload Bandwidth (numactl -m $interest_node ./src/multichase/multiload -a -l memcpy-libc -m 1g -s 256 -n 30 -t ${threads}):\n" >> $file
		numactl -m $interest_node ./src/multichase/multiload -a -l memcpy-libc -m 1g -s 256 -n 30 -t ${threads} >> $file
		echo "\n\nFairness Latency (numactl -m $interest_node ./src/multichase/fairness):\n" >> $file
		numactl -m $interest_node ./src/multichase/fairness >> $file
		#echo "\n\nPingpong Latency:\n" >> $file
		#numactl --cpunodebind=$interest_node ./src/multichase-master/pingpong -u >> $file

	elif [ "$workload" = "mlc" ]; then
	
		# MLC control node
		echo "\n\n\n\nIntel Memory Latency Checker for the control node $control_node:\n\n" >> $file
		echo "sudo numactl -m $control_node ./src/mlc_v3.9a/Linux/mlc" >> $file
		sudo numactl -m $control_node ./src/mlc_v3.9a/Linux/mlc >> $file
		
		# MLC interest node
		echo "\n\n\n\nIntel Memory Latency Checker for the interest node $interest_node:\n\n" >> $file
		echo "sudo numactl -m $interest_node ./src/mlc_v3.9a/Linux/mlc" >> $file
		sudo numactl -m $interest_node ./src/mlc_v3.9a/Linux/mlc >> $file
		
	else
		echo "Invalid Parameter $workload"
	fi
done

IFS=$OIFS

# Call the perl script to convert the txt report file to an excel file that is easier to read
perl scripts/comp_excel_conv.pl "$file" "$workloads" "$filename" "$control_node" "$interest_node" "$date"

# Deleting the temp files needed for the excel files after they are inserted
rm sys_topo_${date}.png

# Ending sensor data collection
if [ "$sensors" = "yes" ]; then
	sudo kill $sensor_process
fi

