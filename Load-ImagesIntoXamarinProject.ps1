[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$images,

    [Parameter(Mandatory=$False)]
    [string]$iosProject,

    [Parameter(Mandatory=$False)]
    [string]$iosResources,
	
    [Parameter(Mandatory=$False)]
    [string]$androidProject,

    [Parameter(Mandatory=$False)]
    [string]$androidResources,

    [Parameter(Mandatory=$False)]
    [bool]$move = $False
)

if ([string]::IsNullOrEmpty($iosProject) -And [string]::IsNullOrEmpty($androidProject))
{
    Write-Error "No `$iosProject or `$androidProject"
    exit 1
}
elseif ((![string]::IsNullOrEmpty($iosProject)) -And (!(Test-Path $iosProject)))
{
    Write-Error "Did not find $iosProject"
    exit 1
}
elseif ((![string]::IsNullOrEmpty($androidProject)) -And (!(Test-Path $androidProject)))
{
    Write-Error "Did not find $androidProject"
    exit 1
}

$imagesPath = $images + "\*"
Get-ChildItem $imagesPath -Include *.png -Exclude *@2x.png, *@3x.png, *dpi.png | 
Foreach-Object {
    $content = Get-Content $_.FullName
    if (![string]::IsNullOrEmpty($iosProject))
    {
        . .\Load-ImageIntoIosProject.ps1 $_ $iosProject $iosResources $move
    }
    if (![string]::IsNullOrEmpty($androidProject))
    {
        . .\Load-ImageIntoAndroidProject.ps1 $_ $androidProject $androidResources $move
    }
}
