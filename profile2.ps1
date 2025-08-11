# Alias configuration
Set-Alias -Name k -Value "C:\Program Files\Docker\Docker\resources\bin\kubectl.exe"

# Custom environment configuration
$env:AWS_DEFAULT_REGION = 'sa-east-1'
$proxy='http://LPGPZENPROXY.EMEA.LEASEPLANCORP.NET:80'
$ENV:HTTP_PROXY=$proxy
$ENV:HTTPS_PROXY=$proxy
$ENV:NO_PROXY='localhost,127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,core-services.leaseplan.systems'

# Set options for PSReadLine using Fzf, if Fzf is installed and configured
if (Get-Module -ListAvailable -Name PSFzf) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# Function to log into Vault using the Okta authentication method
function vl { 
    $username = Read-Host "Please enter your Okta username (firstname.lastname@leaseplan.com)"
    vault login --method=okta username=$username
}

# Function to open a Git Bash shell
function Open-GitBash { 
    & 'C:\Program Files\Git\bin\sh.exe' --login 
}

# Function to read AWS credentials from Vault and update AWS configuration
function aws-vault-read {
    param(
        [Parameter(Mandatory)]
        [string]$workload,
        [string]$profileName = "default"  # Default profile name set to 'default'
    )
    Write-Output "Reading AWS credentials for workload: $workload"

    # Fetch AWS credentials from Vault
    $awsCredentials = vault read "aws/$workload/creds/infra-userland" -format=json | ConvertFrom-Json
    Write-Output "AWS Credentials fetched: Access Key = $($awsCredentials.data.access_key)"

    # Update AWS CLI configuration with fetched credentials
    aws configure set profile.$profileName.aws_access_key_id $awsCredentials.data.access_key
    aws configure set profile.$profileName.aws_secret_access_key $awsCredentials.data.secret_key
    aws configure set profile.$profileName.region 'eu-west-1'  # Set default region

    # Optionally, set this profile as default if required
    aws configure set default.aws_access_key_id $awsCredentials.data.access_key
    aws configure set default.aws_secret_access_key $awsCredentials.data.secret_key
    aws configure set default.region 'eu-west-1'

    # Display the updated configuration for verification
    aws configure list --profile $profileName

    # Setting AWS credentials in the current PowerShell session
    $env:AWS_ACCESS_KEY_ID = $awsCredentials.data.access_key
    $env:AWS_SECRET_ACCESS_KEY = $awsCredentials.data.secret_key
    $env:AWS_DEFAULT_REGION = 'eu-west-1'

    if ($awsCredentials.data.PSObject.Properties.Name -contains 'security_token') {
        $env:AWS_SESSION_TOKEN = $awsCredentials.data.security_token
    }

    Write-Host "AWS Credentials updated for session: Access Key = $($awsCredentials.data.access_key)"
}

# Function to interactively select a workload and read credentials
function usercred() { 
    # List vault secrets and use Fzf to select one interactively
    $workload = vault secrets list -format table | Select-String '[A-Z]{3,3}/\d{4}-[A-Z]{3,3}-[dtapm]/' | Invoke-Fzf 
    $workload_env = ($workload.split(" ")[0]).split("/")[1]

    # Read and set AWS credentials for the selected workload
    aws-vault-read $workload_env 
    #lzt creds aws --role infra-userland --vault-addr https://vault.core-services.leaseplan.systems -S
} 

# Setting PowerShell execution policy for the current user if not already set
if ((Get-ExecutionPolicy -Scope CurrentUser) -ne 'RemoteSigned') {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -force
    Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -force
    Set-ExecutionPolicy RemoteSigned -Scope Process -force
}

# Ensure the Vault address is set for the session
$env:VAULT_ADDR = 'https://vault.core-services.leaseplan.systems'
Write-Host "Vault Address is set to: $env:VAULT_ADDR"

# Automatically update credentials on session start
$initialWorkload = Read-Host "Please enter the initial workload (e.g., 9998-wkl-d)"
aws-vault-read -workload $initialWorkload

Import-Module posh-git
