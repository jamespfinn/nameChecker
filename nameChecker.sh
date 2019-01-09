#!/bin/bash
# 2019.01.09 - jamespfinn@gmail.com - script to check domain and social media availability.
#set -x  
PRETTY=1
PRINT_HEADER=1
WHOIS_TIMEOUT=3

# This function takes as arguments a list of domains to check.  
function checkDomain() {

  #check if timeout is available
  which timeout &>/dev/null && \
  WHOIS_OUTPUT=$(timeout --signal=KILL $WHOIS_TIMEOUT whois -h whois.verisign-grs.com ${1}) || \
  WHOIS_OUTPUT=$(whois -h whois.verisign-grs.com ${1})

  if [ $? -ne 0 ] ; then
    # TIMEOUT
    return 1
  fi

  echo "$WHOIS_OUTPUT" | egrep -q '^No match|^NOT FOUND|^Not fo|AVAILABLE|^No Data Fou|has not been regi|No entri' 
  if [ $? -eq 0 ]; then 
    echo "${1}: available" >2
    return 0
  else
    return 1
  fi 
}

# This function takes as an argument a facebook username to check.
# 404 Response = Available
# Else, unvailable.
function checkFacebook(){
  fbusername=$1
  response=$(curl --write-out %{http_code} --silent --output /dev/null "https://www.facebook.com/$fbusername")

  [ "$response" == "404" ] && return 0 || return 1
}

# This function takes as an argument a twitter handle to check.
# 404 Response = Available
# Else, unvailable.
function checkTwitter(){
  twusername=$1
  response=$(curl --write-out %{http_code} --silent --output /dev/null "https://twitter.com/$twusername")
  [ "$response" == "404" ] && return 0 || return 1
}

# This function takes as an argument an instagram username to check.
# 404 Response = Available
# Else, unvailable.
function checkInstagram(){
  instausername=$1
  response=$(curl --write-out %{http_code} --silent --output /dev/null "https://www.instagram.com/$instausername/")
  [ "$response" == "404" ] && return 0 || return 1
}

function available(){
  if [ $PRETTY -eq 1 ]; then
    printf "\e[92m✔\e[0m"
  else 
    echo 1
  fi
}

function unavailable(){
  if [ $PRETTY -eq 1 ]; then
    printf "\e[91m✗\e[0m"
  else 
    echo 0
  fi
}

placeholder=$(echo $1 | sed 's/./ /g')

if [ $PRINT_HEADER -eq 1 ]; then
  echo -e "$placeholder\t.com\tFb\tTw\tInst"
fi

echo -e  "$1\t$(checkDomain ${1}.com && available || unavailable)\t$(checkFacebook $1 && available || unavailable)\t$(checkTwitter $1 && available || unavailable)\t$(checkInstagram $1 && available || unavailable)"
