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
        Write-Host Hello $script:iosResourcesDirectoryName
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

        $image2 = $image.Substring(0, $image.Length - 4) + "@2x.png"
        if (Test-Path $image2)
        {
            Copy-Item $image2 $script:iosResourcesDirectoryName
            Write-Host Copied $image2 to $script:iosResourcesDirectoryName
        }
        else
        {
            Write-Host "Did not find $image2"
        }

        $image3 = $image.Substring(0, $image.Length - 4) + "@3x.png"
        if (Test-Path $image3)
        {
            Copy-Item $image3 $script:iosResourcesDirectoryName
            Write-Host Copied $image3 to $script:iosResourcesDirectoryName
        }
        else
        {
            Write-Host "Did not find $image3"
        }
    }
}

$parametersOk = Process-Parameters
if ($parametersOk)
{
    Copy-Images
}
else
{
    exit 1
}
