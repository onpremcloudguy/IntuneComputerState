function Get-AuthNonInteractive {
    param (
        [Parameter(mandatory = $true)]
        [pscredential]$credential,
        [Parameter(mandatory = $false)]
        [string]$clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547",
        [Parameter(mandatory = $false)]
        [string]$resourceURL = "https://graph.microsoft.com/"
    )
    $body = @{
        resource   = $resourceURL
        client_id  = $clientId
        grant_type = "password"
        username   = $credential.username
        scope      = "openid"
        password   = $credential.GetNetworkCredential().password
    }
    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri "https://login.microsoftonline.com/Common/oauth2/token" -Method Post -Body $body
        if ($response.StatusCode -eq 200) {
            $objRes = $response.content | ConvertFrom-Json
            #$headers = @{}
            #$headers.Add("Authorization", "$($objRes.token_type) " + $($objRes.access_token))
            $authHeader = @{
                'Content-Type'  = 'application/json'
                'Authorization' = "$($objRes.token_type) $($objRes.access_token))"
                'ExpiresOn'     = ( [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($($objRes.Expires_On))) )
            }
            return $authHeader
        }
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}