function get-IntuneComputerCompliance {
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
    $Compol = (Invoke-RestMethod -Method Get -Uri "$graph/beta/deviceManagement/deviceCompliancePolicies" -Headers $token).value
    $Compolres = @()
    foreach ($SCS in $Compol) {
        $res = (Invoke-RestMethod -Method Get -Uri "$graph/beta/deviceManagement/deviceCompliancePolicies/$($SCS.id)/deviceStatuses" -Headers $token).value
        $res | Add-Member -name 'CompliancePolicyName' -Value $SCS.displayName -MemberType NoteProperty
        $Compolres += $res | Where-Object {$_.deviceDisplayName -eq $Computername -and $_.userPrincipalName -eq $UPN}
    }
    return $Compolres
}