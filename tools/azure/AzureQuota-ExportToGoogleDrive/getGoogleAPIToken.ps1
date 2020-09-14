$clientId = "647234128025-vmj2nsdka9addcvbvkthel4je1ao9ltn.apps.googleusercontent.com"
$clientSecret = "cBCbscerVkYDkKiTXwLSJcpj"  #Replace clientsecret with own
#$redirect_uri = "https://developers.google.com/oauthplayground"

$scopes = "https://www.googleapis.com/auth/drive"

Start-Process "https://accounts.google.com/o/oauth2/v2/auth?client_id=$clientId&scope=$([string]::Join("%20", $scopes))&access_type=offline&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob"    

$code = Read-Host "Please enter the code"

$response = Invoke-WebRequest https://www.googleapis.com/oauth2/v4/token -ContentType application/x-www-form-urlencoded -Method POST -Body "client_id=$clientid&client_secret=$clientSecret&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=$code&grant_type=authorization_code"

Write-Output "Refresh token: " ($response.Content | ConvertFrom-Json).refresh_token

$accessToken = (Invoke-RestMethod @params).access_token

