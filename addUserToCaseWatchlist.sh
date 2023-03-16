#!/bin/sh

export stdout=/tmp/stdout
export stderr=/tmp/stderr
export json=/tmp/json
export loglevel=5
export caseParameters=""

[ -f ${json} ] && rm ${json}
[ -f ${stderr} ] && rm ${stderr}
[ -f ${stdout} ] && rm ${stdout}

usage() {
  info "USAGE: $0 [-a|--apikey APIKEY] [[-e|--email IBM_CLOUD_USER_ID]] [[-c|--case IBM_CLOUD_SUPPORT_CASE]] [-d|--debug]"
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

getparameters() {
  while test $# -gt 0
  do
    parameter=$1
    shift
    case $parameter in
      -a|--apikey)
        apikey=$1
        shift
        debug API Key=${apykey}
        ;;
      -d|--debug)
        loglevel=10
        info Log Level=${loglevel}
        ;;
      -e|--email)
        emailParameters="${emailParameters} $1"
        shift
        debug Email List=${emailParameters}
        ;;
      -c|--case)
        caseParameters="${caseParameters} $1"
        shift
        debug Case List=${caseParameters}
        ;;
      *)
        usage
    esac
  done

  export emailParameters
  export caseParameters
}

addusertocase() {
  email=$1
  case=$2
  debug ADD IBM CLOUD USER ID ${email} TO CASE ${case} WATCHLIST
  watchlist='{"watchlist":[{"realm":"IBMid","user_id":"'${email}'","type":"customer"}]}'
  curl -X PUT https://support-center.cloud.ibm.com/case-management/v1/cases/${case}/watchlist --header 'Content-Type:application/json' -H Authorization:${token} -d ${watchlist} 1>${stdout} 2>${stderr}
  if [ $? -ne 0 ]
  then
    debug $(cat ${stdout})
    debug $(cat ${stderr})
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
}

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
  done <${json}
  
  debug ALL CASES = ${allCases}
  debug EMAIL CASES = ${emailCases}

  if test "${allCases}" = "" 
  then
    warn NO ACTIVE CASES
    exit 0
  fi

  for case in ${allCases}
  do
    echo "${emailCases}" | grep "${case}">/dev/null
    if test $? -eq 1
    then 
      addusertocase $email $case
    else
      info IBM CLOUD USER ID ${email} ALREADY PART OF CASE ${case} WATCHLIST
    fi
  done
}

gettoken() {
  info GET IBM CLOUD IDENTITY TOKEN
  curl -X POST "https://iam.cloud.ibm.com/identity/token" --header 'Content-Type: application/x-www-form-urlencoded' --header 'Accept: application/json' --data-urlencode grant_type=urn:ibm:params:oauth:grant-type:apikey --data-urlencode apikey=${apikey} 1>${stdout} 2>${stderr}
  if [ $?  -ne 0 ] 
  then
    error $(cat ${stdout})
    error $(cat ${stderr})
    error ERROR GETTING IBM CLOUD IDENTITY TOKEN
    exit 1
  fi
  export token=$(cat ${stdout} | grep -o '"access_token":"[^"]*' | grep -o '[^"]*$')
  if [ "${token}" = "" ]
  then
    error $(cat ${stdout})
    error FAILED TO GET IBM CLOUD IDENTITY TOKEN 
    exit 1
  fi
}

getallcases() {
  info GET ALL IBM CLOUD CASES
  curl -s -X GET "https://support-center.cloud.ibm.com/case-management/v1/cases?fields=number,watchlist&status=new,in_progress,waiting_on_client,resolution_provided" -H Authorization:${token} 1>${json} 2>${stderr}
  if [ $? -ne 0 ] 
  then
    error $(cat ${json})
    error $(cat ${stderr})
    error ERROR GETTING IBM CLOUD CASES
    exit 1
  fi

  cat ${json} | grep '"number":' >/dev/null
  if  [ $? -ne 0 ]
  then
    debug $(cat ${debug})
    warn NO IBM CLOUD CASES OPENED
  fi
}

getcases() {
  info "GET CASE(S)" $*
  for case in $*
  do
    getcase ${case}
  done
}

getcase() {
  info GET IBM CLOUD CASE $1
  case=$1
  curl -s -X GET "https://support-center.cloud.ibm.com/case-management/v1/cases/${case}?fields=number,watchlist" -H Authorization:${token} 1>${stdout} 2>${stderr}
  if [ $? -ne 0 ] 
  then
    error $(cat ${stdout})
    error $(cat ${stderr})
    error ERROR GETTING IBM CLOUD CASE ${case}
    exit 1
  else
    cat ${stdout} | grep "not_found" >/dev/null
    if [ $? -eq 0 ]
    then
      warn $(cat ${stdout})
      warn FAILED TO GET IBM CLOUD CASE ${case}
    else
      cat ${stdout} >>${json}
    fi
  fi
}

adduserstocases() {
  emails=$1
  for email in ${emails}
  do
    addusertocases ${email}
  done
}

getparameters $*

gettoken

if [ $(echo ${caseParameters} | wc -w) -eq 0 ]
then
  getallcases
else
  getcases ${caseParameters} 
fi

if [ $(echo ${emailParameters} | wc -w) -eq 0 ]
then
  adduserstocases "${emails}"
else
  adduserstocases "${emailParameters}"
fi 
