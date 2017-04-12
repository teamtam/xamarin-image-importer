$iosResourcesDirectory = ""
$iosImage1 = $Image
$iosImage2 = ""
$iosImage3 = ""

function Copy-ImagesToResources()
{
    [CmdletBinding()]
    Param(
        [Parameter()]
        [switch]$Move
    )

    $script:iosImage1 = Copy-Image $Image $iosResourcesDirectory -Move:$Move -Verbose:($PSBoundParameters['Verbose'] -eq $True)

    $script:iosImage2 = $Image.Substring(0, $Image.Length - 4) + "@2x.png"
    $script:iosImage2 = Copy-Image $iosImage2 $iosResourcesDirectory -Move:$Move -Verbose:($PSBoundParameters['Verbose'] -eq $True)

    $script:iosImage3 = $Image.Substring(0, $Image.Length - 4) + "@3x.png"
    $script:iosImage3 = Copy-Image $iosImage3 $iosResourcesDirectory -Move:$Move -Verbose:($PSBoundParameters['Verbose'] -eq $True)
}

function Add-ImagesToProject()
{
    $projectXml = [xml](Get-Content $IosProject)
    $nsmgr = Get-XmlNamespaceManager $projectXml
    $itemGroup = Get-BundleResourceItemGroup $projectXml $nsmgr

    Add-BundleResource $projectXml $nsmgr $itemGroup $iosImage1 $IosProject
    if ((![string]::IsNullOrEmpty($iosImage2)) -and (Test-Path $iosImage2))
    {
        Add-BundleResource $projectXml $nsmgr $itemGroup $iosImage2 $IosProject
    }
    if ((![string]::IsNullOrEmpty($iosImage3)) -and (Test-Path $iosImage3))
    {
        Add-BundleResource $projectXml $nsmgr $itemGroup $iosImage3 $IosProject
    }

    $projectXml.Save($IosProject)
}

<#
 .Synopsis
  Copies images with multiple resolutions into correct locations and imports them to a Xamarin.iOS project.

 .Description
  Copies a .png image into the Resources directory of a Xamarin.iOS project and imports them to the .csproj
  project file so it will be available when viewed in Visual/Xamarin Studio. If *@2x.png or *@3x.png variants
  of the image exist, these will be imported as well.

 .Parameter Image
  The .png image to process.

 .Parameter IosProject
  The .csproj of the Xamarin.iOS project to import the image(s) into.

 .Parameter Move
  Moves instead of copies the source image(s).

 .Parameter Verbose
  Shows additional output in the verbose stream of attempts to process an image that did not complete.

 .Example
  # Run with minimal parameters.
  Add-XamarinIosImage C:\Images\logo.png C:\Source\MyProject.iOS\MyProject.iOS.csproj

 .Example
  # Run with all optional parameters.
  Add-XamarinIosImage -Image C:\Images\logo.png -IosProject C:\Source\MyProject.iOS\MyProject.iOS.csproj -Move -Verbose
#>
function Add-XamarinIosImage()
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=1)]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [ValidatePattern("[^\s]+(\.(?i)(png))$")]
        [string]$Image,
	
        [Parameter(Mandatory=$True, Position=2)]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [ValidatePattern("[^\s]+(\.(?i)(csproj))$")]
        [string]$IosProject,

        [Parameter()]
        [switch]$Move
    )

    $iosProjectDirectory = Get-Item (Get-Item $IosProject).DirectoryName
    $script:iosResourcesDirectory = Join-Path $iosProjectDirectory.ToString() "Resources"
    Copy-ImagesToResources -Move:$Move -Verbose:($PSBoundParameters['Verbose'] -eq $True)
    Add-ImagesToProject
}
