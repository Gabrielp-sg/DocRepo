
Set-Alias -Name vault -Value "C:\Users\guimg\Downloads\vault_1.20.1_windows_amd64\vault.exe"
Set-Alias -Name k -Value "C:\Program Files\Docker\Docker\resources\bin\kubectl.exe"
#Set-Alias -Name gossm -Value C:\Users\gometi\go\bin\gossm.exe
$env:AWS_DEFAULT_REGION = 'sa-east-1'
$ssh_key_path = (get-item ~/.ssh/id_ed25519) #Se foi alterado o nome da chave padrao, substitua o id_rsa pelo nome da chave
$ssh_key_alias = 'AM+guimg@LPBR-WDW8AWEF3'  #Altere aqui com o alias do SSH que foi configurado no GIT. Ex 'gometi@LPBRWS0046'
$okta_login_name = 'gabriel.guimaraes-ext@leaseplan.com' #Altere aqui com o endereco de email. Ex 'thiago.gomes@leaseplan.com
$vault_addr = "https://vault.core-services.leaseplan.systems" 

# -- Functions
Function Add-EnvironmentPathVariable {
  Param(
    [string]$value,
    [ValidateSet("user", "machine")]
    [string[]]$Target = "user"
  )
  foreach ($TargetItem in $Target) {
    $current = [System.Environment]::GetEnvironmentVariable("Path", $TargetItem)
    if ( $current.split(';') -notcontains $value ) {
      [Environment]::SetEnvironmentVariable(
        "Path",
        $current.TrimEnd(';') + ";$value",
        [System.EnvironmentVariableTarget]::$TargetItem
      )
    }
    if ($env:Path.split(';') -notcontains $value ) {
      $env:Path += ";$value";
    }
  }
}

Function Set-EnvironmentVariable {
  Param(
    [string]$variable,
    [string]$value,
    [ValidateSet("user", "machine")]
    [string[]]$Target = "user"
  )
  foreach ($TargetItem in $Target) {
    $current = [System.Environment]::GetEnvironmentVariable($variable, $TargetItem)
    if ($current -ne $value) {
      [Environment]::SetEnvironmentVariable(
        $variable,
        $value,
        [System.EnvironmentVariableTarget]::$TargetItem
      )
    }
    if ((Get-Item -Path Env:$variable -ea 0) -ne $value){
      Set-Item -Path Env:$variable -Value $value
    }
  }
}

Function code {
  param (
    $path = $pwd.path
  )
  if ($Path -eq '.') { $path = $pwd.path }
  if ($Path -like './*') { $path = $path -replace ('^./', "$pwd.path/") }
  if ($Path -like '~/*') { $path = $path -replace ('^~/', "$home/") }
  & "C:\Program Files\Microsoft VS Code\bin\code.cmd" $path
}

Function parse-aws {
  [CmdletBinding()]  Param(
    [Parameter(ValueFromPipeline)]
    $item
  )
  begin {
    $token_map = @{
      'secret_key'     = 'AWS_SECRET_ACCESS_KEY';
      'access_key'     = 'AWS_ACCESS_KEY_ID';
      'security_token' = 'AWS_SESSION_TOKEN'
    }
  }
  process {
    $a = ($item -split "\s+")[0, 1];

    if ($token_map.keys -contains $a[0]) {
      $key = $token_map[$a[0]]
      $value = $a[1]
      # write-host ('${0} = "{1}"' -f $key, $value)
      [Environment]::SetEnvironmentVariable($key, $value)
      # Set-Item -Path Env:$key -Value $value
      # New-Item -Path Env:\MYCOMPUTER -Value MY-WIN10-PC
    }
  }
}

function vault-login() {
  vault login --method=okta username=$okta_login_name
}

function usercred($wkl) {
  if ("$wkl") {
    write-host "provided $wkl"
  }
  else {
    $wkl = $( vault secrets list | sls -SimpleMatch 'aws/' | % { [string]::join("/", (($_ -split "\s+")[0].split('/')[0, 1])) } | fzf)
  }

  $(vault read $wkl/creds/infra-userland | parse-aws )
  [Environment]::SetEnvironmentVariable('wkl', $wkl)
  write-host "selected workload: ${wkl}"
}

function EPHEMERAL_PORT() {
  $aListeningPorts = (netstat -aon | select-string -pattern "listening" ) | % {
    ($_ -split "\s+")[2].replace('[::]', 'ipv6').split(':')[1]
  } | select -unique

  Foreach ($i in 60000..65000) {
    if ($aListeningPorts -notcontains $i) {
      break;
    }
  }
  return $i
}

function rdp() {
  $port = $(EPHEMERAL_PORT)
  $sbGetSSMInventory = {
    aws ssm get-inventory --query 'Entities[].Data.\"AWS:InstanceInformation\".Content[?InstanceStatus==`Active`][].{ComputerName:ComputerName, InstanceId:InstanceId, InstanceStatus:InstanceStatus}' | convertfrom-json
  }

  $ssm_inventory_result = . $sbGetSSMInventory
  if (!($ssm_inventory_result)) {
    usercred
    $ssm_inventory_result = . $sbGetSSMInventory
  }

  $instance = $ssm_inventory_result | sort ComputerName | ft -HideTableHeaders | fzf --reverse
  $INSTANCE_NAME, $TARGET_HOST, $Status = $instance -split "\s+"
  if ($TARGET_HOST) {
    $p = ('{\"portNumber\":[\"3389\"],\"localPortNumber\":[\"' + $port + '\"]}')
    aws ssm start-session --target $TARGET_HOST --document-name AWS-StartPortForwardingSession --parameters $p
    # Start-SSMSession -Target $TARGET_HOST -DocumentName AWS-StartPortForwardingSession -Parameter @{portNumber='3389';localPortNumber=('{0}'-f $port)}
  }
  else {
    write-host "No AWS Instance selected."
  }
}
#Error
function git_branch_name_prompt () {
  try {
    $branch = git rev-parse --abbrev-ref HEAD 2> $null
    if ($branch) {
      Write-Host "$branch" -f DarkGreen
    }
  }
  catch {
  }
}

function aws_profile_prompt {
  if ($AWS_PROFILE = [Environment]::GetEnvironmentVariable('AWS_PROFILE')) {
    write-host '[' -n
    write-host "aws:${AWS_PROFILE}" -n -f DarkYellow
    write-host ']' -n
  }
}

function aws_wkl_prompt {
  if ($wkl = [Environment]::GetEnvironmentVariable('wkl')) {
    write-host '[' -n
    write-host "wkl:${wkl}" -n -f DarkYellow
    write-host ']' -n
  }
}

# [enum]::GetValues([System.ConsoleColor]) | % { Write-Host "$(whoami)`t$_`n" -n -f $_ }
function Prompt {
  Write-Host "PS " -n
  Write-Host "$(whoami)" -n -f DarkMagenta ; Write-Host '@' -n -f DarkCyan; Write-host "$(HOSTNAME)" -n -f DarkYellow;
  write-host ":" -n -f red
  write-host ((Get-Location).Path) -n -f DarkCyan
  aws_profile_prompt
  aws_wkl_prompt
  write-host "|" -n -f red
  git_branch_name_prompt
  return "> "
}

# --- Environment variables
$GIT_SSH_SOURCE = (Get-Command -Name ssh).Source;
Add-EnvironmentPathVariable -value "$env:USERPROFILE\.pyenv\pyenv-win\bin"
Add-EnvironmentPathVariable -value "$env:USERPROFILE\.pyenv\pyenv-win\shims"
Add-EnvironmentPathVariable -value "$env:USERPROFILE\.local\bin"
Set-EnvironmentVariable -variable "SSH_KEY_PATH" -value $ssh_key_path
Set-EnvironmentVariable -variable "GIT_SSH" -value ('"{0}"' -f $GIT_SSH_SOURCE)
Set-EnvironmentVariable -variable "GIT_SSH_COMMAND" -value ('"{0}"' -f $GIT_SSH_SOURCE)
Set-EnvironmentVariable -variable "VAULT_ADDR" -value $vault_addr

# --- scripts
# add ssh key if not loaded
# if (!(ssh-add -l | sls -SimpleMatch $ssh_key_path)) {
#   if (ssh-add -l | sls -SimpleMatch $ssh_key_alias) {
#     # echo skip
#   } else {
#     ssh-add $ssh_key_path;
#   }
#   if(!$?) { 'failed to load ssh key is your ssh-agent running? "get-service ssh-agent" '}
# }

# --- alias

$env:AWS_DEFAULT_REGION = 'sa-east-1'