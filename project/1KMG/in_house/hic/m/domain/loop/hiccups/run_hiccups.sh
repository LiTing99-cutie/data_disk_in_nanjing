################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Sat Jun  6 21:11:09 2020
################################################

#!/bin/sh 

#### 2021-04-02 ####

# Note Warning Hi-C map is too sparse to find many loops via HiCCUPS.

[ -d  hiccups_output  ] || mkdir -p hiccups_output
juicerJar=/rd1/user/lixs/Projects/1KMG/tools/juicer_tools.1.9.9_jcuda.0.8.jar

## 1 high-resolution mode

## 1. high-resolution mode - resolution 10000
mkdir -p hiccups_output/highRes10kb
mkdir -p log

hic=/rd1/user/lixs/Projects/1KMG/HiC/macaque_PFC/rheMac10Plus_comChrom/contactMap/juiceBox/krNorm/PFC_allValidPairs.hic
java -Xmx32g -jar $juicerJar hiccups --cpu  --ignore_sparsity --threads 40 -m 512 -r 10000 -k KR $hic hiccups_output/highRes10kb 1>log/juicer_hiccups_highRes10kb.log 2>&1 &

## 2. medium-resolution mode - resolution 25000

mkdir -p hiccups_output/mediumRes25kb
java -Xmx32g -jar $juicerJar hiccups --cpu  --ignore_sparsity  --threads 40 -m 512 -r 25000 -k KR $hic hiccups_output/mediumRes25kb 1>log/juicer_hiccups_mediumRes25kb.log 2>&1 &

wait
wait
#### EO 2021-04-02 ####


#### 2021-12-07 ####
## mediumRes
cat hiccups_output/mediumRes25kb/merged_loops.bedpe | cut -f1-9 |sed '/#/d' | awk -v OFS="\t"  '{print "chr"$1,$2,$3,"chr"$4,$5,$6,"pfcloop_"NR,1000,$8,$9}' > hiccups_output/mediumRes25kb/merged_loops.neat.bedpe

#### EO 2021-12-07 ####