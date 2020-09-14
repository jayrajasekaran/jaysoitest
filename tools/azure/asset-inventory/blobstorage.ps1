Write-Host "Creating a directory: C:\AzStorageInventory. This operation will override if you have a directory with the same name" -ForegroundColor Yellow
New-Item C:\AzStorageInventory. -Type Directory -Force

$AzBlobVHDreport = @()

#Connect to Azure Susbscription.

Login-AzAccount

#Select desired Azure Subscription.

$subscription = Get-AzSubscription

Select-AzSubscription -SubscriptionId $subscription[1].Id 

#Getting all the Az Storage Accounts in selected Az Subscription.

$storageAccounts = Get-AzStorageAccount | select StorageAccountName, ResourceGroupName

#Looping through each storage to get assciated Storage Account Key to create context.

foreach($storageAccount in $storageAccounts)

{
 $storageKey = (Get-AzStorageAccountKey -ResourceGroupName $storageAccount.ResourceGroupName -Name $storageAccount.StorageAccountName)[0].Value

$context = New-AzStorageContext -StorageAccountName $storageAccount.StorageAccountName -StorageAccountKey $storageKey
$containers = Get-AzStorageContainer -Context $context

    foreach($container in $containers)
  
#Looping through all the containers in all the storage accounts to fetch Blob details.
  {
$AzContainer = $Container.Name  
#Getting all blobs in this container
$Blobs = Get-AzStorageBlob -Container $AzContainer -Context $context

ForEach ($Blob in $Blobs)

#Verify if blob has .vhd extension 
 {     
 If ($Blob.Name -like '*.vhd' -and $Blob.BlobType -eq 'PageBlob')

#Creating custom PS object to store Page Blob propeties.
   {
$Azblob = New-Object -TypeName psobject
$Azblob| Add-Member -MemberType NoteProperty -Name BlobName -Value $Blob.Name
$Azblob| Add-Member -MemberType NoteProperty -Name BlobType -Value $Blob.BlobType
$Azblob| Add-Member -MemberType NoteProperty -Name BlobLastChangeDate -Value $Blob.LastModified
$Azblob| Add-Member -MemberType NoteProperty -Name LeaseState -Value $Blob.ICloudBlob.Properties.LeaseState
$Azblob| Add-Member -MemberType NoteProperty -Name LeaseStatus -Value $Blob.ICloudBlob.Properties.LeaseStatus
$Azblob| Add-Member -MemberType NoteProperty -Name BlobSizeGB -Value ($Blob.Length/1gb)
$Azblob| Add-Member -MemberType NoteProperty -Name IsSnaphot -Value $Blob.ICloudBlob.IsSnapshot
$Azblob| Add-Member -MemberType NoteProperty -Name AbsoluteUri -Value $Blob.ICloudBlob.Uri
$AzBlobVHDreport+=$Azblob
         }
    }

}
}
$AzBlobVHDreport | Export-csv -Path       C:\AzStorageInventory\AzureStorageBlobs.csv