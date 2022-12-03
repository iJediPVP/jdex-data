. ".\utility\PokeUtil.ps1"
. ".\utility\WebUtil.ps1"

function Get-DebugHTML($Pokes, $DexId, $SpriteDir) {
    $Res = "<html><body><table>"
    $Res += "<thead><tr>"
    $Res += "<th>#</th>"
    $Res += "<th>Name</th>"
    $Res += "<th>Alias</th>"
    $Res += "<th>Error</th>"
    $Res += "</tr></thead>"

    foreach($Poke in $Pokes) {

        $PokeError = ""
        $ImgPath = Join-Path $SpriteDir ($Poke.Alias + ".png")
        if((Test-Path $ImgPath) -eq $false) {
            $PokeError = "Missing Sprite"
        }

        if($PokeError.Length -eq 0) {
            continue
        }

        Write-Host ($Poke.Alias + ": $PokeError") -ForegroundColor Red

        $Res += "<tr>"

        $Res += "<td>"
        $Res += $Poke.Num
        $Res += "</td>"

        $Res += "<td>"
        $Res += $Poke.Name
        $Res += "</td>"

        $Res += "<td>"
        $Res += $Poke.Alias
        $Res += "</td>"

        $Res += "<td>"
        $Res += $PokeError
        $Res += "</td>"

        $Res += "</tr>"
    }

    return $Res
}

function Get-Poke($PokeNum, $PokeName, $Alias, $SerebiiLink) 
{
    $Result = [PSCustomObject]@{
        Num = [int]$PokeNum
        Name = $PokeName
        Alias = $Alias
        SerebiiLink = $SerebiiLink
    }

    return $Result
}

function Set-Boxes($Pokes, $Boxes) 
{
    $Page = 1
    $PageSize = 30
    do 
    {
        $Skip = ($Page - 1) * $PageSize
        $SelectedPokes = $Pokes | Select-Object -Skip $Skip -First $PageSize
        if($SelectedPokes.Count -eq 0) 
        {
            break
        }

        $PokesForBox = New-Object System.Collections.ArrayList
        foreach($Poke in $SelectedPokes) 
        {
            [void]$PokesForBox.Add($Poke)
        }

        if($PokesForBox.Count -lt $PageSize) 
        {
            $ToAdd = $PageSize - $PokesForBox.Count
            for($i = 0; $i -lt $ToAdd; $i++) 
            {
                $Poke = Get-Poke -1 "" "" ""
                [void]$PokesForBox.Add($Poke)
            }
        }
        [void]$Boxes.Add(
            [PSCustomObject]@{
                Num = $Boxes.Count + 1
                Monsters = $PokesForBox
            }
        )

        $Page += 1
    } while($true)
}

function Get-Gen9Temp($Results, $DexId, [switch]$IsShiny) {

    Write-Host "Getting Gen 9 | Is Shiny: $IsShiny"

    #region Get Gen 9 Mons
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

    # Get all of the data from serebii. Once we have everything, including forms, we'll use this data to build a "living dex" list.
    $Gen9Pokes = New-Object System.Collections.ArrayList
    $Gen9Response = Get-SerebiiResponse "scarletviolet/pokemon.shtml"
    $Gen9Rows = $Gen9Response.body.getElementsByClassName("pkmn")

    foreach($Row in $Gen9Rows) {
        # We're finding the serebii link to each poke in the dex
        # Row = <A href="/pokedex-sv/sprigatito/"><IMG class=listsprite src="/scarletviolet/pokemon/906.png" loading="lazy"></A>
        $Anchor = $Row.getElementsByTagName("a")[0]
        $AnchorPath = $Anchor.pathname
        $Alias = [System.IO.Path]::GetFileName($AnchorPath.Substring(0, $AnchorPath.Length - 1))
        $Num = [System.IO.Path]::GetFileNameWithoutExtension($Anchor.firstChild.src).Split("-")[0]

        $NameRow = $Row.parentNode.parentNode.parentNode.parentNode.nextSibling
        $Name = $NameRow.getElementsByTagName("a")[0].innerText.Split("`r`n")[0].Trim()

        $Existing = $Gen9Pokes | Where-Object { $_.Num -eq [int]$Num } | Select-Object -First 1
        if($null -ne $Existing) {
            continue
        }

        #Write-Host "# $Num $Alias - $Name" -ForegroundColor Green

        # Now that we have the link, we can request data for the poke
        $PokeResponse = Get-SerebiiResponse "pokedex-sv/$Alias"

        # Handle forms
        $Forms = $PokeResponse.body.getElementsByClassName("sprite-select")
        if($Forms.Length -le 0) {

            $SpriteURL = "scarletviolet/pokemon/$Num.png"
            if($IsShiny) {
                $SpriteURL = "Shiny/SV/$Num.png"
                if($ShinyLocked.Contains($Alias)) {
                    $Num = -1
                    $Name = "$Name (Not Available)"
                }
            }

            $Poke = [PSCustomObject]@{
                Num = [int]$Num
                Name = $Name.Trim()
                SerebiiLink = "pokemon/$Alias"
                SpriteURL = $SpriteURL
            }
            [void]$Gen9Pokes.Add($Poke)

        } else {
            
            foreach($Form in $Forms) {

                $FormTitle = $Form.title.Replace("Form", "").Trim()
                $FormName = $Name
                if($FormTitle -ne "Male") {
                    $FormName = "$Name ($FormTitle)"
                }

                $SerebiiSprite = $Form.attributes['data-key'].textContent
                $SpriteURL = "scarletviolet/pokemon/$SerebiiSprite.png"
                if($IsShiny) {
                    $SpriteURL = "Shiny/SV/$SerebiiSprite.png"

                    if($ShinyLocked.Contains($Alias)) {
                        $Num = -1
                        $FormName = "$FormName (Not Available)"
                    }
                }

                $Poke = [PSCustomObject]@{
                    Num = [int]$Num
                    Name = $FormName.Trim()
                    SerebiiLink = "pokemon/$Alias"
                    SpriteURL = $SpriteURL
                }
                [void]$Gen9Pokes.Add($Poke)
            }
            
        }
    }

    ### Manually add Tuaros
    Write-Host "Manually Add Tauros" -ForegroundColor Green
    $Poke = [PSCustomObject]@{
        Num = 128
        Name = "Paldean Tauros"
        SerebiiLink = "pokemon/tauros"
        SpriteURL = "scarletviolet/pokemon/128-p.png"
    }
    if($IsShiny) { $Poke.SpriteURL = $Poke.SpriteURL.Replace("scarletviolet/pokemon", "Shiny/SV") }
    [void]$Gen9Pokes.Add($Poke)
    
    $Poke = [PSCustomObject]@{
        Num = 128
        Name = "Paldean Tauros (Blaze)"
        SerebiiLink = "pokemon/tauros"
        SpriteURL = "scarletviolet/pokemon/128-b.png"
    }
    if($IsShiny) { $Poke.SpriteURL = $Poke.SpriteURL.Replace("scarletviolet/pokemon", "Shiny/SV") }
    [void]$Gen9Pokes.Add($Poke)
    
    $Poke = [PSCustomObject]@{
        Num = 128
        Name = "Paldean Tauros (Aqua)"
        SerebiiLink = "pokemon/tauros"
        SpriteURL = "scarletviolet/pokemon/128-a.png"
    }
    if($IsShiny) { $Poke.SpriteURL = $Poke.SpriteURL.Replace("scarletviolet/pokemon", "Shiny/SV") }
    [void]$Gen9Pokes.Add($Poke)

    ### Manually add Wooper
    Write-Host "Manually Add Woopy Boy" -ForegroundColor Green
    $Poke = [PSCustomObject]@{
        Num = 194
        Name = "Paldean Wooper"
        SerebiiLink = "pokemon/wooper"
        SpriteURL = "scarletviolet/pokemon/194-p.png"
    }
    if($IsShiny) { $Poke.SpriteURL = $Poke.SpriteURL.Replace("scarletviolet/pokemon", "Shiny/SV") }
    [void]$Gen9Pokes.Add($Poke)

    #endregion

    #region Transofmr Gen 9 into our "living dex" forms

    foreach($PokeTD in $Gen9Pokes) {

        $SplitSrc = $PokeTD.SpriteURL.Split("/")
        $Png = $SplitSrc[$SplitSrc.Length - 1].Replace(".png", "")

        $PokeName = $PokeTD.Name
        $Alias = ""
        $Form = ""
        $PokeNum = $PokeTD.Num
        $SerebiiLink = ($PokeTD.SerebiiLink + "/")

        # $IsUnavailable = $false
        if($PokeName.Contains("(Not Available)")) {
            $PokeName = $PokeTD.Name.Replace("(Not Available)", "").Trim()
            # $IsUnavailable = $true
        }

        if($Png -ne "blank") {
            $PngSplit = $Png.Split("-")
            $PokeNum = [int]::Parse($PngSplit[0])
            if($PngSplit.Length -gt 1) {
                $Form = $PngSplit[1]
            }
        }

        # For now, we'll mark all of gen 9 as unavailable
        $PokeName += " (Not Available)"
        $PokeNum = -1

        Set-PokeNameAndAlias ([ref]$PokeName) ([ref]$Alias) $Form
        $Result = Get-Poke $PokeNum $PokeName $Alias $SerebiiLink
        [void]$Results.Add($Result)

        # Download sprite if it is missing
        $FullSpriteURL = "https://www.serebii.net/" + $PokeTD.SpriteURL
        $SpritePath = Join-Path ((Get-Location).Path) "livingdex" "sprites" $DexId "$Alias.png"
        if((Test-Path $SpritePath) -eq $false) {
            Write-Host ("Getting Sprite For " + $Alias + ": $FullSpriteURL") -ForegroundColor Yellow
            $ProgressPreference = "SilentlyContinue"
            Invoke-WebRequest $FullSpriteURL -OutFile $SpritePath -ErrorAction Stop -Timeout 10
            $ProgressPreference = "Continue"
        }#>

    }

    #endregion

}

$OutputDir = Join-Path ((Get-Location).Path) "livingdex" "data"
New-Item $OutputDir -ItemType Directory -ErrorAction SilentlyContinue

$TextInfo = [System.Globalization.CultureInfo]::new("en-US", $false).TextInfo

$Response = Get-SerebiiResponse "pokemonhome/depositablepokemon.shtml"
$Divs = $Response.body.getElementsByTagName("div") | Where-Object { $_.Id -eq"normal" -or $_.Id -eq "shiny" }

foreach($SelectedDiv in $Divs) {

    $DexId = $SelectedDiv.id
    $DexName = $TextInfo.ToTitleCase($DexId)
    Write-Host "Starting $DexName" -ForegroundColor Green

    $Results = New-Object System.Collections.ArrayList
    $FirstPowerZygarde = $true

    $PokeTDs = $SelectedDiv.getElementsByTagName("td") | Where-Object { $_.ClassName -eq "pkmn" }
    foreach($PokeTD in $PokeTDs) {

        $Link = $PokeTD.getElementsByTagName("a")[0]
        $Img = $PokeTD.getElementsByTagName("img")[0]
        $SplitSrc = $Img.src.Split("/")
        $Png = $SplitSrc[$SplitSrc.Length - 1].Replace(".png", "")

        $PokeName = $Img.title
        $Alias = ""
        $Form = ""
        $PokeNum = -1

        if($Png -ne "blank") {
            $PngSplit = $Png.Split("-")
            $PokeNum = [int]::Parse($PngSplit[0])
            if($PngSplit.Length -gt 1) {
                $Form = $PngSplit[1]
            }
        }

        Set-PokeNameAndAlias ([ref]$PokeName) ([ref]$Alias) $Form

        # Shiny Alcremie are all the same aside from the modifier. So we only need 7 shiny forms
        if($Alias.StartsWith("alcremi") -and $DexId -eq "shiny" -and $Alias.Contains("vanilla-cream") -eq $false) {
            continue
        }

        # Zygarde is weird..
        if($PokeName -eq "Zygarde Power Construct" -and $FirstPowerZygarde -eq $true) {
            $PokeName = "Zygarde 10% Power Construct"
            $Alias = "zygarde-10-power-construct"
            $FirstPowerZygarde = $false
        }

        $Result = Get-Poke $PokeNum $PokeName $Alias $Link.pathname
        [void]$Results.Add($Result)
    }

    # Temp Gen 9 data
    #Load-Gen9 $DexId $PokeResults
    $IsShiny = $false
    if($DexId -eq "shiny") {
        $IsShiny = $true
    }
    Get-Gen9Temp $Results $DexId $IsShiny

    # Debug HTML to find missing images
    $SpriteDir = Join-Path ((Get-Location).Path) "livingdex" "sprites" $DexId
    $DebugHTML = Get-DebugHTML $Results $DexId $SpriteDir
    $OutFileHTML = Join-Path $OutputDir "$DexId.html"
    $DebugHTML | Out-File $OutFileHTML -Force -Encoding UTF8

    $TotalPokeCount = ($Results | Where-Object { $_.Num -gt 0 }).Count 

    # Pull out Pikachu Caps
    $CapPikachus = $Results | Where-Object { $_.Alias.StartsWith("pikachu-") -and $_.Alias.EndsWith("-cap") }
    foreach($Poke in $CapPikachus) {
        $Index = $Results.IndexOf($Poke)
        $Results.RemoveAt($Index)
    }

    # Pull out non regional variants. 
    $Regions = @("Alolan", "Galarian", "Hisuian", "Paldean")
    $RegionalPokes = $Results | Where-Object { $Regions.Contains($_.Name.Split(" ")[0]) }
    foreach($Poke in $RegionalPokes) {
        $Index = $Results.IndexOf($Poke)
        $Results.RemoveAt($Index)
    }

    # Sort non-regional forms
    $Boxes = New-Object System.Collections.ArrayList
    Set-Boxes $Results $Boxes 

    # Sort Pikachu Caps
    Set-Boxes $CapPikachus $Boxes

    # Sort regional forms
    foreach($Region in $Regions) {
        $Pokes = $RegionalPokes | Where-Object { $_.Name.Split(" ")[0] -eq $Region }
        Set-Boxes $Pokes $Boxes
    }


    # Write output files
    $Dex = [PSCustomObject]@{
        Id = $DexId
        Name = $DexName
        Count = $TotalPokeCount   
        Boxes = $Boxes.ToArray()
    }

    $OutFileJSON = Join-Path $OutputDir "$DexId.json"
    ConvertTo-Json $Dex -Compress -Depth 10 | Out-File $OutFileJSON -Encoding utf8 -Force 
    
    Write-Host "Finished $DexName - $TotalPokeCount available Pokes" -ForegroundColor Green
}