Import-Module .\XamarinIosImageImporter.psm1
Import-Module .\XamarinAndroidImageImporter.psm1

function Add-XamarinImages()
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=1)]
        [string]$images,

        [Parameter(Mandatory=$False)]
        [string]$iosProject,

        [Parameter(Mandatory=$False)]
        [string]$iosResources,
	
        [Parameter(Mandatory=$False)]
        [string]$androidProject,

        [Parameter(Mandatory=$False)]
        [string]$androidResources,

        [Parameter()]
        [switch]$move
    )

    if ([string]::IsNullOrEmpty($iosProject) -And [string]::IsNullOrEmpty($androidProject))
    {
        Write-Error "No `$iosProject or `$androidProject"
        return
    }
    elseif ((![string]::IsNullOrEmpty($iosProject)) -And (!(Test-Path $iosProject)))
    {
        Write-Error "Did not find $iosProject"
        return
    }
    elseif ((![string]::IsNullOrEmpty($androidProject)) -And (!(Test-Path $androidProject)))
    {
        Write-Error "Did not find $androidProject"
        return
    }

    $imagesPath = $images + "\*"
    $done = @{}

    Get-ChildItem $imagesPath -Include *.png -Exclude *@2x.png, *@3x.png, *dpi.png |
    Foreach-Object {
        if (![string]::IsNullOrEmpty($iosProject))
        {
            Add-XamarinIosImage $_ $iosProject -iosResources $iosResources -move:$move -Verbose:($PSBoundParameters['Verbose'] -eq $True)
        }
        if (![string]::IsNullOrEmpty($androidProject))
        {
            Add-XamarinAndroidImage $_ $androidProject -androidResources $androidResources -move:$move -Verbose:($PSBoundParameters['Verbose'] -eq $True)
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
                Add-XamarinAndroidImage (Join-Path $_.Directory $filename) $androidProject -androidResources $androidResources -move:$move -Verbose:($PSBoundParameters['Verbose'] -eq $True)
                $done.Add($filename, $filename)
            }
        }
    }
}
