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

## The IBM Cloud Code Engine Job

- Created with command conf/createjob.sh

## The IBM Cloud Code Engine app

- Created with command conf/createapp.sh
