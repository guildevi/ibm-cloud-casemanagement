#!/bin/sh

stdout=/tmp/stdout
stderr=/tmp/stderr
export cases_json=/tmp/cases.json
loglevel=5

usage() {
  info "USAGE: $0 [-a|--apikey APIKEY] [[-e|--email IBM_CLOUD_USER_ID]] [-d|--debug]"
  exit 1
}

log() {
  echo $(date "+%Y-%m-%d %H:%M:%S") $*
}

error() {
  [ ${loglevel} -ge 0 ] && log ERROR $* 
}

warn() {
  [ ${loglevel} -ge 2 ] && log WARNING $* 
}

info() {
  [ ${loglevel} -ge 5 ] && log INFO $*
}

debug() {
  [ ${loglevel} -ge 10 ] && log DEBUG $* 
}

while test $# -gt 0
do
  parameter=$1
  shift
  case $parameter in
    -a|--apikey)
      apikey=$1
      shift
      ;;
    -d|--debug)
      loglevel=10
      ;;
    -e|--email)
      emails="${emails} $1"
      shift
      ;;
    *)
    usage
  esac
done

addusertocases()
{ 
  email=$1
  debug ADD IBM CLOUD USER ID ${email} TO CASE WATCHLIST

  allCases=""
  emailCases=""

  while read line
  do
    field=$(echo $line |cut -d' ' -f1 | cut -d\" -f2)
    value=$(echo $line |cut -d' ' -f2 | cut -d\" -f2)
    debug ${field}=${value}
    case $field in
      number)
        case=${value}
        allCases="${allCases} ${case}"      
        ;;
      user_id)
        [ "${email}" = "${value}" ] && emailCases="${emailCases} ${case}" 
        ;;
      *)
        debug IGNORED LINE: $line
    esac
  done <${cases_json}
  
  debug ... ALL CASES = ${allCases}
  debug ... EMAIL CASES = ${emailCases}

  if test "${allCases}" = "" 
  then
    debug ... NO CASES
    exit 0
  fi

  for case in ${allCases}
  do
    echo "${emailCases}" | grep "${case}">/dev/null
    if test $? -eq 1
    then 
      debug ADD IBM CLOUD USER ID ${email} TO CASE ${case} WATCHLIST
      watchlist='{"watchlist":[{"realm":"IBMid","user_id":"'${email}'","type":"customer"}]}'
      curl -X PUT https://support-center.cloud.ibm.com/case-management/v1/cases/${case}/watchlist --header 'Content-Type:application/json' -H Authorization:${token} -d ${watchlist} 1>${stdout} 2>${stderr}
      if [ $? -ne 0 ]
      then
        debug $(cat ${stdout})
        debuc $(cat ${stderr})
        warn FAILED TO ADD IBM CLOUD USER ID ${email} TO CASE ${case} WATCHLIST
      else
        cat ${stdout} | grep '"added": \[\],' >/dev/null
        if [ $? -eq 0 ] 
        then 
          warn $(cat ${stdout})
          warn FAILED TO ADD IBM CLOUD USER ID ${email} TO CASE ${case} WATCHLIST
        else
          info ADDED IBM CLOUD USER ID ${email} TO CASE ${case} WATCHLIST
        fi
      fi
    else
      info IBM CLOUD USER ID ${email} ALREADY PART OF CASE ${case} WATCHLIST
    fi
  done
}

info GET IBM CLOUD IDENTITY TOKEN
curl -X POST "https://iam.cloud.ibm.com/identity/token" --header 'Content-Type: application/x-www-form-urlencoded' --header 'Accept: application/json' --data-urlencode grant_type=urn:ibm:params:oauth:grant-type:apikey --data-urlencode apikey=${apikey} 1>${stdout} 2>${stderr}
if [ $?  -ne 0 ] 
then
  error $(cat ${stdout})
  error $(cat ${stderr})
  error ERROR GETTING IBM CLOUD IDENTITY TOKEN
  exit 1
fi
token=$(cat ${stdout} | grep -o '"access_token":"[^"]*' | grep -o '[^"]*$')
if [ "${token}" = "" ]
then
  error $(cat ${stdout})
  error FAILED TO GET IBM CLOUD IDENTITY TOKEN 
  exit 1
fi

info GET IBM CLOUD CASES
curl -s -X GET "https://support-center.cloud.ibm.com/case-management/v1/cases?fields=number,watchlist&status=new,in_progress,waiting_on_client,resolution_provided" -H Authorization:${token} 1>${cases_json} 2>${stderr}
if [ $? -ne 0 ] 
then
  error $(cat ${cases_json})
  error $(cat ${stderr})
  error ERROR GETTING IBM CLOUD CASES
  exit 1
fi

cat ${stdout} | grep '"number":' >/dev/null
if  [ $? -ne 0 ]
then
  debug $(cat ${stdout})
  warn NO IBM CLOUD CASES OPENED
fi

for email in ${emails}
do
  addusertocases ${email}
done