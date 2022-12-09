. ".\utility\WebUtil.ps1"
. ".\utility\PokeUtil.ps1"

$OutputDir = Join-Path ((Get-Location).Path) "scarletviolet" "data"
New-Item $OutputDir -ItemType Directory -ErrorAction SilentlyContinue

$PokeResults = New-Object System.Collections.ArrayList
$PokeInfos = Import-CSV (Join-Path $OutputDir "pokemon.csv") -Encoding utf8

$NameReplacements = @(
    "Alolan ",
    "Galarian ",
    "Hisuian ",
    "Paldean "
)

foreach($PokeInfo in $PokeInfos) {
    if($PokeInfo.DoNotShow -ne "1") {
        
        $Types = New-Object System.Collections.ArrayList
        [void]$Types.Add($PokeInfo.Type1)
        if([string]::IsNullOrEmpty($PokeInfo.Type2) -eq $false) {
            [void]$Types.Add($PokeInfo.Type2)
        } 

        $Result = [PSCustomObject]@{
            Name = $PokeInfo.Display
            Alias = $PokeInfo.Alias
            Types = $Types
        }

        foreach($Repl in $NameReplacements) {
            if($Result.Name.StartsWith($Repl)) {
                $Result.Name = ($Result.Name.Substring($Repl.Length) + " " + $Repl).Trim()
            }
        }

        [void]$PokeResults.Add($Result)
    }
}

$PokeResults = $PokeResults | Sort-Object -Property Name
$OutputFIle = Join-Path $OutputDir "pokemon.json"
ConvertTo-Json $PokeResults -Compress -Depth 10 | Out-File $OutputFIle -Encoding UTF8 -Force -ErrorAction Stop