$env:GCLOUD_SDK_INSTALLATION_NO_PROMPT = "TRUE"
Install-Module GoogleCloud
Import-Module GoogleCloud 
gcloud auth activate-service-account --key-file=gcp-wow-corpit-cldops-dev-8aaf5d77844e.json

$project = "gcp-wow-corpit-cldops-test"
$region = "australia-southeast1"

#Loop Through BU Folder
ForEach ($project in gcloud projects list --format="value(projectId)" --limit 5){
#Compute Quota



# Export quota to CSV
$pathprojectquota = "$($project)_" + $(get-date -f yyyyMMdd) + ".csv"
$pathregionquota = "$($project)_$($region)_" + $(get-date -f yyyyMMdd) + ".csv"

#$projectquota = gcloud compute project-info describe --project $project --flatten quotas --format="value(kind,name,quotas.metric,quotas.usage,quotas.limit)"                           
#$regionalquota = gcloud compute regions describe $region --project $project --format="value(kind,name,quotas.metric,quotas.usage,quotas.limit)" --flatten quotas          

gcloud compute project-info describe --project $project --flatten quotas --format="csv(kind,name,quotas.metric,quotas.usage,quotas.limit)"     >$pathprojectquota
gcloud compute regions describe $region --project $project --format="csv(kind,name,quotas.metric,quotas.usage,quotas.limit)" --flatten quotas >$pathregionquota

#Export CSV not working  not required as gcloud --format alreadt exports as csv
#$projectquota| Export-Csv -Path $pathprojectquota -NoTypeInformation
#$regionalquota| Export-Csv -Path $pathregionquota -NoTypeInformation

}