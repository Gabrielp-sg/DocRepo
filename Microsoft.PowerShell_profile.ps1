$docs = [Environment]::GetFolderPath('MyDocuments')
$ps7 = Join-Path $docs 'PowerShell\Modules'
$win = Join-Path $docs 'WindowsPowerShell\Modules'

# Descobre onde o LpTools já está (se estiver)
$src = @(
  Join-Path $ps7 'LpTools'
  Join-Path $win 'LpTools'
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $src) {
  Write-Warning "LpTools não encontrado. Se precisar, eu recrio o módulo pra você."
} else {
  foreach ($dstBase in @($ps7,$win)) {
    $dst = Join-Path $dstBase 'LpTools'
    New-Item -ItemType Directory -Force $dst | Out-Null
    Copy-Item "$src\*" $dst -Recurse -Force
    # Marca como "Sempre manter neste dispositivo" (OneDrive)
    attrib +P $dst /S /D 2>$null
  }
}

# Garante que ambos os caminhos estão no PSModulePath da sessão
foreach ($p in @($ps7,$win)) {
  if (($env:PSModulePath -split ';') -notcontains $p) {
    $env:PSModulePath = "$env:PSModulePath;$p"
  }
}

# Teste
Import-Module LpTools -Force
Get-Module LpTools




# 1) Copiar o módulo da pasta do PowerShell 7 para a do Windows PowerShell
$src = Join-Path $HOME "Documents\PowerShell\Modules\LpTools"
$dst = Join-Path $HOME "Documents\WindowsPowerShell\Modules\LpTools"

if (Test-Path $src) {
  New-Item -ItemType Directory -Force $dst | Out-Null
  Copy-Item -Path "$src\*" -Destination $dst -Recurse -Force
} else {
  Write-Warning "LpTools não existe em $src. Se for o caso, me diga que eu te mando o instalador completo de novo."
}

# 2) Recarregar o profile desta sessão
. $PROFILE

# 3) Conferir se o módulo agora é visível
Get-Module -ListAvailable LpTools



Import-Module : The specified module 'LpTools' was not loaded because no valid module file was found in any module
directory.
At C:\Users\guimg\OneDrive - LeasePlan Information Services\Documents\WindowsPowerShell\profile.ps1:18 char:1
+ Import-Module LpTools -Force
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceUnavailable: (LpTools:String) [Import-Module], FileNotFoundException
    + FullyQualifiedErrorId : Modules_ModuleNotFound,Microsoft.PowerShell.Commands.ImportModuleCommand

Import-Module : The specified module 'LpTools' was not loaded because no valid module file was found in any module
directory.
At C:\Users\guimg\OneDrive - LeasePlan Information
Services\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1:18 char:1
+ Import-Module LpTools -Force
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceUnavailable: (LpTools:String) [Import-Module], FileNotFoundException
    + FullyQualifiedErrorId : Modules_ModuleNotFound,Microsoft.PowerShell.Commands.ImportModuleCommand


    



# --- Instalação UMA VEZ para tornar suas funções e env persistentes ---

$ModuleName  = 'LpTools'
$ModuleRoot  = Join-Path $HOME "C:\Users\guimg\Documents\WindowsPowerShell\Modules\$ModuleName\1.0.0"
$null = New-Item -ItemType Directory -Force $ModuleRoot

# Conteúdo do módulo com suas funções e alias
$moduleContent = @'
# LpTools.psm1 — suas ferramentas

# Alias "k" como função p/ repassar argumentos ao kubectl
function k { & "C:\Program Files\Docker\Docker\resources\bin\kubectl.exe" @Args }

# Login no Vault (Okta)
function vl {
    param([string]$Username = "gabriel.guimaraes-ext@leaseplan.com")
    vault login --method=okta username=$Username
}

# Abrir Git Bash
function Open-GitBash { & 'C:\Program Files\Git\bin\sh.exe' --login }

# Ler credenciais AWS do Vault e aplicar em CLI + sessão
function aws-vault-read {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$workload,
        [string]$profileName = "default",
        [string]$region = "eu-west-1"
    )

    $json = vault read "aws/$workload/creds/infra-userland" -format=json
    if (-not $json) { throw "Vault retornou vazio." }
    $awsCredentials = $json | ConvertFrom-Json

    aws configure set profile.$profileName.aws_access_key_id $awsCredentials.data.access_key
    aws configure set profile.$profileName.aws_secret_access_key $awsCredentials.data.secret_key
    aws configure set profile.$profileName.region $region

    aws configure set default.aws_access_key_id $awsCredentials.data.access_key
    aws configure set default.aws_secret_access_key $awsCredentials.data.secret_key
    aws configure set default.region $region

    $env:AWS_ACCESS_KEY_ID     = $awsCredentials.data.access_key
    $env:AWS_SECRET_ACCESS_KEY = $awsCredentials.data.secret_key
    $env:AWS_DEFAULT_REGION    = $region

    if ($awsCredentials.data.PSObject.Properties.Name -contains 'security_token') {
        $env:AWS_SESSION_TOKEN = $awsCredentials.data.security_token
    } else {
        Remove-Item Env:AWS_SESSION_TOKEN -ErrorAction SilentlyContinue
    }

    aws configure list --profile $profileName
}

# Selecionar workload via fzf (se existir) e ler credenciais
function usercred {
    if (Get-Module -ListAvailable -Name PSFzf) {
        $workload = vault secrets list -format table |
            Select-String '[A-Z]{3}/\d{4}-[A-Z]{3}-[dtapm]/' |
            Invoke-Fzf
        if (-not $workload) { Write-Warning "Nada selecionado."; return }
        $workload_env = ($workload.split(" ")[0]).split("/")[1]
        aws-vault-read -workload $workload_env
    } else {
        Write-Warning "PSFzf não instalado. Rode: Install-Module PSFzf -Scope CurrentUser"
    }
}
'@

Set-Content -Path (Join-Path $ModuleRoot "$ModuleName.psm1") -Value $moduleContent -Encoding UTF8

# Conteúdo do profile (carrega seu módulo e configura ambiente a cada sessão)
$proxy   = 'http://LPGPZENPROXY.EMEA.LEASEPLANCORP.NET:80'
$noProxy = 'localhost,127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,core-services.leaseplan.systems'

$profileContent = @"
# >>> LeasePlan profile start >>>

# ExecutionPolicy só para CurrentUser (sem admin). Faz nada se já estiver OK.
try {
  if ((Get-ExecutionPolicy -Scope CurrentUser) -ne 'RemoteSigned') {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
  }
} catch {}

# Ambiente desta sessão
`$env:VAULT_ADDR = 'https://vault.core-services.leaseplan.systems'
`$env:HTTP_PROXY = '$proxy'
`$env:HTTPS_PROXY = '$proxy'
`$env:NO_PROXY   = '$noProxy'
`$env:AWS_DEFAULT_REGION = 'eu-west-1'  # mantenha consistente com aws-vault-read

# Carrega suas ferramentas
Import-Module $ModuleName -Force

# PSFzf (se tiver)
if (Get-Module -ListAvailable -Name PSFzf) {
  Import-Module PSFzf -ErrorAction SilentlyContinue
  Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# posh-git (se tiver)
Import-Module posh-git -ErrorAction SilentlyContinue

# >>> LeasePlan profile end <<<
"@

# Grava o profile do host atual e o "AllHosts" (cobre PowerShell 7 e Windows PowerShell)
$targets = @($PROFILE, $PROFILE.CurrentUserAllHosts) | Select-Object -Unique
foreach ($t in $targets) {
  $dir = Split-Path $t
  $null = New-Item -ItemType Directory -Force $dir
  Set-Content -Path $t -Value $profileContent -Encoding UTF8
}

Write-Host "OK! Módulo instalado em: $ModuleRoot"
Write-Host "Profiles escritos em:`n - $($targets -join "`n - ")"
Write-Host "Abra uma nova janela do PowerShell OU rode: . $PROFILE"




