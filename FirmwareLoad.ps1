Import-Module PSCrestron

$user = 'vision'
$pass = 'vision'

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
                       
            if($dev.prompt -match "TSS" -and $file.name -match 'TSW')
            {
                Write-Host "$($file.Name) : $($dev.Prompt)"
            }

            #need to find a way to discern from dmps3-4k-350 and dmps3-4k-150                
            if(($file.name.ToUpper() -split '(?=_)' | Select -First 1) -eq $dev.Prompt)
            {
                Write-Host "$($file.name) : $($dev.prompt)"
            }    
        }
    }
}

##crestron-sendfirmware