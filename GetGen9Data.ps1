$CurrentDir = (pwd).Path
$DataDir = [System.IO.Path]::Combine($CurrentDir, "data")
$ImageDir = [System.IO.Path]::Combine($CurrentDir, "sprites", "home", "normal")
$ShinyImageDir = [System.IO.Path]::Combine($CurrentDir, "sprites", "home", "shiny")

$URL = "https://pokemondb.net/pokedex/stats/gen9"
$DexResponse = Invoke-WebRequest $URL -ErrorAction Stop
$Rows = $DexResponse.ParsedHtml.body.getElementsByTagName("table")[0].getElementsByTagName("tr")
$RowCount = $Rows.length - 1

$Data = [System.Text.StringBuilder]::new()

for($i = 1; $i -le $RowCount; $i++)
{
    Write-Host ("$i of " + $RowCount)
    
    $Row = $Rows[$i]
    $NumTag = $Row.getElementsByClassName("cell-num cell-fixed")[0]
    $Num = [int]::Parse($NumTag.getElementsByClassName("infocard-cell-data")[0].innerText)

    $ImageTag = $NumTag.getElementsByClassName("img-fixed icon-pkmn")[0]
    $ImageURL = $ImageTag.src.Replace("icon", "normal")
    $ShinyImageURL = $ImageTag.src.Replace("icon", "shiny")
    $ImageExt = [System.IO.Path]::GetExtension($ImageURL)
    
    $Alias = [System.IO.Path]::GetFileNameWithoutExtension($ImageURL)

    $Name = $Row.getElementsByClassName("ent-name")[0].innerText 
    if($Alias.Contains("paldean")) {
        $Name = "Paldean " + $Name
    }
    
    [void]$Data.AppendLine("$Num|$Alias|$Name")

    $ImageFile = [System.IO.Path]::Combine($ImageDir, $Alias + $ImageExt)
    if((Test-Path $ImageFile) -eq $false) 
    {
        Invoke-WebRequest $ImageURL -OutFile $ImageFile -ErrorAction Stop
    }

    # Shinies are not up yet - For now we'll use the normal sprite
    $ShinyImageFile = [System.IO.Path]::Combine($ShinyImageDir, $Alias + $ImageExt)
    if((Test-Path $ShinyImageFile) -eq $false) 
    {
        Copy-Item $ImageFile $ShinyImageFile
        #Invoke-WebRequest $ImageURL -OutFile $ShinyImageFile -ErrorAction Stop
    }
}

$OutFile = [System.IO.Path]::Combine($DataDir, "gen9.txt")
$Data.ToString() | Out-File $OutFile -Force -Encoding utf8 -ErrorAction Stop