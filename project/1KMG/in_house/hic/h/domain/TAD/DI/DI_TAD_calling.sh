################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Sat May 30 17:23:10 2020
################################################

#!/bin/sh 

#### 2020-06-01 ####
########################################################
## Call TAD using DI method described in Dixon et al. ##
########################################################

chromSize=/rd1/user/lixs/Projects/1KMG/tools/HiC-Pro_2.11.4/annotation/chrom_rheMac10Plus.noChrUn.sizes
domainCallDir=/rd1/user/lixs/Projects/1KMG/tools/domaincaller/domaincall_software/perl_scripts
binSize=$1
winSize=$2
normal=$3 ## say iced
DiDensMatDir=/rd1/user/lixs/Projects/1KMG/HiC/macaque_PFC_20200518/rheMac10Plus/comChrom/contactMap/validPairs/matrix/DI_dense/iced/${binSize}

<<!
echo "*** DI TAD calling for bin size $binSize, windows size $winSize"

## 1 Calculate DI from DI dense matrix (domainCaller DI_from_matrix.pl)
echo "*** Calculate DI from DI dense matrix"
[ ! -f ./$normal/bin${binSize}_win${winSize}/DI ] && mkdir -p ./$normal/bin${binSize}_win${winSize}/DI
ls -d $DiDensMatDir/* | while read mat
do
	chr=`basename $mat | egrep -o 'chr[a-zA-Z0-9]+'`
	echo "** Calculate DI for $chr"
	perl $domainCallDir/DI_from_matrix.pl  $mat $binSize $winSize $chromSize > ./$normal/bin${binSize}_win${winSize}/DI/${chr}_macaque_PFC_20200518.DI
done

## 2 Concatenate DI's for each chromosome to make a "whole genome DI". 
# chrM, chrX and chrY are called as chr21, chr22 and chr23.
echo '*** Concatenate DI for each chromosome to make a "whole genome DI"'
[ -f ./$normal/bin${binSize}_win${winSize}/DI/merged_macaque_PFC_20200518.DI  ] && rm ./$normal/bin${binSize}_win${winSize}/DI/merged_macaque_PFC_20200518.DI && echo "** merged removed"
cut -f1 $chromSize | while read chr
do
	cat ./$normal/bin${binSize}_win${winSize}/DI/${chr}_macaque_PFC_20200518.DI >> ./$normal/bin${binSize}_win${winSize}/DI/merged_macaque_PFC_20200518.DI
done
sed -i 's/M/21/g;s/X/22/g;s/Y/23/g' ./$normal/bin${binSize}_win${winSize}/DI/merged_macaque_PFC_20200518.DI

## 3 HMM using matlab 
echo '*** HMM using matlab in windows'
# HMM_calls.m was implemented in windows
mkdir -p ./$normal/bin${binSize}_win${winSize}/HMM
# HMM_calls.m and HMM output were transferred from windows and stored in ./$normal/bin${binSize}_win${winSize}/HMM
# (1) HMM_calls.m
# (2) merged_macaque_PFC_20200518.hmm
!
## 4 Post-processing
echo '*** Post-processing'
# 4.1 7col
perl $domainCallDir/file_ends_cleaner.pl \
	./$normal/bin${binSize}_win${winSize}/HMM/merged_macaque_PFC_20200518.hmm \
	./$normal/bin${binSize}_win${winSize}/DI/merged_macaque_PFC_20200518.DI \
	| perl $domainCallDir/converter_7col.pl > ./$normal/bin${binSize}_win${winSize}/HMM/merged_macaque_PFC_20200518.7col

# 4.2 Domain
mkdir -p ./$normal/bin${binSize}_win${winSize}/domain
[ -f ./$normal/bin${binSize}_win${winSize}/merged_macaque_PFC_20200518.domain  ] && rm -f ./$normal/bin${binSize}_win${winSize}/merged_macaque_PFC_20200518.domain
cut -f1 $chromSize | uniq | while read chr
do
	# split
	awk -v chr=$chr '$1==chr' ./$normal/bin${binSize}_win${winSize}/HMM/merged_macaque_PFC_20200518.7col  > ./$normal/bin${binSize}_win${winSize}/HMM/${chr}_macaque_PFC_20200518.7col
	# final domain
	perl $domainCallDir/hmm_probablity_correcter.pl \
		./$normal/bin${binSize}_win${winSize}/HMM/${chr}_macaque_PFC_20200518.7col  2 0.99 20000 \
		| perl $domainCallDir/hmm-state_caller.pl $chromSize $chr \
		| perl $domainCallDir/hmm-state_domains.pl > ./$normal/bin${binSize}_win${winSize}/domain/${chr}_macaque_PFC_20200518.domain
	# merge
	cat ./$normal/bin${binSize}_win${winSize}/domain/${chr}_macaque_PFC_20200518.domain >> ./$normal/bin${binSize}_win${winSize}/domain/merged_macaque_PFC_20200518.domain
	sed -i 's/chr21/chrM/g;s/chr22/chrX/g;s/chr23/chrY/g'  ./$normal/bin${binSize}_win${winSize}/domain/merged_macaque_PFC_20200518.domain
done
#### EO 2020-06-01 ####
