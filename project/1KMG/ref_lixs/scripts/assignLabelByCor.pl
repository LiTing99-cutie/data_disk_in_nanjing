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

my ($cor,$set, $out);
GetOptions(
'c|cor=s'	=> \$cor,
's|set=s'	=> \$set,
'o|out=s'	=> \$out,
'h|help'	=> sub{&usage()}
)||usage();
unless(defined($cor) && defined($set) && defined($out)){
	usage();
    exit;
}

my %correlation;
open COR,"$cor" or die "Can't open $cor:$!";
while(<COR>){
	chomp;
	my ($chr,$cor) = (split "\t")[0, 1];
    $correlation{$chr}=$cor;
}    

open SET,"$set" or die "Can't open $set:$!";
open OUT, "> $out" or die "Can't write to $out:$!";
print OUT join "\t", "#chr", "start", "end", "eigenvector", "correlation", "label" . "\n";
while(<SET>){
	chomp;
	my ($chr, $spos, $epos,$eigenType) = (split "\t")[0, 1, 2, 3];
	my $label; 
	if($correlation{$chr} > 0){
		$label = $eigenType eq "posiEigen" ? "A": "B";	
	}else{
		$label = $eigenType eq "posiEigen" ? "B": "A";
	}
	print OUT join "\t", $chr, $spos, $epos, $eigenType, $correlation{$chr}, $label . "\n";
}

sub usage{
my $scriptName = basename $0;
print <<HELP;
Author: UpLee
Date: Fri May 7 16:30:58 2020
Note: This script labels two sets defined by eigenvector with Compartment A/B based on correlation between gene density and eigenvector (positive correlation: positive eigenvector for A, negative for B; negative correlation: positvie eigenvector for B, negative for A).
Usage: perl $scriptName -c <correlation file> -s <two set partitioned by eigenvector> -o <compartment label file>
Options:
        -c --cor	FILE    correlation for each individual chrmosome (The first two columns: <chromosome> <correlation coefficient>)
        -s --set	FILE	two sets defined by eigenvector (Format: <chr> <spos> <epos> <eigenType [negaEigen/posiEigen]>)
        -o --out	FILE	Chromosomal intervals labelled with A/B (Format: <chr> <spos> <epos> <eigenType><correlation coefficient><label [A/B]>)
	-h --help		Print this help information
HELP
        exit(-1);
}
