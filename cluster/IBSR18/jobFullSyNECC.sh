#!/bin/bash
####################################################
# Author: Omar Ocegueda (omar@cimat.mx)
#PBS -l mem=3GB
#PBS -l pmem=3GB
#PBS -l vmem=3GB
#PBS -l nodes=1:ppn=1
#PBS -l walltime=06:00:00
#PBS -N FullSyNECC
#PBS -M omar@cimat.com
export PATH="/opt/python/anaconda/bin:$PATH"
export PYTHONPATH="/opt/python/anaconda/lib/python2.7/site-packages:/export/opt/python/anaconda/lib/python2.7/site-packages:$PYTHONPATH:$HOME/code/registration"
export PATH=$HOME/opt:$PATH
export PYTHONPATH=$HOME/opt/dipy:$HOME/opt/lib/python2.7/site-packages:$PYTHONPATH
###################################
echo "=====Dipy commit ====="
(cd ~/opt/dipy &&  git branch|grep "*")
(cd ~/opt/dipy &&  git show --stat|grep "commit\|Date")
echo "====dipyreg commit===="
(cd ~/code/registration &&  git branch|grep "*")
(cd ~/code/registration &&  git show --stat|grep "commit\|Date")
echo "======================"
date
reference=$(ls reference)
target=$(ls target)
extension="${target##*.}"
targetbase="${target%.*}"
targetbase="${targetbase%.*}"
referencebase="${reference%.*}"
referencebase="${referencebase%.*}"
#Affine registration using Mutual information with ANTS
affine="${targetbase}_${referencebase}Affine.txt"
affinePrecomputed="../affine/${affine}"
if [ -r $affinePrecomputed ]; then
    cp $affinePrecomputed .
fi
if ! [ -r $affine ]; then
    ANTS 3 -m MI[reference/$reference, target/$target, 1, 32] -i 0 -o ${targetbase}_${referencebase}
else
    echo "Affine mapping found ($affine). Skipping affine registration."
fi
#Diffeomorphic registration
python dipyreg.py target/$target reference/$reference $affine warp target_mask.nii.gz reference_mask.nii.gz --metric=ECC[1.7,4,256] --iter=100,100,25 --step_length=0.25
date
