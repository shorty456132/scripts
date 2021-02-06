#make sure script is in same folder as firmware
#will compare devices in autodiscovery to files in firmware folder and send correct files to correct devices
#currently only for puf files
#still some TODOs to implement

Import-Module PSCrestron

$user = 'admin'
$pass = 'admin'

Write-Host "finding devices"

$devs = Get-AutoDiscovery | Select-Object -ExpandProperty IP | 
                            Get-VersionInfo -Secure -Username $user -Password $pass 

$files = Get-ChildItem $PSScriptRoot -filter *.puf


write-host "checking devs against firmware files"

foreach($dev in $devs)
{
    if($dev.ErrorMessage -eq "")
    {
        write-host "looking for $($dev.Prompt) firmware file"        

        foreach($file in $files)
        {    
            #TODO - make sure firmware file is newer than currently on device
                       
            #TSS panels use the TSW firmware
            if($dev.prompt -match "TSS" -and $file.name -match 'TSW')
            {
                Write-Host "$($file.Name) : $($dev.Prompt)"
            }

            #TODO - need to make sure this works from DMPS-150s and DMPS-350s              
            if(($file.name.ToUpper() -split '(?=_)' | Select -First 1) -eq $dev.Prompt)
            {
                Write-Host "$($file.name) : $($dev.prompt)"
            }    
        }
    }
}


#TODO - refactor for function to send files and function to update device

##crestron-sendfirmware