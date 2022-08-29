#!/usr/bin/perl

use strict;
use warnings;
use Excel::Writer::XLSX;

# Getting the parameters passed in by the workload running script
my ($reportfile, $date, $platform) = @ARGV;
my $filename = "Results/perf_${platform}_functional_report_${date}/perf_${platform}_functional_report_${date}.xlsx";
my @states = ("cpuinfo", "meminfo", "pciinfo", "osinfo", "biosinfo", "bmcinfo", "numastat", "numactl", "numamaps", "lstopo", "stress_short", "stress_long");

# Creating a new xlsx file
my $workbook = Excel::Writer::XLSX->new( $filename );

# Instantiating new worksheets for each of the workloads
my $cpu_info_wk;
my $mem_info_wk;
my $pci_info_wk;
my $numastat_wk;
my $numactl_wk;
my $numamaps_wk;
my $lstopo_wk;
my $os_info_wk;
my $bios_info_wk;
my $bmc_info_wk;
my $stress_short_wk;
my $stress_long_wk;

# Creating a new format type for major workload headers
my $primary_header_format = $workbook->add_format();
$primary_header_format->set_bold();
$primary_header_format->set_size(14);
$primary_header_format->set_align('center');
$primary_header_format->set_align('vcenter');
$primary_header_format->set_bg_color("gray");

# Creating a new format type for headers inside of workload headers
my $secondary_header_format = $workbook->add_format();
$secondary_header_format->set_bold();
$secondary_header_format->set_align('center');
$secondary_header_format->set_align('vcenter');
$secondary_header_format->set_bg_color("silver");

# Creating a new format type for basic data
my $basic_format = $workbook->add_format();
$basic_format->set_align('left');
$basic_format->set_align('vcenter');

# Creating a new format where normal text is centered
my $basic_centered_format = $workbook->add_format();
$basic_centered_format->set_align('center');
$basic_centered_format->set_align('vcenter');

# Creating the specific worksheets with their specific needs
foreach (@states) {
	# Create a new worksheet for the CPU information, setup the columns with the basic format
	if ($_ eq "cpuinfo") {
		$cpu_info_wk = $workbook->add_worksheet("CPU Info");
		$cpu_info_wk->set_row(0, 25);
		$cpu_info_wk->set_column('A:B',25, $basic_format);
		$cpu_info_wk->set_column('D:E',25, $basic_format);
	# Create a new worksheet for Memory Information, setup formatting		
	} elsif ($_ eq "meminfo") {
		$mem_info_wk = $workbook->add_worksheet("Memory Info");
		$mem_info_wk->set_row(0, 30);	
		$mem_info_wk->set_column('A:B',25, $basic_format);
	# Create a new worksheet for OS Information, setup formatting	
	} elsif ($_ eq "osinfo") {
		$os_info_wk = $workbook->add_worksheet("OS Info");
		$os_info_wk->set_row(0, 30);	
		$os_info_wk->set_column('A:B',25, $basic_format);
	# Create a new worksheet for PCI Information, setup formatting	
	} elsif ($_ eq "pciinfo") {
		$pci_info_wk = $workbook->add_worksheet("PCI Info");
		$pci_info_wk->set_row(0, 30);	
		$pci_info_wk->set_column('A:E',25, $basic_format);
	# Create a new worksheet for Numastat, setup formatting	
	} elsif ($_ eq "biosinfo") {
		$bios_info_wk = $workbook->add_worksheet("BIOS Info");
		$bios_info_wk->set_row(0, 30);	
		$bios_info_wk->set_column('A:B',25, $basic_format);
	} elsif ($_ eq "bmcinfo") {
		$bmc_info_wk = $workbook->add_worksheet("BMC Info");
		$bmc_info_wk->set_row(0, 30);	
		$bmc_info_wk->set_column('A:B',25, $basic_format);
	} elsif ($_ eq "numastat") {
		$numastat_wk = $workbook->add_worksheet("Numastat");
		$numastat_wk->set_row(0, 30);	
	# Create a new worksheet for Numactl, setup formatting	
	} elsif ($_ eq "numactl") {
		$numactl_wk = $workbook->add_worksheet("Numactl");
		$numactl_wk->set_row(0, 30);
		$numactl_wk->set_column('A:B',20, $basic_format);
		$numactl_wk->set_column('D:E',20, $basic_format);
	# Create a new worksheet for Numa Maps, setup formatting					
	} elsif ($_ eq "numamaps") {
		$numamaps_wk = $workbook->add_worksheet("Numa Maps");
		$numamaps_wk->set_row(0, 30);
		$numamaps_wk->set_column('A:A',70, $basic_format);	
	# Create a new worksheet for lstopo, setup formatting	
	} elsif ($_ eq "lstopo") {
		$lstopo_wk = $workbook->add_worksheet("Lstopo");
		$lstopo_wk->set_row(0, 30);
		$lstopo_wk->set_column('A:A',30, $basic_format);	
	# Create a new worksheet for StressAppTests Short, setup formatting	
	} elsif ($_ eq "stress_short") {
		$stress_short_wk = $workbook->add_worksheet("StressAppTest Short");
		$stress_short_wk->set_row(0, 30);
		$stress_short_wk->set_column('A:C',30, $basic_format);
	# Create a new worksheet for StressAppTests Long, setup formatting		
	} elsif ($_ eq "stress_long") {
		$stress_long_wk = $workbook->add_worksheet("StressAppTest Long");
		$stress_long_wk->set_row(0, 30);
		$stress_long_wk->set_column('A:C',30, $basic_format);
	}
}

# Intitalizing the states and indexes of the script
my $state = "";
my $state_2 = "hw";
my $file_ind = 1;
my $file_ind_2 = 1;
my $excel_ind = 1;
my $excel_ind_2 = 1;
my $loop_index = 0;
my $node_dis = "false";
my @splits; 
my $stat_ind;

# Opening the report file
open my $info, $reportfile or die "Could not open $reportfile: $!";

# Looping through the file, putting each line in the $line var
while( my $line = <$info>)
{
	# Stripping off the newline from the line
	$line =~ s/\s+$//;

	# Updating the state based on if the file has reached a new workload
	if ($line eq "CPU INFO:") {
		$state = "cpuinfo";
		$state_2 = "cat";
		$file_ind = 1;
		$excel_ind = 1;
		$excel_ind_2 = 1;
	} elsif ($line eq "MEMORY INFO (sudo lshw -C memory):") {
		$state = "meminfo";
		$file_ind = 1;
		$excel_ind = 1;
		$excel_ind_2 = 1;
	} elsif ($line eq "OS INFO (cat /etc/lsb-release, uname -r):") {
		$state = "osinfo";
		$file_ind = 1;
		$excel_ind = 1;
		$excel_ind_2 = 1;
	} elsif ($line eq "PCI INFO (sudo lspci):") {
		$state = "pciinfo";
		$file_ind = 1;
		$excel_ind = 1;
		$excel_ind_2 = 1;
	} elsif ($line eq "StressAppTest (Memory Bandwidth and Latency) Short:") {
		$state = "stress_short";
		$file_ind = 1;
		$excel_ind = 1;
		$excel_ind_2 = 1;
	} elsif ($line eq "StressAppTest (Memory Bandwidth and Latency) Long:") {
		$state = "stress_long";
		$file_ind = 1;
		$excel_ind = 1;
		$excel_ind_2 = 1;
	} elsif ($line eq "Numactl:") {
		$state = "numactl";
		$state_2 = "hw";
		$file_ind = 1;
		$excel_ind = 1;
		$excel_ind_2 = 1;
	} elsif ($line eq "Numastat (numastat -n):") {
		$state = "numastat";
		$file_ind = 1;
		$excel_ind = 1;
		$excel_ind_2 = 1;
	} elsif ($line eq "Numa Maps (cat /proc/self/numa_maps):") {
		$state = "numamaps";
		$file_ind = 1;
		$excel_ind = 1;
		$excel_ind_2 = 1;
	} elsif ($line eq "System Topology (lstopo-no-graphics):") {
		$state = "lstopo";
		$file_ind = 1;
		$excel_ind = 1;
		$excel_ind_2 = 1;
	} elsif ($line eq "Full Multichase and Multiload:") {
		$state = "multichase";
		$file_ind = 1;
		$excel_ind = 1;
		$excel_ind_2 = 1;
	} elsif ($line eq "BIOS INFO (sudo dmidecode --type bios):") {
		$state = "bios";
		$file_ind = 1;
		$excel_ind = 1;
		$excel_ind_2 = 1;
		$state_2 = "not started";
	} elsif ($line eq "BMC INFO (sudo ipmitool bmc info, sudo ipmitool lan print | grep \"IP Address\"):") {
		$state = "bmc";
		$file_ind = 1;
		$excel_ind = 2;
		$excel_ind_2 = 2;
	}
	
	# Put the corresponding data into the files based on the workload
	if ($state eq "cpuinfo") {
		# Set the row to a height of 25
		$cpu_info_wk->set_row( ${excel_ind}-1, 25);
		
		# Splitting the text output into different chunks to be parsed based on their patterns
		if ($file_ind < 6) {
			# Title
			if ($file_ind == 1) {
				$cpu_info_wk->merge_range(0,0,0,4, $line, $primary_header_format);
				++$excel_ind;
			# Secondary Headers
			} elsif ($file_ind == 4) {
				$cpu_info_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 1, $line, $secondary_header_format);
				++$excel_ind;
			}
		# Main data chunk
		} elsif ($file_ind >= 6) {
		
			# Setting cpu command state
			if ($line eq "cat (cat /proc/cpuinfo):") {
				$state_2 = "cat";
			} elsif ($line eq "lscpu (lscpu):") {
				$state_2 = "ls";
				$excel_ind_2 = 2;
			}
			
			# CAT cpu info
			if ($state_2 eq "cat") {
				my ($key, $val) = split(/:/, $line);

				# If the value is not empty
				if (defined $key) {
					$key =~ s/^\s*(.*?)\s*$/$1/;
					$cpu_info_wk->write( "A${excel_ind}", $key);
				}
				
				if (defined $val) {
					$val =~ s/^\s*(.*?)\s*$/$1/;
					$cpu_info_wk->write( "B${excel_ind}", $val);	
				}

				++$excel_ind;
			# lscpu info
			} elsif ($state_2 eq "ls") {
				# Header
				if ($file_ind_2 == 1) {
					$cpu_info_wk->merge_range( ${excel_ind_2}-1, 3, ${excel_ind_2}-1, 4, $line, $secondary_header_format);
					++$excel_ind_2;
				# Splitting up types and values
				} elsif ($file_ind_2 >= 3) {
				
					my ($key, $val) = split(/:/, $line);
			
					if (defined $key) {
						$key =~ s/^\s*(.*?)\s*$/$1/;
						$cpu_info_wk->write( "D${excel_ind_2}", $key);
					}
					
					if (defined $val) {
						$val =~ s/^\s*(.*?)\s*$/$1/;
						$cpu_info_wk->write( "E${excel_ind_2}", $val);	
					}	
					++$excel_ind_2;
				}
				++$file_ind_2;
			}
		}
	# Memory information
	} elsif ($state eq "meminfo") {
		# Set the row to a height of 25
		$mem_info_wk->set_row( ${excel_ind}-1, 25);
	
		if ($file_ind == 1) {
			$line =~ s/^\s*(.*?)\s*$/$1/;
			$mem_info_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 1, $line, $primary_header_format);
			++$excel_ind;
		} elsif ($file_ind > 1) {
			if (index($line, "*-") != -1) {
				$line =~ s/^\s*(.*?)\s*$/$1/;
				$mem_info_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 1, $line, $secondary_header_format);
				++$excel_ind;
			} else {
				my ($key, $val) = split(/:/, $line);
				
				if (defined $key) {
					$key =~ s/^\s*(.*?)\s*$/$1/;
					$mem_info_wk->write( "A${excel_ind}", $key);
				}
				
				if (defined $val) {
					$val =~ s/^\s*(.*?)\s*$/$1/;
					$mem_info_wk->write( "B${excel_ind}", $val);	
				}
			}
			++$excel_ind;
		}
	# PCI information
	} elsif ($state eq "pciinfo") {
	
		$pci_info_wk->set_row(${excel_ind}-1, 30);
		
		if ($file_ind == 1) {
			$pci_info_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 4, $line, $primary_header_format);
		} else {
			$pci_info_wk->write( "A${excel_ind}", $line);
		}
		++$excel_ind;
		
	# Operating System information
	} elsif ($state eq "osinfo") {
		$os_info_wk->set_row(${excel_ind}-1, 30);
		
		# Primary header
		if ($file_ind == 1) {
			$os_info_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 1, $line, $primary_header_format);
		# Keyless data
		} elsif ($file_ind == 2) {
			$os_info_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 1, $line, $basic_format);
		# Parsing key and value formatted data
		} elsif ($file_ind >= 4) {
			my ($key, $val) = split(/=/, $line);
			
			if (defined $key) {
				$key =~ s/^\s*(.*?)\s*$/$1/;
				$os_info_wk->write( "A${excel_ind}", $key);
			}
			
			if (defined $val) {
				$val =~ s/^\s*(.*?)\s*$/$1/;
				$os_info_wk->write( "B${excel_ind}", $val);	
			}
		}
		++$excel_ind;
	# BIOS information parsing
	} elsif ($state eq "bios") {	
		$bios_info_wk->set_row(${excel_ind}-1, 30);
		
		if ($line eq "BIOS INFO (sudo dmidecode --type bios):") {
			$state_2 = "started";
		}
		
		if ($state_2 eq "started") {
			if ($excel_ind == 1) {
				$bios_info_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 1, $line, $primary_header_format);
			} elsif ($file_ind > 1) {
				my ($key, $val) = split(/:/, $line);
			
				if (defined $key) {
					$key =~ s/^\s*(.*?)\s*$/$1/;
					$bios_info_wk->write( "A${excel_ind}", $key);
				}
				
				if (defined $val) {
					$val =~ s/^\s*(.*?)\s*$/$1/;
					$bios_info_wk->write( "B${excel_ind}", $val);	
				}
			}
			++$excel_ind;
		}
	# BMC Information Parsing
	} elsif ($state eq "bmc") {
	
		$bmc_info_wk->set_row(${excel_ind}-1, 30);
		
		if ($file_ind == 1) {
			$bmc_info_wk->merge_range( 0, 0, 0, 1, "BMC INFO (sudo ipmitool bmc info):", $primary_header_format);
		} else {		
			my ($key, $val) = split(/:/, $line);
				
			if (defined $key) {
				$key =~ s/^\s*(.*?)\s*$/$1/;
				$bmc_info_wk->write( "A${excel_ind}", $key);
			}
			
			if (defined $val) {
				$val =~ s/^\s*(.*?)\s*$/$1/;
				$bmc_info_wk->write( "B${excel_ind}", $val);	
			}
		}	
		++$excel_ind;
		
	# StressAppTest Short parsing
	} elsif ($state eq "stress_short") {
		$stress_short_wk->set_row(${excel_ind}-1, 30);
		
		# Main header
		if ($file_ind == 1) {
			$stress_short_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $primary_header_format);
			++$excel_ind;
		} elsif ($file_ind == 3) {
			$stress_short_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $basic_centered_format);
			++$excel_ind;
		# Main data parsing
		} elsif ($file_ind >= 4) {
			if (index($line, "Status") != -1) {
				$stress_short_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $basic_centered_format);
				++$excel_ind;
			}
		}
	# StressAppTest Long parsing
	} elsif ($state eq "stress_long") {
		$stress_long_wk->set_row(${excel_ind}-1, 30);
		
		# Main header
		if ($file_ind == 1) {
			$stress_long_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $primary_header_format);
			++$excel_ind;
		} elsif ($file_ind == 3) {
			$stress_long_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $basic_centered_format);
			++$excel_ind;
		# Main data parsing
		} elsif ($file_ind >= 4) {
			if (index($line, "Status") != -1) {
				$stress_long_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $basic_centered_format);
				++$excel_ind;
			}
		}
	# Numa maps parsing
	} elsif ($state eq "numamaps") {
		$numamaps_wk->set_row( ${excel_ind}-1, 30);
		
		# Primary Header
		if ($file_ind == 1) {
			$numamaps_wk->write( "A${excel_ind}", $line, $primary_header_format);
		# Write the maps data into the first column
		} else {
			$numamaps_wk->write( "A${excel_ind}", $line);
		}
		++$excel_ind;
	# System topography picture
	} elsif ($state eq "lstopo") {
		$lstopo_wk->set_row( ${excel_ind}-1, 30);
	
		# Header
		if ($file_ind == 1) {
			$lstopo_wk->merge_range( 0, 0, 0, 2, $line, $primary_header_format);
			++$excel_ind;
		# System topography image
		} elsif ($file_ind == 2) {
			$lstopo_wk->insert_image( "A2", "sys_topo_${date}.png", { x_scale => 1.2, y_scale => 1.2 });
			++$excel_ind;
		}
	# Numactl parsing
	} elsif ($state eq "numactl") {
		$numactl_wk->set_row( ${excel_ind}-1, 30);

		# Primary header
		if ($file_ind == 1) {
			$numactl_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 4, $line, $primary_header_format);
			++$excel_ind;
			++$excel_ind_2;
		} elsif ($file_ind > 3) {
			# Internal state switching
			if ($line eq "Numa Policy Info (numactl --show):") {
				$state_2 = "policy";
			}
			
			# If the numactl state is the hardware info
			if ($state_2 eq "hw") {
				# Hardware Header
				if ($line eq "Numa Hardware Info (numactl --hardware):") {
					$numactl_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 1, $line, $secondary_header_format);
					++$excel_ind;
				# Main data chunk
				} elsif ($line ne "") {
					if ($node_dis eq "false") {
						my ($key, $val) = split(/:/, $line);
						$key =~ s/^\s*(.*?)\s*$/$1/;
						$val =~ s/^\s*(.*?)\s*$/$1/;
						$numactl_wk->write( "A${excel_ind}", $key);
						$numactl_wk->write( "B${excel_ind}", $val);
						
						if ($line eq "node distances:") {
							$node_dis = "true";
						}
					} else {
						$numactl_wk->write( "A${excel_ind}", $line);
					}
					++$excel_ind;
				}
			# If the numactl state is the numa policy info
			} elsif ($state_2 eq "policy") {
				if ($line eq "Numa Policy Info (numactl --show):") {
					$numactl_wk->merge_range( ${excel_ind_2}-1, 3, ${excel_ind_2}-1, 4, $line, $secondary_header_format);
					++$excel_ind_2;
				} elsif ($line ne "") {
					my ($key, $val) = split(/:/, $line);
					$key =~ s/^\s*(.*?)\s*$/$1/;
					$val =~ s/^\s*(.*?)\s*$/$1/;
					$numactl_wk->write( "D${excel_ind_2}", $key);
					$numactl_wk->write( "E${excel_ind_2}", $val);
					++$excel_ind_2;
				}
			}
			
		}
	} elsif ($state eq "numastat") {
		$numastat_wk->set_row( ${excel_ind}-1, 25);
		
		if ($file_ind == 1) {
			$numastat_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $primary_header_format);
			++$excel_ind;
		} elsif ($file_ind == 4) {
			$numastat_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $secondary_header_format);
			++$excel_ind;
		} elsif ($file_ind  == 5) {
			$line =~ s/^\s+//;
			my @splits = split(/\s\s+/, $line);
			
			$numastat_wk->write( ${excel_ind}-1, 0, "Type", $secondary_header_format);
			
			$loop_index = 1;
			
			foreach(@splits) {
				$numastat_wk->write( ${excel_ind}-1, ${loop_index}, $_, $secondary_header_format);
				++$loop_index;
				$numastat_wk->set_column( 0, ${loop_index}, 20, $basic_format);
			}
			++$excel_ind;
		} elsif ($file_ind >= 7) {
			$line =~ s/^\s+//;
			my @splits = split(/\s\s+/, $line);

			$loop_index = 0;
			
			foreach(@splits) {
				$numastat_wk->write( ${excel_ind}-1, ${loop_index}, $_);
				++$loop_index;
			}
			++$excel_ind;
		}
	}
	# Continue looping thorugh the file
	++$file_ind;
}

# Close the files after done being used
close $info;
$workbook->close;

