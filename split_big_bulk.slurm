#!/bin/bash --login
#SBATCH --job-name=split-bulk
#SBATCH --time=00:15:00
#SBATCH --mem=2G
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --partition=general
#SBATCH --account=a_lena_neuro
#SBATCH -o slurm_%j_output.txt
#SBATCH -e slurm_%j_error.txt

# -------------------------- USER CONFIGURATION ------------------------------

ID="20250"
input_file="/scratch/user/uqahonne/ukb/${ID}.bulk"

# -------------------------- CHECK IF FILE EXISTS ----------------------------

if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file $input_file does not exist."
    exit 1
fi

# -------------------------- SPLIT LOGIC -------------------------------------

# Count total number of lines in the input file
lines=$(wc -l < "$input_file")

# Calculate number of lines per split file (rounded up to ensure full coverage)
lines_per_file=$(( (lines + 3) / 4 ))  # 4 parts

# Split the input file into 4 parts using numeric suffixes
split -d -l "$lines_per_file" "$input_file" input_part_

# Rename parts to readable format (e.g., 20250_part_1.bulk)
mv input_part_00 ${ID}_part_1.bulk
mv input_part_01 ${ID}_part_2.bulk
mv input_part_02 ${ID}_part_3.bulk
mv input_part_03 ${ID}_part_4.bulk

# Output confirmation
echo "Split into 4 parts:"
wc -l ${ID}_part_*.bulk

