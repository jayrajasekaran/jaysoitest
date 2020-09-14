#Start-Transcript -Path "logs.txt"
# Declare endpoint
$ArmEndpoint = "https://management.azure.com/"

#Declare Subscription
#$subname = CORPPROD, corprp

# Add environment
#Add-AzureRmEnvironment -Name "AzureCORPPROD" -ArmEndpoint $ArmEndpoint

# Login
#Connect-AzureRmAccount -EnvironmentName "AzureCORPPROD" -Subscription
#$sp = Get-AzADServicePrincipal -DisplayName SPN-CloudOps-ReportAutomation  
#$pscredential = Get-Credential -UserName $sp.ApplicationId 
$tenantId = (Get-Azcontext).Tenant.Id
#Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId
$subscriptions=Get-AzSubscription
$directory = $(get-date -f yyyy-MM-dd)
if(!(Test-Path -path $directory))  
{  
 New-Item -ItemType directory -Path $directory
 Write-Host "Folder path has been created successfully at: " $directory
 Set-Location $directory
 }
else 
{ 
Write-Host "The given folder path $directoryPathForLog already exists"; 
Set-Location $directory
}

ForEach ($vsub in $subscriptions){
Select-AzSubscription $vsub.SubscriptionID

Write-Host "Working on: " $vsub.Name

# Retrieve Compute quota
$ComputeQuotaaueast = Get-AzVMUsage -Location australiaeast | Select-Object -Property @{n='Subscription';e={$vsub.Name}},@{n='Type';e={"VMUsage"}},Name, CurrentValue, Limit, @{n='Location';e={"AustraliaEast"}},@{n='Date';e={$(get-date -f yyyyMMdd)}},@{n='Cloud';e={"Azure"}}
$ComputeQuotaausoutheast = Get-AzVMUsage -Location australiasoutheast | Select-Object -Property @{n='Subscription';e={$vsub.Name}},@{n='Type';e={"VMUsage"}},Name, CurrentValue, Limit, @{n='Location';e={"AustraliaSouthEast"}},@{n='Date';e={$(get-date -f yyyyMMdd)}},@{n='Cloud';e={"Azure"}}
$ComputeQuotaaueast | ForEach-Object {
    if (-not $_.Name.LocalizedValue) {
        $_.Name = $_.Name.Value -creplace '(\B[A-Z])', ' $1'
    }
    else {
        $_.Name = $_.Name.LocalizedValue
    }
}
$ComputeQuotaausoutheast | ForEach-Object {
    if (-not $_.Name.LocalizedValue) {
        $_.Name = $_.Name.Value -creplace '(\B[A-Z])', ' $1'
    }
    else {
        $_.Name = $_.Name.LocalizedValue
    }
}

# Retrieve Storage quota
$StorageQuotaaueast = Get-AzStorageUsage -Location australiaeast | Select-Object -Property @{n='Subscription';e={$vsub.Name}},@{n='Type';e={"Storage"}},Name, CurrentValue, Limit, @{n='Location';e={"AustraliaEast"}},@{n='Date';e={$(get-date -f yyyyMMdd)}},@{n='Cloud';e={"Azure"}}
$StorageQuotaausoutheast = Get-AzStorageUsage -Location australiasoutheast | Select-Object -Property @{n='Subscription';e={$vsub.Name}},@{n='Type';e={"Storage"}},Name, CurrentValue, Limit, @{n='Location';e={"AustraliaSouthEast"}},@{n='Date';e={$(get-date -f yyyyMMdd)}},@{n='Cloud';e={"Azure"}}


# Retrieve Network quota
$NetworkQuotaeast = Get-AzNetworkUsage -Location australiaeast | Select-Object @{n='Subscription';e={$vsub.Name}},@{n='Type';e={"Storage"}},@{ Label="Name"; Expression={ $_.ResourceType } }, CurrentValue, Limit,@{n='Location';e={"AustraliaEast"}},@{n='Date';e={$(get-date -f yyyyMMdd)}},@{n='Cloud';e={"Azure"}}
$NetworkQuotasoutheast = Get-AzNetworkUsage -Location australiasoutheast | Select-Object  @{n='Subscription';e={$vsub.Name}},@{n='Type';e={"Storage"}},@{ Label="Name"; Expression={ $_.ResourceType } }, CurrentValue, Limit,@{n='Location';e={"AustraliaSouthEast"}},@{n='Date';e={$(get-date -f yyyyMMdd)}},@{n='Cloud';e={"Azure"}}

# Combine quotas
#$AllQuotas = $ComputeQuota + $StorageQuota + $NetworkQuota


# Export quota to CSV   
$pathcompute = "$($vsub.Name)_VM_" + $(get-date -f yyyyMMdd) + ".csv"
#$pathcomputeauSoutheast = "$($vsub.Name)_VM_AuSouthEast_" + $(get-date -f yyyyMMdd) + ".csv"    
$pathstorage = "$($vsub.Name)_SG_" + $(get-date -f yyyyMMdd) + ".csv"
#$pathstorageauSoutheast = "$($vsub.Name)_SG_AuSouthEast_" + $(get-date -f yyyyMMdd) + ".csv"
$pathNetwork = "$($vsub.Name)_NW_" + $(get-date -f yyyyMMdd) + ".csv"
#$pathNetworkauSoutheast = "$($vsub.Name)_NW_AuSouthEast_" + $(get-date -f yyyyMMdd) + ".csv"





$ComputeQuotaaueast | Export-Csv -Path $pathcompute -NoTypeInformation
$ComputeQuotaausoutheast | Export-Csv -Path $pathcompute -NoTypeInformation -append -Force

$StorageQuotaaueast | Export-Csv -Path $pathstorage -NoTypeInformation
$StorageQuotaausoutheast | Export-Csv -Path $pathstorage -NoTypeInformation -append -Force

$NetworkQuotaeast | Export-Csv -Path $pathNetwork -NoTypeInformation
$NetworkQuotasoutheast | Export-Csv -Path $pathNetwork -NoTypeInformation -append -Force

}
 Install-Module ImportExcel -scope CurrentUser -Force


$excelFileName = $(get-date -f yyyyMMdd) + "_Azure_Quote_Report.xlsx"
Write-Host "Creating: $excelFileName"

Get-ChildItem -Path ".\*.csv" | ForEach-Object { rename-item $_.Fullname $_.Fullname.Replace("(Converted to EA)","") }

$csvs = Get-ChildItem .\* -Include *.csv
$csvCount = $csvs.Count
Write-Host "Detected the following CSV files: ($csvCount)"
foreach ($csv in $csvs) {
    Write-Host " -"$csv.Name
}
foreach ($csv in $csvs) {
    $csvPath = ".\" + $csv.Name
    $worksheetName = $csv.Name.Replace("_" + $(get-date -f yyyyMMdd) + ".csv","")
    Write-Host " - Adding $worksheetName to $excelFileName"
    Import-Csv -Path $csvPath | Export-Excel -Path $excelFileName -WorkSheetname $worksheetName
}

#Stop-Transcript
