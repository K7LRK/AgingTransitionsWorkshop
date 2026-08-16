#!/usr/bin/env bash

# Usage:
#   ./md2docx.sh input.md
#
# This script is standalone:
#   - strip_footnotes()     – inline version of strip-footnotes.sh
#   - fix_md_headings()     – inline version of fix-md-headings.sh
# It does NOT call any external helper scripts.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cleanup=1

strip_footnotes() {
  local infile="$1"
  local outfile="FootnotesStripped.md"

  if [[ -z "$infile" || ! -f "$infile" ]]; then
    echo "strip_footnotes: missing or invalid input file" >&2
    return 1
  fi

  echo "Stripping bracketed footnotes into: $outfile" >&2
  # Remove any text in square brackets and the brackets themselves.
  # [^]]* = any run of non-] characters; escapes [ and ] so they’re literal.
  sed 's/\[\^[^]]*\]//g; s/\[[0-9][0-9]*\]//g' "$infile" > "$outfile"
}

fix_md_headings() {
  local infile="$1"
  local outfile="HeadingsFixed.md"

  if [[ -z "$infile" || ! -f "$infile" ]]; then
    echo "fix_md_headings: missing or invalid input file" >&2
    return 1
  fi

  echo "Collapsing multiple blank lines, writing to: $outfile" >&2

  awk '
  # NF == 0 means blank/empty line
  NF == 0 {
    if (!blank) {
      print ""     # print a single blank line
      blank = 1    # remember we are in a blank run
    }
    next           # skip further processing for this line
  }

  # Non-blank line
  {
    blank = 0      # reset blank-run flag
    print
  }
  ' "$infile" > "$outfile"
}

# ---------------- main ----------------

input="$1"

if [[ -z "$input" || ! -f "$input" ]]; then
  echo "Usage: $0 input.md" >&2
  exit 1
fi

echo "md2docx standalone starting, arg: $input" >&2

# Derive output name from input name and document **Date:** header (YYYY-MM-DD)
# Falls back to file birth time if no date header is found
base="$(basename "$input")"
name_no_ext="${base%.*}"
raw_date=$(grep -m1 '\*\*Date:\*\*' "$input" | sed 's/.*\*\*Date:\*\*[[:space:]]*//' | tr -d '\r' | sed 's/[[:space:]]*$//')
if [[ "$raw_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]][0-9]{2}:[0-9]{2}$ ]]; then
  # Full date and time: YYYY-MM-DD HH:MM
  datetime=$(echo "$raw_date" | sed 's/-//g; s/://g; s/ //' | cut -c 3-12)
  echo "Using document date+time for filename: $raw_date -> $datetime" >&2
elif [[ "$raw_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  # Date only: YYYY-MM-DD — pad time with 0000
  datetime=$(echo "$raw_date" | sed 's/-//g' | cut -c 3-8)
  datetime="${datetime}0000"
  echo "Using document date for filename: $raw_date -> $datetime" >&2
else
  datetime="$(stat -f "%SB" -t "%y%m%d%H%M" "$input")"
  echo "No document date found, falling back to file birth time: $datetime" >&2
fi
output="${datetime}_${name_no_ext}.docx"

echo "Using input file: $input" >&2

# Step 1: strip footnotes (function defined above)
strip_footnotes "$input" || exit 1

# Step 2: normalize blank lines (function defined above)
fix_md_headings "FootnotesStripped.md" || exit 1

# Step 2.5: Replace standalone --- lines with * * * so pandoc cannot
# misinterpret them as YAML metadata block delimiters. Both produce a
# horizontal rule in the rendered output.
# Exception: preserve the opening and closing --- of a YAML frontmatter block
# at the very start of the file (lines 1 and the first --- that closes it).
awk '
  /^---$/ && !yaml_seen { yaml_seen=1; yaml_open=1; print; next }
  /^---$/ && yaml_open  { yaml_open=0; print; next }
  /^---$/               { print "* * *"; next }
  { print }
' HeadingsFixed.md > HeadingsFixed_yaml.md \
  && mv HeadingsFixed_yaml.md HeadingsFixed.md

# Step 3: run pandoc on the cleaned markdown
input="HeadingsFixed.md"

echo "Running pandoc on: $input -> $output" >&2
echo "Using template: $SCRIPT_DIR/StylesSettingDocument.docx" >&2

pandoc "$input" \
  --from=markdown \
  --to=docx \
  --reference-doc="$SCRIPT_DIR/StylesSettingDocument.docx" \
  -o "$output"

# Step 4: add footer (filename left, page / total right)
echo "Adding footer to: $output" >&2
python3 "$SCRIPT_DIR/add_footer.py" "$output"

if [[ "$cleanup" -eq 1 ]]; then
  echo "Deleting intermediate files" >&2
  rm -f FootnotesStripped.md HeadingsFixed.md
fi
