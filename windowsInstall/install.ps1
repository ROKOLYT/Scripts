<#
    To run script first run "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass"
#>

param(
    [string]$install = "all"
)

$EssentialPackages = @("GoogleChrome", "Firefox", "7zip", "git", "jre8", "pyenv-win", "miniconda3", "openssl", "SQLite", "tor-browser", "vscode", "jetbrainstoolbox", "blender", "make", "mingw")
$GamePackages = @("discord", "epicgameslauncher", "steam", "valorant", "messenger")
$QoLPackages = @("hwinfo", "lghub", "msiafterburner", "obs", "steelseries-engine")
$VencordCLI = "https://github.com/Vencord/Installer/releases/latest/download/VencordInstallerCli.exe"
$DiscordPath = "C:\Users\jassz\AppData\Local\Discord\app-1.0.9018\Discord.exe"
$StartMenuPath = "C:\Users\jassz\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin"


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
    # Initialize input for installation process [Selects option 1]
    @"
    1
"@ | Set-Content -Path "input.txt"

    # Download installer
    $outfile = "$env:TEMP\$(([uri]$VencordCLI).Segments[-1])"

    Write-Output "Downloading installer to $outfile"

    Invoke-WebRequest -Uri "$VencordCLI" -OutFile "$outfile"

    Write-Output ""

    # Install Vencord
    Start-Process -Wait -NoNewWindow -FilePath "$outfile" -ArgumentList "-install" -RedirectStandardInput input.txt

    # Launch Discord
    Start-Process powershell -WindowStyle Hidden -ArgumentList "-NoExit -Command `"& '$DiscordPath'`""

}

function ConfigureWindowsSettings {
    # Load preconfigured pinned apps
    Copy-Item -Path "D:\.Programs\Scripts\windowsInstall\start2.bin" -Destination $StartMenuPath
}

# Check for correct usage
if ($args -contains "--help" -or @("all", "qol", "game", "essential") -contains -not $install) {
    Write-Host "Usage: ./run.ps1 -install [all, game, qol, essential, default: all]"
    Exit 0
}

DownloadChoco

InstallPackages

InstallVencord

ConfigureWindowsSettings
