#!/bin/bash

# Pattern to match files
pattern="priv/repo/migrations/2025.*\.exs"

# Find deleted files matching the pattern using git log
echo "Running: git log --diff-filter=D --name-only | grep '$pattern' | sort -u"
deleted_files=$(git log --diff-filter=D --name-only | grep "$pattern" | sort -u)

# Check if any deleted files were found
if [[ -z "$deleted_files" ]]; then
  echo "No deleted files found matching the pattern."
  exit 0
fi

# Iterate through each deleted file
while IFS= read -r file; do
  echo "=================================================="
  echo "File: $file"
  echo "=================================================="

  # Get commit history for the file
  echo "Running: git log --pretty=format:\"%H %ad\" --date=iso-strict --follow -- \"$file\""
  commits=$(git log --pretty=format:"%H %ad" --date=iso-strict --follow -- "$file")

  # Iterate through the commits
  while IFS=$' \t\n' read -r commit commit_date; do
    echo "--------------------------------------------------"
    echo "Commit: $commit"
    echo "Commit Date: $commit_date"
    echo "--------------------------------------------------"

    # Show the file content at the current commit
    echo "Running: git show \"$commit:$file\""
    content=$(git show "$commit:$file" 2>&1)

    # Check for deletion
    if [[ $content == *"fatal: path"* ]]; then
        echo "File was deleted in this commit."
    else
        echo "$content"
    fi

  done <<< "$commits"

  echo ""
done <<< "$deleted_files"
