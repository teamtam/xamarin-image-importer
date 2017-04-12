Describe "XamarinIosImageImporter" {
    Import-Module $PSScriptRoot\..\XamarinImageImporter\XamarinIosImageImporter.psd1

    Context "Test-Parameters" {
        BeforeEach {
            Copy-Item .\Sandbox\Solution\Sandbox\Sandbox.iOS $TestDrive -Recurse
            $csproj = Join-Path $TestDrive Sandbox.iOS | Join-Path -ChildPath Sandbox.iOS.csproj
            $image = Copy-Image ".\Sandbox\Images\filter_all_blue.png" (Join-Path $TestDrive Sandbox.iOS | Join-Path -ChildPath Resources) 6>$null
        }
        AfterEach {
            Remove-Item (Join-Path $TestDrive Sandbox.iOS) -Recurse
        }
        It "Should not allow an image that is not found" {
            { Add-XamarinIosImage image.png $csproj } | Should Throw
        }
        It "Should not allow *.csproj that is not found" {
            { Add-XamarinIosImage $image Sandbox.iOS.csproj } | Should Throw
        }
        It "Should not allow projects that are not *.csproj" {
            { Add-XamarinIosImage $image (Join-Path $TestDrive Sandbox.iOS | Join-Path -ChildPath packages.config) } | Should Throw
        }
    }

    Context "Add-XamarinIosImage" {
        BeforeEach {
            Copy-Item .\Sandbox\Solution\Sandbox\Sandbox.iOS $TestDrive -Recurse
            $csproj = Join-Path $TestDrive Sandbox.iOS | Join-Path -ChildPath Sandbox.iOS.csproj
            Copy-Item ".\Sandbox\Images\filter_all_blue*" $TestDrive
            Copy-Item ".\Sandbox\Images\filter_all_white.png" $TestDrive
        }
        AfterEach {
            Remove-Item (Join-Path $TestDrive Sandbox.iOS) -Recurse
        }
        It "Should silently ignore @2x or @3x images not found" {
            (Add-XamarinIosImage (Join-Path $TestDrive filter_all_white.png) $csproj 6>&1 4>$null | Measure-Object -Line).Lines | Should Be 2
            (Add-XamarinIosImage (Join-Path $TestDrive filter_all_white.png) $csproj 6>$null 4>&1 | Measure-Object -Line).Lines | Should Be 0
        }
        It "Should write to the verbose stream when the @2x or @3x image is not found and the verbose switch is on" {
            (Add-XamarinIosImage (Join-Path $TestDrive filter_all_white.png) $csproj -Verbose 6>&1 4>$null | Measure-Object -Line).Lines | Should Be 2
            ((Add-XamarinIosImage (Join-Path $TestDrive filter_all_white.png) $csproj -Verbose 6>$null) 4>&1 | Measure-Object -Line).Lines | Should Be 2
        }
        It "Should write to the information stream for each image copied and added to the project" {
            $info = Add-XamarinIosImage (Join-Path $TestDrive filter_all_blue.png) $csproj -Verbose 6>&1 4>&1
            ($info | Measure-Object -Line).Lines | Should Be 6
            ($info | Where-Object { $_.ToString().StartsWith("Copied") } | Measure-Object -Line).Lines | Should Be 3
            ($info | Where-Object { $_.ToString().StartsWith("Added") } | Measure-Object -Line).Lines | Should Be 3
        }
    }
}
