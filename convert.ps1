# convert flac files to mp3s for a given folder

# example: 
# D:\utils\flac-mp3.ps1 'D:\music2\Metallica\Hardwired To Self-Destruct'
param([string] $flacPath)

# https://xiph.org/flac/download.html
$flac = "C:\Users\Connor\FLAC\flac-1.3.2-win\win64\flac.exe"
$meta = "C:\Users\Connor\FLAC\flac-1.3.2-win\win64\metaflac.exe"

# http://lame.sourceforge.net/links.php#Binaries
# http://www.rarewares.org/mp3-lame-bundle.php
$lame = "C:\lame.exe"

function Get-Tag
{
    param([string] $meta, [string] $FlacName, [string] $tagName)
    # tags: http://help.mp3tag.de/main_tags.html
    
    [string] $cmd = "$meta --show-tag=$tagName `"$FlacName`""
    (Invoke-Expression $cmd) -Replace "$tagName=", ""
}

$tmp = "temp.wav"
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

        $Artist=Get-Tag $meta $FlacName "ARTIST"
        $Album=Get-Tag $meta $FlacName "ALBUM"
        $Year=Get-Tag $meta $FlacName "DATE"
        $Genre=Get-Tag $meta $FlacName "GENRE"
        
        $DiscNum=Get-Tag $meta $FlacName "DISCNUMBER"
        $DiscNum += "/"
        $DiscNum += Get-Tag $meta $FlacName "DISCTOTAL"
        
        $TrackNum=Get-Tag $meta $FlacName "TRACKNUMBER"
        $TrackNum += "/"
        $TrackNum += Get-Tag $meta $FlacName "TRACKTOTAL"

        $Mp3Name = $_.BaseName + ".mp3"

        $flacCmd = "$flac -s -d `"$FlacName`" -o $tmp"
        Write-Host $flacCmd
        Invoke-Expression $flacCmd

        # TODO: tag validation
        $lameCmd = "$lame --silent -m j -b 320 --tt `"$Title`" --ta `"$Artist`" --tl `"$Album`" --ty `"$Year`" --tg `"$Genre`" --tn `"$TrackNum`" --tv `"TPOS=$DiscNum`" --add-id3v2 --ignore-tag-errors `"$tmp`" `"$Mp3Name`""
        Write-Host $lameCmd
        Invoke-Expression $lameCmd

        Remove-Item $tmp
    }

Write-Host "`n`n`t\m/"