[string]$script:iosResourcesDirectoryName = $IosResources
[string]$script:iosImage1 = $Image
[string]$script:iosImage2 = ""
[string]$script:iosImage3 = ""

function Test-Parameters()
{
    $parametersOk = $True

    if (!(Test-Path $Image))
    {
        $parametersOk = $False
        Write-Error "Did not find $Image"
    }
    if (!($Image.EndsWith(".png")))
    {
        $parametersOk = $False
        Write-Error "$Image is not a .png"
    }

    if (!(Test-Path $IosProject))
    {
        $parametersOk = $False
        Write-Error "Did not find $IosProject"
    }
    if (!($IosProject.EndsWith(".csproj")))
    {
        $parametersOk = $False
        Write-Error "$IosProject is not a .csproj"
    }

    if (!([string]::IsNullOrEmpty($IosResources)))
    {
        if (!(Test-Path $IosResources))
        {
            $parametersOk = $False
            Write-Error "Did not find $IosResources"
        }
    }
    elseif (Test-Path $IosProject)
    {
        $iosProjectDirectory = Get-Item (Get-Item $IosProject).DirectoryName
        $script:iosResourcesDirectoryName = Join-Path $iosProjectDirectory.ToString() "Resources"
    }

    return $parametersOk
}

function Copy-ImagesToResources()
{
    [CmdletBinding()]
    Param(
        [Parameter()]
        [switch]$Move
    )

    $script:iosImage1 = Copy-Image $Image $script:iosResourcesDirectoryName -Move:$Move -Verbose:($PSBoundParameters['Verbose'] -eq $True)

    $script:iosImage2 = $Image.Substring(0, $Image.Length - 4) + "@2x.png"
    $script:iosImage2 = Copy-Image $script:iosImage2 $script:iosResourcesDirectoryName -Move:$Move -Verbose:($PSBoundParameters['Verbose'] -eq $True)

    $script:iosImage3 = $Image.Substring(0, $Image.Length - 4) + "@3x.png"
    $script:iosImage3 = Copy-Image $script:iosImage3 $script:iosResourcesDirectoryName -Move:$Move -Verbose:($PSBoundParameters['Verbose'] -eq $True)
}

function Add-ImagesToProject()
{
    $projectXml = [xml](Get-Content $IosProject)

    $nsmgr = Get-XmlNamespace $projectXml

    #$itemGroup = Get-BundleResourceItemGroup $projectXml $nsmgr
    #Write-Debug $itemGroup.GetType()
    $firstItemGroupNode = $projectXml.SelectNodes("//a:BundleResource", $nsmgr)[1]
    if ($firstItemGroupNode)
    {
        $itemGroup = $firstItemGroupNode.ParentNode
    }
    else
    {
        $itemGroup = $projectXml.CreateElement("ItemGroup", $xmlns)
        $x = $projectXml.Project.AppendChild($itemGroup)
    }

    Add-BundleResource $projectXml $nsmgr $itemGroup $script:iosImage1 $IosProject
    if (Test-Path $script:iosImage2)
    {
        Add-BundleResource $projectXml $nsmgr $itemGroup $script:iosImage2 $IosProject
    }
    if (Test-Path $script:iosImage3)
    {
        Add-BundleResource $projectXml $nsmgr $itemGroup $script:iosImage3 $IosProject
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

 .Parameter IosResources
  If the Resources folder is not in a default location relative to the .csproj file, this can be specified.

 .Parameter Move
  Moves instead of copies the source image(s).

 .Parameter Verbose
  Shows additional output in the verbose stream of attempts to process an image that did not complete.

 .Example
  # Run with minimal parameters.
  Add-XamarinIosImage C:\Images\logo.png C:\Source\MyProject.iOS\MyProject.iOS.csproj

 .Example
  # Run with all optional parameters.
  Add-XamarinIosImage -Image C:\Images\logo.png -IosProject C:\Source\MyProject.iOS\MyProject.iOS.csproj -IosResources C:\Source\MyProject.iOS\Resources -Move -Verbose
#>
function Add-XamarinIosImage()
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=1)]
        [string]$Image,
	
        [Parameter(Mandatory=$True, Position=2)]
        [string]$IosProject,

        [Parameter(Mandatory=$False)]
        [string]$IosResources,

        [Parameter()]
        [switch]$Move
    )

    $parametersOk = Test-Parameters
    if ($parametersOk)
    {
        Copy-ImagesToResources -Move:$Move -Verbose:($PSBoundParameters['Verbose'] -eq $True)
        Add-ImagesToProject
    }
}
