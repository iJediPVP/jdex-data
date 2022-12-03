. ".\utility\WebUtil.ps1"
. ".\utility\PokeUtil.ps1"
<#
for($S = 1; $S -lt 7; $S++) {
    
}#>

$S = 1

$Resource = "scarletviolet/teraraidbattles/$S" + "star.shtml"
$Response = Get-SerebiiResponse $Resource
$Table = $Response.body.getElementsByTagName("table")[0]
$Rows = $Table.firstChild.childNodes

$Stars = $S
$Header = $Rows[0].firstChild.innerText.Split("`r`n")
$Category = $Header[0]
$Descriptions = $Header | Select-Object -Skip 1

for($R = 1; $R -lt $Rows.Length; $R += 7) {

    $Sprites = $Rows[$R].childNodes
    $Names = $Rows[$R + 1].childNodes
    # Skipping game
    $Levels = $Rows[$R + 3].childNodes
    $TeraTypes = $Rows[$R + 4].childNodes
    $Abilities = $Rows[$R + 5].childNodes
    $Moves = $Rows[$R + 6].childNodes

    for($C = 0; $C -lt $Sprites.Length; $C++) {

        # We'll use PokeURl and the sprite file to find the form
        $Sprite = $Sprites[$C]
        $PokeURL = $Sprite.firstChild.pathname
        $Png = [System.IO.Path]::GetFileNameWithoutExtension($Sprite.firstChild.firstChild.src)
        $PngSplit = $Png.Split("-")
        $Form = ""
        if($PngSplit.Length -gt 1) {
            $Form = $PngSplit[1]
        }

        $Name = $Names[$C].innerText.Trim()
        $Level = $Levels[$C].lastChild.textContent.Replace("Lv.", "").Trim()
        $TeraType = $TeraTypes[$C].innerText.Replace("Tera Type", "").Trim()
        $Ability = $Abilities[$C].childNodes[2].textContent

        $PokeMoves = $Moves[$C].getElementsByTagName("a") | Select-Object -ExpandProperty innerText 

        # TODO: Lookup abilities and ability descriptions 
        #TODO: Lookup descriptions
    }
}