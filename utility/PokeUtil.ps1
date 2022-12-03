function Set-PokeNameConditional([ref]$Name, $ToReplace, $ReplaceWith) {
    if($Name.Value -eq $ToReplace) {
        $Name.Value = $ReplaceWith
    }
}

function Update-String([ref]$Str, $Replace, $ReplaceWith) {
    $Str.Value = $Str.Value.Replace($Replace, $ReplaceWith)
}

function Rename-PokeAliasRegion([ref]$Alias, $Region) 
{
    $Res = $Alias.Value
    if($Res.StartsWith("$Region-")) {
        $Res = $Res.Replace("$Region-", "")
        if($Res.EndsWith("-f")) {
            $Res = $Res.Replace("-f", "-$Region-f").Trim()
        } else {
            $Res = $Res + "-$Region".Trim()
        }
    }

    $Alias.Value = $Res
}

function Set-PokeNameAndAlias([ref]$Name, [ref]$Alias, $Form) {

    $NameRes = $Name.Value

    #region Clean up the name first

    if($NameRes.EndsWith(" Rotom")) {
        $NameRes = $NameRes.Substring(0, $NameRes.Length - 5).Trim()
    }

    Update-String ([ref]$NameRes) "Forme" "Form"

    Set-PokeNameConditional ([ref]$NameRes) "Pikachu Partner Cap" "Pikachu Johto Cap"
    Set-PokeNameConditional ([ref]$NameRes) "Unown" "Unown A"
    Set-PokeNameConditional ([ref]$NameRes) "Burmy" "Burmy Plant Cloak"
    Set-PokeNameConditional ([ref]$NameRes) "Wormadam" "Wormadam Plant Cloak"
    Set-PokeNameConditional ([ref]$NameRes) "Shellos" "Shellos West"
    Set-PokeNameConditional ([ref]$NameRes) "Gastrodon" "Gastrodon West"
    Set-PokeNameConditional ([ref]$NameRes) "Greninja Battle Bond" "Greninja (Ash)"
    Set-PokeNameConditional ([ref]$NameRes) "Greninja Battle Bond (Not Available)" "Greninja (Ash) (Not Available)"
    Set-PokeNameConditional ([ref]$NameRes) "Vivillon" "Vivillon Meadow"
    Set-PokeNameConditional ([ref]$NameRes) "Flabébé" "Flabébé Red"
    Set-PokeNameConditional ([ref]$NameRes) "Floette" "Floette Red"
    Set-PokeNameConditional ([ref]$NameRes) "Florges" "Florges Red"
    Set-PokeNameConditional ([ref]$NameRes) "Furfrou" "Furfrou Natural"
    Set-PokeNameConditional ([ref]$NameRes) "Furfrou Deputante Trim" "Furfrou Debutante Trim"
    Set-PokeNameConditional ([ref]$NameRes) "Furfrou Deputante Trim (Not Available)" "Furfrou Debutante Trim (Not Available)"
    Set-PokeNameConditional ([ref]$NameRes) "Hoopa Hoopa Unbound" "Hoopa Unbound"
    Set-PokeNameConditional ([ref]$NameRes) "Hoopa Hoopa Unbound (Not Available)" "Hoopa Unbound (Not Available)"
    Set-PokeNameConditional ([ref]$NameRes) "Oricorio" "Oricorio Baile"
    Set-PokeNameConditional ([ref]$NameRes) "Minior" "Minior Red Core"
    Set-PokeNameConditional ([ref]$NameRes) "Lycanroc" "Lycanroc Midday"
    Set-PokeNameConditional ([ref]$NameRes) "Alcremie" "Alcremie Vanilla Cream"

    #endregion

    
    $AliasRes = $NameRes.ToLower().Replace(" ", "-")

    #region Clean up the alias

    Update-String ([ref]$AliasRes) "(female)" "f"
    Update-String ([ref]$AliasRes) "female" "f"
    Update-String ([ref]$AliasRes) "pattern" ""
    Update-String ([ref]$AliasRes) "-forme" ""
    Update-String ([ref]$AliasRes) "-form" ""
    Update-String ([ref]$AliasRes) "♀" "-f"
    Update-String ([ref]$AliasRes) "♂" ""
    Update-String ([ref]$AliasRes) "farfetch'd" "farfetchd"
    Update-String ([ref]$AliasRes) "mr." "mr"
    Update-String ([ref]$AliasRes) "!" "em"
    Update-String ([ref]$AliasRes) "?" "qm"
    Update-String ([ref]$AliasRes) "-cloak" ""
    Update-String ([ref]$AliasRes) "-sea" ""
    Update-String ([ref]$AliasRes) "jr." "jr"
    Update-String ([ref]$AliasRes) "(ash)" "ash"
    Update-String ([ref]$AliasRes) "é" "e"
    Update-String ([ref]$AliasRes) "-flower" ""
    Update-String ([ref]$AliasRes) "-trim" ""
    Update-String ([ref]$AliasRes) "%" ""
    Update-String ([ref]$AliasRes) "-style" ""
    Update-String ([ref]$AliasRes) "'" ""
    Update-String ([ref]$AliasRes) ":" ""
    Update-String ([ref]$AliasRes) "-color" ""
    Update-String ([ref]$AliasRes) "-(not-available)" ""
    Update-String ([ref]$AliasRes) "(" ""
    Update-String ([ref]$AliasRes) ")" ""

    Rename-PokeAliasRegion ([ref]$AliasRes) "alolan"
    Rename-PokeAliasRegion ([ref]$AliasRes) "galarian"
    Rename-PokeAliasRegion ([ref]$AliasRes) "hisuian"
    Rename-PokeAliasRegion ([ref]$AliasRes) "paldean"

    #endregion

    #region Conditional cleanup

    if($AliasRes.StartsWith("alcremi")) {
        if($Form.EndsWith("berry")) { 
            $AliasRes += "-berry" 
            $NameRes += " (Berry)"
        } elseif($Form.EndsWith("love")) { 
            $AliasRes += "-love" 
            $NameRes += " (Love)"
        } elseif($Form.EndsWith("star")) { 
            $AliasRes += "-star" 
            $NameRes += " (Star)"
        } elseif($Form.EndsWith("clover")) { 
            $AliasRes += "-clover" 
            $NameRes += " (Clover)"
        } elseif($Form.EndsWith("flower")) { 
            $AliasRes += "-flower" 
            $NameRes += " (Flower)"
        } elseif($Form.EndsWith("ribbon")) { 
            $AliasRes += "-ribbon" 
            $NameRes += " (Ribbon)"
        } else { 
            $AliasRes += "-strawberry" 
            $NameRes += " (Strawberry)"
        }
    }

    if($NameRes -eq "Sneasel (Female)" -and $Form -eq "h") {
        $NameRes = "Hisuian $NameRes"
        $AliasRes = $NameRes.ToLower().Replace(" ", "-")
        Update-String ([ref]$AliasRes) "(female)" "f"
        Rename-PokeAliasRegion ([ref]$AliasRes) "hisuian"
    }

    if($NameRes -eq "Unown A") {
        $AliasRes = $NameRes.ToLower().Replace(" ", "-")
    }

    if($AliasRes.EndsWith("-")) {
        $AliasRes = $AliasRes.Substring(0, $AliasRes.Length - 1)
    }

    #endregion


    $Name.Value = $NameRes
    $Alias.Value = $AliasRes
}
