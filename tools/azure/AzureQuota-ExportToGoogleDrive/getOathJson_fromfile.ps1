$oauth_json = Get-Content 'C:\My projects\Woolworth\GitHub\azureQuotaOauth.json' | ConvertFrom-Json
$oauth_json.web.client_id
$oauth_json.web.client_secret