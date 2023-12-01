#!/bin/bash
#SBATCH --job-name=movebetas_bodymap  # Job name
#SBATCH --output=log/movebetas/movebetas_bodymap_%a.out  # Output file name, %a is replaced by the array index
#SBATCH --error=log/movebetas/movebetas_bodymap_%a.err  # Error output file name
#SBATCH --ntasks=1  # Number of MPI ranks
#SBATCH --cpus-per-task=1  # Number of cores per task
#SBATCH --time=24:00:00  # Wall time
#SBATCH --partition=normal  # Partition name
#SBATCH --array=0-108  # Array indices, replace with the number of first-level directories you have -1
#SBATCH --account=DBIC
#SBATCH --partition=standard
# Email notifications (comma-separated options: BEGIN,END,FAIL)
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END

# Output and error log directories
output_log_dir="log/movebetas"
error_log_dir="log/movebetas"

# Create the directories if they don't exist
mkdir -p "$output_log_dir"
mkdir -p "$error_log_dir"

hostname

# Enable extended globbing
shopt -s extglob

# FOR DEBUGGING
# SLURM_ARRAY_TASK_ID=0

# Set the directory paths
firstlvl_dir="/dartfs-hpc/rc/lab/C/CANlab/labdata/data/WASABI/derivatives/canlab_firstlvl"
# Second-level batch analysis directory
data_dir="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/WASABI/WASABI_N_of_Few/analysis/WASABI-NofFew_BodyMap/data"

# Set your conditions
# Define the conditions array in Bash
# conditions=("hot_leftface" "warm_leftface" "imagine_leftface"
#             "hot_rightface" "warm_rightface" "imagine_rightface"
#             "hot_leftarm" "warm_leftarm" "imagine_leftarm"
#             "hot_rightarm" "warm_rightarm" "imagine_rightarm"
#             "hot_leftleg" "warm_leftleg" "imagine_leftleg"
#             "hot_rightleg" "warm_rightleg" "imagine_rightleg"
#             "hot_chest" "warm_chest" "imagine_chest"
#             "hot_abdomen" "warm_abdomen" "imagine_abdomen")

# Initialize an empty array to store the quoted strings
# quoted_conditions=()
# for condition in "${conditions[@]}"; do
#   quoted_conditions+=("'$condition'")
# done

# Convert the quoted_conditions array into a comma-separated string
# conditions_str=$(IFS=,; echo "{${quoted_conditions[*]}}")

# If you ran many first-level GLMs, e.g., by subject or by session, you may have to do this:
# Find all the directories matching the pattern 'firstlvl/bodymapST+([1-2])'
# map_dirs=("$firstlvl_dir"/sub-*/ses-*/func/firstlvl/bodymapST+([1-2]))
map_dirs=("$firstlvl_dir"/sub-*/ses-*/func/firstlvl/bodymap)

sub=$(basename "$(dirname "$(dirname "$(dirname "$(dirname "${map_dirs[SLURM_ARRAY_TASK_ID]}")")")")")
ses=$(basename "$(dirname "$(dirname "$(dirname "${map_dirs[SLURM_ARRAY_TASK_ID]}")")")")
task=$(basename "${map_dirs[SLURM_ARRAY_TASK_ID]}")

# Print the extracted components for each 'map_dir'
echo "sub: $sub, ses: $ses, task: $task"
echo "conditions: '${conditions_str}'"

module load matlab

# Run the MATLAB function
# srun matlab -nodisplay -r "addpath(genpath('//dartfs-hpc/rc/lab/C/CANlab/modules/spm12')); addpath(genpath('//dartfs-hpc/rc/lab/C/CANlab/labdata/projects/WASABI/software')); move_betas_to_secondlvl('${map_dirs[${SLURM_ARRAY_TASK_ID}]}', '${data_dir}', 'symlink', ${conditions_str})"
srun matlab -nodisplay -r "move_betas_to_secondlvl('${map_dirs[${SLURM_ARRAY_TASK_ID}]}', '${data_dir}', 'symlink')"
