[![Build status](https://ci.appveyor.com/api/projects/status/3bh4uoa4gffkajr0?svg=true)](https://ci.appveyor.com/project/teamtam/xamarin-image-importer)

# xamarin-image-importer

Copies .png images into the corresponding Resources directory of Xamarin.iOS and Xamarin.Android projects and
imports them to the .csproj project files so it will be available when viewed in Visual/Xamarin Studio. If they
exist, `@2x.png` or `@3x.png` variants of the image will be imported for iOS, while `*ldpi.png`, `*mdpi.png`, `*hdpi.png`,
`*xhdpi.png`, `*xxhdpi.png` and `*xxxhdpi.png` will be imported for Android.

* Blog: [http://teamtam.net/xamarin-image-importer/](http://teamtam.net/xamarin-image-importer/)

## Usage

### Run for iOS only with minimal parameters
`Add-XamarinImages C:\Images -IosProject C:\Source\MyProject.iOS\MyProject.iOS.csproj`

### Run for Android only with minimal parameters
`Add-XamarinImages C:\Images -AndroidProject C:\Source\MyProject.Droid\MyProject.Droid.csproj`

### Run for both iOS and Android with all optional parameters
`Add-XamarinImages -Images C:\Images -IosProject C:\Source\MyProject.iOS\MyProject.iOS.csproj -AndroidProject C:\Source\MyProject.Droid\MyProject.Droid.csproj -Move -Verbose`

### More detailed documentation can be found through PowerShell 'Get-Help' after installation
`Get-Help Add-XamarinImages`

### Sample output
![Sample output](/sample_output.png)

## Installation

### Requirements
* PowerShell 5.0

### PowerShell Gallery
* Option A: install for the current user:  
  `Install-Module -Name "XamarinImageImporter" -Scope CurrentUser`
* Option B: run as Administrator to install for all users:  
  `Install-Module -Name "XamarinImageImporter"`

### Manual Installation
* `git clone https://github.com/teamtam/xamarin-image-importer.git`
* Option A: run as is for the current PowerShell session:  
  `Import-Module .\XamarinImageImporter\XamarinImageImporter.psd1`
* Option B: install for the current and future PowerShell sessions:  
  Copy the `XamarinImageImporter` directory to a path defined in `$Env:PSModulePath` - [[more info]](https://msdn.microsoft.com/en-us/library/dd878350(v=vs.85).aspx)
