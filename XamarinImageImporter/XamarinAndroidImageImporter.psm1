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

    if (!($Image.EndsWith(".png")))
    {
        $parametersOk = $False
        Write-Error "$Image is not a .png"
    }

    if (!(Test-Path $AndroidProject))
    {
        $parametersOk = $False
        Write-Error "Did not find $AndroidProject"
    }
    if (!($AndroidProject.EndsWith(".csproj")))
    {
        $parametersOk = $False
        Write-Error "$AndroidProject is not a .csproj"
    }

    if (!([string]::IsNullOrEmpty($AndroidResources)))
    {
        if (!(Test-Path $AndroidResources))
        {
            $parametersOk = $False
            Write-Error "Did not find $AndroidResources"
        }
    }
    elseif (Test-Path $AndroidProject)
    {
        $androidProjectDirectory = Get-Item (Get-Item $AndroidProject).DirectoryName
        $script:androidResourcesDirectoryName = Join-Path $androidProjectDirectory.ToString() "Resources"
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

    $script:androidImageL = $Image.Substring(0, $Image.Length - 4) + "ldpi.png"
    $androidDirectoryL = Join-Path $script:androidResourcesDirectoryName "drawable-ldpi"
    $script:androidImageL = Copy-ImageAndRename $script:androidImageL $androidDirectoryL $Image -Move:$Move -Verbose:($PSBoundParameters['Verbose'] -eq $True)

    $script:androidImageM = $Image.Substring(0, $Image.Length - 4) + "mdpi.png"
    $androidDirectoryM = Join-Path $script:androidResourcesDirectoryName "drawable-mdpi"
    $script:androidImageM = Copy-ImageAndRename $script:androidImageM $androidDirectoryM $Image -Move:$Move -Verbose:($PSBoundParameters['Verbose'] -eq $True)

    $script:androidImageH = $Image.Substring(0, $Image.Length - 4) + "hdpi.png"
    $androidDirectoryH = Join-Path $script:androidResourcesDirectoryName "drawable-hdpi"
    $script:androidImageH = Copy-ImageAndRename $script:androidImageH $androidDirectoryH $Image -Move:$Move -Verbose:($PSBoundParameters['Verbose'] -eq $True)

    $script:androidImageX1 = $Image.Substring(0, $Image.Length - 4) + "xhdpi.png"
    $androidDirectoryX1 = Join-Path $script:androidResourcesDirectoryName "drawable-xhdpi"
    $script:androidImageX1 = Copy-ImageAndRename $script:androidImageX1 $androidDirectoryX1 $Image -Move:$Move -Verbose:($PSBoundParameters['Verbose'] -eq $True)

    $script:androidImageX2 = $Image.Substring(0, $Image.Length - 4) + "xxhdpi.png"
    $androidDirectoryX2 = Join-Path $script:androidResourcesDirectoryName "drawable-xxhdpi"
    $script:androidImageX2 = Copy-ImageAndRename $script:androidImageX2 $androidDirectoryX2 $Image -Move:$Move -Verbose:($PSBoundParameters['Verbose'] -eq $True)

    $script:androidImageX3 = $Image.Substring(0, $Image.Length - 4) + "xxxhdpi.png"
    $androidDirectoryX3 = Join-Path $script:androidResourcesDirectoryName "drawable-xxxhdpi"
    $script:androidImageX3 = Copy-ImageAndRename $script:androidImageX3 $androidDirectoryX3 $Image -Move:$Move -Verbose:($PSBoundParameters['Verbose'] -eq $True)
}

function Add-ImagesToProject()
{
    $projectXml = [xml](Get-Content $AndroidProject)

    $nsmgr = Get-XmlNamespaceManager $projectXml

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
        Add-AndroidResource $projectXml $nsmgr $itemGroup $script:androidImageL $AndroidProject
    }
    if (!([string]::IsNullOrEmpty($script:androidImageM)))
    {
        Add-AndroidResource $projectXml $nsmgr $itemGroup $script:androidImageM $AndroidProject
    }
    if (!([string]::IsNullOrEmpty($script:androidImageH)))
    {
        Add-AndroidResource $projectXml $nsmgr $itemGroup $script:androidImageH $AndroidProject
    }
    if (!([string]::IsNullOrEmpty($script:androidImageX1)))
    {
        Add-AndroidResource $projectXml $nsmgr $itemGroup $script:androidImageX1 $AndroidProject
    }
    if (!([string]::IsNullOrEmpty($script:androidImageX2)))
    {
        Add-AndroidResource $projectXml $nsmgr $itemGroup $script:androidImageX2 $AndroidProject
    }
    if (!([string]::IsNullOrEmpty($script:androidImageX3)))
    {
        Add-AndroidResource $projectXml $nsmgr $itemGroup $script:androidImageX3 $AndroidProject
    }

    $projectXml.Save($AndroidProject)
}

<#
 .Synopsis
  Copies images with multiple resolutions into correct locations and imports them to a Xamarin.Android project.

 .Description
  Copies .png images into the correct resolution dependent Resources directory of a Xamarin.Android project and
  imports them to the .csproj project file so it will be available when viewed in Visual/Xamarin Studio. Images
  to be imported are by the convention of *ldpi.png, *mdpi.png, *hdpi.png, *xhdpi.png, *xxhdpi.png and
  *xxxhdpi.png suffixes.

 .Parameter Image
  The name of the final .png in each resolution dependent Resources directory.

 .Parameter AndroidProject
  The .csproj of the Xamarin.Android project to import the image(s) into.

 .Parameter AndroidResources
  If the Resources folder is not in a default location relative to the .csproj file, this can be specified.

 .Parameter Move
  Moves instead of copies the source image(s).

 .Parameter Verbose
  Shows additional output in the verbose stream of attempts to process an image that did not complete.

 .Example
  # Run with minimal parameters.
  Add-XamarinAndroidImage C:\Images\logo.png C:\Source\MyProject.Droid\MyProject.Droid.csproj

 .Example
  # Run with all optional parameters.
  Add-XamarinAndroidImage -Image C:\Images\logo.png -AndroidProject C:\Source\MyProject.Droid\MyProject.Droid.csproj -AndroidResources C:\Source\MyProject.Droid\Resources -Move -Verbose
#>
function Add-XamarinAndroidImage()
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=1)]
        [string]$Image,
	
        [Parameter(Mandatory=$True, Position=2)]
        [string]$AndroidProject,

        [Parameter(Mandatory=$False)]
        [string]$AndroidResources,

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
