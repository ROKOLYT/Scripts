<#
    To run script first run "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass"
#>

param(
    [string]$install = "all"
)

$EssentialPackages = @("GoogleChrome", "Firefox", "7zip", "git", "jre8", "pyenv-win", "miniconda3", "openssl", "SQLite", "tor-browser", "vscode", "jetbrainstoolbox", "blender")
$GamePackages = @("discord", "epicgameslauncher", "steam", "valorant", "messenger")
$QoLPackages = @("betterdiscord", "hwinfo", "lghub", "msiafterburner", "obs", "steelseries-engine")
$DiscordPluginsUrls = @("https://betterdiscord.app/Download?id=245", "https://betterdiscord.app/Download?id=81", "https://betterdiscord.app/Download?id=184")
$DiscordPluginsNames = @("FreeEmojis.plugin.js", "Translator.plugin.js", "BetterVolume.plugin.js")


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

function InstallDiscordPlugins {
    if ($DiscordPluginsUrls.Count -eq -not $DiscordPluginsNames.Count) {
        Write-Host "Failed to install discord plugins. Make sure the urls, and names are correct"
        return
    }

    # Install discord plugins
    $outputPath = $env:APPDATA + "\BetterDiscord\plugins\"
    for ($i = 0; $i -lt $DiscordPluginsUrls.Count; $i++) {
        $finalPath = $outputPath + $DiscordPluginsNames[$i]
        
        Invoke-WebRequest -Uri $DiscordPluginsUrls[$i] -OutFile $finalPath -UseBasicParsing
        Start-Sleep -Seconds 1
    }

    # Copy discord theme
    $filePath = "discordtheme.theme.css"
    $outputPath = $env:APPDATA + "\BetterDiscord\themes\" + $filePath
    $sourcePath = $PSScriptRoot + "\" + $filePath
    
    Copy-Item -Path $sourcePath -Destination $outputPath
}

function OpenSteam {
    $steamPath = "C:\Program Files (x86)\Steam\steam.exe"
    Start-Process -FilePath $steamPath
}

if ($args -contains "--help" -or @("all", "qol", "game", "essential") -contains -not $install) {
    Write-Host "Usage: ./run.ps1 -install [all, game, qol, essential, default: all]"
    Exit 0
}


DownloadChoco

InstallPackages

InstallDiscordPlugins

OpenSteam
