function get-IntuneComputerConfiguration{
    param(
        # Computer Name
        [Parameter(Mandatory)]
        [string]
        $Computername,
        # UPN
        [Parameter(Mandatory)]
        [string]
        $UPN,
        [Parameter(Mandatory)]
        [Object]
        $token
    )
    $graph = "https://graph.microsoft.com"
    $Configpol = (Invoke-RestMethod -Method Get -Uri "$graph/beta/deviceManagement/deviceConfigurations" -Headers $token).value
    $Configpolres = @()
    foreach ($SCS in $Configpol) {
        $res = (Invoke-RestMethod -Method Get -Uri "$graph/beta/deviceManagement/deviceConfigurations/$($SCS.id)/deviceStatuses" -Headers $token).value
        $res | Add-Member -name 'ConfigurationPolicyName' -Value $SCS.displayName -MemberType NoteProperty
        $Configpolres += $res | Where-Object {$_.deviceDisplayName -eq $Computername -and $_.userPrincipalName -eq $UPN}
    }
    return $Configpolres
}