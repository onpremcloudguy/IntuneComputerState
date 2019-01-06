function get-IntuneComputersFromUPN {
    param(
        # Computer Name
        [Parameter(Mandatory)]
        [string]
        $UPN,
        [Parameter(Mandatory)]
        [Object]
        $token
    )
    $graph = "https://graph.microsoft.com"
    $devices = (invoke-RestMethod -Method Get -Uri "$graph/Beta/Users/$upn/managedDevices?`$filter=operatingSystem eq 'Windows'" -Headers $token).value
    return $devices
}