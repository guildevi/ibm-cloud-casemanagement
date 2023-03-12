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

createupdate "ce job" ${ic_ce_job} "--env-from-configmap ${ic_ce_configmap} --env-from-secret ${ic_ce_secret} --image ${ic_cr_image} --ephemeral-storage 40M"

createupdate "ce subscription cron" "${ic_ce_cron}" "--destination ${ic_ce_job} --schedule ${ic_ce_cron_schedule} --destination-type job"
#createupdate "ce subscription cron" "${ic_ce_cron}" "--destination ${ic_ce_job} --destination-type job"
