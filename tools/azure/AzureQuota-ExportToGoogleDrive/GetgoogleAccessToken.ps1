$params = @{
    Uri = 'https://accounts.google.com/o/oauth2/token'
    Body = @(
        "refresh_token=1//0gNX6qdTr_jpICgYIARAAGBASNwF-L9Irbkieo_axKmOXiADI7-avWhrYLirQfPYBjwituvVkIfPJlo4pC2vqEozdxTH9jHf9s-E", # Replace $RefreshToken with your refresh token
        "client_id=647234128025-vmj2nsdka9addcvbvkthel4je1ao9ltn.apps.googleusercontent.com",         # Replace $ClientID with your client ID
        "client_secret=cBCbscerVkYDkKiTXwLSJcpj", # Replace $ClientSecret with your client secret
        "grant_type=refresh_token"
    ) -join '&'
    Method = 'Post'
    ContentType = 'application/x-www-form-urlencoded'
}
$accessToken = (Invoke-RestMethod @params).access_token