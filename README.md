# ibm-cloud-casemanagement

Add user ids list to all IBM Cloud Support cases 
- Simply executing shell script job/addUserToCaseWatchlist.sh
- An IBM Cloud Code Engine job can be created to periodically execute it
- An IBM Cloud Code Engine app can be created to triggerits execution

## job/addUserToCaseWatchlist.sh

- /bin/sh script 
- Two environment variable must be initialized:
1. apikey = IBM Cloud user apikey 
2. emails = IBM Cloud user email list to add

## Code Engine configuration

1. Pull the git project
2. Create file conf/.env with emails (list) environment variable 
3. Create file conf/.secret with apikey environment variable
4. Create file conf/.profile with 
    `#!/bin/sh

    export IBMCLOUD_API_KEY=@conf/.apikey.json
    export ibmcloud_region=eu-de

    export ic_ce_project=ibm-cloud-casemanagement
    export ibmcloud_resource_group=${ic_ce_project}
    export ic_ce_module=add-users-to-case-watchlist

    export git_repository=${ic_ce_project}
    export git_host=github.com
    export git_user=guildevi
    #export git_key_path=~/.ssh/id_ed25519
    export git_url=https://${git_host}/${git_user}/${git_repository}.git

    export ic_cr_region="eu-central"
    export ic_cr_registry="private.de.icr.io"
    export ic_cr_namespace=${ic_ce_project}
    export ic_cr_image=${ic_cr_registry}/${ic_cr_namespace}/${ic_ce_module}

    export ic_ce_registry_server=private.de.icr.io
    export ic_ce_registry_secret=ce-auto-icr-private-${ibmcloud_region}

    export ic_ce_repo=${ic_ce_module}"-repo"
    
    export ic_ce_build=${ic_ce_module}"-build"

    export ic_ce_configmap=${ic_ce_module}"-configmap"
    export ic_ce_configmap_file=conf/.env

    export ic_ce_secret=${ic_ce_module}"-secret"
    export ic_ce_secret_file=conf/.secret

    export ic_ce_cron=${ic_cemodule}"-cron"
    set -f
    export ic_ce_cron_schedule="'*/15 * * * *'"
    set +f

    export ic_ce_app_port=8080`

# The IBM Cloud Code Engine Job

- Created with command conf/createjob.sh

# The IBM Cloud Code Engine app

- Created with command conf/createapp.sh
