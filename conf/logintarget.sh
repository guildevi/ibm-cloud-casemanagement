#!/bin/bash
. $(dirname $0)/profile.sh
#bx login -r ${ibmcloud_region}
#if [ $? -eq 0 ]
#then
#    echo LOGIN SUCCESSFUL
#else
#    echo LOGIN FAILED
#    exit 1
#fi

bx target|grep "Not logged in" 1>${stdout} 2>&1
if [ $? -eq 0 ]
then
    error NOT LOGGED IN. USE ibmcloud login TO LOG IN
    exit 1
fi

bx resource group ${ibmcloud_resource_group} 1>${stdout} 2>&1
if [ $? -eq 0 ]
then
    info RESOURCE GROUP ${ibmcloud_resource_group} EXISTS
else
    info RESOURCE GROUP ${ibmcloud_resource_group} DOES NOT EXIST
    bx resource group-create ${ibmcloud_resource_group} 1>${stdout} 2>&1
    if [ $? -eq 0 ]
    then
        info CREATED RESOURCE GROUP ${ibmcloud_resource_group}
    else
        error FAILED TO CREATE RESOURCE GROUP ${ibmcloud_resource_group}
        exit 1
    fi
fi

bx target -g ${ibmcloud_resource_group} 1>${stdout} 2>&1
if [ $? -eq 0 ]
then
    info TARGET RESOURCE GROUP ${ibmcloud_resource_group}
else
    error FAILED TO TARGET RESOURCE GROUP ${ibmcloud_resource_group}
fi

bx cr region-set ${ic_cr_region} 1>${stdout} 2>&1
if [ $? -eq 0 ]
then
    info SET CONTAINER REGISTRY TO ${ic_cr_region}
else
    error FAILED TO SET CONTAINER REGISTRY TO ${ic_cr_region}
    exit 1
fi

bx cr namespace-list | grep  ${ic_cr_namespace} 1>${stdout} 2>&1
if [ $? -eq 0 ]
then
    info CONTAINER REGISTRY NAMESPACE ${ic_cr_namespace} EXISTS
else
    info CONTAINER REGISTRY NAMESPACE ${ic_cr_namespace} DOES NOT EXIST
    bx cr namespace-add -g ${ibmcloud_resource_group} ${ic_cr_namespace} 1>${stdout} 2>&1
    if [ $? -eq 0 ]
    then
        info ADDED CONTAINER REGISTRY NAMESPACE ${ic_cr_namespace}
    else
        error FAILED TO ADD CONTAINER REGISTRY NAMESPACE ${ic_cr_namespace}
        exit 1
    fi
fi

ibmcloudce project get --name ${ic_ce_project}
if [ $? -eq 0 ]
then
    info CODE ENGINE PROJECT ${ic_ce_project} EXISTS
else
    info CODE ENGINE PROJECT ${ic_ce_project} DOES NOT EXIST
    ibmcloudce project create --name ${ic_ce_project} --no-select
    if  [ $? -eq 0 ]
    then
        info CREATED CODE ENGINE PROJECT ${ic_ce_project}
    else
        error FAILED TO CREATE CODE ENGINE PROJECT ${ic_ce_project}
        exist 1
    fi
fi

ibmcloudce project target --name ${ic_ce_project} --endpoint public 
if [ $? -eq 0 ]
then
    info TARGET CODE ENGINE  PROJECT ${ic_ce_project}
else
    error FAILED TO TARGET CODE ENGINE PROJECT ${ic_ce_project}
    exit 1
fi

exit 0