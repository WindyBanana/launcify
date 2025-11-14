#!/bin/bash
# Push with automatic retry and rebase

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git add -A
git commit -m "chore: update Context7 configs for new AI editor platforms"

# Retry push up to 3 times with rebase
for i in 1 2 3; do
  echo "Push attempt $i..."
  if git push origin master 2>&1; then
    echo "✓ Push succeeded"
    exit 0
  else
    echo "✗ Push failed"
    if [ $i -lt 3 ]; then
      echo "Rebasing and retrying..."
      git pull --rebase origin master || exit 1
      sleep 2
    fi
  fi
done

echo "✗ Failed to push after 3 attempts"
exit 1
