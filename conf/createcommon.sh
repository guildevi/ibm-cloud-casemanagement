#!/bin/bash
. $(dirname $0)/profile.sh

#bx ce registry create --name ${ic_ce_registry} --server ${ic_ce_registry_server} --username iamapikey --password ${ic_ce_registry_password} --email ${ic_ce_registry_email}

#createupdate "ce repo" ${ic_ce_repo} "--host ${git_host} --key-path ${git_key_path}"

createupdate "configmap" ${ic_ce_configmap} "--from-env-file ${ic_ce_configmap_file}"

createupdate "secret" ${ic_ce_secret} "--from-env-file ${ic_ce_secret_file}"

exit 0