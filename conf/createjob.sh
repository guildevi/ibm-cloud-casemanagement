#!/bin/bash

. conf/.profile

. conf/logintarget.sh
. conf/createcommon.sh

ic_ce_component=job
ic_ce_job=${ic_ce_module}-${ic_ce_component}
ic_ce_build=${ic_ce_build}-${ic_ce_component}
ic_ce_dockerfile=${ic_ce_component}/Dockerfile
ic_cr_image=${ic_cr_image}-${ic_ce_component}


#createupdate "ce build" ${ic_ce_build} "--git-repo-secret ${ic_ce_repo} --image ${ic_cr_image} -size small --source ${git_url}"
createupdate "ce build" ${ic_ce_build} "-size small --source ${git_url} --image ${ic_cr_image} --dockerfile ${ic_ce_dockerfile}"

submit "build" ${ic_ce_build} "--wait"

echo ----------------------------------------
echo Create job needs to be created manually
echo - Source code is ${ic_cr_image}
echo - Environment variable references full configmap ${ic_ce_configmap}
echo   ... and secret ${ic_ce_secret}
echo ----------------------------------------
echo ibmcloud ce job create --name ${ic_ce_job} --env-from-configmap ${ic_ce_configmap} --env-from-secret ${ic_ce_secret} --image ${ic_cr_image} --ephemeral-storage 40M
#createupdate "ce job" ${ic_ce_job} "--env-from-configmap ${ic_ce_configmap} --env-from-secret ${ic_ce_secret} --image ${ic_cr_image} --ephemeral-storage 40M"

#submit job ${ic_ce_job} "--wait"

echo ----------------------------------------
echo Create subscription needs to be created manually
echo - Periodic timer
echo - cron expression ${ic_ce_cron_schedule}
echo - component type job
echo   ... named ${ic_ce_job}
echo ----------------------------------------
set -f
echo ibmcloud ce subscription cron create --name ${ic_ce_cron} --destination ${ic_ce_job} --schedule ${ic_ce_cron_schedule} --destination-type job
set +f
# createupdate "ce subscription cron" "${ic_ce_cron}" "--destination ${ic_ce_job} --schedule ${ic_ce_cron_schedule} --destination-type job"
# createupdate "ce subscription cron" "${ic_ce_cron}" "--destination ${ic_ce_job} --destination-type job"
