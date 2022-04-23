

## Tools

### tools
domaincaller, HiC-Pro, juicer_tools... software used in hic analysis

### uscs 
bin rsync from ucsc, liftOver and some scripts
run.sh tells how these scripts come from
bin and bin/blat are added in PATH 

--------

## project/1KMG/ref_lixs

### scripts
scripts written or modified by lixs
README and run.sh tell more 

### python 
python utils
added in PYTHONPATH 

### hicpro2juiceBox.sh ice2juiceBox.sh

---------

## project/1KMG/in_house

to see scripts in every sub directories: 
tree -f project/1KMG/in_house | grep .sh$ | less
tree -if project/1KMG/in_house | grep .sh$ | grep -v temp | xargs git add --all --