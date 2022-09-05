$CurrentDir = (pwd).Path
$DataDir = [System.IO.Path]::Combine($CurrentDir, "data")

# Find all poke data
$Files = Get-ChildItem $DataDir -File -Filter "*.json" | Select-Object -ExpandProperty FullName

foreach($F in $Files) 
{
    # Get aliases from data
    $Type = [System.IO.Path]::GetFileNameWithoutExtension($F)
    $Content = Get-Content $F | ConvertFrom-Json
    $Aliases = $Content | Select-Object -ExpandProperty Alias -Unique

    # Find all images in folder
    $ImgPath = [System.IO.Path]::Combine($CurrentDir, "sprites/home", $Type)
    $ImagePaths = Get-ChildItem $ImgPath -Filter "*.png" | Select-Object -ExpandProperty FullName
    foreach($ImagePath in $ImagePaths) 
    {
        $ImageName = [System.IO.Path]::GetFileNameWithoutExtension($ImagePath)
        if($Aliases.Contains($ImageName) -eq $false) 
        {
            write-host "Removing: $ImageName"
            Remove-Item $ImagePath -Force
        }
    }
}


