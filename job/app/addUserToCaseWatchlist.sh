#!/bin/sh

echo apikey=${apikey}
echo emails=${emails}

export cases_json=/tmp/cases.json

addUserToCases()
{ 
  email=$1
  echo ADD ${email}

  allCases=""
  emailCases=""

  while read line
  do
    field=$(echo $line |cut -d' ' -f1 | cut -d\" -f2)
    value=$(echo $line |cut -d' ' -f2 | cut -d\" -f2)
    #echo ${field}=${value}
    case $field in
      number)
        case=${value}
        allCases="${allCases} ${case}"      
        ;;
      user_id)
        [ "${email}" = "${value}" ] && emailCases="${emailCases} ${case}" 
        ;;
      *)
        #echo $line
     esac
  done <${cases_json}

  echo ... ALL CASES = ${allCases}
  echo ... EMAIL CASES = ${emailCases}

  if test "${allCases}" = "" 
  then
    echo ... NO CASES
    exit 0
  fi

  for case in ${allCases}
  do
    echo "${emailCases}" | grep "${case}">/dev/null
    if test $? -eq 1
    then 
      watchlist='{"watchlist":[{"realm":"IBMid","user_id":"'${email}'","type":"customer"}]}'
      echo ... TO ${case}
      curl -X PUT https://support-center.cloud.ibm.com/case-management/v1/cases/${case}/watchlist --header 'Content-Type:application/json' -H Authorization:${token} -d ${watchlist}
    else
      echo ... NOT TO ${case}
    fi
  done
}


echo GET TOKEN
token=$(curl -X POST "https://iam.cloud.ibm.com/identity/token" --header 'Content-Type: application/x-www-form-urlencoded' --header 'Accept: application/json' --data-urlencode grant_type=urn:ibm:params:oauth:grant-type:apikey --data-urlencode apikey=${apikey} | grep -o '"access_token":"[^"]*' | grep -o '[^"]*$')
echo $token


echo GET CASES
curl -X GET "https://support-center.cloud.ibm.com/case-management/v1/cases?fields=number,watchlist&status=new,in_progress,waiting_on_client,resolution_provided" -H Authorization:${token} | grep '"number":\|"user_id":' >${cases_json}

cat ${cases_json}

for email in ${emails}
do
  addUserToCases ${email}
done