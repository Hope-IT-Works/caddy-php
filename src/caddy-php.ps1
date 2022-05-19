$OUTPUT_PATH = (Get-Location).Path+"\caddy-php"

function Read-UserInputMenu($OptionsArray){
    do{
        $UserInput = Read-Host -Prompt "Please choose a ID"
        if($UserInput -ge 0 -or $UserInput -lt $OptionsArray.Count){
            break
        } else {
            Write-Host -ForegroundColor Red "Please enter a valid ID."
        }
    } while ($UserInput -lt 0 -or $UserInput -ge $OptionsArray.Count)
    return $UserInput
}

if([System.Environment]::Is64BitOperatingSystem){
    $OS_ARCH  = "x64"
} else {
    $OS_ARCH  = "x86"
}
Write-Host -ForegroundColor Yellow ("Detected "+$OS_ARCH.Substring(1)+"-Bit OS")
if($OS_ARCH -eq "x86"){
    Write-Host -ForegroundColor Red "Warning: 32-Bit systems are not supported."
}


<#
    PHP
#>
Write-Host -ForegroundColor Yellow "`n/---\`n PHP`n\---/`n"
$PHP_URL      = "https://windows.php.net/downloads/releases/"
$PHP_RES      = (Invoke-WebRequest -UseBasicParsing -Uri $PHP_URL).Links.href | Where-Object -FilterScript {$_ -match ("/downloads/releases/php-")}
$PHP_VERSIONS = New-Object -TypeName System.Collections.ArrayList
foreach($Link in $PHP_RES){
    if($Link -notmatch $OS_ARCH -or $Link -match "src" -or $Link -match "test" -or $Link -match "debug" -or $Link -match "nts" -or $Link -match "devel"){
        continue
    } else {
        $PHP_VER = New-Object -TypeName PSCustomObject
        $PHP_VER | Add-Member -MemberType NoteProperty -Name "ID" -Value $PHP_VERSIONS.Count
        $PHP_VER | Add-Member -MemberType NoteProperty -Name "Name" -Value ($Link.Split("/")[3].Split("-")[1]+"-"+$Link.Split("/")[3].Split("-")[4].Split(".")[0])
        $PHP_VER | Add-Member -MemberType NoteProperty -Name "URL" -Value ("https://windows.php.net"+$Link)
        $PHP_VERSIONS.Add($PHP_VER) | Out-Null
    }
}

if($PHP_VERSIONS.Count -le 0){
    Write-Host -ForegroundColor Red "No PHP-Versions available, please create a issue at https://github.com/Hope-IT-Works/caddy-php/"
    Exit
}

Write-Host -ForegroundColor Yellow ([String]$PHP_VERSIONS.Count+" PHP-Versions available:")
$PHP_VERSIONS | Select-Object -Property "ID","Name" | Format-Table

$PHP_SELECTED = Read-UserInputMenu -OptionsArray $PHP_VERSIONS
$PHP_SELECTED = $PHP_VERSIONS[$PHP_SELECTED]
$PHP_SELECTED_VERSION = $PHP_SELECTED.Name.Split("-")[0]
Write-Host -ForegroundColor Yellow ("`n"+$PHP_SELECTED.Name+" was selected.")


<#
    CADDY
#>
Write-Host -ForegroundColor Yellow "`n/-----\`n Caddy`n\-----/`n"
$CADDY_URL = "https://api.github.com/repos/caddyserver/caddy/releases/latest"
$CADDY_RES = Invoke-WebRequest -UseBasicParsing -Uri $CADDY_URL | ConvertFrom-Json
$CADDY_RES = $CADDY_RES.assets | Where-Object -FilterScript {$_.content_type -eq "application/zip" -and $_.name -match "windows" -and $_.name -match "amd64"}
if($null -eq $CADDY_RES.Count){
    $CADDY_SELECTED = $CADDY_RES
    Write-Host -ForegroundColor Yellow ("`nCaddy version "+$CADDY_SELECTED.name+" was automatically selected.")
} else {
    $CADDY_VERSIONS = New-Object -TypeName System.Collections.ArrayList
    $CADDY_VERSIONS.AddRange($CADDY_RES) | Out-Null
    for($i=0;$i -lt $CADDY_VERSIONS.Count;$i++){
        $CADDY_VERSIONS[$i].id = $i
        $CADDY_VERSIONS[$i].name = $CADDY_VERSIONS[$i].name.Split("_")[1]+"-"+$CADDY_VERSIONS[$i].name.Split("_")[3].Split(".")[0]
    }
    Write-Host -ForegroundColor Yellow ([String]$CADDY_VERSIONS.Count+" Caddy-Versions available:")
    $CADDY_VERSIONS | Select-Object -Property "ID","Name" | Format-Table

    $CADDY_SELECTED = Read-UserInputMenu -OptionsArray $CADDY_VERSIONS
    $CADDY_SELECTED = $CADDY_VERSIONS[$CADDY_SELECTED]
    $CADDY_SELECTED_VERSION = $CADDY_SELECTED.name.Split("-")[0]
    Write-Host -ForegroundColor Yellow ("`nCaddy version "+$CADDY_SELECTED.name+" was selected.")
}

try {
    $PHP_DEST   = $OUTPUT_PATH+"\php"
    $CADDY_DEST = $OUTPUT_PATH
    $WWW_DEST   = $OUTPUT_PATH+"\www"
    $LOG_DEST   = $OUTPUT_PATH+"\log"
    $CADDY_CONF = $OUTPUT_PATH+"\caddy"
    New-Item -Path $OUTPUT_PATH -ItemType "Directory" | Out-Null
    New-Item -Path $PHP_DEST -ItemType "Directory" | Out-Null
    New-Item -Path $WWW_DEST -ItemType "Directory" | Out-Null
    New-Item -Path $LOG_DEST -ItemType "Directory" | Out-Null
    New-Item -Path $CADDY_CONF -ItemType "Directory" | Out-Null
} catch {
    Write-Host -ForegroundColor Red "Error: Couldn't create directories. Elevate session or change path."
    exit
}
try {
    Write-Host -ForegroundColor Yellow "Downloading PHP..."
    $PHP_DL = $OUTPUT_PATH+"\"+$PHP_SELECTED.URL.Split("/")[$PHP_SELECTED.URL.Split("/").Count-1]
    Invoke-WebRequest -UseBasicParsing -Uri $PHP_SELECTED.URL -OutFile $PHP_DL
    if(Test-Path -Path $PHP_DL){
        Write-Host -ForegroundColor Yellow "Downloaded PHP"
    } else {
        Write-Host -ForegroundColor Red "Error: PHP could not be downloaded."
        exit
    }
} catch {
    Write-Host -ForegroundColor Red "Error: PHP could not be downloaded."
    exit
}
try {
    Write-Host -ForegroundColor Yellow "Decompressing PHP..."
    Expand-Archive -Path $PHP_DL -DestinationPath $PHP_DEST
    Write-Host -ForegroundColor Yellow "Decompressed PHP"
    Remove-Item -Path $PHP_DL
    Write-Host -ForegroundColor Yellow "Removed PHP download file"
} catch {
    Write-Host -ForegroundColor Red "Error: PHP could not be decompressed."
    exit
}
try {
    Write-Host -ForegroundColor Yellow "Downloading Caddy..."
    $CADDY_DL = $OUTPUT_PATH+"\"+$CADDY_SELECTED.browser_download_url.Split("/")[$CADDY_SELECTED.browser_download_url.Split("/").Count-1]
    Invoke-WebRequest -UseBasicParsing -Uri $CADDY_SELECTED.browser_download_url -OutFile $CADDY_DL
    if(Test-Path -Path $CADDY_DL){
        Write-Host -ForegroundColor Yellow "Downloaded Caddy"
    } else {
        Write-Host -ForegroundColor Red "Error: Caddy could not be downloaded."
        exit
    }
} catch {
    Write-Host -ForegroundColor Red "Error: Caddy could not be downloaded."
    exit
}
try {
    Write-Host -ForegroundColor Yellow "Decompressing Caddy..."
    Expand-Archive -Path $CADDY_DL -DestinationPath $CADDY_DEST
    Write-Host -ForegroundColor Yellow "Decompressed Caddy"
    Remove-Item -Path $CADDY_DL
    Write-Host -ForegroundColor Yellow "Removed Caddy download file"
} catch {
    Write-Host -ForegroundColor Red "Error: Caddy could not be decompressed."
    exit
}
