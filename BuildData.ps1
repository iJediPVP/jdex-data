$SerebiiBase = "https://www.serebii.net"
$SourceURL = "$SerebiiBase/pokemonhome/depositablepokemon.shtml"
$CurrentDir = (pwd).Path
$OutputDir = [System.IO.Path]::Combine($CurrentDir, "data")
[void][System.IO.Directory]::CreateDirectory($OutputDir)
$Test = $true

$Response = Invoke-WebRequest $SourceURL
$Divs = $Response.ParsedHtml.body.getElementsByTagName("div") | ? { $_.Id -eq"normal" -or $_.Id -eq "shiny" }


$Banned = @(
    "Zygarde Power Construct",
    "Rockruff Own Tempo"
)

# Test HTML to easily view errors
function Get-TestHTML($Pokemons, $DexName) 
{
    $Res = "<html><body><table>"
    $Res += "<thead><tr>"
    $Res += "<th>#</th>"
    $Res += "<th>Name</th>"
    $Res += "<th>Alias</th>"
    $Res += "<th>Form</th>"
    $Res += "<th>Sprite</th>"
    $Res += "</tr></thead>"

    foreach($Poke in $Pokemons) 
    {
        $ImgPath = [System.IO.Path]::Combine($CurrentDir, "sprites/home", $DexName, $Poke.Alias + ".png")
        if(Test-Path $ImgPath)
        {
            continue
        }
        $Img = [System.IO.Path]::Combine("../sprites/home", $DexName, $Poke.Alias + ".png")
        
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
        $Res += $Poke.Form
        $Res += "</td>"

        $Res += "<td>"

        
        $Alt = $Poke.Alias
        $Res += "<img src='$Img' alt='$Alt' />"
        $Res += "</td>"


        $Res += "</tr>"
    }


    $Res += "</table></body><html>"
    return $Res
}

function Replace-Region($Alias, $Region) 
{
    if($Alias.StartsWith("$Region-"))
    {
        $Res = $Alias.Replace("$Region-", "")
        if($Res.EndsWith("-f")) 
        {
            $Res = $Res.Replace("-f", "-$Region-f").Trim()
        }
        else 
        {
            $Res = $Res + "-$Region".Trim()
        }
        return $Res
    }
    return $Alias
}

function Replace-Alias($Alias, $Replace, $ReplaceWith) 
{ 
    
    if($Alias.Contains($Replace)) 
    {
        return $Alias.Replace($Replace, $ReplaceWith).Trim()
    }

    return $Alias
}

function Get-Alias($Name, $Form) 
{
    $Alias = $Name.ToLower().Replace(" ", "-")
    
    $Alias = Replace-Alias $Alias "(female)" "f"
    $Alias = Replace-Alias $Alias "female" "f"
    $Alias = Replace-Alias $Alias "pattern" ""
    $Alias = Replace-Alias $Alias "-forme" ""
    $Alias = Replace-Alias $Alias "-form" ""
    $Alias = Replace-Alias $Alias "♀" "-f"
    $Alias = Replace-Alias $Alias "♂" ""
    $Alias = Replace-Alias $Alias "farfetch'd" "farfetchd"
    $Alias = Replace-Alias $Alias "mr." "mr"
    $Alias = Replace-Alias $Alias "!" "em"
    $Alias = Replace-Alias $Alias "?" "qm"
    $Alias = Replace-Alias $Alias "-cloak" ""
    $Alias = Replace-Alias $Alias "-sea" ""
    $Alias = Replace-Alias $Alias "jr." "jr"
    $Alias = Replace-Alias $Alias "(ash)" "ash"
    $Alias = Replace-Alias $Alias "é" "e"
    $Alias = Replace-Alias $Alias "-flower" ""
    $Alias = Replace-Alias $Alias "-trim" ""
    $Alias = Replace-Alias $Alias "%" ""
    $Alias = Replace-Alias $Alias "-style" ""
    $Alias = Replace-Alias $Alias "'" ""
    $Alias = Replace-Alias $Alias ":" ""
    $Alias = Replace-Alias $Alias "-color" ""
    $Alias = Replace-Alias $Alias "-(not-available)" ""

    $Alias = Replace-Region $Alias "alolan"
    $Alias = Replace-Region $Alias "galarian"
    $Alias = Replace-Region $Alias "hisuian"

    if($Alias.EndsWith("-")) 
    {
        $Alias = $Alias.Substring(0, $Alias.Length - 1)
    }


    return $Alias
}

function Replace-Name($Name, $Replace, $ReplaceWith) 
{
    if($Name -eq $Replace) 
    {
        return $ReplaceWith
    }
    return $Name
}

function Get-Name($Name) 
{
    $Res = $Name
    if($Res.EndsWith(" Rotom")) 
    {
        $Res = $Res.Substring(0, $Res.Length - 5).Trim()
    }

    $Res = Replace-Name $Res "Pikachu Partner Cap" "Pikachu Johto Cap"
    $Res = Replace-Name $Res "Unown" "Unown A"
    $Res = Replace-Name $Res "Burmy" "Burmy Plant Cloak"
    $Res = Replace-Name $Res "Wormadam" "Wormadam Plant Cloak"
    $Res = Replace-Name $Res "Shellos" "Shellos West"
    $Res = Replace-Name $Res "Gastrodon" "Gastrodon West"

    $Res = Replace-Name $Res "Greninja Battle Bond" "Greninja (Ash)"
    $Res = Replace-Name $Res "Greninja Battle Bond (Not Available)" "Greninja (Ash) (Not Available)"

    $Res = Replace-Name $Res "Vivillon" "Vivillon Meadow"

    $Res = Replace-Name $Res "Flabébé" "Flabébé Red"
    $Res = Replace-Name $Res "Floette" "Floette Red"
    $Res = Replace-Name $Res "Florges" "Florges Red"

    $Res = Replace-Name $Res "Furfrou" "Furfrou Natural"
    $Res = Replace-Name $Res "Furfrou Deputante Trim" "Furfrou Debutante Trim"
    $Res = Replace-Name $Res "Furfrou Deputante Trim (Not Available)" "Furfrou Debutante Trim (Not Available)"

    $Res = Replace-Name $Res "Hoopa Hoopa Unbound" "Hoopa Unbound"
    $Res = Replace-Name $Res "Hoopa Hoopa Unbound (Not Available)" "Hoopa Unbound (Not Available)"

    $Res = Replace-Name $Res "Oricorio" "Oricorio Baile"
    $Res = Replace-Name $Res "Minior" "Minior Red Core"
    $Res = Replace-Name $Res "Lycanroc" "Lycanroc Midday"
    $Res = Replace-Name $Res "Alcremie" "Alcremie Vanilla Cream"

    return $Res
}

foreach($SelectedDiv in $Divs) 
{
    $PokeResults = New-Object System.Collections.ArrayList

    $PokeTDs = $SelectedDiv.getElementsByTagName("td") | ? { $_.ClassName -eq "pkmn" }
    foreach($Poke in $PokeTDs) 
    {
        $Link = $Poke.getElementsByTagName("a")[0]
        $Img = $Poke.getElementsByTagName("img")[0]
        $PokeName = $Img.title.Replace("Forme", "Form")
        $PokeName = Get-Name $PokeName

        if($Banned.Contains($PokeName)) { continue }

        $SplitSrc = $Img.src.Split("/")
        $Png = $SplitSrc[$SplitSrc.Length - 1].Replace(".png", "")
        $PokeNum = -1
        $Form = ""

        if($Png -ne "blank")
        {
            $PngSplit = $Png.Split("-")
            $PokeNum = [int]::Parse($PngSplit[0])
            if($PngSplit.Length -gt 1) 
            {
                $Form = $PngSplit[1]
            }
        }

        $Alias = Get-Alias $PokeName $Form


        if($Alias.StartsWith("alcremi")) 
        {
            if($Form.EndsWith("berry")) 
            { 
                $Alias += "-berry" 
                $PokeName += " (Berry)"
            }
            elseif($Form.EndsWith("love")) 
            { 
                $Alias += "-love" 
                $PokeName += " (Love)"
            }
            elseif($Form.EndsWith("star")) 
            { 
                $Alias += "-star" 
                $PokeName += " (Star)"
            }
            elseif($Form.EndsWith("clover")) 
            { 
                $Alias += "-clover" 
                $PokeName += " (Clover)"
            }
            elseif($Form.EndsWith("flower")) 
            { 
                $Alias += "-flower" 
                $PokeName += " (Flower)"
            }
            elseif($Form.EndsWith("ribbon")) 
            { 
                $PokeName += " (Ribbon)"
                $Alias += "-ribbon" 
            }
            else 
            { 
                $Alias += "-strawberry" 
                $PokeName += " (Strawberry)"
            }
        }
        
        if($PokeName -eq "Sneasel (Female)" -and $Form -eq "h") 
        {
            $PokeName = "Hisuian " + $PokeName
            $Alias = Get-Alias $PokeName
        }

        # Temp code to help with alias cleanup
        if($PokeName.ToLower().StartsWith("unown") `
            -or $PokeName.ToLower().StartsWith("vivillon")) 
        {
            $Form = ""
        }

        $Result = [PSCustomObject]@{
            Num = $PokeNum
            Name = $PokeName
            Alias = $Alias
            SerebiiLink = "$SerebiiBase/" + $Link.pathname
            #Form = $Form
        }
        [void]$PokeResults.Add($Result)
    }

    # Split monsters into boxes
    $Boxes = New-Object System.Collections.ArrayList
    $Page = 1
    $PageSize = 30
    do 
    {
        $Skip = ($Page - 1) * $PageSize
        $PokesForBox = $PokeResults | Select-Object -Skip $Skip -First $PageSize

        if($PokesForBox.Count -eq 0) 
        {
            break
        }
        [void]$Boxes.Add(
            [PSCustomObject]@{
                Num = $Page
                Monsters = $PokesForBox
            }
        )

        $Page += 1
    } while($true)


    $TextInfo = [System.Globalization.CultureInfo]::new("en-US", $false).TextInfo
    $Dex = [PSCustomObject]@{
        Id = $SelectedDiv.id
        Name = $TextInfo.ToTitleCase($SelectedDiv.id)
        Count = ($PokeResults | ? { $_.Num -gt 0 }).Count    
        Boxes = $Boxes.ToArray()
    }



    $OutFileJSON = [System.IO.Path]::Combine($OutputDir, $SelectedDiv.id + ".json")
    ConvertTo-Json $Dex -Compress -Depth 10 | Out-File $OutFileJSON -Encoding utf8 -Force 
    
    if($Test) 
    {
        $OutFileCSV = [System.IO.Path]::Combine($OutputDir, $SelectedDiv.id + ".csv")
        $PokeResults | Export-Csv $OutFileCSV -Encoding utf8 -NoTypeInformation -Force

        $OutFileHTML = [System.IO.Path]::Combine($OutputDir, $SelectedDiv.id + ".html")
        $HTML = Get-TestHTML $PokeResults $SelectedDiv.id
        $HTML | Out-File $OutFileHTML
    }

    Write-Host ($SelectedDiv.id + " - " + $PokeResults.Count + " pokes")
}