################################################
#File Name: run.sh
#Author: Up Lee    
#Mail: uplee@pku.edu.cn
#Created Time: Fri May 15 16:20:42 2020
################################################

#!/bin/sh 

#### 2020-05-15 ####
mkdir -p  liftOver/scripts/ bin/ scripts/
chmod 755 liftOver/scripts/ bin/ scripts/

## bin
rsync -a rsync://hgdownload.soe.ucsc.edu/genome/admin/exe/linux.x86_64/ ./bin
## scripts
scp lixs@202.205.131.254:/home/lixs/bin/scripts/* /rd1/user/lixs/Tools/ucsc/scripts/
## liftOver/scripts/
git archive --remote=git://genome-source.soe.ucsc.edu/kent.git   --prefix=kent/ HEAD src/hg/utils/automation      | tar vxf - -C ./liftOver/scripts/ --strip-components=5         --exclude='kent/src/hg/utils/automation/incidentDb'       --exclude='kent/src/hg/utils/automation/configFiles'       --exclude='kent/src/hg/utils/automation/ensGene'       --exclude='kent/src/hg/utils/automation/genbank'       --exclude='kent/src/hg/utils/automation/lastz_D'       --exclude='kent/src/hg/utils/automation/openStack'

#### EO 2020-05-15 ####
