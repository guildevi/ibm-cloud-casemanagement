#!/bin/bash
. $(dirname $0)/profile.sh

ic_ce_component=app
ic_ce_dockerfile=${ic_ce_component}/Dockerfile
ic_ce_app=${ic_ce_module}-${ic_ce_component}
ic_ce_app_port=8080
ic_cr_image=${ic_cr_registry}/${ic_cr_namespace}/${ic_ce_app}
ic_ce_build=${ic_ce_app}-build

invoke()
{
    component=$1
    name=$2
    parameters=$3
    ibmcloudce ${component} get --name ${name}
    if [ $? -eq 0 ]
    then
        debug ${component} ${name} EXISTS
    else
        error ${stdout} ${component} ${name} DOES NOT EXIST
        exit 1
    fi

    #bx ce ${component} get --name ${name} | grep "URL" | grep "codeengine.appdomain.cloud" | cut -w -f2
    url=$(cat ${stdout} | grep "URL" | grep "codeengine.appdomain.cloud" | cut -w -f2)
    if [ "url" != "" ]
    then
        debug URL IS ${url}
        curl ${url} 1>${stdout} 2>&1
        if [ $? -eq 0 ]
        then
            info ${stdout} SUCCESSFULLY INVOKED ${component} ${name}
        else
            error ${stdout} FAILED INVOKING ${component} ${name}
            exit 1
        fi
    else
        error ${stdout} FAILED TO GET URL ${url}
        exit 1
    fi
}

createupdate "build" ${ic_ce_build} "-size small --source ${git_url} --image ${ic_cr_image} --dockerfile ${ic_ce_dockerfile}"

submit build ${ic_ce_build} "--wait"

createupdate "app" ${ic_ce_app} "--env-from-configmap ${ic_ce_configmap} --env-from-secret ${ic_ce_secret} --image ${ic_cr_image} --registry-secret ${ic_ce_registry_secret} --port 8080 --visibility public"

invoke app ${ic_ce_app} 