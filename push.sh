#!/bin/bash

echo "Enter your commit message:"
read commit_message

git add -A
git commit -m "$commit_message"
git push origin main


