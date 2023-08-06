<#
    To run script first run "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass"
#>
param(
    [string]$name = "john",
    [string]$ip
)

# Generate ssh key
scp ServerScript_2.sh "$name@$ip"":"
Set-Location .ssh
ssh-keygen.exe -t rsa -b 4096 -f vultr -N 727
scp vultr.pub "$name@$ip"":"
