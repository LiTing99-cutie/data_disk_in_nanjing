################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Mon Jun  1 20:03:40 2020
################################################

#!/bin/sh 

#### 2021-03-23 ####
binSize="500000 100000"
avpDir=/rd1/user/lixs/Projects/1KMG/HiC/macaque_PFC/rheMac10Plus_comChrom/HiC-Pro/validPairs
chrSize=/rd1/brick/lixs/Data/General/fna/rheMac10Plus/rheMac10Plus.comChr.chrom.sizes
geneDensDir=/rd1/user/lixs/Projects/1KMG/data/geneDens/bins/r10p
call_compartment=/rd1/user/lixs/Projects/1KMG/tools/scripts/call-compartment.sh

  for bin in $binSize;do
	echo "**** Call compartment for organ: macaque_PFC, binSize: $bin"
	[ -d bin$bin ] || mkdir -p bin$bin
	pushd bin$bin
	bash $call_compartment $bin 20 macaque_PFC $chrSize $avpDir/macaque_PFC.allValidPairs $geneDensDir/r10p.bin${bin}.geneDens.txt
    
	## Convert to bigWig compatible with UCSC visualization
	# bigwigToWig
	bigWigToWig macaque_PFC.compartment.cis.bw  macaque_PFC.compartment.cis.bdg
    # wig to clean wig
	egrep -v '#|nan' macaque_PFC.compartment.cis.bdg > macaque_PFC.compartment.cis.clean.bdg
	bedGraphToBigWig macaque_PFC.compartment.cis.clean.bdg  $chrSize  macaque_PFC.compartment.cis.clean.bw
	popd
  done

#### EO 2021-03-23 ####
