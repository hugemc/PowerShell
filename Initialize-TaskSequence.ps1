function Initialize-TaskSequence {
    Param (
        [parameter(Mandatory = $true)]
        $TSName,
        $trigger = "{00000000-0000-0000-0000-000000000021}",
        $machine = $env:COMPUTERNAME
    )
    $VerbosePreference = "continue"
    ## Connect to Software Center
    Try {
        Write-Verbose "$((Get-Date).ToShortTimeString()) - Connecting to Software Center..."
        $SoftwareCenter = New-Object -ComObject "UIResource.UIResourceMgr"
    }
    Catch {
        Write-Verbose "$((Get-Date).ToShortTimeString()) - Failed to connect to Software Center."
        exit 1
    }
    # Runs a maximum of 5 times until TS is present; abort if not found
    for ($i = 1; $i -le 5; $i++) {

        # Initiates trigger of Machine Policy Retrieval and Evaluation
        Write-Verbose "$((Get-Date).ToShortTimeString()) - Trying to invoke Machine Policy Retrieval..."
        Invoke-WmiMethod -ComputerName $machine -Namespace root\ccm -Class sms_client -Name TriggerSchedule $trigger | Out-Null
        Start-Sleep -Seconds 15

        # Search for Task Sequence
        Write-Verbose "$((Get-Date).ToShortTimeString()) - Searching for $TSName..."
        $TS = $SoftwareCenter.GetAvailableApplications() | ? { $_.PackageName -eq "$TSName" }
        # If Task Sequence is found
        If ($TS) {
            $i = 5
            Write-Verbose "$((Get-Date).ToShortTimeString()) - Found $TSName."

            ## Attempt to execute the Task Sequence
            Try {
                Write-Verbose "$((Get-Date).ToShortTimeString()) - Executing $TSName..."
                $SoftwareCenter.ExecuteProgram($($TS.ID), $($TS.PackageID), $true)
                Write-Verbose "$((Get-Date).ToShortTimeString()) - $TSName executed."
            }
            Catch {
                Write-Verbose "$((Get-Date).ToShortTimeString()) - Failed to run $TSName"
                exit 1
            }
        }
        else {
            if ($i -ne 5) {
                Write-Verbose "$((Get-Date).ToShortTimeString()) - Could not find $TSName. Trying $(5 - $i) more time(s)."
            }
            else {
                Write-Verbose "$((Get-Date).ToShortTimeString()) - Could not find $TSName after maximum attempts. Exiting script."
                exit 1
            }
        }
    }
}
