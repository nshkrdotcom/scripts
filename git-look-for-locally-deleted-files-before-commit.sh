#!/bin/bash

# Pattern to match files
pattern="priv/repo/migrations/2025.*\.exs"

# Find files matching the pattern that have been deleted
echo "Running: git ls-files --deleted | grep '$pattern'"
deleted_files=$(git ls-files --deleted | grep "$pattern")

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
  echo "Running: git log --pretty=format:\"%H\" --follow -- \"$file\""
  commits=$(git log --pretty=format:"%H" --follow -- "$file")

  # Iterate through the commits
  while IFS= read -r commit; do
    echo "--------------------------------------------------"
    echo "Content at revision: $commit"
    echo "--------------------------------------------------"

    # Show the file content at the current commit
    echo "Running: git show \"$commit:$file\""
    git show "$commit:$file"
  done <<< "$commits"

  echo ""
done <<< "$deleted_files"
