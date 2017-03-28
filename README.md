# xamarin-image-importer

Copies .png images into the corresponding Resources directory of Xamarin.iOS and Xamarin.Android projects and
imports them to the .csproj project files so it will be available when viewed in Visual/Xamarin Studio. If they
exist, `@2x.png` or `@3x.png` variants of the image will be imported for iOS, and `*ldpi.png`, `*mdpi.png`, `*hdpi.png`,
`*xhdpi.png`, `*xxhdpi.png` and `*xxxhdpi.png` will be imported for Android.

## Usage

### Run for iOS only.
`Add-XamarinImages C:\Images -iosProject C:\Source\MyProject.iOS\MyProject.iOS.csproj`

### Run for Android only
`Add-XamarinImages C:\Images -androidProject C:\Source\MyProject.Droid\MyProject.Droid.csproj`

### Run for both iOS and Android with all optional parameters.
`Add-XamarinImages -images C:\Images -iosProject C:\Source\MyProject.iOS\MyProject.iOS.csproj -iosResources C:\Source\MyProject.iOS\Resources -androidProject C:\Source\MyProject.Droid\MyProject.Droid.csproj -androidResources C:\Source\MyProject.Droid\Resources -move -Verbose`

### More detailed documentation can be found through PowerShell `Get-Help` after installation.
* `Get-Help Add-XamarinImages`
* `Get-Help Add-XamarinIosImage`
* `Get-Help Add-XamarinAndroidImage`

## Requirements
* PowerShell 5.0

## Installation
* *Coming soon!*
