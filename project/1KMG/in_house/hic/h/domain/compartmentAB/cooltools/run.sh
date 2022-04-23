################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Tue Mar 16 15:44:21 2021
################################################

#!/bin/sh 

#### 2021-03-16 ####
bash run_compartment.sh  1>log/run_compartment.log 2>&1 &
#### EO 2021-03-16 ####

#### 2021-06-06 ####
# Extract compartment A/B coordinate from bdg.
pushd bin500000
cat human_PFC.compartment.cis.clean.bdg | awk '$4>0' | sort -k1,1 -k2,2n | bedtools merge -i - | awk -v OFS="\t" '{print $1,$2,$3,"A"}'  > human_PFC.compartment.cis.clean.compartA.bed4
cat human_PFC.compartment.cis.clean.bdg | awk '$4<0' | sort -k1,1 -k2,2n | bedtools merge -i - | awk -v OFS="\t" '{print $1,$2,$3,"B"}'  > human_PFC.compartment.cis.clean.compartB.bed4
cat human_PFC.compartment.cis.clean.compartA.bed4 human_PFC.compartment.cis.clean.compartB.bed4 | sort -k1,1 -k2,2n  > human_PFC.compartment.cis.clean.bed4
popd 

pushd bin100000
cat human_PFC.compartment.cis.clean.bdg | awk '$4>0' | sort -k1,1 -k2,2n | bedtools merge -i - | awk -v OFS="\t" '{print $1,$2,$3,"A"}'  > human_PFC.compartment.cis.clean.compartA.bed4
cat human_PFC.compartment.cis.clean.bdg | awk '$4<0' | sort -k1,1 -k2,2n | bedtools merge -i - | awk -v OFS="\t" '{print $1,$2,$3,"B"}'  > human_PFC.compartment.cis.clean.compartB.bed4
cat human_PFC.compartment.cis.clean.compartA.bed4 human_PFC.compartment.cis.clean.compartB.bed4 | sort -k1,1 -k2,2n  > human_PFC.compartment.cis.clean.bed4
popd

#### EO 2021-06-06 ####
