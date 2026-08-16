#!/bin/bash

# Convert DOCX to Markdown using pandoc
# Usage: ./docx_to_md.sh input.docx [output.md]

if [ $# -eq 0 ]; then
    echo "Usage: $0 input.docx [output.md]"
    echo "Example: $0 document.docx"
    echo "         $0 document.docx custom_name.md"
    exit 1
fi

INPUT_FILE="$1"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found"
    exit 1
fi

# Generate output filename if not provided
if [ $# -eq 2 ]; then
    OUTPUT_FILE="$2"
else
    # Get basename without extension and add .md
    OUTPUT_FILE="${INPUT_FILE%.*}.md"
fi

echo "Converting '$INPUT_FILE' to '$OUTPUT_FILE'..."

# Run pandoc conversion
pandoc "$INPUT_FILE" -t markdown -o "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo "Successfully created: $OUTPUT_FILE"
else
    echo "Conversion failed"
    exit 1
fi