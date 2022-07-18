#!/bin/bash

# Ask if the user wants to collect sensor data
echo ""
read -p "Do you want to collect sensor data? (yes or no, default is yes): " sensors

# Setting default value
if [ "$sensors" = "" ]; then
	sensors="yes"
fi

# Script Start Date and Time (for use in file name)
date=`date +"%m-%d-%y_%T"`
file=Results/comparison_report_${date}.txt

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

# Get the workloads that the user would like to run
echo "\n"
read -p "What workloads do you want to run? (enter a comma-seperated list, multichase for multichase and multiload, stress for StressAppTest, fio for FIO, and stream for STREAM, all for all workloads, default is no workloads): " workloads

# Setting default value
if [ "workloads" = "all" ]; then
	workloads="multichase,stress,stream,fio"
fi


# Starting sensor data collection
if [ "$sensors" = "yes" ]; then
	sh sensor_data.sh &
	sensor_process=$!
fi

OIFS=$IFS
IFS=","

# Main loop
for workload in $workloads
do
	if [ "$workload" = "stress" ]; then

		# Get number of threads for StressAppTest
		echo ""
		read -p "How many threads do you want to use for StressAppTest on the control node (default is 1, enter -1 to use all the machines threads): " stressthreadvar
		read -p "How much memory do you want to use for StressAppTest on the control node (default is 40000 -> 40gb the format is the # of megabytes): " stressmemvar
		
		
		# StressAppTest for the control node
		echo "\n\n\n\nStressAppTest (Memory Bandwidth and Latency) for the control node $control_node:\n" >> $file
		
		if [ "$stressmemvar" = "" ]; then
			stressmemvar="40000"
		fi
		
		if [ "$stressthreadvar" = "-1" ]; then
			numactl --cpunodebind=$control_node stressapptest -s 2000 -M $stressmemvar -W -v 4 >> $file

		elif [ "$stressthreadvar" = "" ]; then
			numactl --cpunodebind=$control_node stressapptest -s 2000 -M $stressmemvar -W -m 1 -v 4  >> $file

		else
			numactl --cpunodebind=$control_node stressapptest -s 2000 -M $stressmemvar -W -m "$stressthreadvar" -v 4  >> $file
			
		fi
		
		
		# StressAppTest for the interest node
		echo "\n\n\n\nStressAppTest (Memory Bandwidth and Latency) for the interest node $control_node:\n" >> $file
		
		if [ "$stressthreadvar" = "-1" ]; then
			numactl --cpunodebind=$interest_node stressapptest -s 2000 -M $stressmemvar -W -v 4 >> $file

		elif [ "$stressthreadvar" = "" ]; then
			numactl --cpunodebind=$interest_node stressapptest -s 2000 -M $stressmemvar -W -m 1 -v 4  >> $file

		else
			numactl --cpunodebind=$interest_node stressapptest -s 2000 -M $stressmemvar -W -m "$stressthreadvar" -v 4  >> $file
			
		fi
		
	elif [ "$workload" = "stream" ]; then
	
		# STREAM on the control node
		echo "\n\n\n\nSTREAM (Memory Bandwidth) for the control node $control_node:\n" >> $file
		numactl --cpunodebind=$control_node ./src/Stream/stream >> $file
		
		# STREAM interest node
		echo "\n\n\n\nSTREAM (Memory Bandwidth) for the interest node $interest_node:\n" >> $file
		numactl --cpunodebind=$interest_node ./src/Stream/stream >> $file
		
	elif [ "$workload" = "fio" ]; then
	
		# Flexible I/O tester (Latency Test) on the control node
		echo "\n\n\n\nFlexible I/O Tester for the control node $control_node:\n\n" >> $file
		echo "Latency Test:\n" >> $file
		
		# Create a csv version of the timing data
#		fio_csv_creation
		
		# Run and output to report file
		numactl --cpunodebind=$control_node fio --name=readlatency-test-job --rw=randread --bs=4k --iodepth=1 --direct=1 --ioengine=libaio --group_reporting --time_based --runtime=120 --size=128M --numjobs=1 >> $file
#		fio_generate_plots "Read Test" 800 600
		
		# Delete job file
		rm readlatency-test-job.0.0
		
		# Flexible I/O tester (Latency Test) on the interest node
		echo "\n\n\n\nFlexible I/O Tester for the interest node $interest_node:\n\n" >> $file
		echo "Latency Test:\n" >> $file
		
		# Create a csv version of the timing data
#		fio_csv_creation
		
		# Run and output to report file
		numactl --cpunodebind=$interest_node fio --name=readlatency-test-job --rw=randread --bs=4k --iodepth=1 --direct=1 --ioengine=libaio --group_reporting --time_based --runtime=120 --size=128M --numjobs=1 >> $file
#		fio_generate_plots "Read Test" 800 600
		
		# Delete job file
		rm readlatency-test-job.0.0
		
	elif [ "$workload" = "multichase" ]; then
	
		# Get number of threads for multichase
		echo ""
		read -p "How many threads do you want to use for multichase on the control node (default is 1, enter -1 to use all the machines threads): " threadvar
		
		if [ "$threadvar" = "-1" ]; then
			threads=`nproc`
		elif [ "$threadvar" = "" ]; then
			threads=1
		else
			threads=$threadvar
		fi
		
		
		echo "\n\n\n\nFull Multichase and Multiload for the control node:\n\n" >> $file
	
		# Multichase tests
		echo "Pointer Chase:\n" >> $file
		numactl --cpunodebind=$control_node ./src/multichase/multichase -a -s 256 -m 1g -c simple -n 30 >> $file
		echo "\n\nMultiload Latency:\n" >> $file
		numactl --cpunodebind=$control_node ./src/multichase/multiload >> $file
		echo "\n\nMultiload Loaded Latency:\n" >> $file
		numactl --cpunodebind=$control_node ./src/multichase/multiload -s 16 -n 5 -t "${threads}" -m 512M -c chaseload -l stream-sum >> $file
		echo "\n\nMultiload Bandwidth:\n" >> $file
		numactl --cpunodebind=$control_node ./src/multichase/multiload -a -c chaseload -l memcpy-libc -m 1g -s 256 -n 30 -t "${threads}" >> $file
		echo "\n\nFairness Latency:\n" >> $file
		numactl --cpunodebind=$control_node ./src/multichase/fairness >> $file
		#echo "\n\nPingpong Latency:\n" >> $file
		#numactl --cpunodebind=$control_node ./src/multichase-master/pingpong -u >> $file
		
		
		echo "\n\n\n\nFull Multichase and Multiload for the interest node:\n\n" >> $file
	
		# Multichase tests
		echo "Pointer Chase:\n" >> $file
		numactl --cpunodebind=$interest_node ./src/multichase/multichase -a -s 256 -m 1g -c simple -n 30 >> $file
		echo "\n\nMultiload Latency:\n" >> $file
		numactl --cpunodebind=$interest_node ./src/multichase/multiload >> $file
		echo "\n\nMultiload Loaded Latency:\n" >> $file
		numactl --cpunodebind=$interest_node ./src/multichase/multiload -s 16 -n 5 -t "${threads}" -m 512M -c chaseload -l stream-sum >> $file
		echo "\n\nMultiload Bandwidth:\n" >> $file
		numactl --cpunodebind=$interest_node ./src/multichase/multiload -a -c chaseload -l memcpy-libc -m 1g -s 256 -n 30 -t "${threads}" >> $file
		echo "\n\nFairness Latency:\n" >> $file
		numactl --cpunodebind=$interest_node ./src/multichase/fairness >> $file
		#echo "\n\nPingpong Latency:\n" >> $file
		#numactl --cpunodebind=$control_node ./src/multichase-master/pingpong -u >> $file

	else
		echo "Invalid Parameter $workload"
	fi
done

IFS=$OIFS

# Ending sensor data collection
if [ "$sensors" = "yes" ]; then
	sudo kill $sensor_process
fi

