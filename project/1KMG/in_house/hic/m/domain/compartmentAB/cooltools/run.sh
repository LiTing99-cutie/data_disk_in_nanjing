################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Tue Mar 16 15:44:21 2021
################################################

#!/bin/sh 

#### 2021-03-23 ####
bash run_compartment.sh  1>log/run_compartment.log 2>&1 &
#### EO 2021-03-23 ####

#### 2021-06-06 ####
# Extract compartment A/B coordinate from bdg.
for d in bin100000  bin500000;do
  pushd $d
  cat macaque_PFC.compartment.cis.clean.bdg | awk '$4>0' | sort -k1,1 -k2,2n | bedtools merge -i - | awk -v OFS="\t" '{print $1,$2,$3,"A"}'  > macaque_PFC.compartment.cis.clean.compartA.bed4
  cat macaque_PFC.compartment.cis.clean.bdg | awk '$4<0' | sort -k1,1 -k2,2n | bedtools merge -i - | awk -v OFS="\t" '{print $1,$2,$3,"B"}'  > macaque_PFC.compartment.cis.clean.compartB.bed4
  cat macaque_PFC.compartment.cis.clean.compartA.bed4 macaque_PFC.compartment.cis.clean.compartB.bed4 | sort -k1,1 -k2,2n  > macaque_PFC.compartment.cis.clean.bed4
  popd
done
#### EO 2021-06-06 ####
~
