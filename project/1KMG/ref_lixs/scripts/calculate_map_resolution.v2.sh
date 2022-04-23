#!/bin/bash
##########
#The MIT License (MIT)
#
# Copyright (c) 2015 Aiden Lab
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.
##########
#
# Author: Suhas Rao
# modifications by Neva C. Durand
# revised by Up Lee ## 2020-05-27
#
# As described in Rao&Huntley et al., Cell 2014, calculates the map resolution
#
# First creates the 50bp coverage vector. That is, counts the number of 
# contacts for every 50bp bin in the genome (defined as any contact where one
# read mapped within that 50bp bin).
# 
# This vector is then binned into larger and larger increments (i.e. 100bp, 150bp,
# and so on) until the number of bins with >1000 contacts is at least 80% of the 
# total number of bins
#
# Note that the total number of bins depends on the genome size. Change that 
# parameter below if the genome is not hg19
#
# Modified so that binary search is used to more quickly find the map resolution
#
# Usage:
# calculate_map_resolution.sh <merged_nodups file> <coverage file binned by parameter step> <genome size> <step> <count threshod>
#
# The 50bp coverage vector is calculated from the merged_nodups file.
# The 50bp coverage file will be created under the name sent; if it's already been
# created under that name, the script will not recreate it (and indeed will not
# examine the first argument)

# total size of genome, from http://genomewiki.ucsc.edu/index.php/Hg19_Genome_size_statistics
# modify this number if your genome is not hg19

# rheMac10Plus  2971328783
# rheMac10Plus_noChrUn 2853990158
# hg19 3137161264
# hg18 3107677273
# mm9  2725765481
# hg38 3209286105

if [ $3 == 'hg18' ]; then 
	total=3107677273
elif [ $3 == 'mm9' ]; then
	total=2725765481
elif [ $3 == 'hg19'  ]; then
	total=3137161264
elif [ $3 == 'rheMac10Plus'  ]; then
	total=2971328783
elif [ $3 == 'rheMac10Plus_noChrUn'  ]; then
	total=2853990158
elif [ $3 == 'hg38'  ]; then
    total=3209286105
fi

if [ "$#" -ne 5 ]
then
    echo "Usage: calculate_map_resolution.sh <merged_nodups file> <50bp coverage file>"
    echo "  <merged_nodups file>: file created by Juicer containing all valid+unique read pairs"
    echo "  <50bp coverage file>: where to write the 50bp coverage file; if this file is non-empty, the 50bp coverage vector won't be recalculated"
	echo " <step> "
	echo " <threshold> "
    exit
fi	

filename=$1
coveragename=$2
step=$4
countThres=$5

# Create coverage vector binned based on $step
if [ ! -s $coveragename ]
then
    awk -v step=$step '{
      if ($9>0&&$12>0&&$4!=$8)
        {
        chr1=0;
        chr2=0;

        chr1=$2; 
        chr2=$6;
        if (chr1!=0&&chr2!=0)
        {
         val[chr1 " " int($3/step)*step]++
         val[chr2 " " int($7/step)*step]++
        }
      }
   }
   END{
     for (i in val)
     {
       print i, val[i]
     }
   }' "$filename" > $coveragename
fi

# threshold is 80% of total bins
binstotal=$(( $total / $step ))
threshold=$(( $binstotal * 4 ))
threshold=$(( $threshold / 5 ))

echo -ne "."
newbin=$step
bins1000=$(awk -v thres=$countThres '$3>=thres{sum++}END{if (sum == 0) print 0; else print sum}' $coveragename)
lowrange=$newbin

# find reasonable range with big jumps
while [ $bins1000 -lt $threshold ]
do
    lowrange=$newbin
    newbin=$(( $newbin + 1000 ))
    echo -ne "."
    bins1000=$(awk -v x=$newbin -v thres=$countThres '{ 
      val[$1 " " int($2/x)*x]=val[$1 " " int($2/x)*x]+$3
    }
    END { 
      for (i in val) { 
        if (val[i] >= thres) {
          count++
        } 
     } 
     print count
   }' $coveragename )
    binstotal=$(( $total / $newbin ))
    threshold=$(( $binstotal * 4 ))
    threshold=$(( $threshold / 5 ))
done

# at this point, lowrange failed but newbin succeeded
# thus the map resolution is somewhere between (lowrange, newbin]
midpoint=$(( $newbin - $lowrange ))
midpoint=$(( $midpoint / 2 ))
midpoint=$(( $midpoint + $lowrange ))
# now make sure it's a factor of 50 (ceil)
midpoint=$(( $midpoint + $step - 1 ))
midpoint=$(( $midpoint / $step ))
midpoint=$(( $midpoint * $step ))

# binary search
while [ $midpoint -lt $newbin ]
do
    echo -ne "."
    bins1000=$(awk -v x=$midpoint  -v thres=$countThres '{ 
      val[$1 " " int($2/x)*x]=val[$1 " " int($2/x)*x]+$3
    }
    END { 
      for (i in val) { 
        if (val[i] >= thres) {
          count++
        } 
     } 
     print count
   }' $coveragename )
    binstotal=$(( $total / $midpoint ))
    threshold=$(( $binstotal * 4 ))
    threshold=$(( $threshold / 5 ))
    if [ $bins1000 -lt $threshold ]
    then
	lowrange=$midpoint;
	# at this point, lowrange failed but newbin succeeded
	midpoint=$(( $newbin - $lowrange ))
	midpoint=$(( $midpoint / 2 ))
	midpoint=$(( $midpoint + $lowrange ))
	# now make sure it's a factor of 50 (ceil)
	midpoint=$(( $midpoint + $step - 1 ))
	midpoint=$(( $midpoint / $step ))
	midpoint=$(( $midpoint * $step ))
    else
	newbin=$midpoint;
	# at this point, lowrange failed but newbin succeeded
	midpoint=$(( $newbin - $lowrange ))
	midpoint=$(( $midpoint / 2 ))
	midpoint=$(( $midpoint + $lowrange ))
	# now make sure it's a factor of 50
	midpoint=$(( $midpoint + $step -1 ))
	midpoint=$(( $midpoint / $step ))
	midpoint=$(( $midpoint * $step ))
    fi
done

echo -e "\nThe map resolution is $newbin"
