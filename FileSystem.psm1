function Get-Filename([string]$filenameWithPath)
{
    $filenameIndex = $filenameWithPath.LastIndexOf("\") + 1
    $filenameWithPath.Substring($filenameIndex)
}

function Copy-Image([string]$source, [string]$destination, [bool]$move)
{
    if (Test-Path $destination)
    {
        if (Test-Path $source)
        {
            if ($move)
            {
                Move-Item $source $destination -Force
                Write-Information "Moved $($source) to $($destination)" -InformationAction Continue
            }
            else
            {
                Copy-Item $source $destination
                Write-Information "Copied $($source) to $($destination)" -InformationAction Continue
            }
            $newImage = Join-Path $destination (Get-Filename $source)
            $newImage
        }
        else
        {
            Write-Verbose "Did not find $source"
        }
    }
    else
    {
        Write-Verbose "Did not find $destination"
    }
}

function Copy-ImageAndRename([string]$source, [string]$destination, [string]$renameTo, [bool]$move)
{
    if (Test-Path $destination)
    {
        if (Test-Path $source)
        {
            if ($move)
            {
                Move-Item $source $destination -Force
                Move-Item (Join-Path $destination (Get-Filename $source)) (Join-Path $destination (Get-Filename $renameTo)) -Force
                Write-Information "Moved $($source) to $($destination)" -InformationAction Continue
            }
            else
            {
                Copy-Item $source $destination
                Move-Item (Join-Path $destination (Get-Filename $source)) (Join-Path $destination (Get-Filename $renameTo)) -Force
                Write-Information "Copied $($source) to $($destination)" -InformationAction Continue
            }
            $newImage = Join-Path $destination + (Get-Filename $renameTo)
            $newImage
        }
        else
        {
            Write-Verbose "Did not find $source"
        }
    }
    else
    {
        Write-Verbose "Did not find $destination"
    }
}

Export-ModuleMember -Function 'Get-Filename'
Export-ModuleMember -Function 'Copy-Image'
Export-ModuleMember -Function 'Copy-ImageAndRename'
