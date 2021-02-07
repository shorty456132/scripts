#make sure script is in same folder as firmware
#will compare devices in autodiscovery to files in firmware folder and send correct files to correct devices
#currently only for puf files
#still some TODOs to implement

Import-Module PSCrestron

function SendFile($FWFileToSend, $SendToDevice)
{
    Send-CrestronFirmware -Device $SendToDevice.IPAddress.Value -LocalFile "$($pwd)\$($FWFileToSend)" -Secure -Username $user -Password $pass
}

function CheckVersion ($FWFile, $Device)
{

    if($FWFile.BaseName.Split('_')[1] -le $Device.versionPUF)
    {
        write-host "Device is up to date `n"

    }
    else
    {
        write-host "SEND TO UPDATE FIRMWARE FUNCTION"
        SendFile $FWFile $Device
    }
}

$user = 'vision'
$pass = 'vision'

Write-Host "finding devices"

$devs = Get-AutoDiscovery | Select-Object -ExpandProperty IP | 
                            Get-VersionInfo -Secure -Username $user -Password $pass 

$files = Get-ChildItem $PSScriptRoot -filter *.puf


write-host "checking devs against firmware files `n"

foreach($dev in $devs)
{
$dev.v
    if($dev.ErrorMessage -eq "")
    {
        write-host "looking for $($dev.Prompt) firmware file"        

        foreach($file in $files)
        {    
            #TODO - make sure firmware file is newer than currently on device
                       
            #TSS panels use the TSW firmware
            if($dev.prompt -match "TSS" -and $file.name -match 'TSW')
            {
                Write-Host "$($file.Name) : $($dev.Prompt) $($dev.VersionPUF)"
                CheckVersion $file $dev
            }

            #TODO - need to make sure this works from DMPS-150s and DMPS-350s              
            elseif(($file.name.ToUpper() -split '(?=_)' | Select -First 1) -eq $dev.Prompt)
            {
                Write-Host "$($file.name) : $($dev.prompt) $($dev.VersionPUF)"

                CheckVersion $file $dev

            }    
        }
    }
}


#TODO - refactor for function to send files and function to update device

##crestron-sendfirmware