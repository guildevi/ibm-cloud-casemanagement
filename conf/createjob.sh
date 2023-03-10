#!/bin/bash
set -f
. ./.profile

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


bx login
if [ $? -eq 0 ]
then
    echo LOGIN SUCCESSFUL
else
    echo LOGIN FAILED
    exit 1
fi

bx resource group ${ibmcloud_resource_group}
if [ $? -eq 0 ]
then
    echo RESOURCE GROUP ${ibmcloud_resource_group} EXISTS
else
    echo RESOURCE GROUP ${ibmcloud_resource_group} DOES NOT EXIST
    bx resource group-create ${ibmcloud_resource_group}
    if [ $? -eq 0 ]
    then
        echo CREATED RESOURCE GROUP ${ibmcloud_resource_group}
    else
        echo FAILED TO CREATE RESOURCE GROUP ${ibmcloud_resource_group}
        exit 1
    fi
fi

bx target -g ${ibmcloud_resource_group}
if [ $? -eq 0 ]
then
    echo TARGET RESOURCE GROUP ${ibmcloud_resource_group}
else
    echo FAILED TO TARGET RESOURCE GROUP ${ibmcloud_resource_group}
fi

bx cr region-set ${ic_cr_region}
if [ $? -eq 0 ]
then
    echo SET CONTAINER REGISTRY TO ${ic_cr_region}
else
    echo FAILED TO SET CONTAINER REGISTRY TO ${ic_cr_region}
    exit 1
fi

bx cr namespace-list | grep  ${ic_cr_namespace}
if [ $? -eq 0 ]
then
    echo CONTAINER REGISTRY NAMESPACE ${ic_cr_namespace} EXISTS
else
    echo CONTAINER REGISTRY NAMESPACE ${ic_cr_namespace} DOES NOT EXIST
    bx cr namespace-add -g ${ibmcloud_resource_group} ${ic_cr_namespace}
    if [ $? -eq 0 ]
    then
        echo ADDED CONTAINER REGISTRY NAMESPACE ${ic_cr_namespace}
    else
        echo FAILED TO ADD CONTAINER REGISTRY NAMESPACE ${ic_cr_namespace}
        exit 1
    fi
fi

bx ce project list | grep ${ic_ce_project}
if [ $? -eq 0 ]
then
    echo CODE ENGINE PROJECT ${ic_ce_project} EXISTS
else
    echo CODE ENGINE PROJECT ${ic_ce_project} DOES NOT EXIST
    bx ce project create --name ${ic_ce_project} --no-select
    if  [ $? -eq 0 ]
    then
        echo CREATED CODE ENGINE PROJECT ${ic_ce_project}
    else
        echo FAILED TO CREATE CODE ENGINE PROJECT ${ic_ce_project}
        exist 1
    fi
fi

bx ce project target --name ${ic_ce_project} --endpoint public
if [ $? -eq 0 ]
then
    echo TARGET CODE ENGINE  PROJECT ${ic_ce_project}
else
    echo FAILED TO TARGET CODE ENGINE PROJECT ${ic_ce_project}
    exit 1
fi

#bx ce registry create --name ${ic_ce_registry} --server ${ic_ce_registry_server} --username iamapikey --password ${ic_ce_registry_password} --email ${ic_ce_registry_email}

#createupdate "ce repo" ${ic_ce_repo} "--host ${git_host} --key-path ${git_key_path}"

#createupdate "ce build" ${ic_ce_build} "--git-repo-secret ${ic_ce_repo} --image ${ic_cr_image} -size small --source ${git_url}"
createupdate "ce build" ${ic_ce_build} "-size small --source ${git_url} --image ${ic_cr_image}  --context-dir ${ic_ce_build_dir}"

createupdate "ce configmap" ${ic_ce_configmap} "--name ${ic_ce_configmap} --from-env-file ${ic_ce_configmap_file}"

createupdate "ce secret" ${ic_ce_secret} "--from-env-file ${ic_ce_secret_file}"

createupdate "ce job" ${ic_ce_job} "--env-from-configmap ${ic_ce_configmap} --env-from-secret ${ic_ce_secret} --image ${ic_cr_image} --ephemeral-storage 40M"

#createupdate "ce subscription cron" "${ic_ce_cron}" "--destination ${ic_ce_job} --schedule ${ic_ce_cron_schedule} --destination-type job"
createupdate "ce subscription cron" "${ic_ce_cron}" "--destination ${ic_ce_job} --destination-type job"
