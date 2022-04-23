################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Sun Jun 28 20:39:49 2020
################################################

#!/bin/sh 
#### 2020-06-28 ####
hicpro2fithic=/rd1/user/lixs/Projects/1KMG/tools/HiC-Pro_2.11.4/bin/utils/hicpro2fithic.py
#resolution="5000 10000 20000 40000 100000 500000 1000000"
resolution="5000 10000"
## 1 hicpro2fithic (bias/no bias)
# 1.1 hicpro2fithic
for res in $resolution;do
  [ -d  hicpro2fithic/${res}  ] || mkdir -p hicpro2fithic/${res} 
  matrix=/rd1/user/lixs/Projects/1KMG/HiC/macaque_PFC/rheMac10Plus_comChrom/allValidPairs/contactMap/matrix/HiC-Pro_sparse/raw/${res}/macaque_PFC_${res}.matrix
  abs=/rd1/user/lixs/Projects/1KMG/HiC/macaque_PFC/rheMac10Plus_comChrom/allValidPairs/contactMap/matrix/HiC-Pro_sparse/raw/${res}/macaque_PFC_${res}_abs.bed
  python $hicpro2fithic -i  $matrix  -b $abs -r $res -o hicpro2fithic/${res} 1>hicpro2fithic/hicpro2fithic.res${res}.log 2>&1 &
done
wait
# 1.2 hicpro2fithic_iceBias
resolution="5000 10000"
for res in $resolution;do
  [ -d  hicpro2fithic_iceBias/${res}  ] || mkdir -p hicpro2fithic_iceBias/${res} 
  matrix=/rd1/user/lixs/Projects/1KMG/HiC/macaque_PFC/rheMac10Plus_comChrom/allValidPairs/contactMap/matrix/HiC-Pro_sparse/raw/${res}/macaque_PFC_${res}.matrix
  abs=/rd1/user/lixs/Projects/1KMG/HiC/macaque_PFC/rheMac10Plus_comChrom/allValidPairs/contactMap/matrix/HiC-Pro_sparse/raw/${res}/macaque_PFC_${res}_abs.bed
  bias=/rd1/user/lixs/Projects/1KMG/HiC/macaque_PFC/rheMac10Plus_comChrom/allValidPairs/contactMap/matrix/HiC-Pro_sparse/iced/${res}/macaque_PFC_${res}_iced.matrix.biases
  python $hicpro2fithic -i  $matrix  -b $abs -s $bias  -r $res -o hicpro2fithic_iceBias/${res} 1>hicpro2fithic_iceBias/hicpro2fithic.res${res}.log 2>&1 &
done
wait

## 2 fithic
# 2.1 No -t option
# Running: res 5Kb (2020-06-29 11:19 am)
# Running: res 10Kb (2020-06-29 18:11 pm)
resolution="5000 10000"
for res in $resolution;do
  [ -d output/fithic/${res}  ] || mkdir output/fithic/${res}
  frag=hicpro2fithic/${res}/fithic.fragmentMappability.gz
  inter=hicpro2fithic/${res}/fithic.interactionCounts.gz
  fithic -i  $inter  -f  $frag  -o output/fithic/${res} -r ${res} 1>output/fithic/fithic.noBias.res${res}.log 2>&1 &
done
wait
# 2.2 -t option
resolution="5000 10000"
for res in $resolution;do
  [ -d output/fithic_iceBias/${res}  ] || mkdir output/fithic_iceBias/${res}
  frag=hicpro2fithic_iceBias/${res}/fithic.fragmentMappability.gz
  inter=hicpro2fithic_iceBias/${res}/fithic.interactionCounts.gz
  bias=hicpro2fithic_iceBias/${res}/fithic.biases.gz
  fithic -i  $inter  -f  $frag  -o output/fithic_iceBias/${res} -r ${res} -t $bias 1>output/fithic_iceBias/fithic.bias.res${res}.log 2>&1 &
done
wait
#### EO 2020-06-28 ####

#### 2020-06-30 ####
zcat output/fithic_iceBias/5000/FitHiC.spline_pass1.res5000.significances.txt.gz | awk '$7<0.01' |less 
## Number: 70
zcat output/fithic_iceBias/5000/FitHiC.spline_pass1.res5000.significances.txt.gz | awk '$7<0.05' | less
## Number: 107
zcat output/fithic_iceBias/5000/FitHiC.spline_pass1.res5000.significances.txt.gz | awk '$7<0.1' | less
## Number: 136
#### EO 2020-06-30 ####
