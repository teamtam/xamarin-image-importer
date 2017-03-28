Import-Module .\FileSystemHelper.psm1
Import-Module .\ProjectHelper.psm1

[string]$script:androidResourcesDirectoryName = $androidResources
[string]$script:androidImageL = ""
[string]$script:androidImageM = ""
[string]$script:androidImageH = ""
[string]$script:androidImageX1 = ""
[string]$script:androidImageX2 = ""
[string]$script:androidImageX3 = ""

function Test-Parameters()
{
    $parametersOk = $True

    if (!($image.EndsWith(".png")))
    {
        $parametersOk = $False
        Write-Error "$image is not a .png"
    }

    if (!(Test-Path $androidProject))
    {
        $parametersOk = $False
        Write-Error "Did not find $androidProject"
    }
    if (!($androidProject.EndsWith(".csproj")))
    {
        $parametersOk = $False
        Write-Error "$androidProject is not a .csproj"
    }

    if (!([string]::IsNullOrEmpty($androidResources)))
    {
        if (!(Test-Path $androidResources))
        {
            $parametersOk = $False
            Write-Error "Did not find $androidResources"
        }
    }
    elseif (Test-Path $androidProject)
    {
        $androidProjectDirectory = Get-Item (Get-Item $androidProject).DirectoryName
        $script:androidResourcesDirectoryName = Join-Path $androidProjectDirectory.ToString() "Resources"
    }

    return $parametersOk
}

function Copy-ImagesToResources()
{
    [CmdletBinding()]
    Param(
        [Parameter()]
        [switch]$move
    )

    $script:androidImageL = $image.Substring(0, $image.Length - 4) + "ldpi.png"
    $androidDirectoryL = Join-Path $androidResourcesDirectoryName "drawable-ldpi"
    $script:androidImageL = Copy-ImageAndRename $script:androidImageL $androidDirectoryL $image -move:$move -Verbose:($PSBoundParameters['Verbose'] -eq $True)

    $script:androidImageM = $image.Substring(0, $image.Length - 4) + "mdpi.png"
    $androidDirectoryM = Join-Path $androidResourcesDirectoryName "drawable-mdpi"
    $script:androidImageM = Copy-ImageAndRename $script:androidImageM $androidDirectoryM $image -move:$move -Verbose:($PSBoundParameters['Verbose'] -eq $True)

    $script:androidImageH = $image.Substring(0, $image.Length - 4) + "hdpi.png"
    $androidDirectoryH = Join-Path $androidResourcesDirectoryName "drawable-hdpi"
    $script:androidImageH = Copy-ImageAndRename $script:androidImageH $androidDirectoryH $image -move:$move -Verbose:($PSBoundParameters['Verbose'] -eq $True)

    $script:androidImageX1 = $image.Substring(0, $image.Length - 4) + "xhdpi.png"
    $androidDirectoryX1 = Join-Path $androidResourcesDirectoryName "drawable-xhdpi"
    $script:androidImageX1 = Copy-ImageAndRename $script:androidImageX1 $androidDirectoryX1 $image -move:$move -Verbose:($PSBoundParameters['Verbose'] -eq $True)

    $script:androidImageX2 = $image.Substring(0, $image.Length - 4) + "xxhdpi.png"
    $androidDirectoryX2 = Join-Path $androidResourcesDirectoryName "drawable-xxhdpi"
    $script:androidImageX2 = Copy-ImageAndRename $script:androidImageX2 $androidDirectoryX2 $image -move:$move -Verbose:($PSBoundParameters['Verbose'] -eq $True)

    $script:androidImageX3 = $image.Substring(0, $image.Length - 4) + "xxxhdpi.png"
    $androidDirectoryX3 = Join-Path $androidResourcesDirectoryName "drawable-xxxhdpi"
    $script:androidImageX3 = Copy-ImageAndRename $script:androidImageX3 $androidDirectoryX3 $image -move:$move -Verbose:($PSBoundParameters['Verbose'] -eq $True)
}

function Add-ImagesToProject()
{
    $projectXml = [xml](Get-Content $androidProject)

    $nsmgr = Get-Namespace $projectXml

    #$itemGroup = Get-AndroidResourceItemGroup $projectXml $nsmgr
    #Write-Debug $itemGroup.GetType()
    $firstItemGroupNode = $projectXml.SelectNodes("//a:AndroidResource", $nsmgr)[1]
    if ($firstItemGroupNode)
    {
        $itemGroup = $firstItemGroupNode.ParentNode
    }
    else
    {
        $itemGroup = $projectXml.CreateElement("ItemGroup", $xmlns)
        $x = $projectXml.Project.AppendChild($itemGroup)
    }

    if (!([string]::IsNullOrEmpty($script:androidImageL)))
    {
        Add-AndroidResource $projectXml $nsmgr $itemGroup $script:androidImageL $androidProject
    }
    if (!([string]::IsNullOrEmpty($script:androidImageM)))
    {
        Add-AndroidResource $projectXml $nsmgr $itemGroup $script:androidImageM $androidProject
    }
    if (!([string]::IsNullOrEmpty($script:androidImageH)))
    {
        Add-AndroidResource $projectXml $nsmgr $itemGroup $script:androidImageH $androidProject
    }
    if (!([string]::IsNullOrEmpty($script:androidImageX1)))
    {
        Add-AndroidResource $projectXml $nsmgr $itemGroup $script:androidImageX1 $androidProject
    }
    if (!([string]::IsNullOrEmpty($script:androidImageX2)))
    {
        Add-AndroidResource $projectXml $nsmgr $itemGroup $script:androidImageX2 $androidProject
    }
    if (!([string]::IsNullOrEmpty($script:androidImageX3)))
    {
        Add-AndroidResource $projectXml $nsmgr $itemGroup $script:androidImageX3 $androidProject
    }

    $projectXml.Save($androidProject)
}

<#
 .Synopsis
  Copies images with multiple resolutions into correct locations and imports them to a Xamarin.Android project.

 .Description
  Copies .png images into the correct resolution dependent Resources directory of a Xamarin.Android project and
  imports them to the .csproj project file so it will be available when viewed in Visual/Xamarin Studio. Images
  to be imported are by the convention of *ldpi.png, *mdpi.png, *hdpi.png, *xhdpi.png, *xxhdpi.png and
  *xxxhdpi.png suffixes.

 .Parameter image
  The name of the final .png in each resolution dependent Resources directory.

 .Parameter androidProject
  The .csproj of the Xamarin.Android project to import the image(s) into.

 .Parameter androidResources
  If the Resources folder is not in a default location relative to the .csproj file, this can be specified.

 .Parameter move
  Moves instead of copies the source image(s).

 .Parameter verbose
  Shows additional output in the verbose stream of attempts to process an image that did not complete.

 .Example
  # Run with minimal parameters.
  Add-XamarinAndroidImage C:\Images\logo.png C:\Source\MyProject.Droid\MyProject.Droid.csproj

 .Example
  # Run with all optional parameters.
  Add-XamarinAndroidImage -image C:\Images\logo.png -androidProject C:\Source\MyProject.Droid\MyProject.Droid.csproj -androidResources C:\Source\MyProject.Droid\Resources -move -Verbose
#>
function Add-XamarinAndroidImage()
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=1)]
        [string]$image,
	
        [Parameter(Mandatory=$True, Position=2)]
        [string]$androidProject,

        [Parameter(Mandatory=$False)]
        [string]$androidResources,

        [Parameter()]
        [switch]$move
    )

    $parametersOk = Test-Parameters
    if ($parametersOk)
    {
        Copy-ImagesToResources -move:$move -Verbose:($PSBoundParameters['Verbose'] -eq $True)
        Add-ImagesToProject
    }
}

Export-ModuleMember -Function "Add-XamarinAndroidImage"
