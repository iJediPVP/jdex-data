$CurrentDir = (Get-Location).Path
$ResponseFolder = Join-Path $CurrentDir "cachedresponse"
New-Item $ResponseFolder -ItemType Directory -ErrorAction SilentlyContinue

function Get-Response($BaseURL, $Resource, $SubFolder) {
    # Check for cached
    $FileName = [System.IO.Path]::GetFileName($Resource)
    
    if($null -ne $SubFolder -and $SubFolder.Length -gt 0) {
        $SubDir = Join-Path $ResponseFolder $SubFolder
        New-Item $SubDir -ItemType Directory -ErrorAction SilentlyContinue
        $FileName = [System.IO.Path]::Combine($SubDir, $FileName)

    } else {
        $FileName = [System.IO.Path]::Combine($ResponseFolder, $FileName)
    }

    if(Test-Path $FileName) {
        $Raw = Get-Content $FileName -Raw
        $Response = New-Object -Com "HTMLFile"
        $Response.write([System.Text.Encoding]::Unicode.GetBytes($Raw))
        return $Response
    }

    # Get from web
    Start-Sleep -Seconds 1 # DO NOT SPAM SEREBII PLX
    $FinalURL = "$BaseURL/$Resource"
    Write-Host "Calling $FinalURL" -ForegroundColor Yellow
    $Response = Invoke-WebRequest $FinalURL -ErrorAction Stop -Timeout 10
    $Response.Content | Out-File $FileName -Encoding UTF8 -Force -ErrorAction Stop
    return (Get-Response $BaseURL $Resource $SubFolder)
}

function Get-SerebiiResponse($Resource) {
    $Response = Get-Response "https://www.serebii.net" $Resource "serebii"
    return $Response
}

