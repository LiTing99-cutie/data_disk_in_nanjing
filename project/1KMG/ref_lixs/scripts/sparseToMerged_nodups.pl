################################################
#File Name: sparseToSws.pl
#Author: Up Lee 
#Mail: uplee@pku.edu.cn
#Created Time: Mon Apr 27 19:39:56 2020
################################################

#!/usr/bin/perl 
use strict;
use warnings;
use Getopt::Long;
use File::Basename;

my ($sparse,$abs, $merNo);
GetOptions(
's|spa=s'	=> \$sparse,
'a|abs=s'	=> \$abs,
'm|merNo=s'	=> \$merNo,
'h|help'	=> sub{&usage()}
)||usage();
unless(defined($sparse) && defined($abs) && defined($merNo)){
	usage();
    exit;
}

my %coord;
open ABS,"$abs" or die "Can't open $abs:$!";
while(<ABS>){
	chomp;
	my ($chr,$spos, $epos,$index) = (split "\t")[0, 1, 2, 3];
    $coord{$index}=[$chr,$spos, $epos];
}    

open SPA,"$sparse" or die "Can't open $sparse:$!";
open MER, "> $merNo" or die "Can't write to $merNo:$!";
while(<SPA>){
	chomp;
	my ($bin1, $bin2, $score) = (split "\t")[0, 1, 2];
	print MER join "\t", 0, $coord{$bin1}->[0], $coord{$bin1}->[1], 0, 1, $coord{$bin2}->[0], $coord{$bin2}->[1], 1, $score . "\n";
}

sub usage{
my $scriptName = basename $0;
print <<HELP;
Author: UpLee
Date: Thu Mar 14 16:30:58 2019
Note: This script convert contact matrix in sparse format (defined by HiC-Pro) to merged_nodups in "short with score" format, in order to generate .hic file for visualization
Usage: perl $scriptName -s -a -m
Options:
        -s --sparse	FILE    HiC-Pro sparse matrix
        -a --abs	FILE    HiC-Pro chromosome bins (abs)
        -m --merNo	FILE	Juicer supported merged_nodups file in "short with score" format
	-h --help		Print this help information
HELP
        exit(-1);
}
