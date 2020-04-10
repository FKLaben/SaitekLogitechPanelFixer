
function Pause ($Message="Press any key to continue...")
{
	Write-Host -NoNewLine $Message
	$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	Write-Host ""
}


If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    # Relaunch as an elevated process:
    Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
    exit
}
# Now running elevated so launch the script:


try
{
    # Known devices
    $devices = @{
        "Flight Multi Panel" = "VID_06A3&PID_0D06"
        "Flight Radio Panel" = "VID_06A3&PID_0D05"
    }

    foreach($deviceKV in $devices.GetEnumerator())
    {
        $name=$deviceKV.Key
        $device=$deviceKV.Value
        
        $path="HKLM:\SYSTEM\CurrentControlSet\Enum\USB\"+ $device +"\*\Device Parameters"
        if (test-path $path)
        {
            $deviceParameters=Resolve-Path $path
            if ($deviceParameters)
            {
                
                $msg="Disabling power management for all known instances of " + $name + ":"
                Write-Output $msg
                foreach($deviceParameter in $deviceParameters)
                {
                    $key="EnhancedPowerManagementEnabled"
                    $kPath=[System.String]::Concat($deviceParameter,$key)
                    Set-ItemProperty -Path $deviceParameter -Name $key -Value 0
                }
                
                Write-Output ($name + ": OK")
            }
            else
            {
                Write-Warning ($name + " not found. Connect it then retry!")
            }
        }
        else
        {
            Write-Warning ($name + " not found. Connect it then retry!")
        }
    }
}
catch 
{
    $string_err = $_ | Out-String
    Write-Warning $string_err
    Write-Output ""
    Pause "An error occurred. Cannot fix."
}

Write-Output ""
Pause "Check there is no error then restart your computer and enjoy!"
