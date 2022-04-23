################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Fri Apr 10 23:05:48 2020
################################################

#!/bin/sh 

#### 2020-07-16 ####
hicproUtilDir=/rd1/user/lixs/Projects/1KMG/tools/HiC-Pro_2.11.4/bin/utils
validPairs=/rd1/user/lixs/Projects/1KMG/HiC/macaque_PFC/rheMac10Plus_comChrom/HiC-Pro/validPairs/macaque_PFC.allValidPairs
chromSize=/rd1/user/lixs/Projects/1KMG/tools/HiC-Pro_2.11.4/annotation/chrom_rheMac10Plus.noChrUn.sizes
juicerJar=/rd1/user/lixs/Projects/1KMG/tools/juicer_tools.1.9.9_jcuda.0.8.jar ## work!
resFrag=/rd1/user/lixs/Projects/1KMG/tools/HiC-Pro_2.11.4/annotation/rheMac10Plus_mboi.noChrUn.bed
#mkdir -p tmp

#resolution="5000,10000,15000,20000,25000,40000,50000"
#java -Xmx32g -jar  $juicerJar  pre -r  $resolution  tmp/40424_allValidPairs.pre_juicebox_sorted macaque_PFC.allValidPairs.20200717.hic $chromSize 1>log/hicpro2juicebox.20200717.log 2>&1

#sh -x $hicproUtilDir/hicpro2juicebox.sh -i $validPairs -g $chromSize -j $juicerJar -l $resolution -t tmp/ -o ./ 1>log/hicpro2juicebox.20200716.log 2>&1
#### EO 2020-07-16 ####


#### 2020-10-12 ####
#sh -x $hicproUtilDir/hicpro2juicebox.sh -i $validPairs -g $chromSize -j $juicerJar -r $resFrag  -t tmp/ -o ./ 1>log/hicpro2juicebox.log 2>&1
#java -Xmx32g -jar $juicerJar pre -f  ./tmp/135548_resfrag.juicebox ./tmp/135548_allValidPairs.pre_juicebox_sorted ./macaque_PFC.allValidPairs.20201013.hic  /rd1/user/lixs/Projects/1KMG/tools/HiC-Pro_2.11.4/annotation/chrom_rheMac10Plus.noChrUn.sizes 1>>log/hicpro2juicebox.log 
#### 2020-10-12 ####

#### 2021-03-23 ####
ln -s macaque_PFC.allValidPairs.20201013.hic macaque_PFC.allValidPairs.hic
#### EO 2021-03-23 ####

