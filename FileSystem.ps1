function Get-Filename([string]$filenameWithPath)
{
    $filenameIndex = $filenameWithPath.LastIndexOf("\") + 1
    $filenameWithPath.Substring($filenameIndex)
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

#Export-ModuleMember -Function 'Get-Filename'
#Export-ModuleMember -Function 'Copy-Image'
