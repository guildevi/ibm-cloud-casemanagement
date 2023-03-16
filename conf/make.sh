#!/bin/sh
. $(dirname $0)/profile.sh $*
info "START $0"

create_app=0
create_job=0
config_file=conf/default.env

usage() {
  echo "USAGE: $0 [[OPTIONS]]\n\nOPTIONS:"
  echo "\t--config:\t(alias -c) Environment variable file. Default ${default_config_file}"
  echo "\t--region:\t(alias -r) IBM Cloud regions (default ${default_region})"
  echo "\t--project:\t(alias -p) IBM Cloud Code Engine project (default: ${default_ic_ce_project}). Used also as IBM Cloud resource group and registry namespace"
  echo "\t--module:\t(alias -m) IBM Cloud Code Engine project artefact prefix (default: ${default_ic_ce_module})."
  echo "\t--secret:\t(alias -s) File setting apikey environment variable when running add-users-to-case-watchlist.sh (default ${default_ic_ce_secret_file})"
  echo "\t--email-list:\t(alias -e) File setting emails environment variable when running add-users-to-case-watchlist.sh (default ${default_ic_ce_configmap_file})"
  echo "\t--debug:\t(alias -d) Enable debug execution"
  echo "\t--job:\t(alias -j) Enable IBM Cloud Code Engine job creation only (not app)"
  echo "\t--app:\t(alias -a) Enable IBM Cloud Code Engine app creation only (not job)"
  exit 1
}

configfile() {
    while test $# -gt 0
    do
        parameter=$1
        shift
        case $parameter in
            -c|--config)
            config_file=$1
            info CONFIG FILE IS ${config_file}
            break
            ;;
        *)
            debug IGNORE PARAMETER ${parameter}
        esac
    done
}

inlineparameter() {
    while test $# -gt 0
    do
        parameter=$1
        shift
        case $parameter in
        -r|--region)
            export ibm_cloud_region=$1
            info INLINE PARAMETER ibm_cloud_region=${ibm_cloud_region}
            shift
            ;;
        -p|--project)
            export ic_ce_project=$1
            info INLINE PARAMETER ic_ce_project=${ic_ce_project}
            shift
            ;; 
        -m|--module)
            export ic_ce_module=$1
            info INLINE PARAMETER ic_ce_module=${ic_ce_module}
            shift
            ;;
        -s|--secret)
            export ic_ce_secret_file=$1
            info INLINE PARAMETER ic_ce_secret_file=${ic_ce_secret_file}
            shift
            ;;
        -e|-l|--email-list)
            export ic_ce_configmap_file=$1
            info INLINE PARAMETER ic_ce_configmap_file=${ic_ce_configmap_file}
            shift
            ;;
        -a|--app)
            create_job=1
            info INLINE PARAMETER create_app=${create_app}
            info INLINE PARAMETER create_job=${create_job}
            ;;
        -j|--job)
            create_app=1
            info INLINE PARAMETER create_app=${create_app}
            info INLINE PARAMETER create_job=${create_job}
            ;;
        *)
            warn INLINE PARAMETER INGORED ${parameter}
        esac
    done
}

configfile $*
setenvfromfile ${config_file} default_
setenvfromfile ${config_file}
inlineparameter $*

setenvfromfile conf/config.env

conf/logintarget.sh
test $? -ne 0  && exit 1

conf/createcommon.sh
test $? -ne 0 && exit 1

if [ ${create_app} -eq 0 ]
then
    conf/createapp.sh
    test $? -ne 0 && exit 1
fi

if [ ${create_job} -eq 0 ]
then
    conf/createjob.sh
    test $? -ne 0 && exit 1
fi