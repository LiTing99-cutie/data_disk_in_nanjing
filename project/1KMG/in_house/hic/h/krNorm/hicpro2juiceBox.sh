################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Fri Apr 10 23:05:48 2020
################################################

#!/bin/sh 
hicproUtilDir=/rd1/user/lixs/Projects/1KMG/tools/HiC-Pro_2.11.4/bin/utils
validPairs=/rd1/user/lixs/Projects/1KMG/HiC/human_PFC/hg38_comChr/HiC-Pro/validPairs/human_PFC.allValidPairs
chromSize=/rd1/user/lixs/Projects/1KMG/tools/HiC-Pro_2.11.4/annotation/chrom_hg38_comChr.chrom.sizes
resFrag=/rd1/user/lixs/Projects/1KMG/tools/HiC-Pro_2.11.4/annotation/hg38_comChr_mboi.bed
juicerJar=/rd1/user/lixs/Projects/1KMG/tools/juicer_tools.1.9.9_jcuda.0.8.jar ## work!
#mkdir -p tmp
#sh -x $hicproUtilDir/hicpro2juicebox.sh -i $validPairs -g $chromSize -j $juicerJar -r $resFrag -t tmp/ -o ./ 1>log/hicpro2juicebox.log 2>&1 

#### 2020-07-16 ####
resolution="5000,10000,15000,20000,25000,40000,50000"
#sh -x $hicproUtilDir/hicpro2juicebox.sh -i $validPairs -g $chromSize -j $juicerJar -r $resFrag -l $resolution -t tmp/ -o ./ 1>log/hicpro2juicebox.20200716.log 2>&1
java -Xmx32g -jar  $juicerJar  pre -r  $resolution  tmp/40181_allValidPairs.pre_juicebox_sorted    human_PFC.allValidPairs.20200716.hic $chromSize  
#### EO 2020-07-16 ####

#### 2020-09-02 ####
rm -f tmp/40181_allValidPairs.pre_juicebox_sorted tmp/40181_resfrag.juicebox
#### EO 2020-09-02 ####
