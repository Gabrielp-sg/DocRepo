<powershell>
#!/usr/bin/env pwsh

$awx_url="${awx_url}"
$job="${template_id}"
$secretId="${secret_id}"
$extraVars='${extra_vars}'
$region='${region}'


function Get-InstanceName ($token)
{

    $instance_id=Get-InstanceId ($token)
    return ((Get-EC2Instance -instanceid $instance_id).instances.tags |?{$_.Key -eq 'Name'}).Value
}

function Get-InstanceId ($token)
{
    return Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token" = $token} -Method GET -Uri http://169.254.169.254/latest/meta-data/instance-id
}


function get-SMSecret ($secretId)
{
return ((Get-SECSecretValue -SecretId $secretId -Region $region).SecretString | ConvertFrom-Json)
}


function Get-MetadataToken()
{
    return (Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token-ttl-seconds" = "21600"} -Method PUT -Uri http://169.254.169.254/latest/api/token)
}


function Start-AWXTemplate
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # The name (tag) of the instance to limit the AWX job to.
        [string]
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        $InstanceName,
        # A valid AWX Username
        [string]
        $Username,
        # A valid AWX Password
        [string]
        $Password,
        # The job template ID to launch from AWX
        [string]
        $JobTemplateId,
        #The Uri of the AWX Server
        [string]
        $AWXUri,
        #Extra Variables to pass to the job
        [string]
        $ExtraVars,
        #Instance ID for fine targeting in ASG
        [string]
        $InstanceId
    )
    Begin
    {


        $credentials = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Username+":"+$Password))
        $extra="{ target: " + $target + ", instance_id: "+ $instance_id+","+$extraVars+"}"

        $AWXParams = @{ extra_vars= $extra }|ConvertTo-Json -Compress
        $headers= @{
            'Authorization' = "Basic $credentials";
            'Content-Type' = 'application/json'
        }
        $postParams = @{
            Uri         = "$AWXUri/api/v2/job_templates/$JobTemplateId/launch/";
            Method      = 'POST';
            Body        = $AWXParams;
            ContentType = 'application/json'
            Headers     = $headers
        }
    }
    Process
    {
        Invoke-RestMethod @postParams
    }
}

# Install the AWS Cli to access instance metadata
Install-PackageProvider -Name NuGet -Force
Install-Module -Name AWSPowerShell -Force

$token = Get-MetadataToken
$secret = (get-SMSecret ("awx/"+$secretId))
$target=Get-InstanceName ($token)
$instance_id=Get-InstanceId  ($token)
Start-AWXTemplate -InstanceName $target -AWXUri $awx_url -JobTemplateId $job -Username $secretId -Password $secret.password -ExtraVars $extraVars -InstanceId $instance_id

</powershell>
