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

#   Splits a UK Biobank bulk file into n roughly equal parts.
#   Output files are renamed to <ID>_part_n1.bulk through <ID>_part_n4.bulk

# Usage:
#   sbatch split_bulk_file.slurm <UKB_ID> <NUM_PARTS>
#   Example:
#     sbatch split_bulk_file.slurm 20250 6

# -------------------------- USER CONFIGURATION ------------------------------

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: sbatch $0 <UKB_ID> <NUM_PARTS>"
    echo "Example: sbatch $0 20250 6"
    exit 1
fi

ID="$1"
NUM_PARTS="$2"
input_file="/scratch/user/${USER}/ukb/${ID}.bulk"

# ------------------------ VALIDATE INPUT FILE --------------------------

if [[ ! -f "$input_file" ]]; then
    echo "Error: File $input_file does not exist."
    exit 1
fi

if ! [[ "$NUM_PARTS" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: NUM_PARTS must be a positive integer."
    exit 1
fi

# ------------------------ SPLIT LOGIC ----------------------------------

total_lines=$(wc -l < "$input_file")
lines_per_file=$(( (total_lines + NUM_PARTS - 1) / NUM_PARTS ))  # ceiling division

split -d -l "$lines_per_file" "$input_file" "${ID}_part_"

# ------------------------ RENAME FILES ---------------------------------

counter=1
for file in ${ID}_part_??; do
    mv "$file" "${ID}_part_${counter}.bulk"
    ((counter++))
done

echo "Successfully split ${ID}.bulk into ${NUM_PARTS} parts:"
wc -l ${ID}_part_*.bulk
