#!/bin/bash

. conf/.profile

. conf/logintarget.sh
. conf/createcommon.sh

ic_ce_component=app
ic_ce_app=${ic_ce_module}-${ic_ce_component}
ic_cr_image=${ic_cr_image}-${ic_ce_component}
ic_ce_build=${ic_ce_build}-${ic_ce_component}
ic_ce_dockerfile=${ic_ce_component}/Dockerfile

createupdate "ce build" ${ic_ce_build} "-size small --source ${git_url} --image ${ic_cr_image} --dockerfile ${ic_ce_dockerfile}"

submit build ${ic_ce_build} "--wait"

createupdate "ce app" ${ic_ce_app} "--env-from-configmap ${ic_ce_configmap} --env-from-secret ${ic_ce_secret} --image ${ic_cr_image} --port 8080 --visibility public"
