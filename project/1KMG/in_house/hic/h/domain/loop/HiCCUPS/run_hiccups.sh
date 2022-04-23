################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Sat Jun  6 21:11:09 2020
################################################

#!/bin/sh 

#### 2020-07-05 ####

hic=/rd1/user/lixs/Projects/1KMG/HiC/human_PFC/hg38_comChr/allValidPairs/contactMap/juiceBox/iceNorm/hic/human_PFC_1000.hic
[ -d  hiccups_output  ] || mkdir -p hiccups_output
juicerJar=/rd1/user/lixs/Projects/1KMG/tools/juicer_tools.1.9.9_jcuda.0.8.jar


#### 1. Run HiCCUPS
#### 2020-07-05 ####
### 1.1 high-resolution mode (DEPRECATED)
mkdir -p hiccups_output/highRes
java -Xmx32g -jar $juicerJar hiccups --cpu  --threads 30 -m 512 -r 5000,10000 -k KR $hic hiccups_output/highRes 1>log/juicer_hiccups_highRes.log 2>&1
#### EO 2020-07-05 ####

#### 2021-03-31 ####
## 1.2 high-resolution mode - resolution 10000
hic=/rd1/user/lixs/Projects/1KMG/HiC/human_PFC/hg38_comChr/allValidPairs/contactMap/juiceBox/krNorm/human_PFC.allValidPairs.hic
java -Xmx32g -jar $juicerJar hiccups --cpu  --threads 30 -m 512 -r 10000 -k KR $hic hiccups_output/highRes10kb 1>log/juicer_hiccups_highRes10kb.log 2>&1

## 1.3 medium-resolution mode - resolution 25000
java -Xmx32g -jar $juicerJar hiccups --cpu  --threads 30 -m 512 -r 25000 -k KR $hic hiccups_output/mediumRes 1>log/juicer_hiccups_mediumRes25kb.log 2>&1
#### EO 2021-03-31 ####


#### 2. Bedpe to bed12 for UCSC visualization

### 2.1 Pre-process bedpe
## highRes10kb
cat hiccups_output/highRes10kb/merged_loops.bedpe | cut -f1-9 |sed '/#/d' | awk -v OFS="\t"  '{print "chr"$1,$2,$3,"chr"$4,$5,$6,"pfcloop_"NR,1000,$8,$9}' > hiccups_output/highRes10kb/merged_loops.neat.bedpe 
## mediumRes
cat hiccups_output/mediumRes/merged_loops.bedpe | cut -f1-9 |sed '/#/d' | awk -v OFS="\t"  '{print "chr"$1,$2,$3,"chr"$4,$5,$6,"pfcloop_"NR,1000,$8,$9}' > hiccups_output/mediumRes/merged_loops.neat.bedpe

### 2.2 bedpe to bed12
conda activate 3point6
pyDir=/rd1/brick/lixs/Bin/python
## highRes10kb
python $pyDir/bedpeToBed12.py -i hiccups_output/highRes10kb/merged_loops.neat.bedpe | sort -k1,1 -k2,2n > hiccups_output/highRes10kb/merged_loops.bed12
python $pyDir/bedpeToBed12.py -i hiccups_output/mediumRes/merged_loops.neat.bedpe | sort -k1,1 -k2,2n >  hiccups_output/mediumRes/merged_loops.bed12

hg38ChrSize=/rd1/brick/lixs/Data/General/fna/hg38/hg38.chrom.sizes
bedToBigBed hiccups_output/highRes10kb/merged_loops.bed12 $hg38ChrSize hiccups_output/highRes10kb/merged_loops.bb
bedToBigBed hiccups_output/mediumRes/merged_loops.bed12 $hg38ChrSize hiccups_output/mediumRes/merged_loops.bb


