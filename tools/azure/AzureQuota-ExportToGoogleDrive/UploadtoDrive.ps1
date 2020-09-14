Add-Type -AssemblyName "System.Web"
 $SourceFile = $(get-date -f yyyyMMdd) + "_Azure_Quote_Report.xlsx"

# Get the source file contents and details, encode in base64
$sourceItem = Get-Item $sourceFile
$sourceBase64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($sourceItem.FullName))
$sourceMime = [System.Web.MimeMapping]::GetMimeMapping($sourceItem.FullName)


# Set the file metadata
$uploadMetadata = @{
    originalFilename = $sourceItem.Name
    name = $sourceItem.Name
    description = $sourceItem.VersionInfo.FileDescription
    parents = @(‘1ma3Nf3Z0xAaj1apNNUps2yThKrPDJZtg’)  #The folder ID can be seen in your address bar when browsing Google Drive. For example: https://drive.google.com/drive/folders/1hUL97Xd6tEiR-44fV7PYQ9BZaulA3ASg
    teamDriveId = ‘1YaThFBcLKRsswF92PzReYG96uYmND0Sf’
}


# Set the upload body
$uploadBody = @"
--boundary
Content-Type: application/json; charset=UTF-8

$($uploadMetadata | ConvertTo-Json)

--boundary
Content-Transfer-Encoding: base64
Content-Type: $sourceMime

$sourceBase64
--boundary--
"@

# Set the upload headers
$uploadHeaders = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = 'multipart/related; boundary=boundary'
    "Content-Length" = $uploadBody.Length
}

# Perform the upload
$response = Invoke-RestMethod -Uri 'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&supportsTeamDrives=true' -Method Post -Headers $uploadHeaders -Body $uploadBody
