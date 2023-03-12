#!/bin/bash

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

