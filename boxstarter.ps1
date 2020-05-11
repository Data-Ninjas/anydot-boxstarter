## start http://boxstarter.org/package/url?https://raw.githubusercontent.com/anydot/anydot-boxstarter/master/boxstarter.ps1

function Upsert-Registry {
	param(
		$description,
		$path,
		$name,
		$type,
		$value
	)

	Write-Host -NoNewLine "$description..."

	If (-Not (Test-Path $path)) {
		New-Item -Path $path | Out-Null
		Write-Host -NoNewLine " [path created]"
	}

	$curvalue = (Get-Item -LiteralPath $path).GetValue($name, $null)

	if ($curvalue -eq $value) {
		Write-Host " Already set"
	}

	if ($curvalue -eq $null) {
		Set-ItemProperty -Path $path -Name $name -Type $type -Value $value | Out-Null
		Write-Host " Created"
	}

	if ($curvalue -ne $value) {
		Set-ItemProperty -Path $path -Name $name -Type $type -Value $value | Out-Null
		Write-Host " Set"
	}
}

function explorerSettings {
	# Show hidden files, Show protected OS files, Show file extensions
	Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions

	#--- File Explorer Settings ---
	# will expand explorer to the actual folder you're in
	Upsert-Registry "Expand explorer to the actual folder" "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "NavPaneExpandToCurrentFolder" "DWORD" 1
	Upsert-Registry "Add things back in your left pane like recycle bin" "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "NavPaneShowAllFolders" "DWORD" 
	Upsert-Registry "Open PC to This PC, not quick access" "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" "DWORD" 1
}

function removeApp {
	Param ([string]$appName)
	Write-Output "Trying to remove $appName"
	Get-AppxPackage $appName -AllUsers | Remove-AppxPackage
	Get-AppXProvisionedPackage -Online | Where DisplayName -like $appName | Remove-AppxProvisionedPackage -Online
}

function hideTaskbarSearchBox {
    Upsert-Registry "Hide Taskbar Search box / button" "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" "DWORD" 0
}

function hideTaskView {
	Upsert-Registry "Hide Task view button" "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" "DWORD" 0
}

$applicationList = @(
	"Microsoft.BingFinance"
	"Microsoft.3DBuilder"
	"Microsoft.BingFinance"
	"Microsoft.BingNews"
	"Microsoft.BingSports"
	"Microsoft.BingWeather"
	"Microsoft.CommsPhone"
	"Microsoft.Getstarted"
	"Microsoft.WindowsMaps"
	"*MarchofEmpires*"
	"Microsoft.GetHelp"
	"Microsoft.Messaging"
	"*Minecraft*"
	"Microsoft.MicrosoftOfficeHub"
	"Microsoft.OneConnect"
	"Microsoft.WindowsPhone"
	"Microsoft.WindowsSoundRecorder"
	"*Solitaire*"
	"Microsoft.MicrosoftStickyNotes"
	"Microsoft.Office.Sway"
	"Microsoft.XboxApp"
	"Microsoft.XboxIdentityProvider"
	"Microsoft.ZuneMusic"
	"Microsoft.ZuneVideo"
	"Microsoft.NetworkSpeedTest"
	"Microsoft.FreshPaint"
	"Microsoft.Print3D"
	"*Autodesk*"
	"*BubbleWitch*"
    "king.com*"
    "G5*"
	"*Dell*"
	"*Facebook*"
	"*Keeper*"
	"*Twitter*"
	"*Plex*"
	"*.Duolingo-LearnLanguagesforFree"
	"*.EclipseManager"
	"ActiproSoftwareLLC.562882FEEB491" # Code Writer
	"*.AdobePhotoshopExpress"
	"*Skype*"
	"*Spotify*"
	"PLRWorldwideSales.Gardenscapes-NewAcres"

);

# https://github.com/mwrock/boxstarter/issues/241#issuecomment-336028348
$cacheLocation = "C:\temp\"
New-Item -Path $cacheLocation -ItemType directory -Force | Out-Null

foreach ($app in $applicationList) {
    removeApp $app
}

#--- Enable developer mode on the system ---
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Value 1

explorerSettings

Disable-BingSearch
Disable-GameBarTips

# Privacy: Let apps use my advertising ID: Disable
If (-Not (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
    New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo | Out-Null
}
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -Name Enabled -Type DWord -Value 0

# WiFi Sense: HotSpot Sharing: Disable
If (-Not (Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
    New-Item -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting | Out-Null
}
Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting -Name value -Type DWord -Value 0

# WiFi Sense: Shared HotSpot Auto-Connect: Disable
Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots -Name value -Type DWord -Value 0

# Start Menu: Disable Bing Search Results
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name BingSearchEnabled -Type DWord -Value 0

# Start Menu: Disable Cortana 
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows' -Name 'Windows Search' -ItemType Key | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name AllowCortana -Type DWORD -Value 0

# Disable Xbox Gamebar
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name AppCaptureEnabled -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name GameDVR_Enabled -Type DWord -Value 0

# Turn off People in Taskbar
If (-Not (Test-Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
    New-Item -Path HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People | Out-Null
}
Set-ItemProperty -Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name PeopleBand -Type DWord -Value 0

$chocoWinFeatures = @(
	"Microsoft-Hyper-V-All"
	"Microsoft-Windows-Subsystem-Linux"
	)

$chocoPackages = @(
	"7zip"
	"f.lux"
	"git"
	"GoogleChrome"
	"hugo-extended"
	"microsoft-teams.install"
	"microsoft-windows-terminal"
	"plantuml"
	"powershell-core"
	"skype"
	"smplayer"
	"spotify"
	"sublimetext3"
	"telegram"
	"vscode"
	"vscode-csharp"
	"Office365ProPlus"
	)

foreach ($feature in $chocoWinFeatures) {
	choco upgrade -y $feature --source=windowsFeatures --cacheLocation=$cacheLocation
}

foreach ($package in $chocoPackages) {
	choco upgrade -y $package --cacheLocation=$cacheLocation
}

hideTaskbarSearchBox
hideTaskView

## TODO:
## * redirect documents/pictures folders
## * unpin default programs (edge, store, smth)
## * test if the feature is installed before we install it ourselves

#PowerShell help
Update-Help -ErrorAction SilentlyContinue

if ($env:computername -eq "smth") {

}

Install-WindowsUpdate -acceptEula