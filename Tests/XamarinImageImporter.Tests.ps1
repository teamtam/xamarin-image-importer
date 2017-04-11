Describe "XamarinImagesImporter" {
    Import-Module $PSScriptRoot\..\XamarinImageImporter\XamarinImageImporter.psm1

    Context "Test-Parameters" {
        It "Should not allow both iOS and Android *.csproj to be omitted" {
            (Add-XamarinImages $TestDrive 2>&1 | Measure-Object -Line).Lines | Should Be 1
        }
        It "Should not allow an iOS *.csproj that is not found" {
            (Add-XamarinImages $TestDrive -IosProject (Join-Path $TestDrive "Sandbox.iOS.csproj") 2>&1 | Measure-Object -Line).Lines | Should Be 1
        }
        It "Should not allow an Android *.csproj that is not found" {
            (Add-XamarinImages $TestDrive -AndroidProject (Join-Path $TestDrive "Sandbox.Android.csproj") 2>&1 | Measure-Object -Line).Lines | Should Be 1
        }
    }

    Context "Add-XamarinImages" {
        BeforeEach {
            Copy-Item .\Sandbox\Solution\Sandbox\Sandbox.iOS $TestDrive -Recurse
            $iosProject = Join-Path $TestDrive Sandbox.iOS | Join-Path -ChildPath Sandbox.iOS.csproj
            Copy-Item .\Sandbox\Solution\Sandbox\Sandbox.Android $TestDrive -Recurse
            $androidProject = Join-Path $TestDrive Sandbox.Android | Join-Path -ChildPath Sandbox.Android.csproj
        }
        AfterEach {
            Remove-Item (Join-Path $TestDrive Sandbox.iOS) -Recurse
            Remove-Item (Join-Path $TestDrive Sandbox.Android) -Recurse
        }
        It "Should silently ignore images or directories not found" {
            (Add-XamarinImages ".\Sandbox\Images\" -IosProject $iosProject -AndroidProject $androidProject 6>&1 4>$null | Measure-Object -Line).Lines | Should BeGreaterThan 0
            (Add-XamarinImages ".\Sandbox\Images\" -IosProject $iosProject -AndroidProject $androidProject 6>$null 4>&1 | Measure-Object -Line).Lines | Should Be 0
        }
        It "Should write to the verbose stream when an image or directory is not found and the verbose switch is on" {
            (Add-XamarinImages ".\Sandbox\Images\" -IosProject $iosProject -AndroidProject $androidProject -Verbose 6>&1 4>$null | Measure-Object -Line).Lines | Should BeGreaterThan 0
            ((Add-XamarinImages ".\Sandbox\Images\" -IosProject $iosProject -AndroidProject $androidProject -Verbose 6>$null) 4>&1 | Measure-Object -Line).Lines | Should Be 33
        }
        It "Should write to the information stream for each image copied and added to the project" {
            $info = Add-XamarinImages ".\Sandbox\Images\" -IosProject $iosProject -AndroidProject $androidProject 6>&1
            ($info | Measure-Object -Line).Lines | Should Be 66
            ($info | Where-Object { $_.ToString().StartsWith("Copied") } | Measure-Object -Line).Lines | Should Be 33 # note: coincidence 33 is same as above
            ($info | Where-Object { $_.ToString().StartsWith("Added") } | Measure-Object -Line).Lines | Should Be 33 # note: coincidence 33 is same as above
        }
    }
}
