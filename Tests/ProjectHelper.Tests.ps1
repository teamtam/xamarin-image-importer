Describe "ProjectHelper" {
    Import-Module $PSScriptRoot\..\XamarinImageImporter\ProjectHelper.psm1

    Context "Get-XmlNamespaceManager" {
        BeforeEach {
            Copy-Item .\Sandbox\Solution\Sandbox\Sandbox.iOS $TestDrive -Recurse
            $csproj = Join-Path $TestDrive Sandbox.iOS | Join-Path -ChildPath Sandbox.iOS.csproj
            $projectXml = [xml](Get-Content $csproj)
        }
        AfterEach {
            Remove-Item (Join-Path $TestDrive Sandbox.iOS) -Recurse
        }
        It "Should return a System.Xml.XmlNamespaceManager" {
            Get-XmlNamespaceManager $projectXml | Should BeOfType System.Xml.XmlNamespaceManager
        }
    }

    Context "Get-ItemGroup" {
        BeforeEach {
            Copy-Item .\Sandbox\Solution\Sandbox\Sandbox.iOS $TestDrive -Recurse
            $csproj = Join-Path $TestDrive Sandbox.iOS | Join-Path -ChildPath Sandbox.iOS.csproj
            $projectXml = [xml](Get-Content $csproj)
            $nsmgr = Get-XmlNamespaceManager $projectXml
        }
        AfterEach {
            Remove-Item (Join-Path $TestDrive Sandbox.iOS) -Recurse
        }
        It "Should create and return an ItemGroup System.Xml.XmlElement if one is not found" {
            $itemGroupNodes = $projectXml.SelectNodes("//a:ItemGroup", $nsmgr)
            $itemGroupNodes.Count | Should BeGreaterThan 1
            $itemGroupNodes | ForEach-Object {
                $_.ParentNode.RemoveChild($_) 1>$null
            }
            $projectXml.SelectNodes("//a:ItemGroup", $nsmgr).Count | Should Be 0
            Get-ItemGroup $projectXml $nsmgr "//a:BundleResource" | Should BeOfType System.Xml.XmlElement
            $projectXml.SelectNodes("//a:ItemGroup", $nsmgr).Count | Should Be 1
        }
    }

    Context "Get-BundleResourceItemGroup" {
        BeforeEach {
            Copy-Item .\Sandbox\Solution\Sandbox\Sandbox.iOS $TestDrive -Recurse
            $csproj = Join-Path $TestDrive Sandbox.iOS | Join-Path -ChildPath Sandbox.iOS.csproj
            $projectXml = [xml](Get-Content $csproj)
            $nsmgr = Get-XmlNamespaceManager $projectXml
        }
        AfterEach {
            Remove-Item (Join-Path $TestDrive Sandbox.iOS) -Recurse
        }
        It "Should return a System.Xml.XmlElement" {
            Get-BundleResourceItemGroup $projectXml $nsmgr | Should BeOfType System.Xml.XmlElement
        }
    }

    Context "Get-AndroidResourceItemGroup" {
        BeforeEach {
            Copy-Item .\Sandbox\Solution\Sandbox\Sandbox.Android $TestDrive -Recurse
            $csproj = Join-Path $TestDrive Sandbox.Android | Join-Path -ChildPath Sandbox.Android.csproj
            $projectXml = [xml](Get-Content $csproj)
            $nsmgr = Get-XmlNamespaceManager $projectXml
        }
        AfterEach {
            Remove-Item (Join-Path $TestDrive Sandbox.Android) -Recurse
        }
        It "Should return a System.Xml.XmlElement" {
            Get-AndroidResourceItemGroup $projectXml $nsmgr | Should BeOfType System.Xml.XmlElement
        }
    }

    Context "Add-BundleResource" {
        BeforeEach {
            Copy-Item .\Sandbox\Solution\Sandbox\Sandbox.iOS $TestDrive -Recurse
            $csproj = Join-Path $TestDrive Sandbox.iOS | Join-Path -ChildPath Sandbox.iOS.csproj
            $image = Copy-Image ".\Sandbox\Images\filter_all_blue.png" (Join-Path $TestDrive Sandbox.iOS | Join-Path -ChildPath Resources) 6>$null
            $projectXml = [xml](Get-Content $csproj)
            $nsmgr = Get-XmlNamespaceManager $projectXml
            $itemGroup = Get-BundleResourceItemGroup $projectXml $nsmgr
        }
        AfterEach {
            Remove-Item (Join-Path $TestDrive Sandbox.iOS) -Recurse
        }
        It "Should add a BundleResource element to the .csproj if it doesn't already exist" {
            Add-BundleResource $projectXml $nsmgr $itemGroup $image $csproj 6>$null
            $localFilename = "Resources\" + (Get-Filename $image)
            $xPath = [string]::Format("//a:BundleResource[@Include='{0}']", $localFilename)
            $projectXml.SelectNodes($xPath, $nsmgr).Count | Should Be 1
        }
        It "Should not add a BundleResource element to the .csproj if it already exists" {
            Add-BundleResource $projectXml $nsmgr $itemGroup $image $csproj 6>$null
            Add-BundleResource $projectXml $nsmgr $itemGroup $image $csproj 6>$null
            $localFilename = "Resources\" + (Get-Filename $image)
            $xPath = [string]::Format("//a:BundleResource[@Include='{0}']", $localFilename)
            $projectXml.SelectNodes($xPath, $nsmgr).Count | Should Be 1
        }
        It "Should write to the information stream when a BundleResource element is added to the .csproj" {
            (Add-BundleResource $projectXml $nsmgr $itemGroup $image $csproj 6>&1 | Measure-Object -Line).Lines | Should Be 1
        }
    }

    Context "Add-AndroidResource" {
        BeforeEach {
            Copy-Item .\Sandbox\Solution\Sandbox\Sandbox.Android $TestDrive -Recurse
            $csproj = Join-Path $TestDrive Sandbox.Android | Join-Path -ChildPath Sandbox.Android.csproj
            $image = Copy-ImageAndRename ".\Sandbox\Images\filter_all_bluehdpi.png" (Join-Path $TestDrive Sandbox.Android | Join-Path -ChildPath Resources | Join-Path -ChildPath drawable-hdpi) filter_all_blue.png  6>$null
            $projectXml = [xml](Get-Content $csproj)
            $nsmgr = Get-XmlNamespaceManager $projectXml
            $itemGroup = Get-AndroidResourceItemGroup $projectXml $nsmgr
        }
        AfterEach {
            Remove-Item (Join-Path $TestDrive Sandbox.Android) -Recurse
        }
        It "Should add an AndroidResource element to the .csproj if it doesn't already exist" {
            Add-AndroidResource $projectXml $nsmgr $itemGroup $image $csproj 6>$null
            $localFilename = $image.Substring($image.IndexOf("Resources\"))
            $xPath = [string]::Format("//a:AndroidResource[@Include='{0}']", $localFilename)
            $projectXml.SelectNodes($xPath, $nsmgr).Count | Should Be 1
        }
        It "Should not add an AndroidResource element to the .csproj if it already exists" {
            Add-AndroidResource $projectXml $nsmgr $itemGroup $image $csproj 6>$null
            Add-AndroidResource $projectXml $nsmgr $itemGroup $image $csproj 6>$null
            $localFilename = $image.Substring($image.IndexOf("Resources\"))
            $xPath = [string]::Format("//a:AndroidResource[@Include='{0}']", $localFilename)
            $projectXml.SelectNodes($xPath, $nsmgr).Count | Should Be 1
        }
        It "Should write to the information stream when an AndroidResource element is added to the .csproj" {
            (Add-AndroidResource $projectXml $nsmgr $itemGroup $image $csproj 6>&1 | Measure-Object -Line).Lines | Should Be 1
        }
    }
}
