#! /bin/sh

# Run the program
OUTPUT=$(zig build run -- sample.txt)

if [ $? -ne 0 ]; then
	echo "OUTPUT:"
	echo "$OUTPUT"
	exit 1
fi

# Read the expected output file
EXPECTED=$(cat sample-out.txt)

# Compare
clear
if [ "$OUTPUT" = "$EXPECTED" ]; then
	echo "✅"
else
	echo "Mismatch!"
	echo "---- OUTPUT ----"
	echo "$OUTPUT"
	echo "---- EXPECTED ----"
	echo "$EXPECTED"
fi
