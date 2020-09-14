#Upload to GCS
$env:GCLOUD_SDK_INSTALLATION_NO_PROMPT = "TRUE"

$Typepattern1 = "_VM_"
$Typepattern2 = "_SG_"
$Typepattern3 = "_NW_"
Install-Module -Name GoogleCloud -Scope CurrentUser -Force -AllowClobber

gcloud auth activate-service-account --key-file $(authkey.secureFilePath)
$directory = $(get-date -f yyyy-MM-dd)
Set-Location $directory

$csvs = Get-ChildItem .\* -Include *.csv
$csvCount = $csvs.Count
Write-Host "Count of Detected CSV files: ($csvCount)"

#Switch(Get-ChildItem .\* -Include *.csv){
    #{$_.Name -match $Typepattern1}{ Write-GcsObject -Bucket azurequotaimport -File $_.Name -ObjectName "quota/($_.Name)"}
    #{$_.Name -match $Typepattern2}{Write-GcsObject -Bucket azurequotaimport  -File $_.Name -ObjectName "quota/($_.Name)"}
    #{$_.Name -match $Typepattern3}{Write-GcsObject -Bucket azurequotaimport  -File $_.Name -ObjectName "quota/($_.Name)"}
#}
Set-Location (Split-Path -Path (Get-Location))
New-GcsObject -Bucket azurequotaimport -Folder $directory
<# foreach ($csv in $csvs) {
    $csvPath = ".\" + $csv.Name
    #$worksheetName = $csv.Name.Replace("_" + $(get-date -f yyyyMMdd) + ".csv","")
    Write-Host " - Adding $csv.Name to $gcspath"
    Import-Csv -Path $csvPath | Export-Excel -Path $excelFileName -WorkSheetname $worksheetName
}#>
