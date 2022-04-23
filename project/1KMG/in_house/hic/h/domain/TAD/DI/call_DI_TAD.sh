################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Mon Jun  1 22:35:45 2020
################################################

#!/bin/sh 

#### 2020-07-04 ####

## 1 Pre HMM
binSize="5000 10000"
winSize="250000"

<<!
[ ! -d log ] && mkdir log
for bin in $binSize;do
  for win in $winSize;do
	bash DI_TAD_calling.pre.sh $bin $win iced human_PFC 1>log/DI_TAD_calling.${bin}_${win}.pre.log 2>&1
  done
done

## 2 rsync .hmm from uplee's DELL
## Put merged_human_PFC.hmm into iced/bin${bin}_win${win}
!
## 3 Post HMM
for bin in $binSize;do
  for win in $winSize;do
    bash DI_TAD_calling.post.sh $bin $win iced human_PFC 1>log/DI_TAD_calling.${bin}_${win}.post.log 2>&1 
  done
done
wait 
#### EO 2020-07-04 ####

#### 2020-08-29 ####
## 4 Filter
for bin in $binSize;do
  cat iced/bin${bin}_win250000/domain/merged_human_PFC.domain | awk 'NF==3' > iced/bin${bin}_win250000/domain/merged_human_PFC.filtered.domain
done
#### EO 2020-08-29 ####
