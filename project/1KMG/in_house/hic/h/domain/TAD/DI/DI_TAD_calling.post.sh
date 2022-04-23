################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Sat May 30 17:23:10 2020
################################################

#!/bin/sh 

#### 2020-06-13 ####
#############################################################
## Call TAD using DI method described in Dixon et al.      ##
## NOTE: This script implements processes befor HMM (post) ##
#############################################################

chromSize=/rd1/user/lixs/Projects/1KMG/tools/HiC-Pro_2.11.4/annotation/chrom_hg38_comChr.chrom.sizes
domainCallDir=/rd1/user/lixs/Projects/1KMG/tools/domaincaller/domaincall_software/perl_scripts
binSize=$1
winSize=$2
normal=$3 ## say iced
name=$4

## 3 HMM using matlab 
echo '*** 3 HMM using matlab in windows'
# HMM_calls.m was implemented in windows
[  ! -d ./$normal/bin${binSize}_win${winSize}/HMM  ] && mkdir -p ./$normal/bin${binSize}_win${winSize}/HMM
if [ -f ./$normal/bin${binSize}_win${winSize}/merged_${name}.hmm ];then
mv ./$normal/bin${binSize}_win${winSize}/merged_${name}.hmm ./$normal/bin${binSize}_win${winSize}/HMM/
# HMM_calls.m and HMM output were transferred from windows and stored in ./$normal/bin${binSize}_win${winSize}/HMM
# (1) HMM_calls.m
# (2) merged_${name}.hmm

## 4 Post-processing
echo '*** 1 Post-processing'
# 4.1 7col
echo -e '  ** 7col......'
perl $domainCallDir/file_ends_cleaner.pl \
	./$normal/bin${binSize}_win${winSize}/HMM/merged_${name}.hmm \
	./$normal/bin${binSize}_win${winSize}/DI/merged_${name}.DI \
	| perl $domainCallDir/converter_7col.pl > ./$normal/bin${binSize}_win${winSize}/HMM/merged_${name}.7col

# 4.2 Domain
echo -e '  ** Calling domain......'
mkdir -p ./$normal/bin${binSize}_win${winSize}/domain
[ -f ./$normal/bin${binSize}_win${winSize}/merged_${name}.domain  ] && rm -f ./$normal/bin${binSize}_win${winSize}/merged_${name}.domain
chrLst=$( cut -f1 iced/bin${binSize}_win${winSize}/HMM/merged_human_PFC.7col | sort | uniq  | tr "\n" " " )

for chr in $chrLst
do
	# split
	echo -e '    * Split 7col to individual chromosome......'
	awk -v chr=$chr '$1==chr' ./$normal/bin${binSize}_win${winSize}/HMM/merged_${name}.7col  > ./$normal/bin${binSize}_win${winSize}/HMM/${chr}_${name}.7col
	# final domain
	perl $domainCallDir/hmm_probablity_correcter.pl \
		./$normal/bin${binSize}_win${winSize}/HMM/${chr}_${name}.7col  2 0.99 20000 \
		| perl $domainCallDir/hmm-state_caller.pl $chromSize $chr \
		| perl $domainCallDir/hmm-state_domains.pl > ./$normal/bin${binSize}_win${winSize}/domain/${chr}_${name}.domain
	# merge
	echo -e '    * Merge all domains......'
	cat ./$normal/bin${binSize}_win${winSize}/domain/${chr}_${name}.domain >> ./$normal/bin${binSize}_win${winSize}/domain/merged_${name}.domain
	sed -i 's/chr23/chrM/g;s/chr24/chrX/g;s/chr25/chrY/g'  ./$normal/bin${binSize}_win${winSize}/domain/merged_${name}.domain
done
else
	echo -e "!!!!.hmm doesn't exist for ./$normal/bin${binSize}_win${winSize}, probably being constructed in windows. Skip......"
fi
#### EO 2020-06-13 ####
