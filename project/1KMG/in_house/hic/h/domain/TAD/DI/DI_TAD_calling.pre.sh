################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Sat May 30 17:23:10 2020
################################################

#!/bin/sh 

#### 2020-07-04 ####
############################################################
## Call TAD using DI method described in Dixon et al.     ##
## NOTE: This script implements processes befor HMM (pre) ##
############################################################

chromSize=/rd1/user/lixs/Projects/1KMG/tools/HiC-Pro_2.11.4/annotation/chrom_hg38_comChr.chrom.sizes
domainCallDir=/rd1/user/lixs/Projects/1KMG/tools/domaincaller/domaincall_software/perl_scripts
binSize=$1
winSize=$2
normal=$3 ## say iced
name=$4

DiDensMatDir=/rd1/user/lixs/Projects/1KMG/HiC/human_PFC/hg38_comChr/allValidPairs/contactMap/matrix/DI_dense/iced/${binSize}

echo "*** 1 DI TAD calling for bin size $binSize, windows size $winSize"

## 1 Calculate DI from DI dense matrix (domainCaller DI_from_matrix.pl)
echo "  ** Calculate DI from DI dense matrix"
[ ! -f ./$normal/bin${binSize}_win${winSize}/DI ] && mkdir -p ./$normal/bin${binSize}_win${winSize}/DI
ls -d $DiDensMatDir/* | while read mat
do
	chr=`basename $mat | egrep -o 'chr[a-zA-Z0-9]+'`
	echo "    * Calculate DI for $chr"
	perl $domainCallDir/DI_from_matrix.pl  $mat $binSize $winSize $chromSize > ./$normal/bin${binSize}_win${winSize}/DI/${chr}_${name}.DI
done

## 2 Concatenate DI's for each chromosome to make a "whole genome DI". 
# chrM, chrX and chrY are called as chr21, chr22 and chr23.
echo '*** 2 Concatenate DI for each chromosome to make a "whole genome DI"'
[ -f ./$normal/bin${binSize}_win${winSize}/DI/merged_${name}.DI  ] && rm ./$normal/bin${binSize}_win${winSize}/DI/merged_${name}.DI && echo "** merged removed"
cut -f1 $chromSize | while read chr
do
	cat ./$normal/bin${binSize}_win${winSize}/DI/${chr}_${name}.DI >> ./$normal/bin${binSize}_win${winSize}/DI/merged_${name}.DI
done
sed -i 's/M/23/g;s/X/24/g;s/Y/25/g' ./$normal/bin${binSize}_win${winSize}/DI/merged_${name}.DI ## Note different chromosome numbers among species

<<!
## 3 HMM using matlab 
echo '*** HMM using matlab in windows'
# HMM_calls.m was implemented in windows
mkdir -p ./$normal/bin${binSize}_win${winSize}/HMM
# HMM_calls.m and HMM output were transferred from windows and stored in ./$normal/bin${binSize}_win${winSize}/HMM
# (1) HMM_calls.m
# (2) merged_${name}.hmm
!
#### EO 2020-07-04 ####
