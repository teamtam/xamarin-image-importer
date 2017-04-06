Describe "FileSystemHelper" {
    Import-Module $PSScriptRoot\..\XamarinImageImporter\FileSystemHelper.psd1

    Context "Get-Filename" {
        It "Should return the filename when there is a full path" {
            Get-Filename C:\Images\image.png | Should be 'image.png' 
        }
    }

    Context "Copy-Image with -Verbose" {
        It "Should write to the verbose stream when the source cannot be found and the verbose switch is on" {
            (Copy-Image C:\Qwertyuiop\Asdfghjkl.png $TestDrive -Verbose 4>&1 | Measure-Object -Line).Lines | Should Be 1
        }
        It "Should not write to the verbose stream when the source cannot be found and the verbose switch is off" {
            (Copy-Image C:\Qwertyuiop\Asdfghjkl.png $TestDrive 4>&1 | Measure-Object -Line).Lines | Should Be 0
        }
        It "Should write to the verbose stream when the destination cannot be found and the verbose switch is on" {
            (Copy-Image .\Sandbox\Images\filter_all_blue.png C:\Qwertyuiop -Verbose 4>&1 | Measure-Object -Line).Lines | Should Be 1
        }
        It "Should not write to the verbose stream when the destination cannot be found and the verbose switch is off" {
            (Copy-Image .\Sandbox\Images\filter_all_blue.png C:\Qwertyuiop 4>&1 | Measure-Object -Line).Lines | Should Be 0
        }
    }

    Context "Copy-Image with -Move" {
        BeforeEach {
            New-Item (Join-Path $TestDrive Something) -ItemType Directory
            $Source = (Copy-Image .\Sandbox\Images\filter_all_blue.png $TestDrive) 6>$null
        }
        AfterEach {
            Remove-Item (Join-Path $TestDrive Something) -Recurse
        }
        It "Should remove the source file when the move switch is on" {
            (Copy-Image $Source (Join-Path $TestDrive Something) -Move) 6>$null
            Test-Path $Source | Should Be $false
        }
        It "Should be a file at the destination when the move switch is on" {
            (Copy-Image $Source (Join-Path $TestDrive Something) -Move) 6>$null
            Test-Path (Join-Path $TestDrive Something | Join-Path -ChildPath filter_all_blue.png) | Should Be $true
        }
        It "Should write to the information stream when a move operation occurs" {
            ((Copy-Image $Source (Join-Path $TestDrive Something) -Move) 6>&1 | Measure-Object -Line).Lines | Should Be 2
        }
        It "Should return the new filename with the path when a move operation occurs" {
            (Copy-Image $Source (Join-Path $TestDrive Something) -Move) 6>$null | Should BeLike "*filter_all_blue.png"
        }
    }

    Context "Copy-Image without -Move" {
        It "Should not remove the source file when the move switch is omitted" {
            (Copy-Image .\Sandbox\Images\filter_all_blue.png $TestDrive) 6>$null
            Test-Path .\Sandbox\Images\filter_all_blue.png | Should Be $true
        }
        It "Should be a file at the destination when the move switch is omitted" {
            (Copy-Image .\Sandbox\Images\filter_all_blue.png $TestDrive) 6>$null
            Test-Path (Join-Path $TestDrive filter_all_blue.png) | Should Be $true
        }
        It "Should write to the information stream when a copy operation occurs" {
            ((Copy-Image .\Sandbox\Images\filter_all_blue.png $TestDrive) 6>&1 | Measure-Object -Line).Lines | Should Be 2
        }
        It "Should return the new filename with the path when a copy operation occurs" {
            (Copy-Image .\Sandbox\Images\filter_all_blue.png $TestDrive) 6>$null| Should BeLike "*filter_all_blue.png"
        }
    }

    Context "Copy-ImageAndRename with -Verbose" {
        It "Should write to the verbose stream when the source cannot be found and the verbose switch is on" {
            (Copy-ImageAndRename C:\Qwertyuiop\Asdfghjkl.png $TestDrive image.png -Verbose 4>&1 | Measure-Object -Line).Lines | Should Be 1
        }
        It "Should not write to the verbose stream when the source cannot be found and the verbose switch is off" {
            (Copy-ImageAndRename C:\Qwertyuiop\Asdfghjkl.png $TestDrive image.png 4>&1 | Measure-Object -Line).Lines | Should Be 0
        }
        It "Should write to the verbose stream when the destination cannot be found and the verbose switch is on" {
            (Copy-ImageAndRename .\Sandbox\Images\filter_all_blue.png C:\Qwertyuiop image.png -Verbose 4>&1 | Measure-Object -Line).Lines | Should Be 1
        }
        It "Should not write to the verbose stream when the destination cannot be found and the verbose switch is off" {
            (Copy-ImageAndRename .\Sandbox\Images\filter_all_blue.png C:\Qwertyuiop image.png 4>&1 | Measure-Object -Line).Lines | Should Be 0
        }
    }

    Context "Copy-ImageAndRename with -Move" {
        BeforeEach {
            New-Item (Join-Path $TestDrive Something) -ItemType Directory
            $Source = (Copy-Image .\Sandbox\Images\filter_all_blue.png $TestDrive) 6>$null
        }
        AfterEach {
            Remove-Item (Join-Path $TestDrive Something) -Recurse
        }
        It "Should remove the source file when the move switch is on" {
            (Copy-ImageAndRename $Source (Join-Path $TestDrive Something) image.png -Move) 6>$null
            Test-Path $Source | Should Be $false
        }
        It "Should be a renamed file at the destination when the move switch is on" {
            (Copy-ImageAndRename $Source (Join-Path $TestDrive Something) image.png -Move) 6>$null
            Test-Path (Join-Path $TestDrive Something | Join-Path -ChildPath filter_all_blue.png) | Should Be $false
            Test-Path (Join-Path $TestDrive Something | Join-Path -ChildPath image.png) | Should Be $true
        }
        It "Should write to the information stream when a move operation occurs" {
            ((Copy-ImageAndRename $Source (Join-Path $TestDrive Something) image.png -Move) 6>&1 | Measure-Object -Line).Lines | Should Be 2
        }
        It "Should return the new filename with the path when a move operation occurs" {
            (Copy-ImageAndRename $Source (Join-Path $TestDrive Something) image.png -Move) 6>$null | Should BeLike "*image.png"
        }
    }

    Context "Copy-ImageAndRename without -Move" {
        It "Should not remove the source file when the move switch is omitted" {
            (Copy-ImageAndRename .\Sandbox\Images\filter_all_blue.png $TestDrive image.png) 6>$null
            Test-Path .\Sandbox\Images\filter_all_blue.png | Should Be $true
        }
        It "Should be a renamed file at the destination when the move switch is omitted" {
            (Copy-ImageAndRename .\Sandbox\Images\filter_all_blue.png $TestDrive image.png) 6>$null
            Test-Path (Join-Path $TestDrive filter_all_blue.png) | Should Be $false
            Test-Path (Join-Path $TestDrive image.png) | Should Be $true
        }
        It "Should write to the information stream when a copy operation occurs" {
            ((Copy-ImageAndRename .\Sandbox\Images\filter_all_blue.png $TestDrive image.png) 6>&1 | Measure-Object -Line).Lines | Should Be 2
        }
        It "Should return the new filename with the path when a copy operation occurs" {
            (Copy-ImageAndRename .\Sandbox\Images\filter_all_blue.png $TestDrive image.png) 6>$null | Should BeLike "*image.png"
        }
    }
}
