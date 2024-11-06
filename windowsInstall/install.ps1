<#
    To run script first run "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass"
#>

param(
    [string]$install = "all"
)

$EssentialPackages = @("GoogleChrome", "Firefox", "git", "pyenv-win", "openssl", "vscode", 
"yubico-authenticator", "nodejs-lts", "typescript", "winrar")
$GamePackages = @("discord", "epicgameslauncher", "steam", "valorant", "messenger")
$QoLPackages = @("hwinfo", "lghub", "obs")
$VencordCLI = "https://github.com/Vencord/Installer/releases/latest/download/VencordInstallerCli.exe"
$global:DiscordRootPath = "$env:LOCALAPPDATA\Discord\"
$global:DiscordPath = Get-ChildItem -Path $DiscordRootPath -Filter "Discord.exe" -File -Recurse | Select-Object -First 1
$DiscordPath = $DiscordPath.FullName

function RefreshDiscordPath {
    $global:DiscordPath = Get-ChildItem -Path $DiscordRootPath -Filter "Discord.exe" -File -Recurse | Select-Object -First 1
    $global:DiscordPath = $DiscordPath.FullName
}

function RefreshEnviroment {
    # Refresh Enviroment to make sure all newly installed packages work
    Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
    refreshenv
}

function DownloadChoco {
    # Install Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    RefreshEnviroment
}

function InstallPackages {
    # Install packages based on needs
    foreach ($Package in $EssentialPackages) {
        choco install $Package -y
        RefreshEnviroment
    }
    if ($install -eq "essential") {
        Exit 0
    }

    if ($install -eq "all" -or $install -eq "game") {
        foreach ($Package in $GamePackages) {
            choco install $Package -y
            RefreshEnviroment
        }
    }

    if ($install -eq "all" -or $install -eq "qol") {
        foreach ($Package in $QoLPackages) {
            choco install $Package -y
            RefreshEnviroment
        }
    }
}

function InstallVencord {
    # Refresh the Discord path
    RefreshDiscordPath
    
    # Launch Discord to ensure it is fully installed
    Start-Process -FilePath $DiscordPath
    Start-Sleep -Seconds 30

    # Close all instances of Discord after 20 seconds
    Write-Output "Closing all instances of Discord..."
    Stop-Process -Name "Discord" -Force -ErrorAction SilentlyContinue
    Start-Sleep 1

    # Refresh the Discord path again, just in case it changed
    RefreshDiscordPath

    # Set up the download URL and output path for the installer
    $outfile = "$env:TEMP\$(([uri]$VencordCLI).Segments[-1])"
    Write-Output "Downloading installer to $outfile"

    # Download the installer file to the specified path
    Invoke-WebRequest -Uri "$VencordCLI" -OutFile "$outfile"
    Write-Output "Installer downloaded successfully."

    # Launch the installer
    $process = Start-Process -FilePath "$outfile" -ArgumentList "-install -branch stable" -NoNewWindow -PassThru
    
    # Wait for the installer process to complete
    $process.WaitForExit()
}

# Check for correct usage
if ($args -contains "--help" -or @("all", "qol", "game", "essential") -contains -not $install) {
    Write-Host "Usage: ./run.ps1 -install [all, game, qol, essential, default: all]"
    Exit 0
}


DownloadChoco

InstallPackages

InstallVencord

# ConfigureWindowsSettings
