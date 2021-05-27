#!/bin/bash
# The interpreter used to execute the script

#“#SBATCH” directives that convey submission options:

#SBATCH --job-name=ConsciousPig
#SBATCH --mail-user=gharahih@umich.edu
#SBATCH --mail-type=END
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=36
#SBATCH --mem-per-cpu=2000m 
#SBATCH --time=120:00:00
#SBATCH --account=beardda1
#SBATCH --partition=standard
#SBATCH --output=/home/%u/%x-%j.log
#SBATCH --output=matlab_parfor.out
#SBATCH --error=matlab_parfor.err

cd /home/gharahih/ExerciseModel/ExerciseModel/ConsciousPig/
module load matlab
matlab -nodisplay -r -noFigureWindows -nosplash "ExerciseModelParamEst" > ConsciousPig.out

