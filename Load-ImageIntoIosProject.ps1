[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$image,
	
    [Parameter(Mandatory=$True)]
    [string]$iosProject,

    [Parameter(Mandatory=$False)]
    [string]$iosResources,

    [Parameter(Mandatory=$False)]
    [bool]$move = $False
)

[string]$script:iosResourcesDirectoryName = $iosResources
[string]$script:image2 = ""
[string]$script:image3 = ""

function Process-Parameters()
{
    $parametersOk = $True

    if (!(Test-Path $image))
    {
        $parametersOk = $False
        Write-Error "Did not find $image"
    }
    if (!($image.EndsWith(".png")))
    {
        $parametersOk = $False
        Write-Error "$image is not a .png"
    }

    if (!(Test-Path $iosProject))
    {
        $parametersOk = $False
        Write-Error "Did not find $iosProject"
    }
    if (!($iosProject.EndsWith(".csproj")))
    {
        $parametersOk = $False
        Write-Error "$iosProject is not a .csproj"
    }

    if (!([string]::IsNullOrEmpty($iosResources)))
    {
        if (!(Test-Path $iosResources))
        {
            $parametersOk = $False
            Write-Error "Did not find $iosResources"
        }
    }
    elseif (Test-Path $iosProject)
    {
        $iosProjectDirectory = Get-Item (Get-Item $iosProject).DirectoryName
        $script:iosResourcesDirectoryName = $iosProjectDirectory.ToString() + "\Resources"
    }

    return $parametersOk
}

function Get-Filename([string]$filenameWithPath)
{
    $filenameIndex = $filenameWithPath.LastIndexOf("\") + 1
    return $filenameWithPath.Substring($filenameIndex)
}

function Copy-Image([string]$source, [string]$destination)
{
    if ($move)
    {
        Move-Item $source $destination -Force
        Write-Output "Moved $($source) to $($destination)"
    }
    else
    {
        Copy-Item $source $destination
        Write-Output "Copied $($source) to $($destination)"
    }
}

function Copy-ImagesToResources()
{
    Copy-Image $image $script:iosResourcesDirectoryName

    $script:image2 = $image.Substring(0, $image.Length - 4) + "@2x.png"
    if (Test-Path $script:image2)
    {
        Copy-Image $script:image2 $script:iosResourcesDirectoryName
        $script:image2 = $script:iosResourcesDirectoryName + "\" + (Get-Filename $script:image2)
    }
    else
    {
        Write-Output "Did not find $script:image2"
    }

    $script:image3 = $image.Substring(0, $image.Length - 4) + "@3x.png"
    if (Test-Path $script:image3)
    {
        Copy-Image $script:image3 $script:iosResourcesDirectoryName
        $script:image3 = $script:iosResourcesDirectoryName + "\" + (Get-Filename $script:image3)
    }
    else
    {
        Write-Output "Did not find $script:image3"
    }
}

function Add-ImagesToProject()
{
    $projectXml = [xml](Get-Content $iosProject)

    $filename = "Resources\" + (Get-Filename $image)
    if (Test-Path $script:image2)
    {
        $filename2 = "Resources\" + (Get-Filename $script:image2)
    }
    if (Test-Path $script:image3)
    {
        $filename3 = "Resources\" + (Get-Filename $script:image3)
    }

    $xmlns = "http://schemas.microsoft.com/developer/msbuild/2003"
    [System.Xml.XmlNamespaceManager] $nsmgr = $projectXml.NameTable
    $nsmgr.AddNamespace('a', $xmlns)

    $itemGroupXPath = [string]::Format("//a:BundleResource")
    $firstItemGroupNode = $projectXml.SelectNodes($itemGroupXPath, $nsmgr)[1]
    [System.Xml.XmlDocument] $itemGroup
    if ($firstItemGroupNode)
    {
        $itemGroup = $firstItemGroupNode.ParentNode
    }
    else
    {
        $itemGroup = $projectXml.CreateElement("ItemGroup", $xmlns);
        $x = $projectXml.Project.AppendChild($itemGroup);
    }

    // TODO: refactor
    $xPath = [string]::Format("//a:BundleResource[@Include='{0}']", $filename)
    $node = $projectXml.SelectSingleNode($xPath, $nsmgr)
    if (!$node)
    {
        $bundleResource = $projectXml.CreateElement("BundleResource", $xmlns);
        $bundleResource.SetAttribute("Include", $filename);
        $x = $itemGroup.AppendChild($bundleResource)
        Write-Output "Added $(Get-Filename $filename) to $($iosProject)"
    }

    if (Test-Path $script:image2)
    {
        $xPath2 = [string]::Format("//a:BundleResource[@Include='{0}']", $filename2)
        $node2 = $projectXml.SelectSingleNode($xPath2, $nsmgr)
        if (!$node2)
        {
            $bundleResource2 = $projectXml.CreateElement("BundleResource", $xmlns);
            $bundleResource2.SetAttribute("Include", $filename2);
            $x = $itemGroup.AppendChild($bundleResource2)
            Write-Output "Added $(Get-Filename $script:image2) to $($iosProject)"
        }
    }

    if (Test-Path $script:image3)
    {
        $xPath3 = [string]::Format("//a:BundleResource[@Include='{0}']", $filename3)
        $node3 = $projectXml.SelectSingleNode($xPath3, $nsmgr)
        if (!$node3)
        {
            $bundleResource3 = $projectXml.CreateElement("BundleResource", $xmlns);
            $bundleResource3.SetAttribute("Include", $filename3);
            $x = $itemGroup.AppendChild($bundleResource3)
            Write-Output "Added $(Get-Filename $script:image3) to $($iosProject)"
        }
    }

    $projectXml.Save($iosProject)
}

$parametersOk = Process-Parameters
if ($parametersOk)
{
    Copy-ImagesToResources
    Add-ImagesToProject
}
else
{
    exit 1
}
