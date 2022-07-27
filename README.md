# Performance Analysis

## Introduction

This workflow has the purpose of testing the performance of a system, while also including functional and stress testing. The goal is to provide a simple flow with as much as possible being installed and run automatically. The process of installation should only include the importing of the directory that includes all the necessary files, and then running one script to ensure that all the dependencies are included. Then running the workloads and compiling the data should be done by running only one script that handles everything.

### Whats in the Workflow Directory

-	There are 4 folders and 3 files inside of the directory
-	The “Results” folder contains all of the results when testing scripts are run
  -	Inside are files with the type of test, the date in the filename
  -	The files should be either text or excel version of the same results. The text file will have more complete information but the excel file will be easier to read
-	The “src” folder contains all of the files that are not downloaded into linux, and instead are scripts for the workloads such as Stream and Multichase
-	The “log” folder contains the results of the depends file when it is run. The files will contain information on what is being installed on the system that was not already there and it necessary
-	The “scripts” folder contains all of the helper scripts that run the workloads and generate the excel files. The scripts in this directory are run by the “run.sh” script
-	The README file contains information on the usage of the workflow
-	The “depend” bash script ensures that the dependencies of the workflow and installs something if it is not already installed. It also  recompiles the STREAM file every time because that file requires to be compiled by the gcc on that specific system
-	The “run” bash script asks the user what script they would like to run, what platform they are on, and what workloads they would like to run. It then runs the corresponding script in the “scripts” directory



### Workflow Summary

1.	Install the directory into the machine using git
2.	Cd into the directory
3.	Run the depend.sh script to ensure the dependencies of the workflow
a.	Check the log file to see what was checked and installed
4.	Run the run.sh script that will ask what you want to run and then call the corresponding script
5.	Check the results of the script in the results directory

## Installation

First, clone the directory to the desired location. This should have the majority of the needed things to run the workflow.

Next, verify all the depedencies of the workflow by running the depend script using "sh depend.sh"

At this point all of the scripts should be able to be run. Ensure that when you run the "depend" script there are no situations where something is not found. It is normal for there to be a recompilation happen every time the script is run.

## Usage

Run the "run.sh" script in the main directory
- This will ask you what you would like to run
  - The options are simply collection system information, running a functional test, running a performance data collection test, and running a comparison test bewtween 2 NUMA nodes
  - The performance data and comparison test will ask what platform the system is and what workloads to run
- After that the script will run the coressponding helper script that will generate the output files

All the results from these tests are stored in the Results/ directory with the filename of what script was run and its timestamp

**All scripts will also collect sensor data that is also stored in the Results/ directory**
