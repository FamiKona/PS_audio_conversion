# convert flac files to mp3s for a given folder

# example: 
# D:\utils\flac-mp3.ps1 'D:\music2\Metallica\Hardwired To Self-Destruct'
param([string] $flacPath)

# https://xiph.org/flac/download.html
# $flac = "C:\Users\Connor\FLAC\flac-1.3.2-win\win64\flac.exe"
$meta = "C:\Users\Connor\FLAC\flac-1.3.2-win\win64\metaflac.exe"

# http://lame.sourceforge.net/links.php#Binaries
# http://www.rarewares.org/mp3-lame-bundle.php
# $lame = "C:\lame.exe"

function Get-Tag
{
    param([string] $meta, [string] $FlacName, [string] $tagName)
    # tags: http://help.mp3tag.de/main_tags.html
    
    [string] $cmd = "$meta --show-tag=$tagName `"$FlacName`""
    (Invoke-Expression $cmd) -Replace "$tagName=", ""
}

$counter = 0
Get-ChildItem -Path "$flacPath" *.flac | 
    ForEach-Object {
        $counter += 1
        Write-Host --------------------------------
        Write-Host $counter 
        $FlacName=$_.FullName

        Write-Host $FlacName

        Write-Host -NoNewline "Title: "
        $Title=Get-Tag $meta $FlacName "TITLE"
        Write-Host "$Title"

        # Artist tag could be used later
        # $Artist=Get-Tag $meta $FlacName "ARTIST"
        $Album=Get-Tag $meta $FlacName "ALBUM"
        $Year=Get-Tag $meta $FlacName "DATE"
        $sYear=$Year.split('-')[0]
        
        # Unused for now, could be of use later
        # $DiscNum=Get-Tag $meta $FlacName "DISCNUMBER"
        # $DiscNum += "/"
        # $DiscNum += Get-Tag $meta $FlacName "DISCTOTAL"
        
        # Unused for now, could be of use later
        # $TrackNum=Get-Tag $meta $FlacName "TRACKNUMBER"
        # $TrackNum += "/"
        # $TrackNum += Get-Tag $meta $FlacName "TRACKTOTAL"

        
        $UpperFolder = "../[$sYear] - $Album [320]/"
        if (!(Test-Path -LiteralPath $UpperFolder))
        {
            mkdir $UpperFolder
        }
        $Mp3Name = $UpperFolder + $_.BaseName + ".mp3"


        $convCmd = "ffmpeg -loglevel warning -vsync 0 -i `"$flacName`" -ab 320k -map_metadata 0 -id3v2_version 3 `"$Mp3Name`""
        Write-Host $convCmd
        Invoke-Expression $convCmd

    }

Write-Host "`n`n`t\m/"