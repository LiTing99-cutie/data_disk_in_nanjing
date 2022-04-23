################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Mon Jun  1 20:51:09 2020
################################################

#!/bin/sh 

sparseToDense=/home/user/data2/uplee/tools/HiC-Pro-3.1.0/HiC-Pro_3.1.0/bin/utils/sparseToDense.py
name=$1
bin=$2
absBed=$3
iceMat=$4
genome=$5

echo "**** HiC-Pro ICE matrix to IS dense matrix for ${name}_${bin}"

[ ! -d $name/$bin ] && mkdir -p $name/$bin
pushd $name/$bin
python2.7 $sparseToDense -b  $absBed -g $genome -i -c -o ${name}_${bin}.is.matrix  $iceMat 1>sparseToDense.${name}_${bin}.log 2>&1
popd

