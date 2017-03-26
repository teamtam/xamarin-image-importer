function Get-Filename([string]$filenameWithPath)
{
    $filenameIndex = $filenameWithPath.LastIndexOf("\") + 1
    $filenameWithPath.Substring($filenameIndex)
}

function Copy-Image([string]$source, [string]$destination, [bool]$move)
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

function Copy-ImageAndRename([string]$source, [string]$destination, [string]$renameTo, [bool]$move)
{
    if ($move)
    {
        Move-Item $source $destination -Force
        Move-Item ($destination + "\" + (Get-Filename $source)) ($destination + "\" + $renameTo) -Force
        Write-Output "Moved $($source) to $($destination)"
    }
    else
    {
        Copy-Item $source $destination
        Move-Item ($destination + "\" + (Get-Filename $source)) ($destination + "\" + $renameTo) -Force
        Write-Output "Copied $($source) to $($destination)"
    }
}

Export-ModuleMember -Function 'Get-Filename'
Export-ModuleMember -Function 'Copy-Image'
Export-ModuleMember -Function 'Copy-ImageAndRename'
