[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$image,
	
    [Parameter(Mandatory=$True)]
    [string]$androidProject,

    [Parameter(Mandatory=$False)]
    [string]$androidResources,

    [Parameter(Mandatory=$False)]
    [bool]$move = $False
)

[string]$script:androidResourcesDirectoryName = $androidResources
[string]$script:androidImageL = ""
[string]$script:androidImageM = ""
[string]$script:androidImageH = ""
[string]$script:androidImageX1 = ""
[string]$script:androidImageX2 = ""
[string]$script:androidImageX3 = ""

function Load-Parameters()
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
        $script:androidResourcesDirectoryName = $androidProjectDirectory.ToString() + "\Resources"
    }

    return $parametersOk
}

function Copy-ImagesToResources()
{
    $script:androidImageL = $image.Substring(0, $image.Length - 4) + "ldpi.png"
    $androidDirectoryL = $androidResourcesDirectoryName + "\drawable-ldpi"
    if (Test-Path $androidDirectoryL)
    {
        if (Test-Path $script:androidImageL)
        {
            Copy-ImageAndRename $script:androidImageL $androidDirectoryL $image $move
            $script:androidImageL = $androidDirectoryL + "\" + (Get-Filename $image)
        }
        else
        {
            Write-Output "Did not find $script:androidImageL"
        }
    }
    else
    {
        Write-Output "Did not find $androidDirectoryL"
    }

    $script:androidImageM = $image.Substring(0, $image.Length - 4) + "mdpi.png"
    $androidDirectoryM = $androidResourcesDirectoryName + "\drawable-mdpi"
    if (Test-Path $androidDirectoryM)
    {
        if (Test-Path $script:androidImageM)
        {
            Copy-ImageAndRename $script:androidImageM $androidDirectoryM $image $move
            $script:androidImageM = $androidDirectoryM + "\" + (Get-Filename $image)
        }
        else
        {
            Write-Output "Did not find $script:androidImageM"
        }
    }
    else
    {
        Write-Output "Did not find $androidDirectoryM"
    }

    $script:androidImageH = $image.Substring(0, $image.Length - 4) + "hdpi.png"
    $androidDirectoryH = $androidResourcesDirectoryName + "\drawable-hdpi"
    if (Test-Path $androidDirectoryH)
    {
        if (Test-Path $script:androidImageH)
        {
            Copy-ImageAndRename $script:androidImageH $androidDirectoryH $image $move
            $script:androidImageH = $androidDirectoryH + "\" + (Get-Filename $image)
        }
        else
        {
            Write-Output "Did not find $script:androidImageH"
        }
    }
    else
    {
        Write-Output "Did not find $androidDirectoryH"
    }

    $script:androidImageX1 = $image.Substring(0, $image.Length - 4) + "xhdpi.png"
    $androidDirectoryX1 = $androidResourcesDirectoryName + "\drawable-xhdpi"
    if (Test-Path $androidDirectoryX1)
    {
        if (Test-Path $script:androidImageX1)
        {
            Copy-ImageAndRename $script:androidImageX1 $androidDirectoryX1 $image $move
            $script:androidImageX1 = $androidDirectoryX1 + "\" + (Get-Filename $image)
        }
        else
        {
            Write-Output "Did not find $script:androidImageX1"
        }
    }
    else
    {
        Write-Output "Did not find $androidDirectoryX1"
    }

    $script:androidImageX2 = $image.Substring(0, $image.Length - 4) + "xxhdpi.png"
    $androidDirectoryX2 = $androidResourcesDirectoryName + "\drawable-xxhdpi"
    if (Test-Path $androidDirectoryX2)
    {
        if (Test-Path $script:androidImageX2)
        {
            Copy-ImageAndRename $script:androidImageX2 $androidDirectoryX2 $image $move
            $script:androidImageX2 = $androidDirectoryX2 + "\" + (Get-Filename $image)
        }
        else
        {
            Write-Output "Did not find $script:androidImageX2"
        }
    }
    else
    {
        Write-Output "Did not find $androidDirectoryX2"
    }

    $script:androidImageX3 = $image.Substring(0, $image.Length - 4) + "xxxhdpi.png"
    $androidDirectoryX3 = $androidResourcesDirectoryName + "\drawable-xxxhdpi"
    if (Test-Path $androidDirectoryX3)
    {
        if (Test-Path $script:androidImageX3)
        {
            Copy-ImageAndRename $script:androidImageX3 $androidDirectoryX3 $image $move
            $script:androidImageX3 = $androidDirectoryX3 + "\" + (Get-Filename $image)
        }
        else
        {
            Write-Output "Did not find $script:androidImageX3"
        }
    }
    else
    {
        Write-Output "Did not find $androidDirectoryX3"
    }
}

function Add-ImagesToProject()
{
    $projectXml = [xml](Get-Content $androidProject)

    $nsmgr = Load-Namespace $projectXml

    #$itemGroup = Get-BundleResourceItemGroup $projectXml $nsmgr
    #Write-Host $itemGroup.GetType()
    $itemGroupXPath = "//a:AndroidResource"
    $firstItemGroupNode = $projectXml.SelectNodes($itemGroupXPath, $nsmgr)[1]
    [System.Xml.XmlElement]$itemGroup
    if ($firstItemGroupNode)
    {
        $itemGroup = $firstItemGroupNode.ParentNode
    }
    else
    {
        $itemGroup = $projectXml.CreateElement("ItemGroup", $xmlns)
        $x = $projectXml.Project.AppendChild($itemGroup)
    }

    if (Test-Path $script:androidImageL)
    {
        Add-AndroidResource $projectXml $nsmgr $itemGroup $script:androidImageL $androidProject
    }
    if (Test-Path $script:androidImageM)
    {
        Add-AndroidResource $projectXml $nsmgr $itemGroup $script:androidImageM $androidProject
    }
    if (Test-Path $script:androidImageH)
    {
        Add-AndroidResource $projectXml $nsmgr $itemGroup $script:androidImageH $androidProject
    }
    if (Test-Path $script:androidImageX1)
    {
        Add-AndroidResource $projectXml $nsmgr $itemGroup $script:androidImageX1 $androidProject
    }
    if (Test-Path $script:androidImageX2)
    {
        Add-AndroidResource $projectXml $nsmgr $itemGroup $script:androidImageX2 $androidProject
    }
    if (Test-Path $script:androidImageX3)
    {
        Add-AndroidResource $projectXml $nsmgr $itemGroup $script:androidImageX3 $androidProject
    }

    $projectXml.Save($androidProject)
}

. .\FileSystem.ps1
. .\Project.ps1
#Import-Module -Name .\'FileSystem.psm1' -Verbose
#Import-Module -Name .\'Project.psm1' -Verbose

$parametersOk = Load-Parameters
if ($parametersOk)
{
    Copy-ImagesToResources
    Add-ImagesToProject
}
else
{
    exit 1
}
