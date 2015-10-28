#!/usr/bin/env bash
# mountall - mount all partitions from an image in subfolders of the current directory
# Usage: mountall my_disk.dd

# Author: Luc Gommans
# Version: 1.2

# Find the block size from fdisk
bs=$(fdisk -l $1 | grep sectors | grep ' bytes$' | grep -o '[0-9]* bytes$' | grep -o '[0-9]*')
echo Detected block size $bs

# Pipe the output from fdisk, the part that displays partitions, to a loop
# Every line is read into the variable called $line
fdisk --color=never -l $1 | grep -EA9001 '^Device.*Boot.*Start.*End' | grep '[0-9]' | while read line; do
	# The directory we're going to mount in is simply the device name prefixed with 'mnt-'
	dir=$(echo "$line" | awk '{print "mnt-" $1}');

	# Does the second column contain a '*' sign?
	echo "$line" | awk '{print $2}' | grep '*' > /dev/null
	if [ $? -eq 0 ]; then # If this was a boot partition, the * is seen as a column so skip it...
		start=$(echo "$line" | awk '{print $3}')
		end=$(echo "$line" | awk '{print $4}')
	else
		start=$(echo "$line" | awk '{print $2}')
		end=$(echo "$line" | awk '{print $3}')
	fi;

	mkdir $dir 2>/dev/null; # Redirect error output in case the dir already exists
	lodev=$(losetup -f) # Create and store a loop device to use
	offset=$(($start*$bs)) # Calculate the offset to use
	losetup -o $offset $lodev $1 # Setup the loop device with the image to mount and the right offset

	# Show what we have found and calculated
	echo "part $dir starts $start ends $end loopdev $lodev offset $offset; mounting..."

	# And finally try mounting it
	mount -ro $lodev $dir

	# If that didn't work, show that it didn't work.
	if [ $? -ne 0 ]; then
		echo "ERROR MOUNTING $dir"
	fi;
done

