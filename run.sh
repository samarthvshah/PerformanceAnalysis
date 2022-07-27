#!/bin/bash

# Ask which of the scripts the user would like to run
echo ""
read -p "What do you want to run? (sys for only gathering system info, func for functional testing, perf for performance testing, comp for NUMA node comparison testing, default is system info): " run

if [ "$run" = "func" ]; then 
	sh scripts/functional_test.sh

elif [ "$run" = "perf" ]; then

	# Ask what platform the system is on
	echo ""
	read -p "What platform is the system running on? (intel or amd, default is amd): " platform
	

	if [ "$platform" = "intel" ]; then
	
		# Ask what workloads to run
		echo ""
		read -p "What workloads do you want to run? (enter a comma-seperated list with stream for STREAM, stress for StressAppTest, fio for Flexible I/O tester, multichase for Multichase, lmbench for Lmbench, mlc for Intel Memory Latency Checker, all for All Workloads): " workloads
		
		sh scripts/int_performance_test.sh "$workloads"
		
	elif [ "$platform" = "amd" ]; then
	
		# Ask what workloads to run
		echo ""
		read -p "What workloads do you want to run? (enter a comma-seperated list with stream for STREAM, stress for StressAppTest, fio for Flexible I/O tester, multichase for Multichase, lmbench for Lmbench, all for All Workloads): " workloads
		
		sh scripts/amd_performance_test.sh "$workloads"
		
	fi
		
	
elif [ "$run" = "comp" ]; then

	# Ask what platform the system is on
	echo ""
	read -p "What platform is the system running on? (intel or amd, default is amd): " platform
	

	if [ "$platform" = "intel" ]; then
	
		# Ask what workloads to run
		echo ""
		read -p "What workloads do you want to run? (enter a comma-seperated list with stream for STREAM, stress for StressAppTest, fio for Flexible I/O tester, multichase for Multichase, lmbench for Lmbench, mlc for Intel Memory Latency Checker, all for All Workloads): " workloads
		
		sh scripts/int_comparison_test.sh "$workloads"
		
	elif [ "$platform" = "amd" ]; then
	
		# Ask what workloads to run
		echo ""
		read -p "What workloads do you want to run? (enter a comma-seperated list with stream for STREAM, stress for StressAppTest, fio for Flexible I/O tester, multichase for Multichase, lmbench for Lmbench, all for All Workloads): " workloads
		
		sh scripts/amd_comparison_test.sh "$workloads"	
	
	fi
	
else 
	sh scripts/system_info.sh
	
fi

	
	
