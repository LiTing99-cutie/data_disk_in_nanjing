################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Mon Jun 29 22:10:36 2020
################################################

#!/bin/sh 
#### 2020-06-30 ####
## pyschic for macaque_PFC ice res5kb_win2Mb chr18 APCDD1 (ENSMMUG00000056891)
ls -d iced/res5000/win2000000/chr18/macaque_PFC.chr18.enh_* | while read f;do
  fd=$( basename $f .bed )
  awk '$2>0 && $3>0' $f| egrep 'ENSMMUG00000056891' | awk -v OFS="\t" '{print $1,$2,$3,$4,".",".",$2,$3,"0,0,25"}' > iced/res5000/win2000000/chr18/${fd}.juiceBox.bed
done
#### EO 2020-06-30 ####

#### 2020-07-11 ####
## 1 Create bedpe for APCDD1 promoter-enhancer pair for juiceBox visualization
## ENSMMUG00000056891 chr18:71384351-71418743 (/rd1/brick/lixs/Data/General/geneAnno/rheMac10Plus/rheMac10Plus.collapsed.bed)
## Promoter was chosen as 2kb upstream APCDD1
ls -d  iced/res5000/win2000000/chr18/macaque_PFC.chr18.enh_*juiceBox* | while read f;do
  fd=$( basename $f .juiceBox.bed )
  awk -F"\t" -v OFS="\t" '{print "chr18",71384351-2000,71384351,$1,$2,$3,"0,0,204",$4}' $f > iced/res5000/win2000000/chr18/$fd.promoter.juiceBox.bedpe
  awk -F"\t" -v OFS="\t" '{print "chr18",71384351,71418743,$1,$2,$3,"0,0,204",$4}' $f > iced/res5000/win2000000/chr18/$fd.gene.juiceBox.bedpe
done
#### EO 2020-07-11 ####
