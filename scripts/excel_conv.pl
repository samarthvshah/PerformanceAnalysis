#!/usr/bin/perl

use strict;
use warnings;
use Excel::Writer::XLSX;

# Getting the parameters passed in by the workload running script
my ($reportfile, $workloadsstr, $date, $type, $platform) = @ARGV;
my $filename = "Results/perf_${platform}_${type}_report_${date}/perf_${platform}_${type}_report_${date}.xlsx";
my @workloads = split(/,/, $workloadsstr);
my @states = ("cpuinfo", "meminfo", "pciinfo", "osinfo", "biosinfo", "bmcinfo", "numastat", "numactl", "numamaps", "lstopo", @workloads);

# Creating a new xlsx file
my $workbook = Excel::Writer::XLSX->new( $filename );

# Instantiating new worksheets for each of the workloads
my $cpu_info_wk;
my $mem_info_wk;
my $pci_info_wk;
my $stress_wk;
my $stream_wk;
my $fio_wk;
my $fio_data_wk;
my $numastat_wk;
my $numactl_wk;
my $numamaps_wk;
my $lstopo_wk;
my $multichase_wk;
my $os_info_wk;
my $bios_info_wk;
my $bmc_info_wk;
my $mlc_wk;

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
	} elsif ($_ eq "multichase") {
		$multichase_wk = $workbook->add_worksheet("Multichase");
		$multichase_wk->set_column('A:L',15, $basic_format);
	# Create a new worksheet for StressAppTests, setup formatting	
	} elsif ($_ eq "stress") {
		$stress_wk = $workbook->add_worksheet("StressAppTest");
		$stress_wk->set_row(0, 30);
		$stress_wk->set_row(5, 30);
		$stress_wk->set_column('A:C',30, $basic_format);
	# Create a new worksheet for STREAM, setup formatting	
	} elsif ($_ eq "stream") {
		$stream_wk = $workbook->add_worksheet("STREAM");
		$stream_wk->set_row(0, 30);
		$stream_wk->set_column('A:E', 20, $basic_format);	
	# Create a new worksheet for FIO, setup formatting		
	} elsif ($_ eq "fio") {
		$fio_wk = $workbook->add_worksheet("FIO");
		$fio_wk->set_row(0, 30);
		$fio_wk->set_column('A:R',25, $basic_format);
	# Create a new worksheet for Intel MLC, setup formatting
	} elsif ($_ eq "mlc") {
		$mlc_wk = $workbook->add_worksheet("MLC");
		$mlc_wk->set_row(0, 30);
		$mlc_wk->set_column('A:C',25, $basic_format);
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
	} elsif ($line eq "PCI INFO (sudo lspci):") {
		$state = "pciinfo";
		$file_ind = 1;
		$excel_ind = 1;
		$excel_ind_2 = 1;
	} elsif ($line eq "OS INFO (cat /etc/lsb-release, uname -r):") {
		$state = "osinfo";
		$file_ind = 1;
		$excel_ind = 1;
		$excel_ind_2 = 1;
	} elsif ($line eq "StressAppTest (Memory Bandwidth and Latency):") {
		$state = "stress";
		$file_ind = 1;
		$excel_ind = 1;
		$excel_ind_2 = 1;
		$stress_wk->set_row(6, 30);
	} elsif ($line eq "STREAM:") {
		$state = "stream";
		$file_ind = 1;
		$excel_ind = 1;
		$excel_ind_2 = 1;
	} elsif ($line eq "Flexible I/O Tester:") {
		$state = "fio";
		$file_ind = 1;
		$excel_ind = 1;
		$excel_ind_2 = 1;
		
#		create_timing_data();
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
	} elsif ($line eq "Intel Memory Latency Checker (sudo ./src/mlc_v3.9a/Linux/mlc):") {
		$state = "mlc";
		$file_ind = 1;
		$excel_ind = 1;
		$excel_ind_2 = 1;
		$state_2 = "start";
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
		
	# StressAppTest parsing
	} elsif ($state eq "stress") {
		$stress_wk->set_row(${excel_ind}-1, 30);
		
		# Main header
		if ($file_ind == 1) {
			$stress_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $primary_header_format);
			++$excel_ind;
		} elsif ($file_ind >= 3 && $file_ind < 7) {
			$stress_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $basic_centered_format);
			++$excel_ind;
		# Main data parsing
		} elsif ($file_ind >= 7) {
		
			if ($file_ind == 7) {
				$stress_wk->write( "A${excel_ind}", "Type", $secondary_header_format);
				$stress_wk->write( "B${excel_ind}", "Total Amount", $secondary_header_format);
				$stress_wk->write( "C${excel_ind}", "Bandwidth", $secondary_header_format);
				
				++$excel_ind;
			}
			
			if (index($line, "Stats") != -1) {
				$stat_ind = index($line, "Stats");
				$line = substr($line, $stat_ind);
				
				my ($stats, $key, $val) = split(/:/, $line);
				
				if (defined $key) {
					$key =~ s/^\s*(.*?)\s*$/$1/;
					$stress_wk->write( "A${excel_ind}", $key);
				}
		
				if (defined $val) {
					$val =~ s/^\s*(.*?)\s*$/$1/;

					my ($total, $bandw) = split(/ at /, $val);
										
					if (defined $bandw) {
						$total = substr( $total, 0, -1);
						$bandw = substr( $bandw, 0, -4);
					}
					
					if (defined $total) {
						$stress_wk->write( "B${excel_ind}", $total);
					}
					
					if (defined $bandw) {
						$stress_wk->write( "C${excel_ind}", $bandw);
					}
				}
				++$excel_ind;
			}	
			
			if (index($line, "Status") != -1) {
				$stress_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $basic_centered_format);
				++$excel_ind;
				
				my $stress_band_data_chart = $workbook->add_chart( type => 'bar', name => 'Bandwidth Data', embedded => 1 );
			
				$stress_band_data_chart->add_series(
					categories => '=StressAppTest!$A$9:$A$14',
					values => '=StressAppTest!$C$9:$C$14',
					name => 'Bandwidth',
				);
				
				$stress_band_data_chart->set_y_axis( name => 'Type of Operation');
				$stress_band_data_chart->set_x_axis( name => 'Bandwidth (mb/s)');
				$stress_band_data_chart->set_legend( none => 1 );
				$stress_band_data_chart->set_title( name => 'Bandwidth Data' );
				
				$stress_wk->insert_chart( 'A17', $stress_band_data_chart);
				
				
				my $stress_total_data_chart = $workbook->add_chart( type => 'bar', name => 'Total Data', embedded => 1 );
			
				$stress_total_data_chart->add_series(
					categories => '=StressAppTest!$A$9:$A$14',
					values => '=StressAppTest!$B$9:$B$14',
					name => 'Total Amount',
				);
				
				$stress_total_data_chart->set_y_axis( name => 'Type of Operation');
				$stress_total_data_chart->set_x_axis( name => 'Total Amount (mb)');
				$stress_total_data_chart->set_legend( none => 1 );
				$stress_total_data_chart->set_title( name => 'Total Amount Data' );
				
				$stress_wk->insert_chart( 'A32', $stress_total_data_chart);
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
	} elsif ($state eq "stream") {
		$stream_wk->set_row( ${excel_ind}-1, 25);
		
		if ($file_ind == 1) {
			$stream_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 4, $line, $primary_header_format);
			++$excel_ind;
		} elsif ($file_ind == 3) {
			$stream_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 4, $line, $basic_centered_format);
			++$excel_ind;
		} elsif ($file_ind == 16 || $file_ind == 17) {
			$stream_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 4, $line, $basic_centered_format);
			++$excel_ind;
		} elsif ($file_ind >= 29 && $file_ind < 34) {
			$line =~ s/^\s+//;
			my @splits = split(/\s\s+/, $line);

			$loop_index = 0;
			
			foreach(@splits) {
				if ($file_ind == 29) {
					$stream_wk->write( ${excel_ind}-1, ${loop_index}, $_, $secondary_header_format);
				} else {
					$stream_wk->write( ${excel_ind}-1, ${loop_index}, $_);
				}

				++$loop_index;
			}
			++$excel_ind;
		} elsif ($file_ind == 34) {
		
			my $stream_band_data_chart = $workbook->add_chart( type => 'bar', name => 'Bandwidth Data', embedded => 1 );
			
			$stream_band_data_chart->add_series(
				categories => '=STREAM!$A$5:$A$8',
				values => '=STREAM!$B$5:$B$8',
				name => 'Best Rate',
			);
			
			$stream_band_data_chart->set_y_axis( name => 'Type of Operation');
			$stream_band_data_chart->set_x_axis( name => 'Bandwidth (mb/s)');
			$stream_band_data_chart->set_legend( none => 1 );
			$stream_band_data_chart->set_title( name => 'Bandwidth Data' );
			
			$stream_wk->insert_chart( 'A10', $stream_band_data_chart);
			
			
			
			my $stream_timing_data_chart = $workbook->add_chart( type => 'bar', name => 'Timing Data', embedded => 1 );
		
			$stream_timing_data_chart->add_series(
				categories => '=STREAM!$A$5:$A$8',
				values => '=STREAM!$D$5:$D$8',
				name => 'Min Time',
			);
			
			$stream_timing_data_chart->add_series(
				categories => '=STREAM!$A$5:$A$8',
				values => '=STREAM!$C$5:$C$8',
				name => 'Avg Time',
			);
			
			$stream_timing_data_chart->add_series(
				categories => '=STREAM!$A$5:$A$8',
				values => '=STREAM!$E$5:$E$8',
				name => 'Max Time',
			);
			
			$stream_timing_data_chart->set_y_axis( name => 'Type of Operation');
			$stream_timing_data_chart->set_x_axis( name => 'Timing (sec)');
			$stream_timing_data_chart->set_title( name => 'Timing Data' );
			
			$stream_wk->insert_chart( 'A25', $stream_timing_data_chart);
		}
	} elsif ($state eq "fio") {
		$fio_wk->set_row( ${excel_ind}-1, 25);
		
		if ($file_ind == 1) {
			$fio_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 7, $line, $primary_header_format);
			++$excel_ind;	
			++$excel_ind_2;		
		} elsif ($file_ind == 4) {
			$fio_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 7, $line, $basic_centered_format);
			++$excel_ind;
			++$excel_ind_2;	
		} elsif ($file_ind == 13) {
			$fio_wk->merge_range( ${excel_ind}-2, 0, ${excel_ind}-2, 5, $line, $basic_centered_format);
			++$excel_ind;
			++$excel_ind_2;	
		} elsif ($file_ind == 5) {
			$fio_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 7, $line, $secondary_header_format);
			++$excel_ind;
			++$excel_ind_2;	
		} elsif ($file_ind == 6) {
		
			$fio_wk->write(${excel_ind}, 0, "Data Type", $secondary_header_format);
			$fio_wk->write(${excel_ind}, 1, "Min", $secondary_header_format);
			$fio_wk->write(${excel_ind}, 2, "Avg", $secondary_header_format);
			$fio_wk->write(${excel_ind}, 3, "Max", $secondary_header_format);
			$fio_wk->write(${excel_ind}, 4, "Std Dev", $secondary_header_format);
			$fio_wk->write(${excel_ind}, 5, "Samples", $secondary_header_format);
			
			++$excel_ind;
			++$excel_ind_2;	
		} elsif (($file_ind >= 14 && $file_ind < 17) || ($file_ind >= 23 && $file_ind < 25)) {
			my ($key, $val) = split(/:/, $line);
			$key =~ s/^\s*(.*?)\s*$/$1/;
			$val =~ s/^\s*(.*?)\s*$/$1/;
			
			$fio_wk->write( "A${excel_ind}", $key);
			
			my @splits = split(/,/, $val);
			
			foreach(@splits) {
				$_ =~ s/^\s+//;
				
				my ($key_2, $val_2) = split(/=/, $_);
				
				if ($key_2 eq "min") {
					$fio_wk->write(${excel_ind}-1, 1, $val_2);
				} elsif ($key_2 eq "avg") {
					$fio_wk->write(${excel_ind}-1, 2, $val_2);
				} elsif ($key_2 eq "max") {
					$fio_wk->write(${excel_ind}-1, 3, $val_2);
				} elsif ($key_2 eq "stdev") {
					$fio_wk->write(${excel_ind}-1, 4, $val_2);
				} elsif ($key_2 eq "samples") {
					$fio_wk->write(${excel_ind}-1, 5, $val_2);
				}
			}
			
			$loop_index = 1;
			
			++$excel_ind;
		} elsif ($file_ind == 17) {
			$line =~ s/^\s+//;
			$fio_wk->write(${excel_ind_2}-1, 7, $line);
			++$excel_ind_2;
		} elsif ($file_ind >= 18 && $file_ind < 23) {
			my @splits = split(/,/, $line);	
			
			$loop_index = 7;
			
			foreach(@splits) {
				$_ = substr $_, 1;
				$_ =~ s/^\s+//;
				$fio_wk->write(${excel_ind_2}-1, ${loop_index}, $_);
				++$loop_index;
			}
			
			if ($file_ind == 22) {
				++$excel_ind_2;	
			}
			++$excel_ind_2;
		} elsif ($file_ind == 34) {
			
			my $fio_lat_data_chart = $workbook->add_chart( type => 'bar', name => 'Latency Data', embedded => 1 );
			
			$fio_lat_data_chart->add_series(
				categories => '=FIO!$B$5:$E$5',
				values => '=FIO!$B$8:$E$8',
				name => 'Latency',
			);
			
			$fio_lat_data_chart->set_y_axis( name => 'Value Type');
			$fio_lat_data_chart->set_x_axis( name => 'Latency (usec)');
			$fio_lat_data_chart->set_legend( none => 1 );
			$fio_lat_data_chart->set_title( name => 'Latency Data' );
			
			$fio_wk->insert_chart( 'A12', $fio_lat_data_chart);
			
			
			my $fio_clat_data_chart = $workbook->add_chart( type => 'bar', name => 'clat Data', embedded => 1 );
			
			$fio_clat_data_chart->add_series(
				categories => '=FIO!$B$5:$E$5',
				values => '=FIO!$B$7:$E$7',
				name => 'Latency',
			);
			
			$fio_clat_data_chart->set_y_axis( name => 'Value Type');
			$fio_clat_data_chart->set_x_axis( name => 'Latency (nsec)');
			$fio_clat_data_chart->set_legend( none => 1 );
			$fio_clat_data_chart->set_title( name => 'Clat Data' );
			
			$fio_wk->insert_chart( 'A27', $fio_clat_data_chart);
			
			
			my $fio_slat_data_chart = $workbook->add_chart( type => 'bar', name => 'Slat Data', embedded => 1 );
			
			$fio_slat_data_chart->add_series(
				categories => '=FIO!$B$5:$E$5',
				values => '=FIO!$B$6:$E$6',
				name => 'Latency',
			);
			
			$fio_slat_data_chart->set_y_axis( name => 'Value Type');
			$fio_slat_data_chart->set_x_axis( name => 'Latency (usec)');
			$fio_slat_data_chart->set_legend( none => 1 );
			$fio_slat_data_chart->set_title( name => 'Slat Data' );
			
			$fio_wk->insert_chart( 'D12', $fio_slat_data_chart);
			
				
			my $fio_band_data_chart = $workbook->add_chart( type => 'bar', name => 'Bandwidth Data', embedded => 1 );
			
			$fio_band_data_chart->add_series(
				categories => '=FIO!$B$5:$E$5',
				values => '=FIO!$B$9:$E$9',
				name => 'Bandwidth',
			);
			
			$fio_band_data_chart->set_y_axis( name => 'Value Type');
			$fio_band_data_chart->set_x_axis( name => 'Bandwidth (mb/s)');
			$fio_band_data_chart->set_legend( none => 1 );
			$fio_band_data_chart->set_title( name => 'Bandwidth Data' );
			
			$fio_wk->insert_chart( 'D27', $fio_band_data_chart);
		}
	} elsif ($state eq "multichase") {
		$multichase_wk->set_row( ${excel_ind}-1, 20);
		
		if ($file_ind == 1) {
			$multichase_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 11, $line, $primary_header_format);
			++$excel_ind;
		} elsif ($file_ind >= 4 && $file_ind < 8) {
			if ($file_ind == 4) {
				$multichase_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 3, $line, $secondary_header_format);
				++$excel_ind;
			} elsif ($file_ind == 6 || $file_ind == 7) {
				$multichase_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 3, $line, $basic_centered_format);
				++$excel_ind;
			}


		} elsif ($file_ind >= 9 && $file_ind < 14) {
			if ($file_ind == 9) {
				$multichase_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 11, $line, $secondary_header_format);
				++$excel_ind;
			} elsif ($file_ind == 11 || $file_ind == 12) {
				my @splits = split(/,/, $line);	
				$loop_index = 0;
			
				foreach(@splits) {
					$_ =~ s/^\s+//;
					$multichase_wk->write(${excel_ind}-1, ${loop_index}, $_);
					++$loop_index;
				}
				++$excel_ind;
			} elsif ($file_ind == 13) {
				++$excel_ind;
			}
		} elsif ($file_ind >= 15 && $file_ind < 20) {
			if ($file_ind == 15) {
				$multichase_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 11, $line, $secondary_header_format);
				++$excel_ind;
			} elsif ($file_ind == 17 || $file_ind == 18) {
				my @splits = split(/,/, $line);	
				$loop_index = 0;
			
				foreach(@splits) {
					$_ =~ s/^\s+//;
					$multichase_wk->write(${excel_ind}-1, ${loop_index}, $_);
					++$loop_index;
				}
				++$excel_ind;
			} elsif ($file_ind == 19) {
				++$excel_ind;
			}
		} elsif ($file_ind >= 21 && $file_ind < 26) {
			if ($file_ind == 21) {
				$multichase_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 11, $line, $secondary_header_format);
				++$excel_ind;
			} elsif ($file_ind == 23 || $file_ind == 24) {
				@splits = split(/,/, $line);	
				$loop_index = 0;
			
				foreach(@splits) {
					$_ =~ s/^\s+//;
					$multichase_wk->write(${excel_ind}-1, ${loop_index}, $_);
					++$loop_index;
				}
				++$excel_ind;
			} elsif ($file_ind == 25) {
				++$excel_ind;
			}
		} elsif ($file_ind >= 27 && $file_ind < 43) {
			if ($file_ind == 27) {
				$multichase_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 11, $line, $secondary_header_format);
				++$excel_ind;
			} elsif ($file_ind == 29 || $file_ind == 31 || $file_ind == 37) {
				$multichase_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 11, $line, $basic_centered_format);
				++$excel_ind;
			} elsif ($file_ind != 28 && $file_ind != 43) {
				if ($file_ind == 30) {
					$loop_index = 0;
				} else {
					$loop_index = 1;
				}
				
				my ($key, $value) = split(/:/, $line);	
				@splits = split(/\s+/, $key);
				my @splits_2 = split(/\s+/, $value);
				
				foreach(@splits) {
					$_ =~ s/^\s+//;
					
					if ($_ ne "") {
						$multichase_wk->write(${excel_ind}-1, ${loop_index}, $_);
						++$loop_index;
					}
				}
				
				foreach(@splits_2) {
					$_ =~ s/^\s+//;
					
					if ($_ ne "") {
						$multichase_wk->write(${excel_ind}-1, ${loop_index}, $_);
						++$loop_index;
					}
				}
				++$excel_ind;
			}
		} else {
			if ($file_ind == 45) {
				$multichase_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 5, $line, $secondary_header_format);
				++$excel_ind;
			} elsif ($file_ind == 47 || $file_ind == 48) {
				$multichase_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 5, $line, $basic_centered_format);
				++$excel_ind;
			} elsif ($file_ind >= 50) {
				if ($file_ind == 50) {
					$loop_index = 1;
				} else {
					$loop_index = 0;
				}
			
				my ($key_2, $value_2) = split(/:/, $line);	
				
				if ( defined $key_2 ) {
					@splits = split(/\s+/, $key_2);
					
					foreach(@splits) {
						$_ =~ s/^\s+//;
						
						if ($_ ne "") {
							$multichase_wk->write(${excel_ind}-1, ${loop_index}, $_);
							++$loop_index;
						}
					}
				}
				
				
				if (defined $value_2 ) {
					my @splits_2 = split(/\s+/, $value_2);
				
					foreach(@splits_2) {
						$_ =~ s/^\s+//;
						
						if ($_ ne "") {
							$multichase_wk->write(${excel_ind}-1, ${loop_index}, $_);
							++$loop_index;
						}
					}
				}
				
				++$excel_ind;
			} elsif ($file_ind == 44) {
				++$excel_ind;
			}
		}
	} elsif ($state eq "mlc") {
		$mlc_wk->set_row( ${excel_ind}-1, 20);
		
		if ($file_ind == 1) {
			$mlc_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $primary_header_format);
			++$excel_ind;
		}
		
		
		if ($line eq "Measuring Peak Injection Memory Bandwidths for the system") {
			$state_2 = "peakbw";
			$excel_ind_2 = 0;
		} elsif ($line eq "Measuring Memory Bandwidths between nodes within system") {
			$state_2 = "bandbtw";
			$excel_ind_2 = 0;
		} elsif ($line eq "Measuring Loaded Latencies for the system") {
			$state_2 = "loadlat";
			$excel_ind_2 = 0;
		} elsif ($line eq "Measuring cache-to-cache transfer latency (in ns)...") {
			$state_2 = "translat";
			$excel_ind_2 = 0;
		} elsif ($line eq "Measuring idle latencies (in ns)...") {
			$state_2 = "idle";
			$excel_ind_2 = 0;
		}
		
		if ($state_2 eq "idle") {
			if ($excel_ind_2 == 0) {
				$mlc_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $secondary_header_format);
				++$excel_ind;
				++$excel_ind_2;
			} elsif ($excel_ind_2 == 1) {
				@splits = split(/\s\s+/, $line);
				
				$loop_index = 1;
				
				foreach(@splits) {
					$_ =~ s/^\s+//;
					
					if ($_ ne "") {
						$mlc_wk->write(${excel_ind}-1, ${loop_index}, $_);
						++$loop_index;
					}
				}
				++$excel_ind;
				++$excel_ind_2;
			} else {
				@splits = split(/\s\s+/, $line);
				
				$loop_index = 0;
				
				foreach(@splits) {
					$_ =~ s/^\s+//;
					
					if ($_ ne "") {
						$mlc_wk->write(${excel_ind}-1, ${loop_index}, $_);
						++$loop_index;
					}
				}
				++$excel_ind;
				++$excel_ind_2;
			}
		} elsif ($state_2 eq "peakbw") {
			if ($excel_ind_2 == 0) {
				$mlc_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $secondary_header_format);
				++$excel_ind;
				++$excel_ind_2;
			} elsif ($excel_ind_2 < 4) {
				$mlc_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $basic_centered_format);
				++$excel_ind;
				++$excel_ind_2;
			} else {
				my ($key, $val) = split(/:\s/, $line);
				
				if (defined $key) {
					$key =~ s/^\s*(.*?)\s*$/$1/;
					$mlc_wk->write( "A${excel_ind}", $key);
				}
				
				if (defined $val) {
					$val =~ s/^\s*(.*?)\s*$/$1/;
					$mlc_wk->write( "B${excel_ind}", $val);
				}
				++$excel_ind;
				++$excel_ind_2;
			}
		} elsif ($state_2 eq "bandbtw") {
			if ($excel_ind_2 == 0) {
				$mlc_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $secondary_header_format);
				++$excel_ind;
				++$excel_ind_2;
			} elsif ($excel_ind_2 < 4) {
				$mlc_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $basic_centered_format);
				++$excel_ind;
				++$excel_ind_2;	
			} elsif ($excel_ind_2 == 4) {
				@splits = split(/\s\s+/, $line);
				
				$loop_index = 1;
				
				foreach(@splits) {
					$_ =~ s/^\s+//;
					
					if ($_ ne "") {
						$mlc_wk->write(${excel_ind}-1, ${loop_index}, $_);
						++$loop_index;
					}
				}
				++$excel_ind;
				++$excel_ind_2;
			} else {
				@splits = split(/\s\s+/, $line);
				
				$loop_index = 0;
				
				foreach(@splits) {
					$_ =~ s/^\s+//;
					
					if ($_ ne "") {
						$mlc_wk->write(${excel_ind}-1, ${loop_index}, $_);
						++$loop_index;
					}
				}
				++$excel_ind;
				++$excel_ind_2;
			}
		} elsif ($state_2 eq "loadlat") {
			if ($excel_ind_2 == 0) {
				$mlc_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $secondary_header_format);
				++$excel_ind;
				++$excel_ind_2;
				
				
				my $mlc_bwlat_curve_chart = $workbook->add_chart( type => 'line', name => 'Bandwidth Latency Curve Data', embedded => 1 );
				
				$mlc_bwlat_curve_chart->add_series(
					categories => '=MLC!$B$30:$B$48',
					values => '=MLC!$C$30:$C$48',
					name => 'Bandwidth Latency Curve',
				);
				
				$mlc_bwlat_curve_chart->set_x_axis( name => 'Latency (ns)');
				$mlc_bwlat_curve_chart->set_y_axis( name => 'Bandwidth (mb/s)');
				$mlc_bwlat_curve_chart->set_legend( none => 1 );
				$mlc_bwlat_curve_chart->set_title( name => 'Bandwidth Latency Curve' );
			
				$mlc_wk->insert_chart( 'D27', $mlc_bwlat_curve_chart);
			} elsif ($excel_ind_2 < 3) {
				$mlc_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $basic_centered_format);
				++$excel_ind;
				++$excel_ind_2;	
			} elsif (index($line, "=") == -1) {
				@splits = split(/\s+/, $line);
				
				$loop_index = 0;
				
				foreach(@splits) {
					$_ =~ s/^\s+//;
					
					if ($_ ne "") {
						$mlc_wk->write(${excel_ind}-1, ${loop_index}, $_);
						++$loop_index;
					}
				}
				++$excel_ind;
				++$excel_ind_2;
			}
		} elsif ($state_2 eq "translat") {
			if ($excel_ind_2 == 0) {
				$mlc_wk->merge_range( ${excel_ind}-1, 0, ${excel_ind}-1, 2, $line, $secondary_header_format);
				++$excel_ind;
				++$excel_ind_2;
			} else {
				my ($key, $val) = split(/\t+/, $line);
				
				if (defined $key) {
					$key =~ s/^\s*(.*?)\s*$/$1/;
					$mlc_wk->write( "A${excel_ind}", $key);
				}
				
				if (defined $val) {
					$val =~ s/^\s*(.*?)\s*$/$1/;
					$mlc_wk->write( "B${excel_ind}", $val);
				}
				++$excel_ind;
				++$excel_ind_2;
			}
		}
	
	}
	# Continue looping thorugh the file
	++$file_ind;
}

# Close the files after done being used
close $info;
$workbook->close;



sub create_timing_data
{
			# Create new worksheet for the full fio data collected into the csv file to be later turned into a chart
			$fio_data_wk = $workbook->add_worksheet("FIO Full Data");
			$fio_data_wk->set_column('A:AB',20, $basic_format);
		
			open my $FH, "fio_csv_${date}_job0.csv" or die "Cannot open csv file: $!\n";	
			my ($x, $y) = (0,0);
			
			while (<$FH>) {
				@splits = split /,/, $_;
				
				foreach my $c (@splits) {
					if ($x == 0) {
						$fio_data_wk->write_string($x, $y++, $c, $basic_centered_format);
					} elsif ($c ne " " && $c ne " \n" && $c ne "\n") {
						$fio_data_wk->write_number($x, $y++, $c);
					} else {
						$y++;
					}
				}
				$x++;$y=0;
			}
			
			close $FH;
			
			my $fio_data_chart = $workbook->add_chart( type => 'scatter', subtype => 'smooth', name => 'Timing Data');
			
			$fio_data_chart->add_series(
				categories => '=FIO Full Data!$A$2:$A$350',,
				values => '=FIO Full Data!$E$2:$E$350',
				name => 'Timing Data',
			);
			
			$fio_data_chart->set_x_axis( name => 'Times (ns)');
			$fio_data_chart->set_y_axis( name => '# of timesc');
}
