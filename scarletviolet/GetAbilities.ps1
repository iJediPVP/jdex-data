. ".\utility\WebUtil.ps1"

$Abilities = New-Object System.Collections.ArrayList

$Response = Get-Game8Response "Pokemon-Scarlet-Violet/archives/388972"
$Headers = $Response.body.getElementsByTagName("h3") 
$Headers = $Headers | Where-Object { $_.innerText.StartsWith("Abilities - ") }
$Tables = $Headers | Select-Object -ExpandProperty NextSibling

foreach($table in $Tables) {
    $Rows = $Table.firstChild.childNodes | Select-Object -Skip 1

    foreach($Row in $Rows) {
        $Ability = [PSCustomObject]@{
            Name = $Row.childNodes[0].innerText.Trim()
            Desc = $Row.childNodes[1].innerText.Trim()
        }
        
        [void]$Abilities.Add($Ability)
    }
}


$OutputDir = Join-Path ((Get-Location).Path) "scarletviolet" "data"
New-Item $OutputDir -ItemType Directory -ErrorAction SilentlyContinue

$OutputFIle = Join-Path $OutputDir "abilities.json"
ConvertTo-Json $Abilities -Compress -Depth 10 | Out-File $OutputFIle -Encoding UTF8 -Force -ErrorAction Stop