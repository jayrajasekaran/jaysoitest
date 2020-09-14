#!/bin/bash
set -e
#set -p
bucket="gcpquotaimport" #change to gcpquotaimport before commit
bu=$SYSTEM_STAGEDISPLAYNAME
gcp_def_project="woolworths-gcp-billing"
echo "Secure key file path $authkey.secureFilePath"
sudo timedatectl set-timezone "Australia/Sydney"
gcloud auth activate-service-account --key-file="keyfile.json"
gcloud config set project $gcp_def_project
export today=$(date +%Y-%m-%d)
export region="australia-southeast1"
[ -d "$today" ] && echo "Directory Exists" || mkdir "$today"

bq --headless ls
bq --headless --project_id "woolworths-gcp-billing" query --format=csv --use_legacy_sql=false "SELECT DISTINCT JSON_EXTRACT(project.resource.data, '$.projectId') AS projectId FROM woolworths-gcp-billing.gcp_asset_inventory.gcp_asset_table_$bu AS project WHERE asset_type='cloudresourcemanager.googleapis.com/Project' AND JSON_EXTRACT(project.resource.data, '$.projectId') IS NOT NULL " | awk 'NR>2' | sed "s/\"//g" > list.csv                                                                                                                

while read project; do    
    echo "Working on project : $project"   
    #put a check if compute api is enabled and then proceed else it exits the loop
    export computeservicestatus=$(gcloud services list --project $project --filter="Name:compute.googleapis.com" --format="csv[no-heading](config.name)")
    #echo "Compute service status:$computeservicestatus"

    if [ -n "${computeservicestatus}"  ];   then  
          echo  "Compute API enabled"
          pathprojectquota="$today/${project}.csv"
          echo "Project Path:"$pathprojectquota
          pathregionquota="$today/${project}_${region}.csv" 
          echo "Region path:"$pathregionquota
          [ -e temp-project.csv ] && rm temp-project.csv
          gcloud compute project-info describe --project $project --flatten quotas --format="csv(kind,name,quotas.metric,quotas.usage,quotas.limit)"     > temp-project.csv

        { echo `head -1 temp-project.csv`",Project,Location,Date,BU,Cloud" ; tail -n +2 temp-project.csv | \
        while read x ; do  echo "$x,$project,Global,$today,$bu,Google"  ; done ; } > $pathprojectquota

          [ -e temp-region.csv ] && rm temp-region.csv
          gcloud compute regions describe $region --project $project --flatten quotas --format="csv(kind,name,quotas.metric,quotas.usage,quotas.limit)" > temp-region.csv
        { echo `head -1 temp-region.csv`",Project,Location,Date,BU,Cloud" ; tail -n +2 temp-region.csv | \
        while read x ; do  echo "$x,$project,$region,$today,$bu,Google"  ; done ; } > $pathregionquota
    else  
	      echo "Compute API not enabled moving to next project"  
    fi                    
done < list.csv

#upload to gcs
echo "Uploading to GCS"
gsutil -m cp -r "$today" gs://"$bucket/$bu/$today"
