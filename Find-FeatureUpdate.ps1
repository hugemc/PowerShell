function Find-FeatureUpdate {
    param (
        [Parameter(Mandatory)]
        [string]$FUVer
    )
    $VerbosePreference = "continue"
    # Get FU from WMI
    $FU = Get-WmiObject -Namespace root\CCM\ClientSDK -Class CCM_SoftwareUpdate -Filter ComplianceState=0 | ? Name -like "*$FUVer*"
    if ($FU) {
        Write-Verbose "$((Get-Date).ToShortTimeString()) - Found $($FU.Name)..."
        return $true
    }
    else {
        Write-Verbose "$((Get-Date).ToShortTimeString()) - Feature Update not found..."
    }
}
