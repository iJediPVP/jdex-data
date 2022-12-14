. ".\utility\WebUtil.ps1"
. ".\utility\PokeUtil.ps1"

function Get-Ability($AbilityName, $IsHidden) {

    if([string]::IsNullOrEmpty($AbilityName) -eq $true) {
        return
    }

    $Ability = [PSCustomObject]@{
        Name = $AbilityName
        IsHidden = $IsHidden
        Description = ""
    }

    $AbilityInfo = $AbilityInfos | Where-Object { $_.Name -eq $AbilityName }
    if($null -eq $AbilityInfo) {
        Write-host "Could not find ability info for $Alias" -ForegroundColor Red
        return
    }

    $Ability.Description = $AbilityInfo.Desc

    return $Ability
}

$OutputDir = Join-Path ((Get-Location).Path) "scarletviolet" "data"
New-Item $OutputDir -ItemType Directory -ErrorAction SilentlyContinue

$Resources = @(
    "scarletviolet/teraraidbattles/1star.shtml",
    "scarletviolet/teraraidbattles/2star.shtml",
    "scarletviolet/teraraidbattles/3star.shtml",
    "scarletviolet/teraraidbattles/4star.shtml",
    "scarletviolet/teraraidbattles/5star.shtml",
    "scarletviolet/teraraidbattles/6star.shtml",

    "scarletviolet/teraraidbattles/event-eeveespotlight.shtml",
    "scarletviolet/teraraidbattles/event-unrivaledcharizard.shtml",
    "scarletviolet/teraraidbattles/event-tyranitarandsalamencespotlight.shtml",
    "scarletviolet/teraraidbattles/event-presentsfromdelibird.shtml",
    "scarletviolet/teraraidbattles/event-mightycinderace.shtml"
)

$TeraInfos = New-Object System.Collections.ArrayList

foreach($Resource in $Resources) {
    Write-Host $Resource -ForegroundColor Green

    $Response = Get-SerebiiResponse $Resource
    $Table = $Response.body.getElementsByTagName("table")[0]
    $Rows = $Table.firstChild.childNodes
    
    $Stars = -1 
    if($Resource.EndsWith("star.shtml")) {
        $Stars = [int]([System.IO.Path]::GetFileName($Resource).Replace("star.shtml", ""))
    }
    
    $Header = $Rows[0].firstChild.innerText.Split("`r`n")
    $Category = $Header[0]
    $Descriptions = New-Object System.Collections.ArrayList 
    foreach($Desc in ($Header | Select-Object -Skip 1)) {
        [void]$Descriptions.Add($Desc)
    }
    
    $Stage = 0
    $Sprites = New-Object System.Collections.ArrayList
    $Links = New-Object System.Collections.ArrayList
    $Names = New-Object System.Collections.ArrayList
    $Levels = New-Object System.Collections.ArrayList
    $TeraTypes = New-Object System.Collections.ArrayList
    $Abilities = New-Object System.Collections.ArrayList
    $Moves = New-Object System.Collections.ArrayList
    $DenStars = New-Object System.Collections.ArrayList
    $Items = New-Object System.Collections.ArrayList
    
    for($R = 1; $R -lt $Rows.Length; $R++) {
        $Row = $Rows[$R]
    
        for($C = 0; $C -lt $Row.childNodes.Length; $C++) {
            $Col = $Row.childNodes[$C]
    
            if($Stage -eq 0) {
                # Sprite
                [void]$Links.Add($Col.firstChild.pathname)
                [void]$Sprites.Add($Col.firstChild.firstChild.src)
            
            } elseif($Stage -eq 1) {
                # Name
                [void]$Names.Add($Col.innerText.Trim())
    
            } elseif($Stage -gt 1) {
    
                $ColText = $Col.innerText.Split("`r`n")
                $ColHeader = $ColText[0]
                
                if($ColHeader.StartsWith("Game")) {
                    # Do nothing
    
                } elseif($ColHeader.StartsWith("Level")) {
                    [void]$Levels.Add($ColText[$ColText.Length - 1])
    
                } elseif($ColHeader.StartsWith("Star Level")) {
                    $ColStars = $ColText[1].Split("&").Length - 1
                    [void]$DenStars.Add($ColStars)
    
                } elseif($ColHeader.StartsWith("Tera Type")) {
                    [void]$TeraTypes.Add($ColText[$ColText.Length - 1])
    
                } elseif($ColHeader.StartsWith("Ability")) {
                    [void]$Abilities.Add($ColText[$ColText.Length - 1])
    
                } elseif($ColHeader.StartsWith("Moves")) {
                    $ColMoves = $ColText | Where-Object { $_.Length -gt 0 -and $_ -ne "Moves" -and $_ -ne "Additional Moves" } 
                    [void]$Moves.Add($ColMoves)
    
                } elseif($ColHeader.StartsWith("Item Drops")) {
    
                    # If we're missing stars, that means that the page might not have them.. Use the default
                    if($DenStars.Count -lt $Names.Count) {
                        $Diff = $Names.Count - $DenStars.Count 
                        for($I = 0; $I -lt $Diff; $I++) {
                            [void]$DenStars.Add($Stars)
                        }
                    }

                    # Let's find the herbas
                    $ColItems = $Col.getElementsByTagName("td")
                    $PokeItems = New-Object System.Collections.ArrayList
                    foreach($Item in $ColItems) {
                        $Img = $Item.getElementsByTagName("img")
                        if($null -ne $Img) {
                            $Title = $Img | Select-Object -Expand title 
                            if([string]::IsNullOrEmpty($Title) -eq $false -and $Title.Contains("Herba Mystica")) {
                                [void]$PokeItems.Add($Title)
                            }
                        }
                    }
                    
                    [void]$Items.Add($PokeItems.ToArray())
    
                    # Reset
                    if($C -eq $Row.childNodes.Length - 1) {
                        $Stage = -1
                        break
                    }
                }
            }
    
        }
    
        $Stage++
    }

    Write-Host ("Pokes found: " + $Names.Count)

    $TeraInfo = [PSCustomObject]@{
        Category = $Category
        Descriptions = $Descriptions
        Sprites = $Sprites
        Links = $Links
        Names = $Names
        Levels = $Levels
        TeraTypes = $TeraTypes
        Abilities = $Abilities
        Moves = $Moves
        DenStars = $DenStars
        Items = $Items
    }

    [void]$TeraInfos.Add($TeraInfo)
}


# Now that we have all of the tera den info, we need to restructure the data
$PokeInfos = Import-CSV (Join-Path $OutputDir "pokemon.csv") -Encoding utf8
$AbilityInfos = Get-Content (Join-Path $OutputDir "abilities.json")  -Encoding utf8 | ConvertFrom-Json
$MoveInfos = Get-Content (Join-Path $OutputDir "moves.json")  -Encoding utf8 | ConvertFrom-Json

foreach($TeraInfo in $TeraInfos) {

    $SplitName = $TeraInfo.Category.Split(" - ")
    $Name = $SplitName[$SplitName.Length - 1]

    Write-Host "Formatting $Name" -ForegroundColor Green

    $Stars = -1
    if($Name.EndsWith("Star")) {
        $SplitName = $Name.Split(" ")
        $Stars = [int]$SplitName[0]
    }

    $Descriptions = @()
    if($TeraInfo.Descriptions.Length -gt 0) {
        $Descriptions = $TeraInfo.Descriptions
    }

    $Monsters = New-Object System.Collections.ArrayList

    for($M = 0; $M -lt $TeraInfo.Sprites.Count; $M++) {
        $Sprite = $TeraInfo.Sprites[$M]
        $PokeName = $TeraInfo.Names[$M]
        $Alias = ""
        $Form = ""
        $PokeStars = $Stars

        $SplitSrc = $Sprite.Split("/")
        $Png = $SplitSrc[$SplitSrc.Length - 1].Replace(".png", "")
        if($Png -ne "blank") {
            $PngSplit = $Png.Split("-")
            if($PngSplit.Length -gt 1) {
                $Form = $PngSplit[1]
            }
        }

        Set-PokeNameAndAlias ([ref]$PokeName) ([ref]$Alias) $Form
        
        if($PokeStars -lt 0) {
            $PokeStars = $TeraInfo.DenStars[$M]
        }

        #region Types

        $Types = New-Object System.Collections.ArrayList
        $PokeInfo = $PokeInfos | Where-Object { $_.Alias -eq $Alias } | Select-Object -First 1
        if($null -eq $PokeInfo) {
            Write-Host "Could not find info for $Alias" -ForegroundColor Red
            return
        }

        if([string]::IsNullOrEmpty($PokeInfo.Type1) -eq $false) {
            [void]$Types.Add($PokeInfo.Type1)
        }
        if([string]::IsNullOrEmpty($PokeInfo.Type2) -eq $false) {
            [void]$Types.Add($PokeInfo.Type2)
        }

        #endregion

        #region Abilities

        $Abilities = New-Object System.Collections.ArrayList
        $Ability = Get-Ability $PokeInfo.Ability1 $false
        if($null -ne $Ability) {
            [void]$Abilities.Add($Ability)
        }
        $Ability = Get-Ability $PokeInfo.Ability2 $false
        if($null -ne $Ability) {
            [void]$Abilities.Add($Ability)
        }
        $Ability = Get-Ability $PokeInfo.HiddenAbility $true
        if($null -ne $Ability) {
            [void]$Abilities.Add($Ability)
        }

        #endregion

        #region Moves

        $Moves = New-Object System.Collections.ArrayList
        $TeraMoves = $TeraInfo.Moves[$M]
        foreach($MoveName in $TeraMoves) {
            $MoveInfo = $MoveInfos | Where-Object { $_.Name -eq $MoveName } | Select-Object -First 1
            if($null -eq $MoveInfo) {
                Write-Host "Could not find move info for $MoveName" -ForegroundColor Red
                return
            }

            $MoveResult = [PSCustomObject]@{
                Name = $MoveName
                Type = $MoveInfo.Type
                Category = $MoveInfo.Category
                Attack = $MoveInfo.Attack
                Accuracy = $MoveInfo.Accuracy
                Description = $MoveInfo.Description
            }
            [void]$Moves.Add($MoveResult)
        }

        #endregion

        $BaseStats = [PSCustomObject]@{
            HP = [int]$PokeInfo.HP
            Attack = [int]$PokeInfo.Attack
            Defense = [int]$PokeInfo.Defense
            SpAttack = [int]$PokeInfo.SpAttack
            SpDefense = [int]$PokeInfo.SpDefense
            Speed = [int]$PokeInfo.Speed
        }

        $PokeResult = [PSCustomObject]@{
            Name = $PokeName
            Alias = $Alias
            Stars = $PokeStars
            Level = [int]$TeraInfo.Levels[$M].Replace("Lv.", "").Trim()
            SerebiiLink = $TeraInfo.Links[$M] + "/"
            PossibleTera = $TeraInfo.TeraTypes[$M]
            PossibleAbility = $TeraInfo.Abilities[$M]
            Types = $Types.ToArray()
            Abilities = $Abilities.ToArray()
            Moves = $Moves.ToArray()
            BaseStats = $BaseStats
            Items = $TeraInfo.Items[$M]
        }
        [void]$Monsters.Add($PokeResult)

    }

    $Monsters = $Monsters | Sort-Object -Property Name | Get-Unique -AsString
    Write-Host ("Pokes found: " + $Monsters.Count)
    $TeraResult = [PSCustomObject]@{
        Name = $Name
        Stars = $Stars
        Descriptions = $Descriptions
        Monsters = $Monsters
    }

    $FileName = "tera_" + $Name.Replace(" ", "") + ".json"
    $OutputFIle = Join-Path $OutputDir $FileName
    ConvertTo-Json $TeraResult -Compress -Depth 10 | Out-File $OutputFIle -Encoding UTF8 -Force -ErrorAction Stop
}

