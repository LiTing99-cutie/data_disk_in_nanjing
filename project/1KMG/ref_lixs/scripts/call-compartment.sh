################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Fri May 29 16:20:29 2020
################################################

#!/bin/sh 

#### 2020-06-01 #### 
##############################################
### hicpro2higlass (.cool)                 ###
### Normalizing using revised              ###
### ICE normlization method adopted by cooler#
##############################################
hicpro2higlass=/rd1/user/lixs/Projects/1KMG/tools/HiC-Pro_2.11.4/bin/utils/hicpro2higlass.sh
resolution=$1
thread=$2
name=$3
chromSize=$4
mat=$5
geneCov=$6

[ ! -d ./cool  ] && mkdir ./cool
[ ! -d ./log  ] && mkdir ./log

## 1 HiC-Pro raw matrix to .cool (Not balanced)
bash $hicpro2higlass -i  $mat  \
	-r $resolution  \
	-c $chromSize  \
	-p $thread -o ./cool -n > log/hicpro2higlass.$resolution.log 2>&1  
## 2 Balancing
cooler balance -p $thread  -c 10000 ./cool/${name}.cool 1>log/cooler_balance.$resolution.log 2>&1 
## 3 Call compartment
[ -f geneDens ] && rm -f geneDens
cat  $geneCov  | sed '1i chrom\tstart\tend\tgeneDens' | awk -v OFS="\t" 'NR==1{print $0}NR!=1{cov=sprintf("%.8f",$4);print $1,$2,$3,cov}' > geneDens
cooltools call-compartments --reference-track ./geneDens  --n-eigs 3 -v  -o ${name}.compartment --bigwig ./cool/${name}.cool  1>log/compartment.$resolution.log 2>&1 
#### EO 2020-06-01 ####
