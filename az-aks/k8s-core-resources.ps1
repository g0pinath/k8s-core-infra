Param(
  [ValidateSet("OMS","EFKinCluster", "ElasticInCloud",  "None")]
        [String]
        $K8SLogMonitoringType,
  [ValidateSet("OMS", "HAPrometheus-Thanos",  "SingleInstancePrometheus", "None")]
        [String]
        $K8SMetricsMonitoringType,        
    [ValidateSet("true","false")]
        [String]
        $requireDefectDojo = "true",
    [ValidateSet("true","false")]
        [String]
        $requireSonarQube = "true",
    [ValidateSet("az","aws")]
        [String]
        $cloudProvider = "az",
    [ValidateSet("true","false")]
        [String]
        $createSPNifNotExists4K8S = "true",
    [ValidateSet("true","false")]
        [String]
        $dryRunforGithubActions = "false",
    [ValidateSet("true","false")]
        [String]
        $applyTFTemplates = "true",
    [ValidateSet("linkerd", "None")]
    [string]
        $serviceMeshType="linkerd",
    [ValidateSet("DEV","PRD")]
        [String]
        $k8sEnvironment = "DEV",    

    [ValidateSet("true","false")]
        [String]
        $requireTLSSecrets = "false", 

    [ValidateSet("true","false")]
        [String]
        $requireAzureFrontDoor = "true", 

    [ValidateSet("PrimaryRegionOnly","PrimaryandSecondaryRegion")]
        [String]
        $productionClusterConfigType = "PrimaryandSecondaryRegion",  
    [ValidateSet("Nginx","AppGW")]
        [String]
        $IngressController = "Nginx", 
    [ValidateSet("AzPolicy","DIY-GateKeeper")]
        [String]
        $Policies = "DIY-GateKeeper",  
    #The default value will create 2 clusters, one in the primary region(Australia East) and another in secondary region(SouthEast Asia). 
    #Region == Location in Azure.   
    #Default values for Dev SPN, K8S cluster RG and K8S nodes RG name
    $DEFAULT_DEV_K8S_SPN_NAME="dev-k8s-cluster-spn",    
    $DEFAULT_DEV_K8S_RG_NAME="RG-DEV-K8S-CLUSTER",
    $DEFAULT_DEV_K8S_NODE_RG_NAME="RG-DEV-K8S-NODES",
    $DEFAULT_DEV_AZ_LOCATION="Australia East",
    $DEFAULT_DEV_DD_SPN_NAME="dev-defectdojo-sso-spn",
    $DEFAULT_DEV_GRAFANA_SPN_NAME="dev-grafana-sso-spn",
    
    $DEFAULT_DEV_URL_SUFFIX="cloudkube.xyz",
    #Default values for PRD SPN, K8S cluster RG and K8S nodes RG name
    $DEFAULT_PRD_K8S_SPN_NAME="prd-k8s-cluster-spn", #Azure AD is globally redundant, so no need for another SPN
    $DEFAULT_PRD_A_K8S_RG_NAME="RG-PRD-A-K8S-CLUSTER", #PRIMARY zone -- Australia East
    $DEFAULT_PRD_B_K8S_RG_NAME="RG-PRD-B-K8S-CLUSTER", #Secondary/DR zone -- SouthEast Asia
    $DEFAULT_PRD_A_K8S_NODE_RG_NAME="RG-PRD-A-K8S-NODES",
    $DEFAULT_PRD_B_K8S_NODE_RG_NAME="RG-PRD-B-K8S-NODES",
    $DEFAULT_PRD_A_AZ_LOCATION="Australia East",
    $DEFAULT_PRD_B_AZ_LOCATION="southeastasia",
    $DEFAULT_PRD_DD_SPN_NAME="prd-defectdojo-sso-spn", #Azure AD is globally redundant, so no need for another SPN
    $DEFAULT_PRD_GRAFANA_SPN_NAME="prd-grafana-sso-spn",
    $DEFAULT_PRD_URL_SUFFIX="cloudkube.xyz" #This is the domain suffix used for all apps - DefectDojo, Grafana.

  )

Function CheckMandatoryEnvVars($k8sEnvironment)
{
  if(($env:ARM_TENANT_ID | Measure).Count -eq 0)
      {
            Write-Error "Env var ARM_TENANT_ID is missing - this is a mandatory value that needs to be set."
      }
  switch($k8sEnvironment)
  {
    
    "DEV"
    {
        if(($env:DEV_K8S_KV_NAME | Measure).Count -eq 0)
          {
            Write-Error "Env var DEV_K8S_KV_NAME is missing - this is a mandatory value that needs to be set."
          }
        if(($env:DEV_K8S_NAME | Measure).Count -eq 0)
          {
            Write-Error "Env var DEV_K8S_NAME is missing - this is a mandatory value that needs to be set."
          }
        
        if(($env:DEV_ARM_SUBSCRIPTION_ID | Measure).Count -eq 0)
          {
            Write-Error "Env var DEV_ARM_SUBSCRIPTION_ID is missing - this is a mandatory value that needs to be set."
          } 
        if(($env:DEV_TF_STORAGE_NAME | Measure).Count -eq 0)
          {
            Write-Error "Env var DEV_TF_STORAGE_NAME is missing - this is a mandatory value that needs to be set."
          }   
        #please set this var(regardless of AKS integration into OMS is required or not). 
        #Its hard to conditionally deploy LA in the current TF flow I have. Regardless of monitoring type set to OMS or none an  LA will
        #always be created  but not used by AKS so it wouldnt cost anything. 
        if(($env:DEV_LA_NAME | Measure).Count -eq 0)
          {
            Write-Error "Env var DEV_LA_NAME is missing - this is a mandatory value that needs to be set."
          }
          
    }
    "PRD-A"
    {
       if(($env:PRD_A_K8S_KV_NAME | Measure).Count -eq 0)
          {
            Write-Error "Env var PRD_A_K8S_KV_NAME is missing - this is a mandatory value that needs to be set."
          }
        if(($env:PRD_A_K8S_NAME | Measure).Count -eq 0)
          {
            Write-Error "Env var PRD_A_K8S_NAME is missing - this is a mandatory value that needs to be set."
          }
        if(($env:PRD_A_ARM_SUBSCRIPTION_ID | Measure).Count -eq 0)
          {
            Write-Error "Env var PRD_A_ARM_SUBSCRIPTION_ID is missing - this is a mandatory value that needs to be set."
          }
        if(($env:PRD_A_TF_STORAGE_NAME | Measure).Count -eq 0)
          {
            Write-Error "Env var PRD_A_TF_STORAGE_NAME is missing - this is a mandatory value that needs to be set."
          }   
         #please set this var(regardless of AKS integration into OMS is required or not). 
        #Its hard to conditionally deploy LA in the current TF flow I have. Regardless of monitoring type set to OMS or none an  LA will
        #always be created  but not used by AKS so it wouldnt cost anything. 
        if(($env:PRD_A_LA_NAME | Measure).Count -eq 0)
          {
            Write-Error "Env var PRD_A_LA_NAME is missing - this is a mandatory value that needs to be set."
          }
    }    
    "PRD-B"
    {
       if(($env:PRD_B_K8S_KV_NAME | Measure).Count -eq 0)
          {
            Write-Error "Env var PRD_B_K8S_KV_NAME is missing - this is a mandatory value that needs to be set."
          }
        if(($env:PRD_B_K8S_NAME | Measure).Count -eq 0)
          {
            Write-Error "Env var PRD_B_K8S_NAME is missing - this is a mandatory value that needs to be set."
          }
        if(($env:PRD_B_ARM_SUBSCRIPTION_ID | Measure).Count -eq 0)
          {
            Write-Error "Env var PRD_B_ARM_SUBSCRIPTION_ID is missing - this is a mandatory value that needs to be set."
          }
        if(($env:PRD_B_TF_STORAGE_NAME | Measure).Count -eq 0)
          {
            Write-Error "Env var PRD_B_TF_STORAGE_NAME is missing - this is a mandatory value that needs to be set."
          }   
        #please set this var(regardless of AKS integration into OMS is required or not). 
        #Its hard to conditionally deploy LA in the current TF flow I have. Regardless of monitoring type set to OMS or none an  LA will
        #always be created  but not used by AKS so it wouldnt cost anything. 
        if(($env:PRD_B_LA_NAME | Measure).Count -eq 0)
          {
            Write-Error "Env var PRD_B_LA_NAME is missing - this is a mandatory value that needs to be set."
          }
    }    
  }
}
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
if((Get-Module powershell-yaml -ListAvailable |Measure).Count -ne 1)
{
  Install-Module powershell-yaml -Force
}

Import-Module powershell-yaml
Function CreateKeyVault($k8sEnvironment)
{
  switch($k8sEnvironment)
  {
    "DEV"
    {
      if(($env:DEV_K8S_RG_NAME | Measure).Count -eq 0)
          {
            $env:DEV_K8S_RG_NAME = $DEFAULT_DEV_K8S_RG_NAME
          }
      if(($env:DEV_AZ_LOCATION | Measure).Count -eq 0)
          {
            $env:DEV_AZ_LOCATION = $DEFAULT_DEV_AZ_LOCATION
          }

      if(($env:DEV_K8S_NODE_RG_NAME | Measure).Count -eq 0)
          {
            $env:DEV_K8S_NODE_RG_NAME = $DEFAULT_DEV_K8S_NODE_RG_NAME
          }

      #Select the subscription.
      #Select-AzSubscription -Subscription "$env:DEV_ARM_SUBSCRIPTION_ID"
      #create RG if it doesnt exist.
      if((Get-AzResourceGroup $env:DEV_K8S_RG_NAME -ErrorAction SilentlyContinue | Measure).Count -eq 0)
      {
        New-AzResourceGroup -Name $env:DEV_K8S_RG_NAME -Location $ENV:DEV_AZ_LOCATION
      }
      if((Get-AzKeyVault $env:DEV_K8S_KV_NAME -ErrorAction SilentlyContinue | Measure).Count -eq 0)
      {
        New-AzKeyVault -VaultName $env:DEV_K8S_KV_NAME -ResourceGroupName $env:DEV_K8S_RG_NAME  -Location $ENV:DEV_AZ_LOCATION
      }
      return (Get-AzKeyVault $env:DEV_K8S_KV_NAME -ErrorAction SilentlyContinue | Measure).Count
    }
    "PRD-A"
    {
      if(($env:PRD_A_K8S_RG_NAME | Measure).Count -eq 0)
          {
            $env:PRD_A_K8S_RG_NAME = $DEFAULT_PRD_A_K8S_RG_NAME
          }
      
      if(($env:PRD_A_AZ_LOCATION | Measure).Count -eq 0)
          {
            $env:PRD_A_AZ_LOCATION = $DEFAULT_PRD_A_AZ_LOCATION
          }


      if(($env:PRD_A_K8S_NODE_RG_NAME | Measure).Count -eq 0)
          {
            $env:PRD_A_K8S_NODE_RG_NAME = $DEFAULT_PRD_A_K8S_NODE_RG_NAME
          }

      
      #Select-AzSubscription -Subscription "$env:PRD_ARM_SUBSCRIPTION_ID"
      if((Get-AzResourceGroup $env:PRD_A_K8S_RG_NAME -ErrorAction SilentlyContinue | Measure).Count -eq 0)
      {
        New-AzResourceGroup -Name $env:PRD_A_K8S_RG_NAME -Location $ENV:PRD_A_AZ_LOCATION
      }
      if((Get-AzKeyVault $env:PRD_A_K8S_KV_NAME -ErrorAction SilentlyContinue | Measure).Count -eq 0)
      {
        New-AzKeyVault -VaultName $env:PRD_A_K8S_KV_NAME -ResourceGroupName $env:PRD_A_K8S_RG_NAME  -Location $ENV:PRD_A_AZ_LOCATION
      }
      return (Get-AzKeyVault $env:PRD_A_K8S_KV_NAME -ErrorAction SilentlyContinue | Measure).Count
    }
    "PRD-B"
    {
      if(($env:PRD_B_K8S_RG_NAME | Measure).Count -eq 0)
          {
            $env:PRD_B_K8S_RG_NAME = $DEFAULT_PRD_B_K8S_RG_NAME
          }
      if(($env:PRD_B_AZ_LOCATION | Measure).Count -eq 0)
          {
            $env:PRD_B_AZ_LOCATION = $DEFAULT_PRD_B_AZ_LOCATION
          }


      if(($env:PRD_B_K8S_NODE_RG_NAME | Measure).Count -eq 0)
          {
            $env:PRD_B_K8S_NODE_RG_NAME = $DEFAULT_PRD_B_K8S_NODE_RG_NAME
          }

      
      #Select-AzSubscription -Subscription "$env:PRD_ARM_SUBSCRIPTION_ID"
      if((Get-AzResourceGroup $env:PRD_B_K8S_RG_NAME -ErrorAction SilentlyContinue | Measure).Count -eq 0)
      {
        New-AzResourceGroup -Name $env:PRD_B_K8S_RG_NAME -Location $ENV:PRD_B_AZ_LOCATION
      }
      if((Get-AzKeyVault $env:PRD_B_K8S_KV_NAME -ErrorAction SilentlyContinue | Measure).Count -eq 0)
      {
        New-AzKeyVault -VaultName $env:PRD_B_K8S_KV_NAME -ResourceGroupName $env:PRD_B_K8S_RG_NAME  -Location $ENV:PRD_B_AZ_LOCATION
      }
      return (Get-AzKeyVault $env:PRD_B_K8S_KV_NAME -ErrorAction SilentlyContinue | Measure).Count
    }
        
  }
  
}
Function CreateClusterSPN($createSPNifNotExists4K8S, $k8sEnvironment)
{
  switch($k8sEnvironment)
  {
    "DEV"
    {
      if($createSPNifNotExists4K8S -eq "true")
      {
          if(($env:DEV_K8S_SPN_NAME | Measure).Count -eq 0)
          {
            $env:DEV_K8S_SPN_NAME = $DEFAULT_DEV_K8S_SPN_NAME
          }
          
          IF((GET-AzADServicePrincipal -DisplayName $env:DEV_K8S_SPN_NAME | MEASURE).count -eq 0)
          {
              #$sp = New-AzADServicePrincipal -DisplayName $env:DEV_K8S_SPN_NAME -SkipAssignment
              #PS method isnt working for Terraform -- not sure what the equivalent for --sdk-auth true is in PowerShell.
              #$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sp.Secret)
              #$UnsecureSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
              az account set -s $env:DEV_ARM_SUBSCRIPTION_ID
              Write-Host "Created SPN for the Cluster --- $env:DEV_K8S_SPN_NAME"

              $CLIOutput = az ad sp create-for-rbac -n $env:DEV_K8S_SPN_NAME --role Contributor `
              --scopes /subscriptions/$env:DEV_ARM_SUBSCRIPTION_ID --sdk-auth true
              $ENV:DEV_ARM_CLIENT_ID = ($CLIOutput|convertfrom-json).ClientID
              $ENV:DEV_ARM_CLIENT_SECRET = ($CLIOutput|convertfrom-json).clientSecret
               
              #assign this SPN editor access on the RG that will have the K8S resource.
              $spnObjId = (Get-AzADServicePrincipal -DisplayName $env:DEV_K8S_SPN_NAME).id  
                            
              #subscription access required to register providers.
              #resourcegroups/$env:DEV_K8S_RG_NAME
              #KV access needs to be set explicitly, RG editor access wont grant the SPN to retrieve the secrets.
              Set-AzKeyVaultAccessPolicy -VaultName $env:DEV_K8S_KV_NAME  -ObjectId $spnObjId `
              -PermissionsToSecrets "all"
              #Update the values in Vault
              
              Write-Host "Created SPN secrets in KV --- $env:DEV_K8S_KV_NAME -- DEV_ARM_CLIENT_ID -- $env:DEV_ARM_CLIENT_ID"
              $Secret = ConvertTo-SecureString -String $ENV:DEV_ARM_CLIENT_ID -AsPlainText -Force
              Set-AzKeyVaultSecret -VaultName $env:DEV_K8S_KV_NAME -Name "DEV-ARM-CLIENT-ID" -SecretValue $Secret
              Write-Host "Created SPN secrets in KV --- $env:DEV_K8S_KV_NAME -- DEV_ARM_CLIENT_SECRET -- $env:DEV_ARM_CLIENT_SECRET"
              $Secret = ConvertTo-SecureString -String $ENV:DEV_ARM_CLIENT_SECRET -AsPlainText -Force
              Set-AzKeyVaultSecret -VaultName $env:DEV_K8S_KV_NAME -Name "DEV-ARM-CLIENT-SECRET" -SecretValue $Secret
              Write-Host "Created SPN secrets in KV --- $env:DEV_K8S_KV_NAME"
          }
      }      
    }
    "PRD-A"
    {
      if($createSPNifNotExists4K8S -eq "true")
      {
          if(($env:PRD_K8S_SPN_NAME | Measure).Count -eq 0)
          {
            $env:PRD_K8S_SPN_NAME = $DEFAULT_PRD_K8S_SPN_NAME
          }
      
          IF((GET-AzADServicePrincipal -DisplayName $env:PRD_K8S_SPN_NAME | MEASURE).count -eq 0)
          {
              
              az account set -s $env:PRD_A_ARM_SUBSCRIPTION_ID
              $CLIOutput = az ad sp create-for-rbac -n $env:PRD_K8S_SPN_NAME --role Contributor `
              --scopes /subscriptions/$env:PRD_A_ARM_SUBSCRIPTION_ID --sdk-auth true
              $ENV:PRD_ARM_CLIENT_ID = ($CLIOutput|convertfrom-json).ClientID
              $ENV:PRD_ARM_CLIENT_SECRET = ($CLIOutput|convertfrom-json).clientSecret
               
              #assign this SPN editor access on the RG that will have the K8S resource.
              $spnObjId = (Get-AzADServicePrincipal -DisplayName $env:PRD_K8S_SPN_NAME).id  
              
              Set-AzKeyVaultAccessPolicy -VaultName $env:PRD_A_K8S_KV_NAME  -ObjectId $spnObjId `
              -PermissionsToSecrets "all"
              #Update the values in Vault
              $Secret = ConvertTo-SecureString -String $ENV:PRD_ARM_CLIENT_ID -AsPlainText -Force
              Set-AzKeyVaultSecret -VaultName $env:PRD_A_K8S_KV_NAME -Name "PRD-ARM-CLIENT-ID" -SecretValue $Secret
              $Secret = ConvertTo-SecureString -String $ENV:PRD_ARM_CLIENT_SECRET -AsPlainText -Force
              Set-AzKeyVaultSecret -VaultName $env:PRD_A_K8S_KV_NAME -Name "PRD-ARM-CLIENT-SECRET" -SecretValue $Secret    
              
          }
      }      
    }   
  
  "PRD-B"
    {
      if($createSPNifNotExists4K8S -eq "true")
      {
          #PRD A AND B uses same SPN, so for secondary zone, we are just checking in the creds to KV.
          
              #Update the values in Vault
              $Secret = ConvertTo-SecureString -String $ENV:PRD_ARM_CLIENT_ID -AsPlainText -Force
              Set-AzKeyVaultSecret -VaultName $env:PRD_B_K8S_KV_NAME -Name "PRD-ARM-CLIENT-ID" -SecretValue $Secret
              $Secret = ConvertTo-SecureString -String $ENV:PRD_ARM_CLIENT_SECRET -AsPlainText -Force
              Set-AzKeyVaultSecret -VaultName $env:PRD_B_K8S_KV_NAME -Name "PRD-ARM-CLIENT-SECRET" -SecretValue $Secret 
          
          
      }      
    }   
  }
}

Function CreateADPrincipalandCheckinCredstoKV($SPN_DP_TO_CHECK, $K8S_KV_NAME, $app_cl_id,  $app_cl_secret, $LOGIN_URL)
{
   $sp = New-AzADServicePrincipal -DisplayName $SPN_DP_TO_CHECK -SkipAssignment
   #PS method isnt working for Terraform -- not sure what the equivalent for --sdk-auth true is in PowerShell.
   $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sp.Secret)
   $UnsecureSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
   $CLIENT_ID = $SP.ApplicationId
   $CLIENT_SECRET = $UnsecureSecret 
   $Secret = ConvertTo-SecureString -String $CLIENT_ID -AsPlainText -Force
   Set-AzKeyVaultSecret -VaultName $K8S_KV_NAME -Name "$app_cl_id" -SecretValue $Secret
   $Secret = ConvertTo-SecureString -String $CLIENT_SECRET -AsPlainText -Force
   Set-AzKeyVaultSecret -VaultName $K8S_KV_NAME -Name "$app_cl_secret" -SecretValue $Secret
   
       #Set redirect URIs - this has to match the login URL of DefectDojo.
     $spnObjId = (Get-AzADApplication -DisplayName $SPN_DP_TO_CHECK | select ObjectId).ObjectId
     Set-AzADApplication   -ObjectId $spnObjId -ReplyUrls $LOGIN_URL

}
Function CreateAppsSPN($k8sEnvironment, $appName, $cloudProvider, $dryRunforGithubActions)
{
  #Login URL for DD must have suffix /complete/azuread-tenant-oauth2/ -- https://defectdojo.readthedocs.io/en/latest/social-authentication.html
  Write-host "CreateAppsSPN called for $appname"
  if($appName -eq "DEFECTDOJO")
  {
    $DEV_DD_LOGIN_URL_PREFIX = "https://" + $cloudProvider + "-" + $appName.tolower() + "-" + "dev."
    $PRD_DD_LOGIN_URL_PREFIX = "https://" + $cloudProvider + "-" + $appName.tolower() + "prd"  
    $AAD_SUFIX = "/complete/azuread-tenant-oauth2/"
  }ELSEIF($APPNAME -EQ "GRAFANA")
  {
    
    $DEV_GRAFANA_LOGIN_URL_PREFIX = "https://" + $cloudProvider + "-" + $appName.tolower() + "-" + "dev."
    $PRD_GRAFANA_LOGIN_URL_PREFIX = "https://" + $cloudProvider + "-" + "grafana-" + "prd" 
    $AAD_SUFIX = "/login/azuread" 
    Write-host "---->"$DEV_GRAFANA_LOGIN_URL_PREFIX
  }
  
  switch($k8sEnvironment)
  {
    "DEV"
    {
          if(($env:DEV_DD_SPN_NAME | Measure).Count -eq 0)
            {
              $env:DEV_DD_SPN_NAME = $DEFAULT_DEV_DD_SPN_NAME
            }
          if(($env:DEV_GRAFANA_SPN_NAME | Measure).Count -eq 0)
            {
              $env:DEV_GRAFANA_SPN_NAME = $DEFAULT_DEV_GRAFANA_SPN_NAME
            }
            $app_cl_id= "DEV-" + $appName + "-CLIENT-ID"
            $app_cl_secret = "DEV-" + $appName + "-CLIENT-SECRET"
            $env:DEV_GRAFANA_LOGIN_URL = $DEV_GRAFANA_LOGIN_URL_PREFIX + $DEFAULT_DEV_URL_SUFFIX + $AAD_SUFIX #this is set on the SPNs reply url
            $env:GRAFANA_INI_URL = $DEV_GRAFANA_LOGIN_URL_PREFIX + $DEFAULT_DEV_URL_SUFFIX #this is for grafan.ini used by helm and is the base URL
            
            $env:DEV_DD_LOGIN_URL = $DEV_DD_LOGIN_URL_PREFIX + $DEFAULT_DEV_URL_SUFFIX + $AAD_SUFIX
            IF($APPNAME -EQ "DEFECTDOJO"){$SPN_DP_TO_CHECK = $env:DEV_DD_SPN_NAME; $LOGIN_URL=$env:DEV_DD_LOGIN_URL}
            ELSEIF($APPNAME -EQ "GRAFANA"){$SPN_DP_TO_CHECK = $env:DEV_GRAFANA_SPN_NAME; $LOGIN_URL=$env:DEV_GRAFANA_LOGIN_URL}
            
            
            IF((GET-AzADServicePrincipal -DisplayName $SPN_DP_TO_CHECK | MEASURE).count -eq 0 -and $dryRunforGithubActions -eq "true")
            {  
              
              CreateADPrincipalandCheckinCredstoKV $SPN_DP_TO_CHECK $env:DEV_K8S_KV_NAME $app_cl_id  $app_cl_secret $LOGIN_URL
            }  
    }
    "PRD-A"
    {
      if(($env:PRD_DD_SPN_NAME | Measure).Count -eq 0)
            {
              $env:PRD_DD_SPN_NAME = $DEFAULT_PRD_DD_SPN_NAME
            }
      if(($env:PRD_GRAFANA_SPN_NAME | Measure).Count -eq 0)
            {
              $env:PRD_GRAFANA_SPN_NAME = $DEFAULT_PRD_GRAFANA_SPN_NAME
            }
            
            $app_cl_id= "PRD-" + $appName + "-CLIENT-ID"
            $app_cl_secret = "PRD-" + $appName + "-CLIENT-SECRET"
            $env:PRD_DD_LOGIN_URL = $PRD_DD_LOGIN_URL_PREFIX + "a" +$DEFAULT_PRD_URL_SUFFIX + $AAD_SUFIX #this is set on the SPNs reply url
            $env:PRD_GRAFANA_LOGIN_URL = $PRD_GRAFANA_LOGIN_URL_PREFIX + "a" +$DEFAULT_PRD_URL_SUFFIX + $AAD_SUFIX
            $env:GRAFANA_INI_URL = $PRD_GRAFANA_LOGIN_URL_PREFIX + $DEFAULT_PRD_URL_SUFFIX #this is for grafan.ini used by helm and is the base URL
            IF($APPNAME -EQ "DEFECTDOJO"){$SPN_DP_TO_CHECK = $env:PRD_DD_SPN_NAME; $LOGIN_URL=$env:PRD_DD_LOGIN_URL}
            ELSEIF($APPNAME -EQ "GRAFANA"){$SPN_DP_TO_CHECK = $env:PRD_GRAFANA_SPN_NAME; $LOGIN_URL=$env:PRD_GRAFANA_LOGIN_URL}
            
            IF((GET-AzADServicePrincipal -DisplayName $env:PRD_DD_SPN_NAME | MEASURE).count -eq 0 -and $dryRunforGithubActions -eq "true")
            {
              CreateADPrincipalandCheckinCredstoKV $SPN_DP_TO_CHECK $env:PRD_A_K8S_KV_NAME $app_cl_id  $app_cl_secret $LOGIN_URL 
            }  
         
    } 
    "PRD-B"
    {
      if(($env:PRD_DD_SPN_NAME | Measure).Count -eq 0)
            {
              $env:PRD_DD_SPN_NAME = $DEFAULT_PRD_DD_SPN_NAME
            }
      if(($env:PRD_GRAFANA_SPN_NAME | Measure).Count -eq 0)
            {
              $env:PRD_GRAFANA_SPN_NAME = $DEFAULT_PRD_GRAFANA_SPN_NAME
            }
            
            $app_cl_id= "PRD-" + $appName + "-CLIENT-ID"
            $app_cl_secret = "PRD-" + $appName + "-CLIENT-SECRET"
            $env:PRD_DD_LOGIN_URL = $PRD_DD_LOGIN_URL_PREFIX + "b" +$DEFAULT_PRD_URL_SUFFIX + $AAD_SUFIX
            $env:PRD_GRAFANA_LOGIN_URL = $PRD_GRAFANA_LOGIN_URL_PREFIX + "b" +$DEFAULT_PRD_URL_SUFFIX + $AAD_SUFIX #this is set on the SPNs reply url
            $env:GRAFANA_INI_URL = $PRD_GRAFANA_LOGIN_URL_PREFIX + $DEFAULT_PRD_URL_SUFFIX #this is for grafan.ini used by helm and is the base URL
            IF($APPNAME -EQ "DEFECTDOJO"){$SPN_DP_TO_CHECK = $env:PRD_DD_SPN_NAME; $LOGIN_URL=$env:PRD_DD_LOGIN_URL}
            ELSEIF($APPNAME -EQ "GRAFANA"){$SPN_DP_TO_CHECK = $env:PRD_GRAFANA_SPN_NAME; $LOGIN_URL=$env:PRD_GRAFANA_LOGIN_URL}
            
            IF((GET-AzADServicePrincipal -DisplayName $SPN_DP_TO_CHECK | MEASURE).count -eq 0 -and $dryRunforGithubActions -eq "true")
            {
              CreateADPrincipalandCheckinCredstoKV $SPN_DP_TO_CHECK $env:PRD_B_K8S_KV_NAME $app_cl_id  $app_cl_secret $LOGIN_URL 
            }  
         
    }   
  }
}
Function CreateStorageAccountforTF($k8sEnvironment)
{
  #This is also the account used for Thanos Long term storage.
  
  switch($k8sEnvironment)
  {
    "DEV"
    {
      if((Get-AzStorageAccount -ResourceGroupName  $env:DEV_K8S_RG_NAME -Name $env:DEV_TF_STORAGE_NAME -ErrorAction SilentlyContinue | Measure).Count -eq 0)
      {
        New-AzStorageAccount -ResourceGroupName $env:DEV_K8S_RG_NAME `
          -Name $env:DEV_TF_STORAGE_NAME `
          -Location $ENV:DEV_AZ_LOCATION `
          -SkuName Standard_LRS `
          -Kind StorageV2
      }
      Set-AzCurrentStorageAccount -Name $env:DEV_TF_STORAGE_NAME -ResourceGroupName $env:DEV_K8S_RG_NAME
      if((Get-AzStorageContainer -Name "tfstate" -ErrorAction SilentlyContinue | Measure).Count -eq 0)
        {
            New-AzStorageContainer -Name "tfstate" -Permission Off
        }
        if((Get-AzStorageContainer -Name "thanos" -ErrorAction SilentlyContinue | Measure).Count -eq 0)
        {
            New-AzStorageContainer -Name "thanos" -Permission Off
        }
       $env:THANOS_LTR_SAKEY=(Get-AzStorageAccountKey -ResourceGroupName $env:DEV_K8S_RG_NAME -AccountName $env:DEV_TF_STORAGE_NAME | select value).value[0]
    }
    "PRD-A"
    {
      if((Get-AzStorageAccount -ResourceGroupName  $env:PRD_A_K8S_RG_NAME -Name $env:PRD_A_TF_STORAGE_NAME -ErrorAction SilentlyContinue | Measure).Count -eq 0)
      {
        New-AzStorageAccount -ResourceGroupName $env:PRD_A_K8S_RG_NAME `
          -Name $env:PRD_A_TF_STORAGE_NAME `
          -Location $ENV:PRD_A_AZ_LOCATION `
          -SkuName Standard_LRS `
          -Kind StorageV2
      }
      Set-AzCurrentStorageAccount -Name $env:PRD_A_TF_STORAGE_NAME -ResourceGroupName $env:PRD_A_K8S_RG_NAME
        if((Get-AzStorageContainer -Name "tfstate" -ErrorAction SilentlyContinue | Measure).Count -eq 0)
        {
            New-AzStorageContainer -Name "tfstate" -Permission Off
        }
        if((Get-AzStorageContainer -Name "thanos" -ErrorAction SilentlyContinue | Measure).Count -eq 0)
        {
            New-AzStorageContainer -Name "thanos" -Permission Off
        }
         $env:THANOS_LTR_SAKEY=(Get-AzStorageAccountKey -ResourceGroupName $env:PRD_A_K8S_RG_NAME -AccountName $env:PRD_A_TF_STORAGE_NAME | select value).value[0]
    }
    "PRD-B"
    {
      if((Get-AzStorageAccount -ResourceGroupName $env:PRD_B_K8S_RG_NAME -Name $env:PRD_B_TF_STORAGE_NAME -ErrorAction SilentlyContinue | Measure).Count -eq 0)
      {
        New-AzStorageAccount -ResourceGroupName $env:PRD_B_K8S_RG_NAME `
          -Name $env:PRD_B_TF_STORAGE_NAME `
          -Location $ENV:PRD_B_AZ_LOCATION `
          -SkuName Standard_LRS `
          -Kind StorageV2
      }
       Set-AzCurrentStorageAccount -Name $env:PRD_B_TF_STORAGE_NAME -ResourceGroupName $env:PRD_B_K8S_RG_NAME
       if((Get-AzStorageContainer -Name "tfstate" -ErrorAction SilentlyContinue | Measure).Count -eq 0)
        {
            New-AzStorageContainer -Name "tfstate" -Permission Off
        }
        if((Get-AzStorageContainer -Name "thanos" -ErrorAction SilentlyContinue | Measure).Count -eq 0)
        {
            New-AzStorageContainer -Name "thanos" -Permission Off
        }
         
         $env:THANOS_LTR_SAKEY=(Get-AzStorageAccountKey -ResourceGroupName $env:PRD_B_K8S_RG_NAME -AccountName $env:PRD_B_TF_STORAGE_NAME | select value).value[0]
    }
  }
  
  
}
Function BuildK8STFInfra($K8SMonitoringType, $k8sEnvironment, $IngressController, $enable_azure_policy)
{
  switch($k8sEnvironment)
  {
    "DEV"
    {
      
      cd  az-aks/k8s-infra/tf/nonProd 
      #Get KV secrets for TF to inject the SPN creds into K8S.
      $secret = Get-AzKeyVaultSecret -VaultName $env:DEV_K8S_KV_NAME -Name "DEV-ARM-CLIENT-ID"
      $secretInPlainText = $secret.SecretValue | ConvertFrom-SecureString -AsPlainText
      $env:ARM_CLIENT_ID = $secretInPlainText
      #client secret
      $secret = Get-AzKeyVaultSecret -VaultName $env:DEV_K8S_KV_NAME -Name "DEV-ARM-CLIENT-SECRET"
      $secretInPlainText = $secret.SecretValue | ConvertFrom-SecureString -AsPlainText
      $env:ARM_CLIENT_SECRET = $secretInPlainText
      $env:ARM_SUBSCRIPTION_ID = $env:DEV_ARM_SUBSCRIPTION_ID
        
          if($K8SMonitoringType -eq "OMS")
          {
            
            terragrunt init
            terragrunt plan  --var OMSLogging=true `
                        --var client_id=$env:ARM_CLIENT_ID --var client_secret=$env:ARM_CLIENT_SECRET `
                        --var subscription_id=$env:ARM_SUBSCRIPTION_ID --var tenant_id=$env:ARM_TENANT_ID `
                        --var rg_group_name=$env:DEV_K8S_RG_NAME --var enable_azure_policy=$enable_azure_policy `
                        --var IngressController=$IngressController --var requireAzureFrontDoor=$requireAzureFrontDoor `
                        --var la_name=$env:DEV_LA_NAME  --var k8s_name=$env:DEV_K8S_NAME

            terragrunt apply --auto-approve  --var OMSLogging=true `
                        --var client_id=$env:ARM_CLIENT_ID --var client_secret=$env:ARM_CLIENT_SECRET `
                        --var subscription_id=$env:ARM_SUBSCRIPTION_ID --var tenant_id=$env:ARM_TENANT_ID `
                        --var rg_group_name=$env:DEV_K8S_RG_NAME --var enable_azure_policy=$enable_azure_policy `
                        --var IngressController=$IngressController --var requireAzureFrontDoor=$requireAzureFrontDoor  `
                        --var la_name$env:DEV_LA_NAME  --var k8s_name=$env:DEV_K8S_NAME
          }
          else 
          {
            
            terragrunt init
            terragrunt plan  --var OMSLogging=false `
                        --var client_id=$env:ARM_CLIENT_ID --var client_secret=$env:ARM_CLIENT_SECRET `
                        --var subscription_id=$env:ARM_SUBSCRIPTION_ID --var tenant_id=$env:ARM_TENANT_ID `
                        --var rg_group_name=$env:DEV_K8S_RG_NAME --var enable_azure_policy=$enable_azure_policy `
                        --var IngressController=$IngressController --var requireAzureFrontDoor=$requireAzureFrontDoor `
                        --var la_name$env:DEV_LA_NAME  --var k8s_name=$env:DEV_K8S_NAME
            
            terragrunt apply --auto-approve  --var OMSLogging=false `
                        --var client_id=$env:ARM_CLIENT_ID --var client_secret=$env:ARM_CLIENT_SECRET `
                        --var subscription_id=$env:ARM_SUBSCRIPTION_ID --var tenant_id=$env:ARM_TENANT_ID `
                        --var rg_group_name=$env:DEV_K8S_RG_NAME --var enable_azure_policy=$enable_azure_policy `
                        --var IngressController=$IngressController --var requireAzureFrontDoor=$requireAzureFrontDoor `
                        --var la_name$env:DEV_LA_NAME  --var k8s_name=$env:DEV_K8S_NAME
          }
    }
    "PRD-A"
    {
      cd  az-aks/k8s-infra/tf/PRD-A
      
      #Get KV secrets for TF to inject the SPN creds into K8S.
      $secret = Get-AzKeyVaultSecret -VaultName $env:PRD_A_K8S_KV_NAME -Name "PRD-ARM-CLIENT-ID"
      $secretInPlainText = $secret.SecretValue | ConvertFrom-SecureString -AsPlainText
      $env:ARM_CLIENT_ID = $secretInPlainText
      $env:ARM_SUBSCRIPTION_ID = $env:PRD_A_ARM_SUBSCRIPTION_ID
      #client secret
      $secret = Get-AzKeyVaultSecret -VaultName $env:PRD_A_K8S_KV_NAME -Name "PRD-ARM-CLIENT-SECRET"
      $secretInPlainText = $secret.SecretValue | ConvertFrom-SecureString -AsPlainText
      $env:ARM_CLIENT_SECRET = $secretInPlainText
      
      if($K8SMonitoringType -eq "OMS")
          {
            terragrunt init
            terragrunt plan  --var OMSLogging=true `
                        --var client_id=$env:ARM_CLIENT_ID --var client_secret=$env:ARM_CLIENT_SECRET `
                        --var subscription_id=$env:ARM_SUBSCRIPTION_ID --var tenant_id=$env:ARM_TENANT_ID `
                        --var rg_group_name=$env:PRD_A_K8S_RG_NAME --var enable_azure_policy=$enable_azure_policy `
                        --var IngressController=$IngressController --var requireAzureFrontDoor=$requireAzureFrontDoor `
                        --var la_name$env:PRD_A_LA_NAME  --var prd_a_k8s_name=$env:PRD_A_K8S_NAME

            
            terragrunt apply --auto-approve  --var OMSLogging=true `
                        --var client_id=$env:ARM_CLIENT_ID --var client_secret=$env:ARM_CLIENT_SECRET `
                        --var subscription_id=$env:ARM_SUBSCRIPTION_ID --var tenant_id=$env:ARM_TENANT_ID `
                        --var rg_group_name=$env:PRD_A_K8S_RG_NAME  --var enable_azure_policy=$enable_azure_policy `
                        --var IngressController=$IngressController --var requireAzureFrontDoor=$requireAzureFrontDoor `
                        --var la_name$env:PRD_A_LA_NAME  --var prd_a_k8s_name=$env:PRD_A_K8S_NAME                        
          }
          else 
          {
            terragrunt init
            terragrunt plan  --var OMSLogging=false `
                        --var client_id=$env:ARM_CLIENT_ID --var client_secret=$env:ARM_CLIENT_SECRET `
                        --var subscription_id=$env:ARM_SUBSCRIPTION_ID --var tenant_id=$env:ARM_TENANT_ID `
                        --var rg_group_name=$env:PRD_A_K8S_RG_NAME  --var enable_azure_policy=$enable_azure_policy `
                        --var IngressController=$IngressController --var requireAzureFrontDoor=$requireAzureFrontDoor `
                        --var la_name$env:PRD_A_LA_NAME  --var prd_a_k8s_name=$env:PRD_A_K8S_NAME

            
            terragrunt apply --auto-approve  --var OMSLogging=false `
                        --var client_id=$env:ARM_CLIENT_ID --var client_secret=$env:ARM_CLIENT_SECRET `
                        --var subscription_id=$env:ARM_SUBSCRIPTION_ID --var tenant_id=$env:ARM_TENANT_ID `
                        --var rg_group_name=$env:PRD_A_K8S_RG_NAME  --var enable_azure_policy=$enable_azure_policy `
                        --var IngressController=$IngressController --var requireAzureFrontDoor=$requireAzureFrontDoor `
                        --var la_name$env:PRD_A_LA_NAME  --var prd_a_k8s_name=$env:PRD_A_K8S_NAME
          }
  
    }

  "PRD-B"
    {
      cd  az-aks/k8s-infra/tf/PRD-B
      #Get KV secrets for TF to inject the SPN creds into K8S.
      $secret = Get-AzKeyVaultSecret -VaultName $env:PRD_B_K8S_KV_NAME -Name "PRD-ARM-CLIENT-ID"
      $secretInPlainText = $secret.SecretValue | ConvertFrom-SecureString -AsPlainText
      $env:ARM_CLIENT_ID = $secretInPlainText
      $env:ARM_SUBSCRIPTION_ID = $env:PRD_B_ARM_SUBSCRIPTION_ID
      #client secret
      $secret = Get-AzKeyVaultSecret -VaultName $env:PRD_B_K8S_KV_NAME -Name "PRD-ARM-CLIENT-SECRET"
      $secretInPlainText = $secret.SecretValue | ConvertFrom-SecureString -AsPlainText
      $env:ARM_CLIENT_SECRET = $secretInPlainText
      
      if($K8SMonitoringType -eq "OMS")
          {
                 terragrunt init
            terragrunt plan  --var OMSLogging=true `
                        --var client_id=$env:ARM_CLIENT_ID --var client_secret=$env:ARM_CLIENT_SECRET `
                        --var subscription_id=$env:ARM_SUBSCRIPTION_ID --var tenant_id=$env:ARM_TENANT_ID `
                        --var prd_b_rg_group_name=$env:PRD_B_K8S_RG_NAME `
                        --var IngressController=$IngressController --var requireAzureFrontDoor=$requireAzureFrontDoor `
                        --var prd_b_la_name=$env:PRD_B_LA_NAME  --var prd_b_k8s_name=$env:PRD_B_K8S_NAME

            
            terragrunt apply --auto-approve  --var OMSLogging=true `
                        --var client_id=$env:ARM_CLIENT_ID --var client_secret=$env:ARM_CLIENT_SECRET `
                        --var subscription_id=$env:ARM_SUBSCRIPTION_ID --var tenant_id=$env:ARM_TENANT_ID `
                        --var prd_b_rg_group_name=$env:PRD_B_K8S_RG_NAME `
                        --var IngressController=$IngressController --var requireAzureFrontDoor=$requireAzureFrontDoor `
                        --var prd_b_la_name=$env:PRD_B_LA_NAME  --var prd_b_k8s_name=$env:PRD_B_K8S_NAME                        
          }
          else 
          {
            terragrunt init
            terragrunt plan  --var OMSLogging=false `
                        --var client_id=$env:ARM_CLIENT_ID --var client_secret=$env:ARM_CLIENT_SECRET `
                        --var subscription_id=$env:ARM_SUBSCRIPTION_ID --var tenant_id=$env:ARM_TENANT_ID `
                        --var prd_b_rg_group_name=$env:PRD_B_K8S_RG_NAME `
                        --var IngressController=$IngressController --var requireAzureFrontDoor=$requireAzureFrontDoor `
                        --var prd_b_la_name=$env:PRD_B_LA_NAME  --var prd_b_k8s_name=$env:PRD_B_K8S_NAME

            
            terragrunt apply --auto-approve  --var OMSLogging=false `
                        --var client_id=$env:ARM_CLIENT_ID --var client_secret=$env:ARM_CLIENT_SECRET `
                        --var subscription_id=$env:ARM_SUBSCRIPTION_ID --var tenant_id=$env:ARM_TENANT_ID `
                        --var prd_b_rg_group_name=$env:PRD_B_K8S_RG_NAME `
                        --var IngressController=$IngressController --var requireAzureFrontDoor=$requireAzureFrontDoor `
                        --var prd_b_la_name=$env:PRD_B_LA_NAME  --var prd_b_k8s_name=$env:PRD_B_K8S_NAME
          }
  
    }

  }
  
 
  cd ../../../..
  $pwd
}
Function LogintoK8S($ARM_SUBSCRIPTION_ID, $K8S_NAME, $ARM_CLIENT_ID, $ARM_CLIENT_SECRET, $K8S_RG_NAME)
{
  az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ENV:ARM_TENANT_ID
  az account set -s $ARM_SUBSCRIPTION_ID 
  az aks Get-Credentials -g $K8S_RG_NAME  -n $K8S_NAME --overwrite-existing --admin
}
Function SetupHelm()
{
      
      helm repo add aad-pod-identity https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts
      helm repo add grafana https://grafana.github.io/helm-charts
      helm repo add oteemocharts https://oteemo.github.io/charts #for sonarqube
      # Add the stable repo for Helm 3
      helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
      helm repo add stable https://charts.helm.sh/stable
      helm repo add loki https://grafana.github.io/loki/charts # deprecated
      helm repo add grafana https://grafana.github.io/helm-charts
      helm repo add haproxytech https://haproxytech.github.io/helm-charts

      
      helm repo add nginx-stable https://helm.nginx.com/stable
      helm repo add linkerd https://helm.linkerd.io/stable
      helm repo add linkerd-edge https://helm.linkerd.io/edge
      helm repo update
}
#Install linkerd
Function InstallLinkerd()
{
    $exp="2021-11-16T02:33:31Z"
    
    #helm upgrade --install linkerd2  --set-file global.identityTrustAnchorsPEM=./k8s-yml-templates/core/linkerd-helm-sshpair/ca.crt --set-file identity.issuer.tls.crtPEM=./k8s-yml-templates/core/linkerd-helm-sshpair/issuer.crt --set-file identity.issuer.tls.keyPEM=./k8s-yml-templates/core/linkerd-helm-sshpair/issuer.key --set identity.issuer.crtExpiry=$exp  --set meta.helm.sh/release-namespace=linkerd     --set prometheusUrl=prometheus-server.devops-addons.svc.cluster.local:9090 linkerd/linkerd2
    helm upgrade --install linkerd2  --set-file global.identityTrustAnchorsPEM=az-aks/k8s-yml-templates/core/linkerd-helm-sshpair/ca.crt `
    --set-file identity.issuer.tls.crtPEM=az-aks/k8s-yml-templates/core/linkerd-helm-sshpair/issuer.crt `
    --set-file identity.issuer.tls.keyPEM=az-aks/k8s-yml-templates/core/linkerd-helm-sshpair/issuer.key --set identity.issuer.crtExpiry=$exp `
    --set meta.helm.sh/release-namespace=linkerd2  --set prometheus.enabled=true `
    linkerd/linkerd2
    #--set global.prometheusUrl="thanos-web.monitoring.svc:10902" ` #this doesnt work. Prometheus has to be enabled with linkerd, else linkerd craps out.
     
  #doesnt honor release-namespace -- it goes to linkerd NS. Linkerd NS shouldnt exist and be created by helm
}

#To use the prometheus instance that comes with linkerd use the above
#linkerd ns needs to be managed by helm, so dont create the NS yet.
Function ApplyK8SCoreTemplates($k8sEnvironment, $Policies)
{
  If($k8sEnvironment -eq "Dev")
  {
    $FolderName = "NONPROD"
  }
  ELSE
  {
    $FolderName = "$k8sEnvironment"
  }
  cd .\az-aks\k8s-yml-templates\core
  #Create Namespaces, RBAC and other core components.
  kubectl apply -f $FolderName/namespaces.yaml
  kubectl apply -f $FolderName/service-accounts.yml
  kubectl apply -f $FolderName/.
  cd ../../..
  
  #To reboot the patched nodes on a schedule. 
  kubectl apply -f ./az-aks/k8s-yml-templates/add-ons/.
  #DEV_TLS_PRIVATE_KEY | PRD_TLS_PRIVATE_KEY is a secret stored in Git. Te generate the value for this variable use the steps below
  #openssl pkcs12 -in stardotcloudkubexyz.pfx  -out stardotcloudkubexyz.enc.key  # extract private key from PFX
  # openssl rsa -in stardotcloudkubexyz.enc.key -outform PEM -out stardotcloudkubexyz.key # convert the encrypted key to unencrypted key.
  #$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$pwd/certs/stardotcloudkubexyz.key")) 
  #The value of $base64string should be set for $env:DEV_TLS_PRIVATE_KEY |$env:PRD_TLS_PRIVATE_KEY or Git secret DEV_TLS_PRIVATE_KEY | PRD_TLS_PRIVATE_KEY
  
  
  if($requireTLSSecrets -eq "true")
  {
    if($k8sEnvironment -eq "DEV")
    {
       [IO.File]::WriteAllBytes("$pwd\certs\stardotcloudkubexyz.key", [Convert]::FromBase64String($ENV:DEV_TLS_PRIVATE_KEY))
       $ENV:DEV_TLS_PRIVATE_KEY
    }
    else
    {
      [IO.File]::WriteAllBytes("$pwd\certs\stardotcloudkubexyz.key", [Convert]::FromBase64String($ENV:PRD_TLS_PRIVATE_KEY))
    }
    kubectl delete secret tls ingress-secret-tls  -n dev 
    kubectl delete secret tls ingress-secret-tls  -n devops-addons
    kubectl delete secret tls ingress-secret-tls  -n ingress
    kubectl delete secret tls ingress-secret-tls  -n monitoring

    kubectl create secret tls ingress-secret-tls --key certs/stardotcloudkubexyz.key --cert ./certs/stardotcloudkubexyz.crt -n dev 
    kubectl create secret tls ingress-secret-tls --key certs/stardotcloudkubexyz.key --cert ./certs/stardotcloudkubexyz.crt -n devops-addons
    kubectl create secret tls ingress-secret-tls --key certs/stardotcloudkubexyz.key --cert ./certs/stardotcloudkubexyz.crt -n ingress
    kubectl create secret tls ingress-secret-tls --key certs/stardotcloudkubexyz.key --cert ./certs/stardotcloudkubexyz.crt -n monitoring

    if($Policies -eq "DIY-GateKeeper")
    {
      kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
      kubectl apply -f .\devsecops\k8s-templates\opa-gatekeeper\baseline-templates\.
      start-sleep -s 60 # wait for a moment before the templates are available for constraints
      kubectl apply -f .\devsecops\k8s-templates\opa-gatekeeper\baseline-constraints\.
    }
  }
}

Function HelmInstallNginxIngress()
{
  
    helm upgrade --install nginx nginx-stable/nginx-ingress --set internal.enabled=true -n ingress 
    #-f ./az-aks/helm/nginx/ingress-internal.yml -- not working. The private IP is not reachable from a VM in the same VNET, need more investigation.
  
  #For AWS internal
  #--set controller.service.annotations="service.beta.kubernetes.io/aws-load-balancer-type: nlb" `
  #--set controller.service.annotations='service.beta.kubernetes.io/aws-load-balancer-internal: "true"' -n ingress
}

Function InstallAZProviders()
{
      # Provider register: Register the Azure Kubernetes Service provider
    Register-AzResourceProvider -ProviderNamespace  Microsoft.ContainerService
    Register-AzResourceProvider -ProviderNamespace  Microsoft.Network
    # Provider register: Register the Azure Policy provider
    Register-AzResourceProvider -ProviderNamespace  Microsoft.PolicyInsights
    Register-AzResourceProvider -ProviderNamespace Microsoft.ContainerRegistry
    Register-AzResourceProvider -ProviderNamespace microsoft.insights
    Register-AzResourceProvider -ProviderNamespace Microsoft.OperationalInsights

    # Feature register: enables installing the add-on
    Register-AzResourceProvider -ProviderNamespace  Microsoft.ContainerService # --name K8S-AzurePolicyAutoApprove

    
    # Install/update the preview extension
    #az extension add --name K8S-preview

}

Function InstallDefectDojo($k8sEnvironment, $FolderName, $cloudProvider, $DEFAULT_PRD_URL_SUFFIX)
{
        #Install DefectDojo
        kubectl delete ing defectdojo -n devops-addons # delete the ING in case it exists.
        cd devsecops/helm/defectdojo
        IF($k8sEnvironment -EQ "Dev")
        {
              if(($env:DEV_DD_SPN_NAME | Measure).Count -eq 0)
              {
                $env:DEV_DD_SPN_NAME = $DEFAULT_DEV_DD_SPN_NAME
              }
              
                #get the SPN secret values from KV.
                $Secret = get-AzKeyVaultSecret -VaultName $env:DEV_K8S_KV_NAME -Name "DEV-DEFECTDOJO-CLIENT-SECRET" 
                $ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
                $ENV:DEV_DD_CLIENT_SECRET = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)

                $Secret = get-AzKeyVaultSecret -VaultName $env:DEV_K8S_KV_NAME -Name "DEV-DEFECTDOJO-CLIENT-ID" 
                $ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
                $ENV:DEV_DD_CLIENT_ID= [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)
              $env=$k8sEnvironment.tolower() 
              $dd_url = "$cloudProvider"+"-defectdojo-"+"$env"+"."+ $DEFAULT_DEV_URL_SUFFIX                
              helm upgrade --install defectdojo . --set django.ingress.activateTLS=false --set createSecret=true --set createRabbitMqSecret=true  `
            --set createRedisSecret=true --set createMysqlSecret=true --set createPostgresqlSecret=true `
            --set extraConfigs.DD_SOCIAL_AUTH_AZUREAD_TENANT_OAUTH2_KEY=$ENV:DEV_DD_CLIENT_ID `
            --set extraConfigs.DD_SOCIAL_AUTH_AZUREAD_TENANT_OAUTH2_TENANT_ID=$ENV:ARM_TENANT_ID `
            --set extraSecrets.DD_SOCIAL_AUTH_AZUREAD_TENANT_OAUTH2_SECRET=$ENV:DEV_DD_CLIENT_SECRET `
            --set admin.password=$ENV:DEV_DD_ADMIN_PWD --set host=$dd_url `
            -n devops-addons 
        }  
        elseif($k8sEnvironment -like "*PRD*")
        {
              if(($env:PRD_DD_SPN_NAME | Measure).Count -eq 0)
              {
                $env:PRD_DD_SPN_NAME = $DEFAULT_PRD_DD_SPN_NAME
              }
              #get the SPN secret values from KV.
                $Secret = get-AzKeyVaultSecret -VaultName $env:PRD_A_K8S_KV_NAME -Name "PRD-DEFECTDOJO-CLIENT-SECRET" 
                $ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
                $ENV:PRD_DD_CLIENT_SECRET = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)

                $Secret = get-AzKeyVaultSecret -VaultName $env:PRD_A_K8S_KV_NAME -Name "PRD-DEFECTDOJO-CLIENT-ID" 
                $ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
                $ENV:PRD_DD_CLIENT_ID= [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)
              $env=$FolderName.tolower()  # for prod it should be prda or prdb
              $dd_url
              $dd_url="$cloudProvider"+"-defectdojo-"+ $env.ToLower() +"."+ $DEFAULT_PRD_URL_SUFFIX
              #$dd_url must match ingress url
              helm upgrade --install defectdojo . --set django.ingress.activateTLS=false --set createSecret=true --set createRabbitMqSecret=true  `
                --set createRedisSecret=true --set createMysqlSecret=true --set createPostgresqlSecret=true `
                --set extraConfigs.DD_SOCIAL_AUTH_AZUREAD_TENANT_OAUTH2_KEY=$ENV:PRD_DD_CLIENT_ID `
                --set extraConfigs.DD_SOCIAL_AUTH_AZUREAD_TENANT_OAUTH2_TENANT_ID=$env:ARM_TENANT_ID `
                --set extraSecrets.DD_SOCIAL_AUTH_AZUREAD_TENANT_OAUTH2_SECRET=$ENV:PRD_DD_CLIENT_SECRET `
                --set admin.password=$env:PRD_DD_ADMIN_PWD --set host=$dd_url `
                -n devops-addons 
        }   
        cd ../../..
  
}

Function SetupK8SLogging($K8SLogMonitoringType, $cloudProvider)
{
      #Most popular image https://hub.docker.com/r/fluent/fluentd-kubernetes-daemonset/tags?page=1&ordering=last_updated -- 100M pulls
      switch($K8SMonitoringType)
      {
        "EFKinCluster"
        {
              # kubectl apply -f .\k8s-yml-templates\efk-logging\. # dont apply all at once, wait for ES to be present and then deploy kibana
            kubectl apply -f .\k8s-yml-templates\efk-logging\$K8SLogMonitoringType\elastic\elastic-statefulset-$cloudProvider.yml
            kubectl apply -f .\k8s-yml-templates\efk-logging\$K8SLogMonitoringType\elastic\elastic-svc.yml
            
            kubectl apply -f .\k8s-yml-templates\efk-logging\$K8SLogMonitoringType\fluent\.
            $esCount = (kubectl get pods | select-string "es-cluster" | Measure).Count
            $timeWaited=0
            #dont install kibana before ES is up and running.
            do
            {
              Start-Sleep -s 1
              $esCount = (kubectl get pods -n monitoring | select-string "es-cluster"  | Measure).Count
              $timeWaited+=1
            }while($esCount -ne 3 -and $timeWaited -lt 300)
            Start-Sleep -s 180 #wait for the 3rd ES cluster pod to be online.
            kubectl apply -f .\k8s-yml-templates\efk-logging\$K8SLogMonitoringType\kibana\.
        }
        "ElasticInCloud"
        {
            kubectl apply -f .\k8s-yml-templates\efk-logging\$K8SLogMonitoringType\fluent\.
        }
        "Loki"
        {
        
            helm upgrade --install loki --namespace=monitoring grafana/loki --set grafana.enabled=false `
            --set prometheus.enabled=false `
            --set loki.persistence.enabled=true `
            --set loki.persistence.storageClassName="default" `
            --set loki.persistence.size=5Gi -n monitoring
            #Loki + Promtail
        }
      }
}

Function SetupK8SMetricsMonitoring($K8SMetricsMonitoringType, $K8SLogMonitoringType, $k8sEnvironment, $FolderName)
{
          
        #THANOS_LTR_SAKEY is a secret stored in Git. This is the storage account key in Azure for THanos LTR
        $yml = get-content "$pwd/az-aks/k8s-yml-templates/prometheus-grafana/prom-values/$FolderName/object-store-template.yml" | ConvertFrom-Yaml
        $yml.config.storage_account_key = $env:THANOS_LTR_SAKEY
        $yml=$yml | ConvertTo-Yaml
        $yml | out-file "$pwd/az-aks/k8s-yml-templates/prometheus-grafana/prom-values/$FolderName/object-store.yml"
        write-host "==SetupK8SMetricsMonitoring====>"$env:GRAFANA_INI_URL
        IF($k8sEnvironment -EQ "DEV")
        {
          $env:K8S_SLACK_NOTIFICATIONS_URL=$env:DEV_K8S_SLACK_NOTIFICATIONS_URL
          $GRAFANA_URL = $env:DEV_GRAFANA_LOGIN_URL
          
          $Secret = get-AzKeyVaultSecret -VaultName $env:DEV_K8S_KV_NAME -Name "DEV-GRAFANA-CLIENT-SECRET" 
          $ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
          $ENV:GRAFANA_CLIENT_SECRET = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)
          $env:GRAFANA_ADMIN_PASSWORD = $env:DEV_GRAFANA_ADMIN_PASSWORD
          $Secret = get-AzKeyVaultSecret -VaultName $env:DEV_K8S_KV_NAME -Name "DEV-GRAFANA-CLIENT-ID" 
          $ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
          $ENV:GRAFANA_CLIENT_ID = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)

        }
        else {
          $env:K8S_SLACK_NOTIFICATIONS_URL=$env:PRD_K8S_SLACK_NOTIFICATIONS_URL
          $GRAFANA_URL = $env:PRD_GRAFANA_LOGIN_URL
          $Secret = get-AzKeyVaultSecret -VaultName $env:PRD_K8S_KV_NAME -Name "PRD-GRAFANA-CLIENT-SECRET" 
          $ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
          $ENV:GRAFANA_CLIENT_SECRET = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)
          $env:GRAFANA_ADMIN_PASSWORD = $env:PRD_GRAFANA_ADMIN_PASSWORD
          $Secret = get-AzKeyVaultSecret -VaultName $env:PRD_K8S_KV_NAME -Name "PRD-GRAFANA-CLIENT-ID" 
          $ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
          $ENV:GRAFANA_CLIENT_ID = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)
        
        }
      #Most popular image https://hub.docker.com/r/fluent/fluentd-kubernetes-daemonset/tags?page=1&ordering=last_updated -- 100M pulls
      switch($K8SMetricsMonitoringType)
      {
        "OMS"
        {
            #all taken care via terraform deployment - baked into K8S setup.
        }
        "SingleInstancePrometheus-Thanos"
        {
              
          #create Thanos components # https://observability.thomasriley.co.uk/prometheus/using-thanos/high-availability/ -- working setup
          #to use the quay.io image instead of the image in the above url, disable externallabel property in promtheus-thanos-values.yml
          kubectl apply -f ./az-aks/k8s-yml-templates/prometheus-grafana/thanos.yml
          #create object store secret 
          $ThanosStorageConfig = "./az-aks/k8s-yml-templates/prometheus-grafana/prom-values/$FolderName/object-store.yml"
          kubectl delete secret thanos-objstore-config -n monitoring
          kubectl -n monitoring create secret generic thanos-objstore-config --from-file=thanos.yml=$ThanosStorageConfig
          #steps for Thanos with 2 prometheus instances -- inject thanos as side car.
          helm upgrade --install prometheus prometheus-community/kube-prometheus-stack `
          -f ./az-aks/k8s-yml-templates/prometheus-grafana/prom-values/$FolderName/prometheus-thanos-values.yml `
          --set prometheusOperator.tlsProxy.enabled=false `
          --set alertmanager.config.global.smtp_auth_password=$env:smtp_auth_password `
          --set alertmanager.config.global.slack_api_url=$env:K8S_SLACK_NOTIFICATIONS_URL `
          --set prometheus.prometheusSpec.replicas=1 -n monitoring
          
          #https://github.com/helm/charts/issues/18765 --WIP Azure AD authentication ------
         #DONT use double quotes in PS 
         helm upgrade --install grafana grafana/grafana --set persistence.enabled=true  `
         -f ./az-aks/k8s-yml-templates/prometheus-grafana/grafana-values/$FolderName/values.yml  `
         --set grafana\.ini.auth\.azuread.client_id="$ENV:GRAFANA_CLIENT_ID"   `
         --set adminPassword="$env:GRAFANA_ADMIN_PASSWORD" `
         --set grafana\.ini.server.root_url="$GRAFANA_INI_URL" `
         --set grafana\.ini.auth\.azuread.auth_url="https://login.microsoftonline.com/$env:ARM_TENANT_ID/oauth2/v2.0/authorize"   `
          --set grafana\.ini.auth\.azuread.token_url="https://login.microsoftonline.com/$env:ARM_TENANT_ID/oauth2/v2.0/token"   `
         --set grafana\.ini.auth\.azuread.client_secret="$ENV:GRAFANA_CLIENT_SECRET" -n monitoring   #persistent is disabled by default.
              kubectl apply -f ./az-aks/k8s-yml-templates/prometheus-grafana/.  # to setup ingress 
          #----TSONLY----#remove-item $pwd/az-aks/k8s-yml-templates/prometheus-grafana/prom-values/$FolderName/object-store.yml -force    
          helm upgrade --install prometheus-adapter prometheus-community/prometheus-adapter `
          -f .\az-aks\k8s-yml-templates\prometheus-grafana\prom-values\$FolderName\prom-adapter-values.yml -n monitoring
        }
        "HAPrometheus-Thanos"
        {
          
          #create Thanos components # https://observability.thomasriley.co.uk/prometheus/using-thanos/high-availability/ -- working setup
          #to use the quay.io image instead of the image in the above url, disable externallabel property in promtheus-thanos-values.yml
          kubectl apply -f ./az-aks/k8s-yml-templates/prometheus-grafana/thanos.yml
          #create object store secret 
          $ThanosStorageConfig = "./az-aks/k8s-yml-templates/prometheus-grafana/prom-values/$FolderName/object-store.yml"
          
          kubectl -n monitoring delete secret thanos-objstore-config
          kubectl -n monitoring create secret generic thanos-objstore-config --from-file=thanos.yml=$ThanosStorageConfig
          #steps for Thanos with 2 prometheus instances -- inject thanos as side car.
          helm upgrade --install prometheus prometheus-community/kube-prometheus-stack `
          -f ./az-aks/k8s-yml-templates/prometheus-grafana/prom-values/$FolderName/prometheus-thanos-values.yml `
          --set prometheusOperator.tlsProxy.enabled=false `
          --set alertmanager.config.global.smtp_auth_password=$env:smtp_auth_password `
          --set prometheus.prometheusSpec.replicas=2 -n monitoring 
         #https://github.com/helm/charts/issues/18765 --WIP Azure AD authentication ------
         #DONT use double quotes in PS 
         
          helm upgrade --install grafana grafana/grafana --set persistence.enabled=true  `
          -f ./az-aks/k8s-yml-templates/prometheus-grafana/grafana-values/$FolderName/values.yml  `
          --set grafana\.ini.auth\.azuread.client_id="$ENV:GRAFANA_CLIENT_ID"   `
          --set adminPassword="$env:GRAFANA_ADMIN_PASSWORD" `
          --set grafana\.ini.server.root_url="$env:GRAFANA_INI_URL" `
          --set grafana\.ini.auth\.azuread.auth_url="https://login.microsoftonline.com/$env:ARM_TENANT_ID/oauth2/v2.0/authorize"   `
          --set grafana\.ini.auth\.azuread.token_url="https://login.microsoftonline.com/$env:ARM_TENANT_ID/oauth2/v2.0/token"   `
          --set grafana\.ini.auth\.azuread.client_secret="$ENV:GRAFANA_CLIENT_SECRET" -n monitoring  #persistent is disabled by default.
          kubectl apply -f ./az-aks/k8s-yml-templates/prometheus-grafana/.  # to setup ingress   
          remove-item $pwd/az-aks/k8s-yml-templates/prometheus-grafana/prom-values/$FolderName/object-store.yml -force      
          helm upgrade --install prometheus-adapter prometheus-community/prometheus-adapter `
          -f .\az-aks\k8s-yml-templates\prometheus-grafana\prom-values\$FolderName\prom-adapter-values.yml -n monitoring
#if the cluster is too big and you want to send metrics of only certain apps based on labels - podMonitorSelector, serviceMonitorSelector
        }
        "None"
        {
        
        }
      }
}

Function InstallSonarQube()
{
   #start-process -filepath "helm" -ArgumentList 'upgrade --install sonarqube oteemocharts/sonarqube --set persistence.storageClass="managed-ssd-retain"  --set persistence.enabled=true --set plugins.install={"#https://binaries.sonarsource.com/Distribution/sonar-csharp-plugin/sonar-csharp-plugin-8.4.0.15306.jar"} -n devops-addons'
   #The above doesnt work
   #powershell + helm doesnt work when passing array values in set so use start-process.
   #C# addins from marketplace not compatible with Sonar version 8 https://www.sonarplugins.com/csharp
   #https://binaries.sonarsource.com/Distribution/sonar-csharp-plugin/sonar-csharp-plugin-8.4.0.15306.jar
   #Oteemo charts doesnt work with version 7.9. Version 8 doesnt support C# unless we use the JAR file.   
   
   #helm upgrade --install sonarqube stable/sonarqube --set persistence.storageClass="managed-ssd-retain"  --set persistence.enabled=true --set image.tag="7.9.2-community" -n devops-addons
   #After running the below, you will the logs stopping with Database needs to be upgrade.
   #Use https://dev-sonarqube.cloudkube.xyz/setup and finish the upgrade -- https://stackoverflow.com/questions/50694564/sonarqube-7-1-with-external-mysql-database-fails-with-database-must-be-upgraded
   #helm upgrade --install -f .\helm\sonarqube\values.yml sonarqube stable/sonarqube --set persistence.enabled=true --set image.tag="8.5.1-community" `
   #--set postgresql.enabled=false --set postgresql.postgresqlServer='sonar-db01.postgres.database.azure.com'  `
   # --set postgresql.postgresqlUsername='sonaradmin@sonar-db01' `
   # --set postgresql.postgresqlPassword=$env:postgres_db_pwd --set postgresql.postgresqlDatabase='postgres'  -n devops-addons 
   helm upgrade --install sonarqube oteemocharts/sonarqube `
   --set extraConfig.account.adminPassword=$env:sonar_admin_password `
   --set extraConfig.account.currentAdminPassword=$env:sonar_admin_password `
   --set sonarProperties.sonar.forceAuthentication="true" --set postgresql.persistence.size="6Gi" -n devops-addons # to let the DB run in the cluster as stateful set.
   #with external DB, it can take upto one hour to load after upgrade. It will be stuck on registerrules for an hour or so.
   #This problem doesnt exist if the DB is a stateful set and exists in cluster and uses the image by helm chart
}

IF($productionClusterConfigType -EQ "PrimaryandSecondaryRegion" -and $k8sEnvironment -eq "PRD")
{
    
    $error.clear()
    CheckMandatoryEnvVars "PRD-A"
    if(($error | measure).count -gt 0){exit}
    
    #To checkin the SPN secrets.
    $KVCount = CreateKeyVault "PRD-A" #sleep only KV was created.
    
    if($KVCount -eq 0)
    {
      Start-Sleep -s 30 # wait for KV to be replicated in Az - just in case.
    }
    #Create the SPNs and checkin the secrets to KV.
    CreateClusterSPN $createSPNifNotExists4K8S "PRD-A"    
    CreateStorageAccountforTF "PRD-A"
    
    CheckMandatoryEnvVars "PRD-B"
    $KVCount = CreateKeyVault "PRD-B" #sleep only KV was created.
    
    if($KVCount -eq 0)
    {
      Start-Sleep -s 30 # wait for KV to be replicated in Az - just in case.
    }
    #Create the SPNs and checkin the secrets to KV.
    CreateClusterSPN $createSPNifNotExists4K8S "PRD-B"    
    CreateStorageAccountforTF "PRD-B"
    

}elseif($productionClusterConfigType -EQ "PrimaryRegionOnly" -and $k8sEnvironment -eq "PRD")
{
    $error.clear()
    CheckMandatoryEnvVars "PRD-A"
    if(($error | measure).count -gt 0){exit}
    $KVCount = CreateKeyVault "PRD-A" #sleep only KV was created.
    if($KVCount -eq 0)
    {
      Start-Sleep -s 30 # wait for KV to be replicated in Az - just in case.
    }
    
    #Create the SPNs and checkin the secrets to KV.
    CreateClusterSPN $createSPNifNotExists4K8S "PRD-A"
    CreateStorageAccountforTF "PRD-A"
}else
{
    $error.clear()
    CheckMandatoryEnvVars $k8sEnvironment
    
    if(($error | measure).count -gt 0){exit}
    $KVCount = CreateKeyVault $k8sEnvironment #sleep only KV was created.
    if($KVCount -eq 0)
    {
      Start-Sleep -s 30 # wait for KV to be replicated in Az - just in case.
    }
    
    #Create the SPNs and checkin the secrets to KV.
    CreateClusterSPN $createSPNifNotExists4K8S $k8sEnvironment
    CreateStorageAccountforTF $k8sEnvironment
}


InstallAZProviders  # remove comment after debug
#Download helm repos
SetupHelm
#Dryrun only creates the required SPNs - we also need env vars for Grafana later.
if($k8sEnvironment -eq "DEV")
{
  if($requireDefectDojo -eq "true"){
    CreateAppsSPN $k8sEnvironment "DEFECTDOJO" $cloudProvider $dryRunforGithubActions
    
  }
  
  if($K8SMetricsMonitoringType -like "*Thanos*")
  {
    CreateAppsSPN $k8sEnvironment "GRAFANA" $cloudProvider  $dryRunforGithubActions
    write-host "==after CreateAppsSPN====>"$env:GRAFANA_INI_URL
  }
}
  

  IF($k8sEnvironment -eq "PRD" -and $productionClusterConfigType -EQ "PrimaryRegionOnly")
  {
    if($requireDefectDojo -eq "true"){
      CreateAppsSPN "PRD-A" "DEFECTDOJO" $cloudProvider $dryRunforGithubActions
    }
    
    if($K8SMetricsMonitoringType -like "*Thanos*")
    {
      CreateAppsSPN "PRD-A" "GRAFANA" $cloudProvider  $dryRunforGithubActions
    } 
  }ELSEif($k8sEnvironment -eq "PRD" -and $productionClusterConfigType -EQ "PrimaryandSecondaryRegion")
  {
    if($requireDefectDojo -eq "true"){
      CreateAppsSPN "PRD-A" "DEFECTDOJO" $cloudProvider $dryRunforGithubActions
      CreateAppsSPN "PRD-B" "DEFECTDOJO" $cloudProvider $dryRunforGithubActions
    }
    
    if($K8SMetricsMonitoringType -like "*Thanos*")
    {
      CreateAppsSPN "PRD-A" "GRAFANA" $cloudProvider  $dryRunforGithubActions
      CreateAppsSPN "PRD-B" "GRAFANA" $cloudProvider  $dryRunforGithubActions
    }
  }

Function ApplyK8SAddonResourceTemplates($FolderName, $IngressController, $serviceMeshType, $requireDefectDojo, $k8sEnvironment, $K8SLogMonitoringType, $cloudProvider, $DEFAULT_PRD_URL_SUFFIX )
{
    
    
    if($IngressController -eq "Nginx")
      {
        HelmInstallNginxIngress 
      }
    if($serviceMeshType -eq "linkerd")
    {
      InstallLinkerd
    }
    if($requireDefectDojo -eq "true")
    {
      
      InstallDefectDojo $k8sEnvironment $FolderName $cloudProvider $DEFAULT_PRD_URL_SUFFIX #foldername is used for DD URL construction.
    }
    #Log monitoring
    SetupK8SLogging $K8SLogMonitoringType $cloudProvider #only for logs
    #Metrics monitoring -- send folder name containing the values
    
    SetupK8SMetricsMonitoring $K8SMetricsMonitoringType $K8SLogMonitoringType $k8sEnvironment $FolderName
    if($requireSonarQube -eq "true")
    {
      InstallSonarQube 
    }
    kubectl apply -f ./az-aks/k8s-yml-templates/voting-app-prereq/$FolderName/.
    #Apply Kube-Bench templates
    kubectl apply -f devsecops/k8s-templates/kube-bench.yml
    kubectl apply -f ./az-aks/k8s-yml-templates/core/ingress/$FolderName/.       
}

if($Policies -eq "AzPolicies")
    {
      $enable_azure_policy="true"
    }
else {
      $enable_azure_policy="false"
}

if($dryRunforGithubActions -eq "false")
{
  if($applyTFTemplates -eq "true" -and  $k8sEnvironment -eq "DEV")
  { 
    
    BuildK8STFInfra $K8SMonitoringType $k8sEnvironment $IngressController $enable_azure_policy
    LogintoK8S $ENV:ARM_SUBSCRIPTION_ID $ENV:DEV_K8S_NAME $ENV:ARM_CLIENT_ID $ENV:ARM_CLIENT_SECRET $ENV:DEV_K8S_RG_NAME
    ApplyK8SCoreTemplates $k8sEnvironment $Policies
    $FolderName="NONPROD"
    ApplyK8SAddonResourceTemplates $FolderName $IngressController $serviceMeshType $requireDefectDojo $k8sEnvironment $K8SLogMonitoringType $cloudProvider $DEFAULT_DEV_URL_SUFFIX
    
    
  }elseif($productionClusterConfigType -EQ "PrimaryRegionOnly")
  {
    BuildK8STFInfra $K8SMonitoringType "PRD-A" $IngressController $enable_azure_policy
    LogintoK8S $ENV:ARM_SUBSCRIPTION_ID $ENV:PRD_A_K8S_NAME $ENV:ARM_CLIENT_ID $ENV:ARM_CLIENT_SECRET $ENV:PRD_A_K8S_RG_NAME
    ApplyK8SCoreTemplates "PRD-A" $Policies
    $FolderName="PRD-A"
    ApplyK8SAddonResourceTemplates $FolderName $IngressController $serviceMeshType $requireDefectDojo $k8sEnvironment $K8SLogMonitoringType $cloudProvider $DEFAULT_PRD_URL_SUFFIX
    
    
  }ELSE
  {
    #deploy in primary region
    BuildK8STFInfra $K8SMonitoringType "PRD-A" $IngressController $enable_azure_policy
    LogintoK8S $ENV:ARM_SUBSCRIPTION_ID $ENV:PRD_A_K8S_NAME $ENV:ARM_CLIENT_ID $ENV:ARM_CLIENT_SECRET $ENV:PRD_A_K8S_RG_NAME
    ApplyK8SCoreTemplates "PRD-A" $Policies
    
    $FolderName="PRD-A"
    ApplyK8SAddonResourceTemplates $FolderName $IngressController $serviceMeshType $requireDefectDojo $k8sEnvironment $K8SLogMonitoringType $cloudProvider 
    
    #deploy on secondary region
    BuildK8STFInfra $K8SMonitoringType "PRD-B" $IngressController $enable_azure_policy
    LogintoK8S $ENV:ARM_SUBSCRIPTION_ID $ENV:PRD_B_K8S_NAME $ENV:ARM_CLIENT_ID $ENV:ARM_CLIENT_SECRET $ENV:PRD_B_K8S_RG_NAME
    ApplyK8SCoreTemplates "PRD-B" $Policies

    $FolderName="PRD-B"
    ApplyK8SAddonResourceTemplates $FolderName $IngressController $serviceMeshType $requireDefectDojo $k8sEnvironment $K8SLogMonitoringType $cloudProvider $DEFAULT_PRD_URL_SUFFIX
    
}

}

