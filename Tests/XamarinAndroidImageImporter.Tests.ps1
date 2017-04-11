Describe "XamarinAndroidImageImporter" {
    Import-Module $PSScriptRoot\..\XamarinImageImporter\XamarinAndroidImageImporter.psm1

    Context "Test-Parameters" {
        BeforeEach {
            Copy-Item .\Sandbox\Solution\Sandbox\Sandbox.Android $TestDrive -Recurse
            $csproj = Join-Path $TestDrive Sandbox.Android | Join-Path -ChildPath Sandbox.Android.csproj
            $image = Copy-ImageAndRename ".\Sandbox\Images\filter_all_bluehdpi.png" (Join-Path $TestDrive Sandbox.Android | Join-Path -ChildPath Resources | Join-Path -ChildPath drawable-hdpi) filter_all_blue.png 6>$null
        }
        AfterEach {
            Remove-Item (Join-Path $TestDrive Sandbox.Android) -Recurse
        }
        It "Should not allow *.jpg" {
            (Add-XamarinAndroidImage image.jpg $csproj 2>&1 | Measure-Object -Line).Lines | Should Be 1
        }
        It "Should not allow *.gif" {
            (Add-XamarinAndroidImage image.gif $csproj 2>&1 | Measure-Object -Line).Lines | Should Be 1
        }
        It "Should not allow *.csproj that is not found" {
            (Add-XamarinAndroidImage $image Sandbox.Android.csproj 2>&1 | Measure-Object -Line).Lines | Should Be 1
        }
        It "Should not allow projects that are not *.csproj" {
            (Add-XamarinAndroidImage $image (Join-Path $TestDrive Sandbox.Android | Join-Path -ChildPath packages.config) 2>&1 | Measure-Object -Line).Lines | Should Be 1
        }
    }

    Context "Add-XamarinAndroidImage" {
        BeforeEach {
            Copy-Item .\Sandbox\Solution\Sandbox\Sandbox.Android $TestDrive -Recurse
            $csproj = Join-Path $TestDrive Sandbox.Android | Join-Path -ChildPath Sandbox.Android.csproj
            Copy-Item ".\Sandbox\Images\filter_all_blue*" $TestDrive
        }
        AfterEach {
            Remove-Item (Join-Path $TestDrive Sandbox.Android) -Recurse
        }
        It "Should silently ignore images not found" {
            (Add-XamarinAndroidImage image.png $csproj 6>&1 4>$null | Measure-Object -Line).Lines | Should Be 0
            (Add-XamarinAndroidImage image.png $csproj 6>$null 4>&1 | Measure-Object -Line).Lines | Should Be 0
        }
        It "Should write to the verbose stream when the image is not found and the verbose switch is on" {
            (Add-XamarinAndroidImage image.png $csproj -Verbose 6>&1 4>$null | Measure-Object -Line).Lines | Should Be 0
            ((Add-XamarinAndroidImage image.png $csproj -Verbose 6>$null) 4>&1 | Measure-Object -Line).Lines | Should Be 6
        }
        It "Should write to the verbose stream when the directory is not found and the verbose switch is on" {
            $androidFolder = Split-Path $csproj -Parent
            Remove-Item (Join-Path $androidFolder Resources | Join-Path -ChildPath drawable-hdpi) -Recurse
            Remove-Item (Join-Path $androidFolder Resources | Join-Path -ChildPath drawable-xhdpi) -Recurse
            Remove-Item (Join-Path $androidFolder Resources | Join-Path -ChildPath drawable-xxhdpi) -Recurse
            (Add-XamarinAndroidImage (Join-Path $TestDrive filter_all_blue.png) $csproj -Verbose 6>&1 4>$null | Measure-Object -Line).Lines | Should Be 0
            ((Add-XamarinAndroidImage (Join-Path $TestDrive filter_all_blue.png) $csproj -Verbose 6>$null) 4>&1 | Measure-Object -Line).Lines | Should Be 6
        }
        It "Should write to the information stream for each image copied and added to the project" {
            $androidFolder = Split-Path $csproj -Parent
            New-Item -Path (Join-Path $androidFolder Resources) -Name drawable-ldpi -ItemType Directory
            New-Item -Path (Join-Path $androidFolder Resources) -Name drawable-mdpi -ItemType Directory
            New-Item -Path (Join-Path $androidFolder Resources) -Name drawable-xxxhdpi -ItemType Directory
            $info = Add-XamarinAndroidImage (Join-Path $TestDrive filter_all_blue.png) $csproj -Verbose 6>&1 4>&1
            ($info | Measure-Object -Line).Lines | Should Be 12
            ($info | Where-Object { $_.ToString().StartsWith("Copied") } | Measure-Object -Line).Lines | Should Be 6
            ($info | Where-Object { $_.ToString().StartsWith("Added") } | Measure-Object -Line).Lines | Should Be 6
        }
    }
}
