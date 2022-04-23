################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Mon May  4 00:01:11 2020
################################################

#!/bin/sh 

########################################## Argument ################################################
juicerJar=/rd1/user/lixs/Projects/1KMG/tools/juicer_tools.1.9.9_jcuda.0.8.jar
chromSize=/rd1/user/lixs/Projects/1KMG/tools/HiC-Pro_2.11.4/annotation/chrom_rheMac10Plus.noChrUn.sizes ##chromosome names
export PATH=/home/light/tool/jdk1.8.0_101/jre/bin:$PATH ## java path
assignLabel=/rd1/user/lixs/Projects/1KMG/tools/scripts/assignLabelByCor.pl

hiC=$1
#hiC=../hicpro2juicebox/remChrUn/macaque_liver_merged.allValidPairs_noChrUn.hic

geneDens=$2
#geneDens=/rd1/user/lixs/Projects/1KMG/data/geneDens/rheMac10Plus/rheMac10Plus.bins_${res}.geneDens
#geneDens_WG=/rd1/user/lixs/Projects/1KMG/data/geneDens/rheMac10Plus/rheMac10Plus.bins_${res}.WG.geneDens

sampleName=$3
#sampleName=macaque_liver_merged_noChrUn

hicNorm=$4
#hicNorm=KR ## KR normalization

res=$5
#resolution="2500000 1000000 500000 250000 100000 50000 40000 25000 10000 5000" ## NOTE: The eigenvector could only be calculated for resolution above 500 Kb in juicer
########################################## Argument ################################################

## 1 Dump eigenvector from .hic file
if [ ! -d eigen/ ]; then mkdir eigen/;fi
cut -f1 $chromSize |grep -v 'chrM' | while read chr ## remove chrM
do
	java -jar $juicerJar eigenvector $hicNorm $hiC $chr BP $res eigen/${sampleName}.${hicNorm}_BP_${res}_${chr}.eigen.txt 1>eigen/${sampleName}.${hicNorm}_BP_${res}_${chr}.eigen.log 2>eigen/${sampleName}.${hicNorm}_BP_${res}_${chr}.eigen.err 
done

## 2 Join gene density with eigenvectors by individual chromosome
if [ ! -d geneDensEigen/ ]; then mkdir geneDensEigen/;fi
cut -f1 $chromSize |grep -v 'chrM' | while read chr ## remove chrM
do
	# per chromosome density
	awk -v chr=$chr '$1==chr' $geneDens | paste -d"\t" - eigen/${sampleName}.${hicNorm}_BP_${res}_${chr}.eigen.txt  > geneDensEigen/${sampleName}.${hicNorm}_BP_${res}_${chr}.geneDensEigen.txt
	# whole genome density
	#awk -v chr=$chr '$1==chr' $geneDens_WG | paste -d"\t" - eigen/${sampleName}.${hicNorm}_BP_${res}_${chr}.eigen.txt  > geneDensEigen/${sampleName}.${hicNorm}_BP_${res}_${chr}.geneDensEigen.WG.txt
done

## 3 Calculate correlation between gene density and eigenvector to determine which set should be labeled Compartement A, which set Compartment B
if [ ! -d assignLabel/geneDensEigenCor/ ]; then mkdir -p assignLabel/geneDensEigenCor/;fi
if [ -f assignLabel/geneDensEigenCor/${sampleName}.${hicNorm}_BP_${res}.geneDensEigenCor.txt  ];then rm assignLabel/geneDensEigenCor/${sampleName}.${hicNorm}_BP_${res}.geneDensEigenCor.txt;fi
cut -f1 $chromSize |grep -v 'chrM' | while read chr ## remove chrM
do
	# Correlation between intra-chromosomal gene density and eigenvector
	icCor=$( cat geneDensEigen/${sampleName}.${hicNorm}_BP_${res}_${chr}.geneDensEigen.txt |  cut -f5-6 | sed -E '1i density\teigen' | Rscript /rd1/brick/lixs/Bin/RScirpt/colPairCorrelation.R -m="spearman" )
	icCorArray=($icCor)
	# Correlation between whole-genome gene density and eigenvector
	#wgCor=$( cat geneDensEigen/${sampleName}.${hicNorm}_BP_${res}_${chr}.geneDensEigen.WG.txt |  cut -f5-6 | sed -E '1i density\teigen' | Rscript /rd1/brick/lixs/Bin/RScirpt/colPairCorrelation.R -m="spearman" )
	#wgCorArray=($wgCor)
	echo -e "$chr\t${icCorArray[2]}" >>assignLabel/geneDensEigenCor/${sampleName}.${hicNorm}_BP_${res}.geneDensEigenCor.txt
done

## 4 Merge bins of positive eigenvector as one set, negative as the other
# NOTE: End up with errors while performing bedtools merge on chrM as a result of empty file
if [ ! -d assignLabel/twoSets ]; then mkdir -p assignLabel/twoSets;fi
cut -f1 $chromSize |grep -v 'chrM' | while read chr ## remove chrM
do
	## Positive eigenvector
	awk '$6>0' geneDensEigen/${sampleName}.${hicNorm}_BP_${res}_${chr}.geneDensEigen.txt | bedtools merge -i - | awk -v OFS="\t" '{print $0, "posiEigen"}' >assignLabel/twoSets/${sampleName}.${hicNorm}_BP_${res}_${chr}.peigenSet 
	## Negative eigenvector
	awk '$6<0' geneDensEigen/${sampleName}.${hicNorm}_BP_${res}_${chr}.geneDensEigen.txt | bedtools merge -i - | awk -v OFS="\t" '{print $0, "negaEigen"}' >assignLabel/twoSets/${sampleName}.${hicNorm}_BP_${res}_${chr}.neigenSet
	cat assignLabel/twoSets/${sampleName}.${hicNorm}_BP_${res}_${chr}.peigenSet assignLabel/twoSets/${sampleName}.${hicNorm}_BP_${res}_${chr}.neigenSet | sort -k1,1 -k2,2n -k3,3n > assignLabel/twoSets/${sampleName}.${hicNorm}_BP_${res}_${chr}.twoSets
done
# Combine two sets in all chromosomes
cat assignLabel/twoSets/${sampleName}.${hicNorm}_BP_${res}_*.twoSets >assignLabel/twoSets/${sampleName}.${hicNorm}_BP_${res}_allChr.twoSets

## 5. Label A/B assignment
if [ ! -d assignLabel/compartmentAB ]; then mkdir -p assignLabel/compartmentAB;fi
perl $assignLabel -c assignLabel/geneDensEigenCor/${sampleName}.${hicNorm}_BP_${res}.geneDensEigenCor.txt -s assignLabel/twoSets/${sampleName}.${hicNorm}_BP_${res}_allChr.twoSets  -o assignLabel/compartmentAB/${sampleName}.${hicNorm}_BP_${res}.compartment
# Convert to bed for juiceBox visualization 
awk -v OFS="\t" 'NR!=1{if($6=="A")col="255,0,0"; else col="0,0,255"; print $1,$2,$3,$6,0,".", $2,$3,col}' assignLabel/compartmentAB/${sampleName}.${hicNorm}_BP_${res}.compartment | sed '1i #chr\tspos\tepos\tname\tscore\tstrand\tthickStart\tthickEnd\titemRgb' > assignLabel/compartmentAB/${sampleName}.${hicNorm}_BP_${res}.compartment.bed
