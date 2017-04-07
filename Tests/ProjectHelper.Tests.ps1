Describe "ProjectHelper" {
    Import-Module $PSScriptRoot\..\XamarinImageImporter\ProjectHelper.psd1

    Context "Add-BundleResource" {
        BeforeEach {
            Copy-Item .\Sandbox\Solution\Sandbox\Sandbox.iOS $TestDrive -Recurse
            $csproj = Join-Path $TestDrive Sandbox.iOS | Join-Path -ChildPath Sandbox.iOS.csproj
            $image = Copy-Image ".\Sandbox\Images\filter_all_blue.png" (Join-Path $TestDrive Sandbox.iOS | Join-Path -ChildPath Resources) 6>$null
        }
        AfterEach {
            Remove-Item (Join-Path $TestDrive Sandbox.iOS) -Recurse
        }
        It "Should add a BundleResource element to the .csproj if it doesn't already exist" {
            $projectXml = [xml](Get-Content $csproj)
            $nsmgr = Get-XmlNamespace $projectXml
            #$itemGroup = Get-AndroidResourceItemGroup $projectXml $nsmgr
            #Write-Debug $itemGroup.GetType()
            $firstItemGroupNode = $projectXml.SelectNodes("//a:BundleResource", $nsmgr)[1]
            if ($firstItemGroupNode)
            {
                $itemGroup = $firstItemGroupNode.ParentNode
            }
            else
            {
                $itemGroup = $projectXml.CreateElement("ItemGroup", $xmlns)
                $x = $projectXml.Project.AppendChild($itemGroup)
            }
            Add-BundleResource $projectXml $nsmgr $itemGroup $image $csproj 6>$null
            
            $localFilename = "Resources\" + (Get-Filename $image)
            $xPath = [string]::Format("//a:BundleResource[@Include='{0}']", $localFilename)
            $projectXml.SelectNodes($xPath, $nsmgr).Count | Should Be 1
        }
        It "Should not add a BundleResource element to the .csproj if it already exists" {
            $projectXml = [xml](Get-Content $csproj)
            $nsmgr = Get-XmlNamespace $projectXml
            #$itemGroup = Get-AndroidResourceItemGroup $projectXml $nsmgr
            #Write-Debug $itemGroup.GetType()
            $firstItemGroupNode = $projectXml.SelectNodes("//a:BundleResource", $nsmgr)[1]
            if ($firstItemGroupNode)
            {
                $itemGroup = $firstItemGroupNode.ParentNode
            }
            else
            {
                $itemGroup = $projectXml.CreateElement("ItemGroup", $xmlns)
                $x = $projectXml.Project.AppendChild($itemGroup)
            }
            Add-BundleResource $projectXml $nsmgr $itemGroup $image $csproj 6>$null
            Add-BundleResource $projectXml $nsmgr $itemGroup $image $csproj 6>$null
            
            $localFilename = "Resources\" + (Get-Filename $image)
            $xPath = [string]::Format("//a:BundleResource[@Include='{0}']", $localFilename)
            $projectXml.SelectNodes($xPath, $nsmgr).Count | Should Be 1
        }
        It "Should write to the information stream when a BundleResource element is added to the .csproj" {
            $projectXml = [xml](Get-Content $csproj)
            $nsmgr = Get-XmlNamespace $projectXml
            #$itemGroup = Get-AndroidResourceItemGroup $projectXml $nsmgr
            #Write-Debug $itemGroup.GetType()
            $firstItemGroupNode = $projectXml.SelectNodes("//a:BundleResource", $nsmgr)[1]
            if ($firstItemGroupNode)
            {
                $itemGroup = $firstItemGroupNode.ParentNode
            }
            else
            {
                $itemGroup = $projectXml.CreateElement("ItemGroup", $xmlns)
                $x = $projectXml.Project.AppendChild($itemGroup)
            }
            (Add-BundleResource $projectXml $nsmgr $itemGroup $image $csproj 6>&1 | Measure-Object -Line).Lines | Should Be 1
        }
    }

    Context "Add-AndroidResource" {
        BeforeEach {
            Copy-Item .\Sandbox\Solution\Sandbox\Sandbox.Android $TestDrive -Recurse
            $csproj = Join-Path $TestDrive Sandbox.Android | Join-Path -ChildPath Sandbox.Android.csproj
            $image = Copy-ImageAndRename ".\Sandbox\Images\filter_all_bluehdpi.png" (Join-Path $TestDrive Sandbox.Android | Join-Path -ChildPath Resources | Join-Path -ChildPath drawable-hdpi) filter_all_blue.png  6>$null
        }
        AfterEach {
            Remove-Item (Join-Path $TestDrive Sandbox.Android) -Recurse
        }
        It "Should add an AndroidResource element to the .csproj if it doesn't already exist" {
            $projectXml = [xml](Get-Content $csproj)
            $nsmgr = Get-XmlNamespace $projectXml
            #$itemGroup = Get-AndroidResourceItemGroup $projectXml $nsmgr
            #Write-Debug $itemGroup.GetType()
            $firstItemGroupNode = $projectXml.SelectNodes("//a:AndroidResource", $nsmgr)[1]
            if ($firstItemGroupNode)
            {
                $itemGroup = $firstItemGroupNode.ParentNode
            }
            else
            {
                $itemGroup = $projectXml.CreateElement("ItemGroup", $xmlns)
                $x = $projectXml.Project.AppendChild($itemGroup)
            }
            Add-AndroidResource $projectXml $nsmgr $itemGroup $image $csproj 6>$null
            
            $localFilename = $image.Substring($image.IndexOf("Resources\"))
            $xPath = [string]::Format("//a:AndroidResource[@Include='{0}']", $localFilename)
            $projectXml.SelectNodes($xPath, $nsmgr).Count | Should Be 1
        }
        It "Should not add an AndroidResource element to the .csproj if it already exists" {
            $projectXml = [xml](Get-Content $csproj)
            $nsmgr = Get-XmlNamespace $projectXml
            #$itemGroup = Get-AndroidResourceItemGroup $projectXml $nsmgr
            #Write-Debug $itemGroup.GetType()
            $firstItemGroupNode = $projectXml.SelectNodes("//a:AndroidResource", $nsmgr)[1]
            if ($firstItemGroupNode)
            {
                $itemGroup = $firstItemGroupNode.ParentNode
            }
            else
            {
                $itemGroup = $projectXml.CreateElement("ItemGroup", $xmlns)
                $x = $projectXml.Project.AppendChild($itemGroup)
            }
            Add-AndroidResource $projectXml $nsmgr $itemGroup $image $csproj 6>$null
            Add-AndroidResource $projectXml $nsmgr $itemGroup $image $csproj 6>$null
            
            $localFilename = $image.Substring($image.IndexOf("Resources\"))
            $xPath = [string]::Format("//a:AndroidResource[@Include='{0}']", $localFilename)
            $projectXml.SelectNodes($xPath, $nsmgr).Count | Should Be 1
        }
        It "Should write to the information stream when an AndroidResource element is added to the .csproj" {
            $projectXml = [xml](Get-Content $csproj)
            $nsmgr = Get-XmlNamespace $projectXml
            #$itemGroup = Get-AndroidResourceItemGroup $projectXml $nsmgr
            #Write-Debug $itemGroup.GetType()
            $firstItemGroupNode = $projectXml.SelectNodes("//a:AndroidResource", $nsmgr)[1]
            if ($firstItemGroupNode)
            {
                $itemGroup = $firstItemGroupNode.ParentNode
            }
            else
            {
                $itemGroup = $projectXml.CreateElement("ItemGroup", $xmlns)
                $x = $projectXml.Project.AppendChild($itemGroup)
            }
            (Add-AndroidResource $projectXml $nsmgr $itemGroup $image $csproj 6>&1 | Measure-Object -Line).Lines | Should Be 1
        }
    }
}
