Import-Module .\XamarinIosImageImporter.psm1
Import-Module .\XamarinAndroidImageImporter.psm1

<#
 .Synopsis
  Copies images with multiple resolutions into correct locations and imports them to Xamarin iOS/Android projects.

 .Description
  Copies .png images into the corresponding Resources directory of Xamarin.iOS and Xamarin.Android projects and
  imports them to the .csproj project files so it will be available when viewed in Visual/Xamarin Studio. If they
  exist, @2x.png or @3x.png variants of the image will be imported for iOS, and *ldpi.png, *mdpi.png, *hdpi.png,
  *xhdpi.png, *xxhdpi.png and *xxxhdpi.png will be imported for Android.

 .Parameter images
  The path to import all .png images from.

 .Parameter iosProject
  The .csproj of the Xamarin.iOS project to import the image(s) into.

 .Parameter iosResources
  If the Resources folder is not in a default location relative to the .csproj file, this can be specified.

 .Parameter androidProject
  The .csproj of the Xamarin.Android project to import the image(s) into.

 .Parameter androidResources
  If the Resources folder is not in a default location relative to the .csproj file, this can be specified.

 .Parameter move
  Moves instead of copies the source image(s).

 .Parameter verbose
  Shows additional output in the verbose stream of attempts to process an image that did not complete.

 .Example
  # Run for iOS only.
  Add-XamarinImages C:\Images -iosProject C:\Source\MyProject.iOS\MyProject.iOS.csproj

  # Run for Android only.
  Add-XamarinImages C:\Images -androidProject C:\Source\MyProject.Droid\MyProject.Droid.csproj

 .Example
  # Run for both iOS and Android with all optional parameters.
  Add-XamarinImages -images C:\Images -iosProject C:\Source\MyProject.iOS\MyProject.iOS.csproj -iosResources C:\Source\MyProject.iOS\Resources -androidProject C:\Source\MyProject.Droid\MyProject.Droid.csproj -androidResources C:\Source\MyProject.Droid\Resources -move -Verbose
#>
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
