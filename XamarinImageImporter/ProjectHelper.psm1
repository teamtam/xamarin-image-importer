$script:xmlns = "http://schemas.microsoft.com/developer/msbuild/2003"

function Get-XmlNamespace([xml]$projectXml)
{
    [System.Xml.XmlNamespaceManager]$nsmgr = $projectXml.NameTable
    $nsmgr.AddNamespace("a", $xmlns)
    ,$nsmgr
}

function Get-ItemGroup([xml]$projectXml, [System.Xml.XmlNamespaceManager]$nsmgr, [string]$xPath)
{
    $firstItemGroupNode = $projectXml.SelectNodes($xPath, $nsmgr)[1]
    if ($firstItemGroupNode)
    {
        $itemGroup = $firstItemGroupNode.ParentNode
    }
    else
    {
        $itemGroup = $projectXml.CreateElement("ItemGroup", $xmlns)
        $projectXml.Project.AppendChild($itemGroup) 1>$null
    }
    ,$itemGroup
}

function Get-BundleResourceItemGroup([xml]$projectXml, [System.Xml.XmlNamespaceManager]$nsmgr)
{
    $itemGroup = Get-ItemGroup $projectXml $nsmgr "//a:BundleResource"
    ,$itemGroup
}

function Get-AndroidResourceItemGroup([xml]$projectXml, [System.Xml.XmlNamespaceManager]$nsmgr)
{
    $itemGroup = Get-ItemGroup $projectXml $nsmgr "//a:AndroidResource"
    ,$itemGroup
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
        $itemGroup.AppendChild($bundleResource) 1>$null
        Write-Information "Added $($localFilename) to $($projectName)" -InformationAction Continue
    }
}

function Add-AndroidResource([xml]$projectXml, [System.Xml.XmlNamespaceManager]$nsmgr, [System.Xml.XmlElement]$itemGroup, [string]$filename, [string]$projectName)
{
    $localFilename = $filename.Substring($filename.IndexOf("Resources\"))
    $xPath = [string]::Format("//a:AndroidResource[@Include='{0}']", $localFilename)
    $node = $projectXml.SelectSingleNode($xPath, $nsmgr)
    if (!$node)
    {
        $androidResource = $projectXml.CreateElement("AndroidResource", $xmlns);
        $androidResource.SetAttribute("Include", $localFilename);
        $itemGroup.AppendChild($androidResource) 1>$null
        Write-Information "Added $($localFilename) to $($projectName)" -InformationAction Continue
    }
}
