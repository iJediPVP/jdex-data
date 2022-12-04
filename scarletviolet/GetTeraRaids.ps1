. ".\utility\WebUtil.ps1"
. ".\utility\PokeUtil.ps1"

$Resources = @(
    "scarletviolet/teraraidbattles/1star.shtml",
    "scarletviolet/teraraidbattles/2star.shtml",
    "scarletviolet/teraraidbattles/3star.shtml",
    "scarletviolet/teraraidbattles/4star.shtml",
    "scarletviolet/teraraidbattles/5star.shtml",
    "scarletviolet/teraraidbattles/6star.shtml",

    "scarletviolet/teraraidbattles/event-eeveespotlight.shtml",
    "scarletviolet/teraraidbattles/event-unrivaledcharizard.shtml"
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
    $Descriptions = $Header | Select-Object -Skip 1
    
    $Stage = 0
    $Sprites = New-Object System.Collections.ArrayList
    $Links = New-Object System.Collections.ArrayList
    $Names = New-Object System.Collections.ArrayList
    $Levels = New-Object System.Collections.ArrayList
    $TeraTypes = New-Object System.Collections.ArrayList
    $Abilities = New-Object System.Collections.ArrayList
    $Moves = New-Object System.Collections.ArrayList
    $DenStars = New-Object System.Collections.ArrayList
    
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
                    $ColMoves = $ColText | Where-Object { $_ -ne "Moves" -and $_ -ne "Additional Moves" }
                    [void]$Moves.Add($ColMoves)
    
                } elseif($ColHeader.StartsWith("Item Drops")) {
    
                    # If we're missing stars, that means that the page might not have them.. Use the default
                    if($DenStars.Count -lt $Names.Count) {
                        $Diff = $Names.Count - $DenStars.Count 
                        for($I = 0; $I -lt $Diff; $I++) {
                            [void]$DenStars.Add($Stars)
                        }
                    }
    
                    # Reset
                    $Stage = -1
                    break
    
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
    }

    [void]$TeraInfos.Add($TeraInfo)
}


# Now that we have all of the tera den info, we need to restructure the data
foreach($TeraInfo in $TeraInfos) {

}


$OutputDir = Join-Path ((Get-Location).Path) "scarletviolet" "data"
New-Item $OutputDir -ItemType Directory -ErrorAction SilentlyContinue

$OutputFIle = Join-Path $OutputDir "teraraids.json"
ConvertTo-Json $TeraInfos -Compress -Depth 10 | Out-File $OutputFIle -Encoding UTF8 -Force -ErrorAction Stop