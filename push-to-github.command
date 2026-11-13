#!/bin/bash

set -u

finish() {
  status=$?
  trap - EXIT
  printf "\n"
  read -r -p "Press Return to close this window..." _ || true
  exit "$status"
}
trap finish EXIT

cd "$(dirname "$0")" || {
  echo "Could not open the project folder."
  exit 1
}

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "This folder is not a Git repository."
  exit 1
fi

branch=$(git branch --show-current) || exit 1
if [ "$branch" != "main" ]; then
  echo "Expected branch 'main', but the current branch is '$branch'."
  exit 1
fi

remote=$(git remote get-url origin) || {
  echo "Could not find the 'origin' remote."
  exit 1
}
case "$remote" in
  https://github.com/sd4wgyzzk5-ship-it/retailnetwork.git|git@github.com:sd4wgyzzk5-ship-it/retailnetwork.git)
    ;;
  *)
    echo "The 'origin' remote is not the expected Retail Network repository:"
    echo "$remote"
    exit 1
    ;;
esac

if [ -n "$(git status --porcelain)" ]; then
  echo "Note: uncommitted changes will not be included in this push:"
  git status --short
  printf "\n"
fi

echo "Pushing committed changes from main to GitHub..."
if git push origin main; then
  echo "Push completed successfully."
  echo "GitHub Pages should deploy the updated site shortly."
else
  status=$?
  echo "Push failed."
  echo "If authentication is the problem, sign in with GitHub CLI first:"
  echo "  gh auth login"
  echo "  gh auth setup-git"
  exit "$status"
fi
