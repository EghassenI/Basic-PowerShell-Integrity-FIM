
do{
Write-Host ""
write-host "What would you like to do?"
write-host "A) Collect new baseline?"
write-host "B) Begin monitoring files with saved Baseline?"

$response = read-host -Prompt "A or B"
    if (($response -ne "A".ToUpper()) -and ($response -ne "B".ToUpper())){
        Write-Host "ERROR : u must choose A or B"

    }
}
while(($response -ne "A".ToUpper()) -and ($response -ne "B".ToUpper()))
Write-Host ""

Function Calculate-File-Hash($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA256
    return $filehash
}

Function Erase-baseline(){
    $baselineExists = Test-Path -Path .\baseline.txt
    if ( $baselineExists){
        #Delete it 
        Remove-Item -Path .\baseline.txt
    } 
}
    
    if ($response -eq "A".ToUpper()) {
    #delete baseline if already exists
    Erase-baseline
    
    #Claculate Hash from the target files and store in baseline.txt
    
    #Collect all files
    $files = Get-ChildItem -Path .\files
    

    #For each file, calculate the hash and write it to baseline.txt
    foreach ($f in $files) {
        $hash = Calculate-File-Hash $f.FullName
        "$($hash.Path)|$($hash.hash)"|Out-File -FilePath .\baseline.txt -Append
        
    }

}
    elseif ($response -eq "B".ToUpper()) {
    
    $filehashdict = @{}
    
    #load files|hash from baseline and store in dict 
    $filepathsandhashes = Get-content -Path .\baseline.txt
    foreach ($f in $filepathsandhashes){
        $filehashdict.add($f.Split("|")[0],$f.Split("|")[1])
    }
    
    
    
    #Begin (for ever)  monitoring files with saved baseline
    while($true){
    Start-Sleep -Seconds 1
    
    $files = Get-ChildItem -Path .\files
    

    #For each file, calculate the hash and write it to baseline.txt
    foreach ($f in $files) {
        $hash = Calculate-File-Hash $f.FullName
        
        #notify if a new file has been created
        if ( $filehashdict[$hash.Path] -eq $null){
            # A file has been created!
            Write-Host "$($hash.Path) has been created !!!" -ForegroundColor Green
        }
        else {
                #notify if a new file has been changed
                if ( $filehashdict[$hash.Path] -ne $hash.Hash){
                    # A file has been changed
                    Write-Host "$($hash.Path) has changed !!!" -ForegroundColor Yellow 
                }
            }

            #notify if a new file has been deleted
       foreach($key in $filehashdict.keys){
            $baselineFileStillExists = Test-Path -Path $key
            if (-Not $baselineFileStillExists){
            Write-Host "$($key) has been deleted !!"  -ForegroundColor red   
            }
       }

               
    }
    }

}


