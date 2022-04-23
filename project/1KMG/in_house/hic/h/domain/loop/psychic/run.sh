################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Thu Jul  9 14:33:26 2020
################################################

#!/bin/sh 

#### 2020-07-09 ####
## pyschic for human_PFC ice res5kb_win2Mb chr18 APCDD1 (ENSG00000154856)
ls -d iced/res5000/win2000000/chr18/human_PFC.chr18.enh_* | while read f;do
  fd=$( basename $f .bed )
  awk '$2>0 && $3>0' $f| egrep 'ENSG00000154856' | awk -v OFS="\t" '{print $1,$2,$3,$4,".",".",$2,$3,"0,0,255"}' > iced/res5000/win2000000/chr18/${fd}.ENSG00000154856.juiceBox.bed
done
#### EO 2020-07-09 ####

#### 2020-07-11 ####
## 1 Create bedpe for APCDD1 promoter-enhancer pair for juiceBox visualization
## ENSG00000154856 chr18:10454627-10489948 (/rd1/brick/lixs/Data/General/geneAnno/hg38/gencode.v26.GRCh38.genes.bed)
ls -d  iced/res5000/win2000000/chr18/human_PFC.chr18.enh_*.ENSG00000154856.juiceBox.bed  | while read f;do
  fd=$( basename $f .juiceBox.bed )
  awk -F"\t" -v OFS="\t" '{print "chr18",10454627-2000,10454627,$1,$2,$3,"0,0,204",$4}' $f > iced/res5000/win2000000/chr18/$fd.promoter.juiceBox.bedpe
  awk -F"\t" -v OFS="\t" '{print "chr18",10454627,10489948,$1,$2,$3,"0,0,204",$4}' $f > iced/res5000/win2000000/chr18/$fd.gene.juiceBox.bedpe
done
#### EO 2020-07-11 ####
