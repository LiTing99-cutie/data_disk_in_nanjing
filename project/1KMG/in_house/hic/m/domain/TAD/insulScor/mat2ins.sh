################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Mon Jun  1 22:35:45 2020
################################################

#!/bin/sh 

#### 2020-06-03 ####
mat2ins=/rd1/user/lixs/Projects/1KMG/tools/crane-nature-2015-master/scripts/matrix2insulation.pl
sqs=$1 # squareSize: -is
dls=$2 # deltaSpan: -ids
binSize=$3
chr=$4
mat=$5
dir=$6

[ -f $dir/mat2ins.log  ] && rm -f $dir/mat2ins.log

pushd $dir
perl $mat2ins -i $mat -is $sqs -ids $dls -v  -im mean -nt 0.25 -bmoe 0  1>>mat2ins.log 2>>mat2ins.err
popd

#### EO 2020-06-03 ####
