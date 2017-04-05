Describe "FileSystemHelper" {
    Import-Module $PSScriptRoot\..\XamarinImageImporter\FileSystemHelper.psd1

    Context "Get-Filename" {
        It "Returns the filename when there is a full path" {
            #$true | Should Be $false
            Get-Filename C:\Images\image.png | Should be 'image.png' 
        }
    }

    Context "Copy-Image" {
        It "Returns the filename when there is a full path" {
            $true | Should Be $false
        }
    }

    Context "Copy-ImageAndRename" {
        It "Returns the filename when there is a full path" {
            $true | Should Be $false
        }
    }
}
