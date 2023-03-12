#!/bin/bash

createupdate()
{
    component=$1
    name=$2
    parameters=$3
    echo ${component} ACTION --name ${name} ${parameters}
    bx ${component} list | grep ${name}
    if [ $? -ne 0 ]
    then
        echo ${component} ${name} DOES NOT EXIST
        bx ${component} create --name ${name} ${parameters}
        if [ $? -eq 0 ]
        then
            echo CREATED ${component} ${name}
        else
            echo FAILED TO CREATE ${component} ${name} 
            exit 1
        fi
    else
        echo ${component} ${name} EXISTS
        echo bx ${component} update --name ${name} ${parameters}
        bx ${component} update --name ${name} ${parameters}
        if [ $? -eq 0 ]
        then
            echo UPDATED ${component} ${name}
        else
            echo FAILED TO UPDATE ${component} ${name} 
            exit 1
        fi
    fi
    bx ${component} get --name ${name}
}

#bx ce registry create --name ${ic_ce_registry} --server ${ic_ce_registry_server} --username iamapikey --password ${ic_ce_registry_password} --email ${ic_ce_registry_email}

#createupdate "ce repo" ${ic_ce_repo} "--host ${git_host} --key-path ${git_key_path}"

createupdate "ce configmap" ${ic_ce_configmap} "--name ${ic_ce_configmap} --from-env-file ${ic_ce_configmap_file}"

createupdate "ce secret" ${ic_ce_secret} "--from-env-file ${ic_ce_secret_file}"