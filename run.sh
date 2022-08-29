#!/bin/bash

# Ask which of the scripts the user would like to run
echo ""
echo "PLEASE MAKE SURE THAT depend.sh HAS BEEN RUN BEFORE USING THIS SCRIPT"
echo ""
echo "1. Gather System Information"
echo "2. Run Functional Testing"
echo "3. Gather Performance Data"
echo "4. Run NUMA Node Comparison Testing"
echo "5. Run All (does not include comp testing"
echo "_________________________________________"
read -p "What do you want to run?: " run

if [ "$run" = "2" ]; then 
	
	# Ask what platform the system is on
	echo ""
	read -p "What platform is the system running on? (intel or amd, default is amd): " platform

	sh scripts/functional_test.sh "$platform"

elif [ "$run" = "3" ]; then

	# Ask what platform the system is on
	echo ""
	read -p "What platform is the system running on? (intel or amd, default is amd): " platform
	

	if [ "$platform" = "intel" ]; then
	
		# Ask what workloads to run
		echo ""
		echo "_____________________________________________"
		echo "| stream     | Stream                       |"
		echo "| stress     | StressAppTest                |"
		echo "| fio        | Flexible I/O Tester          |"
		echo "| multichase | Multichase + Multiload       |"
		echo "| lmbench    | Lmbench                      |"
		echo "| mlc        | Intel Memory Latency Checker |"
		echo "| all        | Run all Workloads            |"
		echo "|____________|______________________________|"
		read -p "What workloads do you want to run? (enter a comma-seperated list with the left side names above): " workloads
		
		sh scripts/int_performance_test.sh "$workloads"
		
	elif [ "$platform" = "amd" ]; then
	
		# Ask what workloads to run
		echo ""
		echo "_____________________________________________"
		echo "| stream     | Stream                       |"
		echo "| stress     | StressAppTest                |"
		echo "| fio        | Flexible I/O Tester          |"
		echo "| multichase | Multichase + Multiload       |"
		echo "| lmbench    | Lmbench                      |"
		echo "| all        | Run all Workloads            |"
		echo "|____________|______________________________|"
		read -p "What workloads do you want to run? (enter a comma-seperated list with the left side names above): " workloads
		
		sh scripts/amd_performance_test.sh "$workloads"
		
	fi
		
	
elif [ "$run" = "4" ]; then

	# Ask what platform the system is on
	echo ""
	read -p "What platform is the system running on? (intel or amd, default is amd): " platform
	

	if [ "$platform" = "intel" ]; then
	
		# Ask what workloads to run
		echo ""
		echo "_____________________________________________"
		echo "| stream     | Stream                       |"
		echo "| stress     | StressAppTest                |"
		echo "| fio        | Flexible I/O Tester          |"
		echo "| multichase | Multichase + Multiload       |"
		echo "| mlc        | Intel Memory Latency Checker |"
		echo "| all        | Run all Workloads            |"
		echo "|____________|______________________________|"
		read -p "What workloads do you want to run? (enter a comma-seperated list with the left side names above): " workloads
		
		sh scripts/int_comparison.sh "$workloads"
		
	elif [ "$platform" = "amd" ]; then
	
		# Ask what workloads to run
		echo ""
		echo "_____________________________________________"
		echo "| stream     | Stream                       |"
		echo "| stress     | StressAppTest                |"
		echo "| fio        | Flexible I/O Tester          |"
		echo "| multichase | Multichase + Multiload       |"
		echo "| all        | Run all Workloads            |"
		echo "|____________|______________________________|"
		read -p "What workloads do you want to run? (enter a comma-seperated list with the left side names above): " workloads
		
		sh scripts/amd_comparison.sh "$workloads"	
	
	fi


elif [ "$run" = "5" ]; then

	# Ask what platform the system is on
	echo ""
	read -p "What platform is the system running on? (intel or amd, default is amd): " platform

	# Run the functional portion of the tests
	sh scripts/functional_test.sh "$platform"
	
	# Run the performance data portion of the tests
	if [ "$platform" = "intel" ]; then
	
		# Ask what workloads to run
		echo ""
		echo "_____________________________________________"
		echo "| stream     | Stream                       |"
		echo "| stress     | StressAppTest                |"
		echo "| fio        | Flexible I/O Tester          |"
		echo "| multichase | Multichase + Multiload       |"
		echo "| lmbench    | Lmbench                      |"
		echo "| mlc        | Intel Memory Latency Checker |"
		echo "| all        | Run all Workloads            |"
		echo "|____________|______________________________|"
		read -p "What workloads do you want to run? (enter a comma-seperated list with the left side names above): " workloads
		
		sh scripts/int_performance_test.sh "$workloads"
		
	elif [ "$platform" = "amd" ]; then
	
		# Ask what workloads to run
		echo ""
		echo "_____________________________________________"
		echo "| stream     | Stream                       |"
		echo "| stress     | StressAppTest                |"
		echo "| fio        | Flexible I/O Tester          |"
		echo "| multichase | Multichase + Multiload       |"
		echo "| lmbench    | Lmbench                      |"
		echo "| all        | Run all Workloads            |"
		echo "|____________|______________________________|"
		read -p "What workloads do you want to run? (enter a comma-seperated list with the left side names above): " workloads
		
		sh scripts/amd_performance_test.sh "$workloads"
		
	fi

else 
	# Ask what platform the system is on
	echo ""
	read -p "What platform is the system running on? (intel or amd, default is amd): " platform
	
	sh scripts/system_info.sh "$platform"
	
fi

	
	
