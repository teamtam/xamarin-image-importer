function Get-Filename([string]$FilenameWithPath)
{
    Split-Path $filenameWithPath -Leaf
}

function Copy-Image()
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=1)]
        [string]$Source,

        [Parameter(Mandatory=$True, Position=2)]
        [string]$Destination,

        [Parameter()]
        [switch]$Move
    )
    if (Test-Path $Destination)
    {
        if (Test-Path $Source)
        {
            if ($Move)
            {
                Move-Item $Source $Destination -Force
                Write-Information "Moved $($Source) to $($Destination)" -InformationAction Continue
            }
            else
            {
                Copy-Item $Source $Destination
                Write-Information "Copied $($Source) to $($Destination)" -InformationAction Continue
            }
            $newImage = Join-Path $Destination (Get-Filename $Source)
            $newImage
        }
        else
        {
            Write-Verbose "Did not find $Source"
        }
    }
    else
    {
        Write-Verbose "Did not find $Destination"
    }
}

function Copy-ImageAndRename()
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=1)]
        [string]$Source,

        [Parameter(Mandatory=$True, Position=2)]
        [string]$Destination,

        [Parameter(Mandatory=$True, Position=3)]
        [string]$RenameTo,

        [Parameter()]
        [switch]$Move
    )

    if (Test-Path $Destination)
    {
        if (Test-Path $Source)
        {
            if ($Move)
            {
                Move-Item $Source $Destination -Force
                Move-Item (Join-Path $Destination (Get-Filename $Source)) (Join-Path $Destination (Get-Filename $RenameTo)) -Force
                Write-Information "Moved $($Source) to $($Destination)" -InformationAction Continue
            }
            else
            {
                Copy-Item $Source $Destination
                Move-Item (Join-Path $Destination (Get-Filename $Source)) (Join-Path $Destination (Get-Filename $RenameTo)) -Force
                Write-Information "Copied $($Source) to $($Destination)" -InformationAction Continue
            }
            $newImage = Join-Path $Destination (Get-Filename $RenameTo)
            $newImage
        }
        else
        {
            Write-Verbose "Did not find $Source"
        }
    }
    else
    {
        Write-Verbose "Did not find $Destination"
    }
}
