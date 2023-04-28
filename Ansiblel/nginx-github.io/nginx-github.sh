#!/bin/bash

# Set the name of the GitHub repository
read -p "enter the GITHUB_REPO_NAME:" REPO_NAME

# Set the GitHub username
read -p "enter the GITHUB_USERNAME:" GITHUB_USERNAME
read -p "enter the GITHUB_TOKEN:" GITHUB_TOKEN

# Set the path to the local repository
LOCAL_REPO_PATH="/root/nginx/"

# Navigate to the local repository
cd $LOCAL_REPO_PATH

# Initialize the Git repository if it hasn't been already
if [ ! -d ".git" ]; then
  git init
fi

# Add all files to the Git staging area
git add .

# Commit the changes with a message
git commit -m "Initial commit"

# Add the remote GitHub repository
git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"

# Push the changes to the GitHub repository
git push -u origin master

# Confirm that the push was successful
if [ $? -eq 0 ]; then
  echo "Push successful"
else
  echo "Push failed"
fi

