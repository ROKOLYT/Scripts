<#
    To run script first run "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass"
#>

param(
    [string]$install = "all"
)


$EssentialPackages = @("GoogleChrome", "Firefox", "7zip", "git", "jre8", "pyenv-win", "miniconda3", "openssl", "SQLite", "tor-browser", "vscode", "jetbrainstoolbox", "blender")
$GamePackages = @("discord", "epicgameslauncher", "steam", "valorant", "messenger")
$QoLPackages = @("betterdiscord", "hwinfo", "lghub", "msiafterburner", "obs", "steelseries-engine")


function RefreshEnviroment {
    Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
    refreshenv
}

function DownloadChoco {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    RefreshEnviroment
}

function InstallPackages {
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

if ($args -contains "--help" -or @("all", "qol", "game", "essential") -contains -not $install) {
    Write-Host "Usage: ./run.ps1 -install [all, game, qol, essential, default: all]"
    Exit 0
}


DownloadChoco

InstallPackages


