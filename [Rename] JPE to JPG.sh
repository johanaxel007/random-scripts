#!/bin/bash

# Find and loop through all .jpe files recursively
find . -type f -name "*.jpe" -print0 | while IFS= read -r -d '' file; do
    # Strip the .jpe extension and append .jpg
    new_file="${file%.jpe}.jpg"
    
    # Rename the file
    mv "$file" "$new_file"
    echo "Renamed: $file -> $new_file"
done
