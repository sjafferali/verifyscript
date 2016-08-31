#!/bin/bash

purple="\033[35;1m"
cyan="\033[1;36m"
green="\033[32m"
yellow="\033[0;33m"
bred="\033[1;31m"
blue="\033[0;34m"
defclr="\033[0m"

echo -e "$blue ====== Script Verification ====== $defclr"


if [[ -z $2 ]]
then
  echo -e "$blue Using Method: github $defclr"
  REPO=$(echo $1 | awk '{print$1}' | awk -F/ '{print$4"/"$5}')
  BRANCH=$(echo $1 | awk '{print$1}' | awk -F/ '{print$6}')

  VERIFY_URL=$(curl -s https://api.github.com/repos/$REPO/git/refs/heads/$BRANCH | awk -F'"' '/url.*commit/ {print$4}') 

  RESULT=$(curl -sH "Accept: application/vnd.github.cryptographer-preview" https://api.github.com/repos/sjafferali/rsi/git/commits/d8fbf275ffb95e9246ef17a2d21b1743d86a19f3 | awk -F" |," '/verified/ {print$6}')
fi



if [[ $RESULT == "true" ]]
then
  echo -e "$blue Verification: $green Passed $blue. Executing script. $defclr"
  echo -e "$blue ================================== $defclr\n"
  bash <(curl -s $(echo $1 | awk '{print$1}')) $(echo $1 | awk '{print$2" "$3" "$4" "$5" "}')
else
  echo -e "$blue Verification: $bred Failed $blue. Not executing script. $defclr"
  echo -e "$blue ================================== $defclr\n"
fi
