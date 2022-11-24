$SerebiiBase = "https://www.serebii.net"

$ShinyLocked = @(
    "gimmighoul",
    "gholdengo",
    "ting-lu",
    "chien-pao",
    "wo-chien",
    "chi-yu",
    "koraidon",
    "miraidon"
)

$SerebiiGen9Dex = "$SerebiiBase/scarletviolet/pokemon.shtml"
$DexResponse = Invoke-WebRequest $SerebiiGen9Dex
$Rows = $DexResponse.ParsedHtml.body.getElementsByClassName("pkmn")

$PokeResults = New-Object System.Collections.ArrayList
$ShinyPokeResults = New-Object System.Collections.ArrayList

foreach($Row in $Rows) {
    $Path = $Row.getElementsByTagName("a")[0].pathname
    $Alias = [System.IO.Path]::GetFileName($Path.Substring(0, $Path.Length - 1))
    $Num = [System.IO.Path]::GetFileNameWithoutExtension($Row.getElementsByTagName("a")[0].firstChild.src).Split("-")[0]

    #if($Alias.StartsWith("dudunsparce") -ne $true) { continue }

    $IsShinyLocked = $ShinyLocked.Contains($Alias)

    $NameRow = $Row.parentNode.parentNode.parentNode.parentNode.nextSibling
    $Name = $NameRow.getElementsByTagName("a")[0].innerText.Split("`r`n")[0].Trim()

    $Existing = $PokeResults | ? { $_.Num -eq [int]$Num } | Select-Object -First 1
    if($Existing -ne $null) { continue } 

    Write-Host "# $Num $Alias - $Name"
    
    $SerebiiLink = "pokemon/$Alias/"
    $PokeResponse = Invoke-WebRequest "$SerebiiBase/$Path"

    # Check for forms
    $Forms = $PokeResponse.ParsedHtml.body.getElementsByClassName("sprite-select")
    if($Forms.Length -gt 0) {

        foreach($Form in $Forms) {
            $SerebiiAliasSplit = $Form.attributes['data-key'].textContent.Split("-")
            $SerebiiAlias = $SerebiiAliasSplit[$SerebiiAliasSplit.Length - 1]

            $SerebiiSpritePath = "$SerebiiBase/scarletviolet/pokemon/$Num"
            $ShinySerebiiSpritePath = "$SerebiiBase/Shiny/SV/$Num"
            if($SerebiiAliasSplit.Length -gt 1 -and $SerebiiAlias.Length -gt 0) {
                $SerebiiSpritePath += "-$SerebiiAlias"
                $ShinySerebiiSpritePath += "-$SerebiiAlias"
            }
            $SerebiiSpritePath += ".png"
            $ShinySerebiiSpritePath += ".png"
            
            $SerebiiFormName = $Form.title.Replace("Form", "").Trim()
            
            $FormName = $Name
            $FormAlias = $Alias
            
            if($SerebiiFormName -eq "Male") {
                # Do nothing

            } elseif($SerebiiFormName -eq "Female") {
                $FormName = "$Name (Female)"
                $FormAlias = "$Alias-f"
            } else {
                $FormName = "$Name (" + $SerebiiFormName + ")"
                $FormAlias = "$Alias-" + $SerebiiFormName.ToLower()
            }

            $Result = [PSCustomObject]@{
                Num = [int]$Num
                Name = $FormName.Trim()
                Alias = $FormAlias.Trim().Replace(" ", "-")
                SerebiiLink = $SerebiiLink
                SpritePath = $SerebiiSpritePath
            }
            [void]$PokeResults.Add($Result)

            $ShinyResult = [PSCustomObject]@{
                Num = [int]$Num
                Name = $FormName.Trim()
                Alias = $FormAlias.Trim().Replace(" ", "-")
                SerebiiLink = $SerebiiLink
                SpritePath = $ShinySerebiiSpritePath
            }
            if($IsShinyLocked) {
                $ShinyResult.Num = -1
                $ShinyResult.Name += " (Not Available)"
                $ShinyResult.SpritePath = $SerebiiSpritePath
            }
            [void]$ShinyPokeResults.Add($ShinyResult)
        }


    } else {
        # No forms

        $SerebiiSpritePath = "$SerebiiBase/scarletviolet/pokemon/$Num.png"
        $ShinySerebiiSpritePath = "$SerebiiBase/Shiny/SV/$Num.png"

        $Result = [PSCustomObject]@{
            Num = [int]$Num
            Name = $Name.Trim()
            Alias = $Alias.Trim().Replace(" ", "-")
            SerebiiLink = $SerebiiLink
            SpritePath = $SerebiiSpritePath
        }
        [void]$PokeResults.Add($Result)

        $ShinyResult = [PSCustomObject]@{
            Num = [int]$Num
            Name = $Name.Trim()
            Alias = $Alias.Trim().Replace(" ", "-")
            SerebiiLink = $SerebiiLink
            SpritePath = $ShinySerebiiSpritePath
        }
        if($IsShinyLocked) {
            $ShinyResult.Num = -1
            $ShinyResult.Name += " (Not Available)"
        }
        [void]$ShinyPokeResults.Add($ShinyResult)
    }

    Start-Sleep -Seconds 2
}

### Hard code plandean forms

# Paldean Tauros
$Result = [PSCustomObject]@{
    Num = 128
    Name = "Paldean Tauros"
    Alias = "tauros-paldean"
    SerebiiLink = "pokemon/tauros/"
    SpritePath = "https://www.serebii.net/scarletviolet/pokemon/128-p.png"
}
[void]$PokeResults.Add($Result)

$Result = [PSCustomObject]@{
    Num = 128
    Name = "Paldean Tauros"
    Alias = "tauros-paldean"
    SerebiiLink = "pokemon/tauros/"
    SpritePath = "https://www.serebii.net/Shiny/SV/128-p.png"
}
[void]$ShinyPokeResults.Add($Result)

# Blaze Paldean Tauros
$Result = [PSCustomObject]@{
    Num = 128
    Name = "Paldean Tauros (Blaze)"
    Alias = "tauros-blaze-paldean"
    SerebiiLink = "pokemon/tauros/"
    SpritePath = "https://www.serebii.net/scarletviolet/pokemon/128-b.png"
}
[void]$PokeResults.Add($Result)

$Result = [PSCustomObject]@{
    Num = 128
    Name = "Paldean Tauros (Blaze)"
    Alias = "tauros-blaze-paldean"
    SerebiiLink = "pokemon/tauros/"
    SpritePath = "https://www.serebii.net/Shiny/SV/128-b.png"
}
[void]$ShinyPokeResults.Add($Result)

# Aqua Paldean Tauros
$Result = [PSCustomObject]@{
    Num = 128
    Name = "Paldean Tauros (Aqua)"
    Alias = "tauros-aqua-paldean"
    SerebiiLink = "pokemon/tauros/"
    SpritePath = "https://www.serebii.net/scarletviolet/pokemon/128-a.png"
}
[void]$PokeResults.Add($Result)

$Result = [PSCustomObject]@{
    Num = 128
    Name = "Paldean Tauros (Aqua)"
    Alias = "tauros-aqua-paldean"
    SerebiiLink = "pokemon/tauros/"
    SpritePath = "https://www.serebii.net/Shiny/SV/128-a.png"
}
[void]$ShinyPokeResults.Add($Result)

# Paldean WOOPY
$Result = [PSCustomObject]@{
    Num = 194
    Name = "Paldean Wooper"
    Alias = "wooper-paldean"
    SerebiiLink = "pokemon/wooper/"
    SpritePath = "https://www.serebii.net/scarletviolet/pokemon/194-p.png"
}
[void]$PokeResults.Add($Result)

$Result = [PSCustomObject]@{
    Num = 194
    Name = "Paldean Wooper"
    Alias = "wooper-paldean"
    SerebiiLink = "pokemon/wooper/"
    SpritePath = "https://www.serebii.net/Shiny/SV/194-p.png"
}
[void]$ShinyPokeResults.Add($Result)

$CurrentDir = (pwd).Path
$OutputDir = [System.IO.Path]::Combine($CurrentDir, "data", "gen9")
[System.IO.Directory]::CreateDirectory($OutputDir)

$PokeResults | Export-Csv -Encoding UTF8 -Path "$OutputDir/normal.csv" -NoTypeInformation -Force 
$ShinyPokeResults | Export-Csv -Encoding UTF8 -Path "$OutputDir/shiny.csv" -NoTypeInformation -Force 