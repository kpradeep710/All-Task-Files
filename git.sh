#!/bin/bash

# Set variables
REPO_NAME="nani-710"
MAIN_BRANCH="main"
STAGING_BRANCH="feature"
DEV_BRANCH="development"
UAT_BRANCH="uat"
GITHUB_USER="kpradeep710"

# 1. Create repo
curl -u "$GITHUB_USER" https://api.github.com/kpradeep710/nani-710 -d "{\"name\":\"$REPO_NAME\"}"

# Navigate to repo directory
git clone https://github.com/$GITHUB_USER/$REPO_NAME.git
cd $REPO_NAME

# 2. Create files and push to repo
echo "f1 file" > f1.txt
echo "java file" > java.txt
echo "python file" > python.txt
git add f1.txt java.txt python.txt
git commit -m "Add initial files"
git push

# 3. Create another branch
git checkout -b $STAGING_BRANCH

# 4. Add files to new branch(staging) and push back to git
echo "f1 file" > f1.txt
echo "java file" > java.txt
echo "python file" > python.txt
git add .
git commit -m "Add files to staging"
git push

# 5. Create PR and merge with main branch
# Requires GitHub CLI
gh pr create --title "Merge staging into main" --body "Merging changes" --base $MAIN_BRANCH --head $STAGING_BRANCH
gh pr merge --merge

# 6. Create development branch and create 3 files -> add 3 files -> do commit -> revert 1 file out of 3
git checkout -b $DEVELOPMENT_BRANCH
echo "f2 file" > f2.txt
echo "f3 file" > f3.txt
echo "f4 file" > f4.txt
git add .
git commit -m "Add development files"
git reflog
git revert a1b220c
git push 

# 7. Create UAT branch and create 3 files -> add 3 files -> do commit -> do push -> revert 1 file out of 3
git checkout -b $UAT_BRANCH
echo "s1 file" > s1.txt
echo "s2 file" > s2.txt
echo "s3 file" > s3.txt
git add .
git commit -m "UAT files"
git reflog
git revert 0ceabab
git push

echo "Completed all tasks."
