################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Mon Jun  1 20:03:40 2020
################################################

#!/bin/sh 

#### 2021-03-23 ####
binSize="500000 100000"
avpDir=/rd1/user/lixs/Projects/1KMG/HiC/human_PFC/hg38_comChr/HiC-Pro/validPairs
chrSize=/rd1/brick/lixs/Data/General/fna/hg38/hg38_comChr.chrom.sizes
geneDensDir=/rd1/user/lixs/Projects/1KMG/data/geneDens/bins/hg38
call_compartment=/rd1/user/lixs/Projects/1KMG/tools/scripts/call-compartment.sh

  for bin in $binSize;do
	echo "**** Call compartment for organ: human_PFC, binSize: $bin"
	[ -d bin$bin ] || mkdir -p bin$bin
	pushd bin$bin
	bash $call_compartment $bin 20 human_PFC $chrSize $avpDir/human_PFC.allValidPairs $geneDensDir/hg38.bin${bin}.geneDens.txt
    
	## Convert to bigWig compatible with UCSC visualization
	# bigwigToWig
	bigWigToWig human_PFC.compartment.cis.bw  human_PFC.compartment.cis.bdg
    # wig to clean wig
	egrep -v '#|nan' human_PFC.compartment.cis.bdg > human_PFC.compartment.cis.clean.bdg
	bedGraphToBigWig human_PFC.compartment.cis.clean.bdg  $chrSize  human_PFC.compartment.cis.clean.bw
	popd
  done

#### EO 2021-03-23 ####
