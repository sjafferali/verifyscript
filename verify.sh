#!/bin/bash

REPO=$(echo $1 | awk '{print$1}' | awk -F/ '{print$4"/"$5}')
BRANCH=$(echo $1 | awk '{print$1}' | awk -F/ '{print$6}')

VERIFY_URL=$(curl -s https://api.github.com/repos/$REPO/git/refs/heads/$BRANCH | awk -F'"' '/url.*commit/ {print$4}') 

RESULT=$(curl -sH "Accept: application/vnd.github.cryptographer-preview" https://api.github.com/repos/sjafferali/rsi/git/commits/d8fbf275ffb95e9246ef17a2d21b1743d86a19f3 | awk -F" |," '/verified/ {print$6}')

if [[ $RESULT == "true" ]]
then
  echo Verification passed. Executing script.
  bash <(curl -s $(echo $1 | awk '{print$1}')) $(echo $1 | awk '{print$2" "$3" "$4" "$5" "}')
else
  echo Verification failed. Not executing script.
fi
