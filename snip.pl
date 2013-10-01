#!/usr/bin/env perl

use strict;
use Spreadsheet::XLSX;
use Getopt::Std;
use Text::Iconv;

# Name:         snip.pl 
# Version:      0.0.2
# Release:      1
# License:      Open Source 
# Group:        System
# Source:       Lateral Blast 
# URL:          N/A
# Distribution: CMDB 
# Vendor:       UNIX
# Packager:     Richard Spindler <richard@lateralblast.com.au>
# Description:  Example script to process a Service Now CMDB extract

# Changes       0.0.1 Tue  1 Oct 2013 09:15:04 EST
#               Initial version
#               0.0.2 Tue  1 Oct 2013 11:31:26 EST
#               Cleaned up output messages
#               0.0.3 Tue  1 Oct 2013 11:37:08 EST
#               Added -i switch to choose input file

my $script_name=$0;
my $script_version=`cat $script_name | grep '^# Version' |awk '{print \$3}'`;
my $options="chVi:";
my %option;
my @cmdb_data;
my $cmdb_file="cmdb.xlsx";

if ($#ARGV == -1) {
  print_usage();
}
else {
  getopts($options,\%option);
}

# If given -i set input file to file given

if ($option{'i'}) {
  $cmdb_file=$option{'i'};
}

# If given -h print usage

if ($option{'h'}) {
  print_usage();
  exit;
}

# Print script version

if ($option{'V'}) {
  print_version();
  exit;
}

# If given -c check CMDB data

if ($option{'c'}) {
  check_local_env();
  import_cmdb_data();
  check_cmdb_data();
  exit;
}

# Do some local environment checks

# Print usage

sub print_usage {
  print "\n";
  print "Usage: $script_name -$options\n";
  print "\n";
  print "-h: Display help/usage\n";
  print "-V: Display version\n";
  print "-c: Check CMDB data\n";
  print "-i: Input file (Default ./cmdb.xlsx)\n";
  print "\n";
  return;
}

# Print version

sub print_version {
  print "$script_version";
  return;
}

# Check local environment

sub check_local_env {
  if (!-e "$cmdb_file") {
    print "File $cmdb_file does not exist\n";
    exit;
  }
}

# Import CMDB
# Get the information we need and put it into an array

sub import_cmdb_data {
  my $host_name;
  my @data;
  my $line;
  my $parser=Text::Iconv->new("utf-8", "windows-1251");
  my $excel=Spreadsheet::XLSX ->new($cmdb_file,$parser);
  foreach my $sheet (@{$excel->{Worksheet}}) {
    $sheet->{MaxRow}||=$sheet->{MinRow};
    foreach my $row ($sheet->{MinRow}..$sheet->{MaxRow}) {
      $sheet->{MaxCol}||=$sheet->{MinCol};
      @data=();
      $line="";
      foreach my $col ($sheet->{MinCol}..$sheet->{MaxCol}) {
        my $cell=$sheet->{Cells}[$row][$col];
        $cell=$cell->{Val};
        $cell=~s/\n/ /g;
        push(@data,$cell);
      }
      $line=join(",",@data);
      if ($line!~/OS Service Pack/) {
        push(@cmdb_data,$line);
      }
    }
    return;
  }
}

# Check CMDB data
# Name,Class,Short description,Manufacturer,Location,OS Service Pack,OS Version,OS Address Width (bits),OS Domain,Operating System,Operational status

sub check_cmdb_data {
  my $line;
  my $lc_line;
  my $junk;
  my @data;
  my $host_name;
  my $host_class;
  my $host_info;
  my $vendor_info;
  my $loc_info;
  my $os_rev;
  my $os_ver;
  my $os_width;
  my $os_domain;
  my $os_name;
  my $status;
  my $lc_status;
  foreach $line (@cmdb_data) {
    $lc_line=lc($line);
    @data=split(/,/,$line);
    $host_name=@data[0];
    $host_class=@data[1];
    $host_info=@data[2];
    $vendor_info=@data[3];
    $loc_info=@data[4];
    $os_rev=@data[5];
    $os_ver=@data[6];
    $os_width=@data[7];
    $os_domain=@data[8];
    $os_name=@data[9];
    $status=@data[10];
    $lc_status=lc($status);
    if ($host_name=~/\s+-/) {
      ($host_name,$junk)=split(/\s+-/,$host_name);
      print "$host_name contains a description in the Hostname field\n";
    }
    if ($lc_line!~/dev|prod|test/) {
      print "$host_name does not contain any environment information (e.g. Dev / Prod / Test)\n";
    }
    if ($os_name!~/[A-z]/) {
      print "$host_name does not contain any OS information\n";
    }
    if ($os_ver!~/[0-9]/) {
      print "$host_name does not contain any OS version information\n";
    }
    if ($os_rev!~/[0-9]/) {
      print "$host_name does not contain any OS revision information\n";
    }
    if ($lc_status!~/operational|decom/) {
      print "$host_name does not contain any operational status information\n";
    }
  }
}
