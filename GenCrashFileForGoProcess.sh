#!/bin/sh

readonly MAX_CRASH_FILES=5

# Check if source and destination directories are provided as arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <process>"
    exit 1
fi

# Source directory containing files to copy
source_dir="/var/log/"

# Create a timestamp for the zip filename
#timestamp=$(date +"%Y%m%d_%H%M%S")
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")


process=$1

crashFile="${process}_crash_${timestamp}"

echo "File name is $crashFile"

# Destination directory where files will be copied
destination_dir="path-to-store/$crashFile"

# Ensure the destination directory exists
mkdir -p "$destination_dir"

# Copy files from source directory to destination directory
cp -r "$source_dir"/$process* "$destination_dir"/

# Zip archive filename (with timestamp)
zip_filename="${crashFile}_${timestamp}"

# Create a zip archive of the copied files
zip -r "$destination_dir/../$zip_filename" "$destination_dir"
rm -rf $destination_dir


#Delete the oldest crash file once crash files reaches max limit of files to be retained
countOfCrashFiles=`ls *$process* | wc -l`
if [ $countOfCrashFiles -ge $MAX_CRASH_FILES ]; then 
	oldestFile=$(ls -t  *$process* | tail -1)
	if [ -n "$oldestFile" ]; then 
		echo "Deleting oldest crash file : $oldestFile as limit of $MAX_CRASH_FILES files are reached !!!"
		rm $oldestFile

echo "Files copied and zipped successfully!"
       
