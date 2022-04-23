################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Mon Jun  1 22:35:45 2020
################################################

#!/bin/sh 

#### 2020-07-11 ####
# This script calculate insulation score and detect TAD boundary by the way. The parameters was referred to LiCheng's Cell paper.
# -is 1000000 -ids 200000 -im mean  -nt 0.25

squareSize=1000000
deltaSpan=200000
binSize=40000
chrSize=/rd1/brick/lixs/Data/General/fna/rheMac10Plus/rheMac10Plus.comChr.chrom.sizes
chrLst=$( cat $chrSize | cut -f1 | tr "\n" " " )

## 1 matrixToInsulScor
# 1.1 Create jobList
[ -f mat2ins.jobList  ] && rm -f mat2ins.jobList

 for bin in $binSize;do
  for sqs in $squareSize;do
   for dls in $deltaSpan;do 
    mkdir -p bin${bin}_sqs${sqs}_dls${dls}
    dir=bin${bin}_sqs${sqs}_dls${dls}
    for chr in $chrLst;do
     ## create jobList for para batch system
	 mat=/rd1/user/lixs/Projects/1KMG/HiC/macaque_PFC/rheMac10Plus_comChrom/matrix/isICE/macaque_PFC/$bin/${chr}_macaque_PFC_${bin}.is.matrix
	 echo -e "bash mat2ins.sh $sqs $dls $bin $chr $mat $dir"	>> mat2ins.jobList
	done
   done
  done
 done

# 1.2 Run para batch system

## 2 Process insulation scores and boundaries for UCSC visualization
chrSize=/rd1/brick/lixs/Data/General/fna/rheMac10Plus/rheMac10Plus.comChr.chrom.sizes
cat $chrSize  | sort -k1,1 -k2,2n > rheMac10Plus.comChr.chrom.sizes
chrSize=$PWD/rheMac10Plus.comChr.chrom.sizes

 for bin in $binSize;do
  for sqs in $squareSize;do
   for dls in $deltaSpan;do
	dir=bin${bin}_sqs${sqs}_dls${dls}
	pushd $dir
	[ -d  bigWig  ] || mkdir -p bigWig
	[ -f bigWig/macaque_PFC_${bin}.clean.insulation.bdg ] && rm -f bigWig/macaque_PFC_${bin}.clean.insulation.bdg
	[ -f bigWig/macaque_PFC_${bin}.clean.insulation.boundaries.bed ] && rm -f bigWig/macaque_PFC_${bin}.clean.insulation.boundaries.bed
	## TAD boundary
	# bedGraph to bigWig
	cat *insulation.bedGraph | egrep -v 'NA|type' | sort -k1,1 -k2,2n > bigWig/macaque_PFC_${bin}.clean.insulation.bdg
	cat *.insulation.boundaries.bed | egrep -v 'track' | sort -k1,1 -k2,2n  | awk -v OFS="\t" '{if ( NR%2 == 1 ) print $1,$2,$3,$4,1000,".",$2,$3,"51,51,0"; else print $1,$2,$3,$4,1000,".",$2,$3,"153,153,0"  }' > bigWig/macaque_PFC_${bin}.clean.insulation.boundaries.bed
	bedGraphToBigWig bigWig/macaque_PFC_${bin}.clean.insulation.bdg $chrSize bigWig/macaque_PFC_${bin}.clean.insulation.bw
	bedToBigBed bigWig/macaque_PFC_${bin}.clean.insulation.boundaries.bed $chrSize bigWig/macaque_PFC_${bin}.clean.insulation.boundaries.bb

	## Get TAD
	
	bedtools complement -i bigWig/macaque_PFC_${bin}.clean.insulation.boundaries.bed  -g $chrSize | egrep -v 'chrY|chrM' | awk '$3-$2<10000000 && $3-$2>40000' | sort -k1,1 -k2,2n | awk -v OFS="\t" '{print $0,"rmPFC_tad_"NR}' > bigWig/macaque_PFC_${bin}.isTad.bed
	bedToBigBed bigWig/macaque_PFC_${bin}.isTad.bed $chrSize bigWig/macaque_PFC_${bin}.isTad.bb

	popd
   done
  done
 done
wait
#### EO 2020-07-11 ####
