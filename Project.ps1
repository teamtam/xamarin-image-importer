$xmlns = "http://schemas.microsoft.com/developer/msbuild/2003"

function Load-Namespace([xml]$projectXml)
{
    [System.Xml.XmlNamespaceManager]$nsmgr = $projectXml.NameTable
    $nsmgr.AddNamespace("a", $xmlns)
    ,$nsmgr
}

function Get-BundleResourceItemGroup([xml]$projectXml, [System.Xml.XmlNamespaceManager]$nsmgr)
{
    $itemGroupXPath = "//a:BundleResource"
    $firstItemGroupNode = $projectXml.SelectNodes($itemGroupXPath, $nsmgr)[1]
    [System.Xml.XmlDocument]$itemGroup
    if ($firstItemGroupNode)
    {
        $itemGroup = $firstItemGroupNode.ParentNode
    }
    else
    {
        $itemGroup = $projectXml.CreateElement("ItemGroup", $xmlns)
        $x = $projectXml.Project.AppendChild($itemGroup)
    }
    ,$itemGroup # Why doesn't this work?
}

function Add-BundleResource([xml]$projectXml, [System.Xml.XmlNamespaceManager]$nsmgr, [System.Xml.XmlElement]$itemGroup, [string]$filename, [string]$projectName)
{
    $localFilename = "Resources\" + (Get-Filename $filename)
    $xPath = [string]::Format("//a:BundleResource[@Include='{0}']", $localFilename)
    $node = $projectXml.SelectSingleNode($xPath, $nsmgr)
    if (!$node)
    {
        $bundleResource = $projectXml.CreateElement("BundleResource", $xmlns);
        $bundleResource.SetAttribute("Include", $localFilename);
        $x = $itemGroup.AppendChild($bundleResource)
        Write-Output "Added $(Get-Filename $localFilename) to $($projectName)"
    }
}

. .\FileSystem.ps1
#Import-Module .\'FileSystem.psm1'

#Export-ModuleMember -Function "Load-Namespace"
#Export-ModuleMember -Function "Get-BundleResourceItemGroup"
#Export-ModuleMember -Function "Add-BundleResource"
