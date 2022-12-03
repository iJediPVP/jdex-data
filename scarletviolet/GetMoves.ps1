. ".\utility\WebUtil.ps1"

$TextInfo = [System.Globalization.CultureInfo]::new("en-US", $false).TextInfo
$Moves = New-Object System.Collections.ArrayList

$Dexes = @(
    "physical",
    "special",
    "other"
)

foreach($Dex in $Dexes) {
    $Response = Get-SerebiiResponse "attackdex-sv/$Dex.shtml"
    $Table = $Response.body.getElementsByClassName("dextable")[0]
    $Rows = $Table.firstChild.childNodes | Select-Object -Skip 1

    foreach($Row in $Rows) {
        $Name = $Row.childNodes[0].innerText
        if([string]::IsNullOrEmpty($Name)) {
            continue
        }
        $Name = $Name.Trim()

        $TypeSrc = $Row.childNodes[1].firstChild.src
        $Type = [System.IO.Path]::GetFileNameWithoutExtension($TypeSrc)
        $Type = $TextInfo.ToTitleCase($Type).Trim()

        $CategorySrc = $Row.childNodes[2].firstChild.src
        $Category = [System.IO.Path]::GetFileNameWithoutExtension($CategorySrc)
        $Category = $TextInfo.ToTitleCase($Category).Trim()
        if($Category -eq "Other") {
            $Category = "Status"
        }

        $PP = $Row.childNodes[3].innerText.Trim()
        $Attack = $Row.childNodes[4].innerText.Trim()
        $Accuracy = $Row.childNodes[5].innerText.Trim()
        $Desc = $Row.childNodes[6].innerText.Trim()

        $Move = [PSCustomObject]@{
            Name = $Name
            Type = $Type
            Category = $Category
            PP = $PP
            Attack = $Attack
            Accuracy = $Accuracy
            Description = $Desc
        }

        [void]$Moves.Add($Move)
    }
}

$OutputDir = Join-Path ((Get-Location).Path) "scarletviolet" "data"
New-Item $OutputDir -ItemType Directory -ErrorAction SilentlyContinue

$OutputFIle = Join-Path $OutputDir "moves.json"
ConvertTo-Json $Moves -Compress -Depth 10 | Out-File $OutputFIle -Encoding UTF8 -Force -ErrorAction Stop