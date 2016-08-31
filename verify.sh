#!/bin/bash

purple="\033[35;1m"
cyan="\033[1;36m"
green="\033[32m"
yellow="\033[0;33m"
bred="\033[1;31m"
blue="\033[0;34m"
defclr="\033[0m"

if [[ -z "$1" ]]
then
  echo '
  Purpose: This script was written to negate the security issues that are present when redirecting 3rd party scripts into bash. It does this by verifying the script using one of two methods to ensure the legitimately of the script before running it. 
  
  == Supported Verification Methods ==
  Method 1: Github PGP Commit Verification
   - This method uses the GitHub API to verify if the commit you are attempting to retrieve is PGP signed.
  
  Method 2: MD5 Hash Verification
   - This method checks the file against the provided MD5 hash that you have personally verified is a legitimate version of the script you are attempting to run.
  
  == Usage ==
  Syntax: bash <(curl -s https://sjafferali.keybase.pub/verify.sh) "script and arguments" "MD5_HASH"
  - If an MD5 hash is not provided, it will use Github PGP verification instead of MD5 verification. 
  
  
  == Examples ==
  To run https://raw.githubusercontent.com/sjafferali/rsi/master/rsi.sh with the -a flag. 
   - Traditionally (without verification): bash <(curl --insecure -s https://raw.githubusercontent.com/sjafferali/rsi/master/rsi.sh) -a
   - With GitHub Verification: bash <(curl -s https://sjafferali.keybase.pub/verify.sh) "https://raw.githubusercontent.com/sjafferali/rsi/master/rsi.sh -a"
   - With MD5 Hash Verification: bash <(curl -s https://sjafferali.keybase.pub/verify.sh) "https://raw.githubusercontent.com/sjafferali/rsi/master/rsi.sh -a" 3e33be38ec154c3f7b717b42bd96b596
  
  '
  exit 1
fi

echo -e "$blue ====== Script Verification ====== $defclr"

if [[ -z $2 ]]
then
  echo -e "$blue Using Method: Github $defclr"
  REPO=$(echo $1 | awk '{print$1}' | awk -F/ '{print$4"/"$5}')
  BRANCH=$(echo $1 | awk '{print$1}' | awk -F/ '{print$6}')

  VERIFY_URL=$(curl -s https://api.github.com/repos/$REPO/git/refs/heads/$BRANCH | awk -F'"' '/url.*commit/ {print$4}') 

  RESULT=$(curl -sH "Accept: application/vnd.github.cryptographer-preview" $VERIFY_URL | awk -F" |," '/verified/ {print$6}')
else
  echo -e "$blue Using Method: MD5 Hash $defclr"
  SCRIPTMD5=$(curl -s $(echo $1 | awk '{print$1}') | md5sum)
  if [[ $SCRIPTMD5 == $2 ]]
  then
    RESULT="true"
  else
    RESULT="false"
  fi
fi

if [[ $RESULT == "true" ]]
then
  echo -e "$blue Verification: $green Passed $blue. Executing script. $defclr"
  echo -e "$blue ================================== $defclr\n"
  VERIFIED=1 bash <(curl -s $(echo $1 | awk '{print$1}')) $(echo $1 | awk '{print$2" "$3" "$4" "$5" "}')
else
  echo -e "$blue Verification: $bred Failed (MD5: $(curl -s $(echo $1 | awk '{print$1}') | md5sum))$blue. Not executing script. $defclr"
  echo -e "If you want to run this script anyways, you should wget the script, inspect its contents and execute it manually. Alterantively, you can also specifiy the MD5 hash above in your command"
  echo -e "$blue ================================== $defclr\n"
fi
