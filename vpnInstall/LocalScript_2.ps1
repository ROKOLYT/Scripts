<#
    To run script first run "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass"
#>
param(
    [string]$name = "john",
    [string]$ip
)

sftp -i .ssh/vultr "$name@$ip"":"

<#
    get vultr.ovpn
#>