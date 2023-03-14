#!/bin/bash

. conf/.profile

. conf/logintarget.sh
. conf/createcommon.sh

ic_ce_component=app
ic_ce_dockerfile=${ic_ce_component}/Dockerfile
ic_ce_app=${ic_ce_module}-${ic_ce_component}
ic_ce_app_port=8080
ic_cr_image=${ic_cr_registry}/${ic_cr_namespace}/${ic_ce_app}
ic_ce_build=${ic_ce_app}-build

invoke()
{
    echo ----------------------------------------------------
    echo ----------------------------------------------------
    component=$1
    name=$2
    parameters=$3
    echo curl ${component} --name ${name} ${parameters}
    bx ce ${component} get --name ${name}
    if [ $? -eq 0 ]
    then
        echo ${component} ${name} EXISTS
    else
        echo ${component} ${name} DOES NOT EXIST
        exit 1
    fi

    bx ce ${component} get --name ${name} | grep "URL" | grep "codeengine.appdomain.cloud" | cut -w -f2
    url=$(bx ce ${component} get --name ${name} | grep "URL" | grep "codeengine.appdomain.cloud" | cut -w -f2)
    if [ "url" != "" ]
    then
        echo URL IS ${url}
        curl ${url}
        if [ $? -eq 0 ]
        then
            echo SUCCESSFULLY INVOKED ${component} ${name}
        else
            echo FAILED INVOKING ${component} ${name}
            echo 1
        fi
    else
        echo FAILED TO GET URL ${url}
        exit 1
    fi
}

#createupdate "build" ${ic_ce_build} "-size small --source ${git_url} --image ${ic_cr_image} --dockerfile ${ic_ce_dockerfile}"

#submit build ${ic_ce_build} "--wait"

#createupdate "app" ${ic_ce_app} "--env-from-configmap ${ic_ce_configmap} --env-from-secret ${ic_ce_secret} --image ${ic_cr_image} --registry-secret ${ic_ce_registry_secret} --port 8080 --visibility public"

invoke app ${ic_ce_app} 