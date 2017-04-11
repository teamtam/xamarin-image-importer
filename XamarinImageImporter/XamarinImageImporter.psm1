<#
 .Synopsis
  Copies images with multiple resolutions into correct locations and imports them to Xamarin iOS/Android projects.

 .Description
  Copies .png images into the corresponding Resources directory of Xamarin.iOS and Xamarin.Android projects and
  imports them to the .csproj project files so it will be available when viewed in Visual/Xamarin Studio. If they
  exist, *@2x.png or *@3x.png variants of the image will be imported for iOS, while *ldpi.png, *mdpi.png, *hdpi.png,
  *xhdpi.png, *xxhdpi.png and *xxxhdpi.png will be imported for Android.

 .Parameter Images
  The path to import all .png images from.

 .Parameter IosProject
  The .csproj of the Xamarin.iOS project to import the image(s) into.

 .Parameter AndroidProject
  The .csproj of the Xamarin.Android project to import the image(s) into.

 .Parameter Move
  Moves instead of copies the source image(s).

 .Parameter Verbose
  Shows additional output in the verbose stream of attempts to process an image that did not complete.

 .Example
  # Run for iOS only.
  Add-XamarinImages C:\Images -IosProject C:\Source\MyProject.iOS\MyProject.iOS.csproj

  # Run for Android only.
  Add-XamarinImages C:\Images -AndroidProject C:\Source\MyProject.Droid\MyProject.Droid.csproj

 .Example
  # Run for both iOS and Android with all optional parameters.
  Add-XamarinImages -Images C:\Images -IosProject C:\Source\MyProject.iOS\MyProject.iOS.csproj -AndroidProject C:\Source\MyProject.Droid\MyProject.Droid.csproj -Move -Verbose
#>
function Add-XamarinImages()
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=1)]
        [string]$Images,

        [Parameter(Mandatory=$False)]
        [string]$IosProject,

        [Parameter(Mandatory=$False)]
        [string]$AndroidProject,

        [Parameter()]
        [switch]$Move
    )

    if ([string]::IsNullOrEmpty($IosProject) -And [string]::IsNullOrEmpty($AndroidProject))
    {
        Write-Error "No `$IosProject or `$AndroidProject"
        return
    }
    elseif ((![string]::IsNullOrEmpty($IosProject)) -And (!(Test-Path $IosProject)))
    {
        Write-Error "Did not find $IosProject"
        return
    }
    elseif ((![string]::IsNullOrEmpty($AndroidProject)) -And (!(Test-Path $AndroidProject)))
    {
        Write-Error "Did not find $AndroidProject"
        return
    }

    $imagesPath = $images + "\*"
    $done = @{}

    Get-ChildItem $imagesPath -Include *.png -Exclude *@2x.png, *@3x.png, *dpi.png |
    Foreach-Object {
        if (![string]::IsNullOrEmpty($IosProject))
        {
            Add-XamarinIosImage $_ $IosProject -Move:$Move -Verbose:($PSBoundParameters['Verbose'] -eq $True)
        }
        if (![string]::IsNullOrEmpty($AndroidProject))
        {
            Add-XamarinAndroidImage $_ $AndroidProject -Move:$Move -Verbose:($PSBoundParameters['Verbose'] -eq $True)
        }
        $done.Add($_.BaseName + $_.Extension, $_.BaseName + $_.Extension)
    }

    if (![string]::IsNullOrEmpty($AndroidProject))
    {
        Get-ChildItem $imagesPath -Include *dpi.png |
        Foreach-Object {
            if ($_.BaseName.EndsWith("xxxhdpi"))
            {
                $filename = $_.BaseName.Substring(0, $_.BaseName.Length - 7) + $_.Extension
            }
            elseif ($_.BaseName.EndsWith("xxhdpi"))
            {
                $filename = $_.BaseName.Substring(0, $_.BaseName.Length - 6) + $_.Extension
            }
            elseif ($_.BaseName.EndsWith("xhdpi"))
            {
                $filename = $_.BaseName.Substring(0, $_.BaseName.Length - 5) + $_.Extension
            }
            else
            {
                $filename = $_.BaseName.Substring(0, $_.BaseName.Length - 4) + $_.Extension
            }
            if (!$done.ContainsKey($filename))
            {
                Add-XamarinAndroidImage (Join-Path $_.Directory $filename) $AndroidProject -Move:$Move -Verbose:($PSBoundParameters['Verbose'] -eq $True)
                $done.Add($filename, $filename)
            }
        }
    }
}
