[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$images,

    [Parameter(Mandatory=$False)]
    [string]$iosProject,

    [Parameter(Mandatory=$False)]
    [string]$iosResources,
	
    [Parameter(Mandatory=$False)]
    [string]$androidProject,

    [Parameter(Mandatory=$False)]
    [string]$androidResources,

    [Parameter(Mandatory=$False)]
    [bool]$move = $False
)

if ([string]::IsNullOrEmpty($iosProject) -And [string]::IsNullOrEmpty($androidProject))
{
    Write-Error "No `$iosProject or `$androidProject"
    exit 1
}
elseif ((![string]::IsNullOrEmpty($iosProject)) -And (!(Test-Path $iosProject)))
{
    Write-Error "Did not find $iosProject"
    exit 1
}
elseif ((![string]::IsNullOrEmpty($androidProject)) -And (!(Test-Path $androidProject)))
{
    Write-Error "Did not find $androidProject"
    exit 1
}

$imagesPath = $images + "\*"
$done = @{}

Get-ChildItem $imagesPath -Include *.png -Exclude *@2x.png, *@3x.png, *dpi.png |
Foreach-Object {
    if (![string]::IsNullOrEmpty($iosProject))
    {
        . .\Add-XamarinIosImage.ps1 $_ $iosProject $iosResources $move
    }
    if (![string]::IsNullOrEmpty($androidProject))
    {
        . .\Add-XamarinAndroidImage.ps1 $_ $androidProject $androidResources $move
    }
    $done.Add($_, $_)
}

if (![string]::IsNullOrEmpty($androidProject))
{
    Get-ChildItem $imagesPath -Include *dpi.png |
    Foreach-Object {
        if ($_.BaseName.EndsWith("xxxhdpi"))
        {
            $filename = $_.BaseName.Substring(0, $_.BaseName.Length - 7) + ".png"
        }
        elseif ($_.BaseName.EndsWith("xxhdpi"))
        {
            $filename = $_.BaseName.Substring(0, $_.BaseName.Length - 6) + ".png"
        }
        elseif ($_.BaseName.EndsWith("xhdpi"))
        {
            $filename = $_.BaseName.Substring(0, $_.BaseName.Length - 5) + ".png"
        }
        else
        {
            $filename = $_.BaseName.Substring(0, $_.BaseName.Length - 4) + ".png"
        }
        if (!$done.ContainsKey($filename))
        {
            . .\Add-XamarinAndroidImage.ps1 $filename $androidProject $androidResources $move
            $done.Add($filename, $filename)
        }
    }
}
