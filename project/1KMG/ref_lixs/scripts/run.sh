################################################
#File Name: scripts/run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Thu Apr  9 13:37:16 2020
################################################

#!/bin/sh 
#### 2020-04-09 ####
## 1 calculate_map_resolution.sh
ln /rd1/user/lixs/Projects/1KMG/tools/juicer-master/misc/calculate_map_resolution.sh /rd1/user/lixs/Projects/1KMG/tools/scripts/calculate_map_resolution.sh
#### EO 2020-04-09 ####

#### 2020-11-16 ####
## 1 coordinate_conversion_function.v2.R
mkdir -p coordConvert
cp /rd1/user/lixs/Projects/1KMG/genome_assembly/coordConvert/script/coordinate_conversion_function.v2.R  ./coordConvert
cp /rd1/user/lixs/Projects/1KMG/genome_assembly/coordConvert/script/rheMac10_rheMac10Plus.40gapFilling.corres.txt  ./coordConvert/
#### EO 2020-11-16 ####

