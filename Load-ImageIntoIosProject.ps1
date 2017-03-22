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

$script:iosResourcesDirectoryName = $iosResources
$script:image2 = ""
$script:image3 = ""

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

    if (!([string]::IsNullOrEmpty($iosResourcesFolder)))
    {
        if (!(Test-Path $iosResourcesFolder))
        {
            $parametersOk = $False
            Write-Error "Did not find $iosResourcesFolder"
        }
    }
    elseif (Test-Path $iosProject)
    {
        $iosProjectDirectory = Get-Item (Get-Item $iosProject).DirectoryName
        $script:iosResourcesDirectoryName = $iosProjectDirectory.ToString() + "\Resources"
    }

    return $parametersOk
}

function Copy-Images()
{
    if ($move)
    {
        Move-Item $image $script:iosResourcesDirectoryName
        Write-Host Moved $image to $script:iosResourcesDirectoryName
    }
    else
    {
        Copy-Item $image $script:iosResourcesDirectoryName
        Write-Host Copied $image to $script:iosResourcesDirectoryName

        $script:image2 = $image.Substring(0, $image.Length - 4) + "@2x.png"
        if (Test-Path $script:image2)
        {
            Copy-Item $script:image2 $script:iosResourcesDirectoryName
            Write-Host Copied $script:image2 to $script:iosResourcesDirectoryName
        }
        else
        {
            Write-Host "Did not find $script:image2"
        }

        $script:image3 = $image.Substring(0, $image.Length - 4) + "@3x.png"
        if (Test-Path $script:image3)
        {
            Copy-Item $script:image3 $script:iosResourcesDirectoryName
            Write-Host Copied $script:image3 to $script:iosResourcesDirectoryName
        }
        else
        {
            Write-Host "Did not find $image3"
        }
    }
}

function Add-ImagesToProject()
{
    $projectXml = [xml](Get-Content $iosProject)

    $imageFile = Get-Item $image
    $filenameIndex = $imageFile.FullName.LastIndexOf("\") + 1
    $filename = "Resources\" + $imageFile.FullName.Substring($filenameIndex)
    if (Test-Path $script:image2)
    {
        $filename2 = "Resources\" + (Get-Item $script:image2).FullName.Substring($filenameIndex)
    }
    if (Test-Path $script:image3)
    {
        $filename3 = "Resources\" + (Get-Item $script:image3).FullName.Substring($filenameIndex)
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
        $projectXml.Project.AppendChild($itemGroup);
    }

    $xPath = [string]::Format("//a:BundleResource[@Include='{0}']", $filename)
    $node = $projectXml.SelectSingleNode($xPath, $nsmgr)
    if (!$node)
    {
        $bundleResource = $projectXml.CreateElement("BundleResource", $xmlns);
        $bundleResource.SetAttribute("Include", $filename);
        $itemGroup.AppendChild($bundleResource)
    }

    if (Test-Path $script:image2)
    {
        $xPath2 = [string]::Format("//a:BundleResource[@Include='{0}']", $filename2)
        $node2 = $projectXml.SelectSingleNode($xPath2, $nsmgr)
        if (!$node2)
        {
            $bundleResource2 = $projectXml.CreateElement("BundleResource", $xmlns);
            $bundleResource2.SetAttribute("Include", $filename2);
            $itemGroup.AppendChild($bundleResource2)
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
            $itemGroup.AppendChild($bundleResource3)
        }
    }

    $projectXml.Save($iosProject)
}

$parametersOk = Process-Parameters
if ($parametersOk)
{
    Copy-Images
    Add-ImagesToProject
}
else
{
    exit 1
}
