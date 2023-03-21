#!/bin/bash

# Check if the current directory is a git repository using git utility
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "Error: This is not a Git repository."
  exit 1
fi

git_main_branch () {
        command git rev-parse --git-dir &> /dev/null || return
        local ref
        for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk}
        do
                if command git show-ref -q --verify $ref
                then
                        echo ${ref:t}
                        return
                fi
        done
        echo master
}

SINCE_DATE=$(date -d "1 month ago" +%Y-%m-%d)

AUTHORS=$(git log $(git_main_branch) --pretty=format:'%aN' --since="$SINCE_DATE" | sort -u)

echo "Number of commits since $SINCE_DATE, by author:"

while read -r author; do
  COMMITS=$(git log $(git_main_branch) --oneline --author="$author" --since="$SINCE_DATE" | wc -l)
  echo "$author: $COMMITS"
done <<< "$AUTHORS" | sort -t ':' -k 2nr
