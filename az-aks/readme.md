# Introduction 
Steps to build an AKS cluster with the following resources

# AZ-AKS:

- Nginx for Ingress controller and FrontDoor for a HA/DR scenarios.
- Log Analytics for AKS monitoring, auditing and compliance.
- KeyVault to store secrets - TLS certs.
- AKS, ACR, VNET and Storage accounts.
- Azure pod security policies for AKS(currently in preview)
- Managed Identities for the apps in AKS to access Azure resources without having to refer to a secret in K8S.
- Azure monitor to alert about AKS, pod health and events.
- Kube hunter to report vulnerabilities and notify via Slack
- Kured for node reboot management.



# Common for both AKS and EKS

- SonarQube for static code analysis  -- Azure AD integration enabled.
- DefectDojo for report OWASP reports and kube-bench reports. 
- kube hunter reports via Slack  -- Azure AD integration enabled.
- kubei for container image vulnerability report using clair

# Getting Started

## To run this locally from your laptop

# AZ-AKS
- Pre-Requisites
    * Powershell Az module.
    * Logged into Azure Powershell with Editor level access on the subcription.
    * Logged into Azure CLI with access to create SPN's on Azure AD.
# Core ENVVARS

# Mandatory Env Vars that needs to be set manually.
    * The below env vars has to be set manually before running the script

        - $env:ARM_TENANT_ID -- this is retrieved from the account with which you have logged in.
# DEV:
        - $env:DEV_ARM_SUBSCRIPTION_ID -- this is the subscription on which the AKS cluster will be deployed for DEV environment.
        - $env:DEV_K8S_KV_NAME -- this has to be unique.
        - $env:DEV_TF_STORAGE_NAME -- this has to be unique.
        - $env:DEV_K8S_NAME -- this has to be unique.
        - $env:DEV_LA_NAME -- this has to be unique. 
        - $ENV:DEV_TLS_PRIVATE_KEY -- if you need TLS for the ingress controller, the private key portion of the cert needs to be stored as env var.
        - $env:DEV_K8S_SLACK_NOTIFICATIONS_URL - if Slack notification for Prometheus alerts are required.                   
## Public DNS Records - if you are exposing the ingress URLs via Azure Front Door.
### Azure Front Door Record
For each custom domain name hosted by AFD there needs to be an equivalent CNAME pointing to <afd_name>.azurefd.net (afd_name is the var name for the Azure Front Door defined in vars.tf)
For example, if I need to host defectdojo.cloudkube.xyz on Azure Front Door, and the name of the Azure front door is cloudkube
then I need to publish a CNAME record pointing defectdojo.cloudkube.xyz to cloudkube.azurefd.net
### Nginx record (whether using AFD or not)
Also, there will be another ingress host name that will be published as az-defectdojo.cloudkube.xyz on nginx ingress. This DNS name has to point to Nginx public IP. Users will use https://defectdojo.cloudkube.xyz which will then route it back to K8S nginx via https://az-defectdojo.cloudkube.xyz. If you choose to skip AFD(front door) then simply publish defectdojo.cloudkube.xyz to point to nginx public IP.
# PRD: 
Configuration options are 
    - Primary region only (or)
    - Primary and Secondary regions.
##  For Primary Region only:     
        - $env:PRD_A_ARM_SUBSCRIPTION_ID -- this is the subscription on which the AKS cluster will be deployed for Prod environment.
        - $env:PRD_A_K8S_KV_NAME -- this has to be unique. 
        - $env:PRD_A_TF_STORAGE_NAME -- this has to be unique. 
        - $env:PRD_A_K8S_NAME -- this has to be unique.
        - $env:PRD_A_LA_NAME -- this has to be unique. 
        - $env:PRD_K8S_SLACK_NOTIFICATIONS_URL - if Slack notification for Prometheus alerts are required.
##  For Primary and Secondary Region:
All of the env vars from the above plus the below.     
        - $env:PRD_B_ARM_SUBSCRIPTION_ID -- this is the subscription on which the AKS cluster will be deployed for Prod environment.
        - $env:PRD_B_K8S_KV_NAME -- this has to be unique. 
        - $env:PRD_B_TF_STORAGE_NAME -- this has to be unique. 
        - $env:PRD_B_K8S_NAME -- this has to be unique.
        - $env:PRD_B_LA_NAME -- this has to be unique. If you are not using OMS for logging, this is not required.
        - $env:PRD_K8S_SLACK_NOTIFICATIONS_URL - if Slack notification for Prometheus alerts are required.                   
##  Common for both configurations.
        - $ENV:PRD_TLS_PRIVATE_KEY -- if you need TLS for the ingress controller, the private key portion of the cert needs to be stored as env var. 
# ENVVARS that will be created automatically if none provided.
    * The below env vars are set automatically by the script if it doesnt exist. To provide your values simply set the values before running
      the script.
# DEV:
        - $env:DEV_K8S_RG_NAME -- defaults to RG-DEV-K8S-CLUSTER, if you want to provide a different name, provide a different value.
        - $env:DEV_K8S_NODE_RG_NAME -- defaults to RG-DEV-K8S-NODES, if you want to provide a different name, provide a different value.
        - $env:DEV_K8S_SPN_NAME -- defaults to dev-k8s-cluster-spn, if you want to provide a different name, provide a different value.
        - $env:DEV_ARM_CLIENT_ID -- if you intend to use an existing SPN and want to override this env var with your values, you should also update the values in the KeyVault $env:DEV_K8S_KV_NAME for secret ARM-CLIENT-ID
        - $env:DEV_ARM_CLIENT_SECRET -- if you are using an existing SPN and want to override this env var with your values, you should also update the values in the KeyVault $env:DEV_K8S_KV_NAME for secret ARM-CLIENT-SECRET
        - $env:DEV_AZ_LOCATION -- defaults to Australia East, if you want to provide a different name, provide a different value.
        - $env:DEV_DD_ADMIN_PWD -- for DefectDojo admin login, if none set, default password for DefectDojo is used. Refer DD helm charts for default password.
        - $env:DEV_GRAFANA_ADMIN_PWD -- for DefectDojo admin login, if none set, default password for DefectDojo is used. Refer DD helm charts for default password.
# PRD:
        - $env:PRD_A_K8S_RG_NAME -- defaults to RG-PRD-A-K8S-CLUSTER, if you want to provide a different name, provide a different value.
        - $env:PRD_B_K8S_RG_NAME (OPTIONAL: for multi-region cluster config only) -- defaults to RG-PRD-B-K8S-CLUSTER, if you want to provide a different name, provide a different value.
        - $env:PRD_A_K8S_NODE_RG_NAME -- defaults to RG-PRD-A-K8S-NODES, if you want to provide a different name, provide a different value.
        - $env:PRD_B_K8S_NODE_RG_NAME (OPTIONAL: for multi-region cluster config only) -- defaults to RG-PRD-B-K8S-NODES, if you want to provide a different name, provide a different value.
        - $env:PRD_K8S_SPN_NAME -- defaults to prd-k8s-cluster-spn, if you want to provide a different name, provide a different value.
        - $env:PRD_ARM_CLIENT_ID -- if you intend to use an existing SPN and want to override this env var with your values, you should also update the values in the KeyVault $env:PRD_K8S_KV_NAME for secret ARM-CLIENT-ID
        - $env:PRD_ARM_CLIENT_SECRET -- if you are using an existing SPN and want to override this env var with your values, you should also update the values in the KeyVault $env:PRD_K8S_KV_NAME for secret ARM-CLIENT-SECRET
        - $env:PRD_A_AZ_LOCATION -- defaults to Australia East, if you want to provide a different name, provide a different value.
        - $env:PRD_B_AZ_LOCATION (OPTIONAL: for multi-region cluster config only) -- defaults to Australia East, if you want to provide a different name, provide a different value.
        - $env:PRD_DD_ADMIN_PWD -- for DefectDojo admin login, if none set, default password for DefectDojo is used. Refer DD helm charts for default password.
        - $env:PRD_GRAFANA_ADMIN_PWD -- for DefectDojo admin login, if none set, default password for DefectDojo is used. Refer DD helm charts for default password.
# Execute the script.
    * Clone this repo and run k8s-core-resourcesv2.ps1 in az-aks folder. 
       Examples
        
        To create the new SPN and set a secret for the SPN. If the SPN called Dev-K8S-SPN doesnt exist, it will be created.
        The secret will be checked into a keyvault for future reference.
        DEV:
        - .\k8s-core-resourcesv2.ps1 -createSPNifNotExists4K8S "true" -k8sEnvironment DEV
        For TLS ingress.
        - .\k8s-core-resourcesv2.ps1 -createSPNifNotExists4K8S "true" -k8sEnvironment DEV -requireTLSSecrets true
        PRD:
        - .\k8s-core-resourcesv2.ps1 -createSPNifNotExists4K8S "true" -k8sEnvironment PRD
        For TLS ingress.
        - .\k8s-core-resourcesv2.ps1 -createSPNifNotExists4K8S "true" -k8sEnvironment PRD -requireTLSSecrets true

        To use an existing SPN -- If the client ID and secret was not created using this script, ensure that this value is also updated on the Keyvault. The values stored in the keyvault is used by Terraform to configure AKS to "runAs" this SPN.
        DEV:
        - .\k8s-core-resourcesv2.ps1 -createSPNifNotExists4K8S "false" -k8sEnvironment DEV
        PRD:
        - .\k8s-core-resourcesv2.ps1 -createSPNifNotExists4K8S "false" -k8sEnvironment PRD

## To run this using Github actions
# Pre-requsite: Create an SPN for Github to connect to Azure. This SPN must have editor level access on the subscription and also global administrator role to create SPNs for DefectDojo, Grafana etc.

# Option 1: Create the SPN via script, run the below locally (on your laptop).
** You need to be logged into Azure CLI with permissions to create SPN in Azure AD and also to Azure PowerShell with editor level access on the subscription.
        DEV:
        - .\k8s-core-resourcesv2.ps1 -createSPNifNotExists4K8S "false" -k8sEnvironment DEV -dryRunforGithubActions "true"
        PRD:
        - .\k8s-core-resourcesv2.ps1 -createSPNifNotExists4K8S "false" -k8sEnvironment PRD -dryRunforGithubActions "true"
This will create the SPN, Resource group, KeyVault with the SPN secrets and StorageAccount to store Terraform state.
Checkout the secrets for ARM-CLIENT-ID and ARM-CLIENT-SECRET from KeyVault to create the Github secrets - DEV_ARM_CLIENT_ID and DEV_ARM_CLIENT_SECRET

# Option 2: If you are using existing SPN, then update the below Github secrets -  DEV_ARM_CLIENT_ID and DEV_ARM_CLIENT_SECRET.
If you are using existing SPN credentials, these also needs to be updated in the KeyVault($env:PRD_K8S_KV_NAME|$env:DEV_K8S_KV_NAME). The RG should be created and contributor permissions for the SPN needs to be set at RG level.

This deployment SPN will be the only thing that will be created outside of Git. For other K8S secrets like TLS cert, SPN for SonarQube and other apps the source of truth will be Git Secrets.

# Mandatory Secrets
- Create the following  secrets in Github
    - ARM_TENANT_ID - Azure ARM tenant ID.
    - DEPLOY_TOKEN_GITHUB - Required for create deployments in Git. This is the Personal access token with access to repos.
    # Dev:
    # The below is used by Terraform.
    - DEV_ARM_SUBSCRIPTION_ID - subscription ID in Azure.    
    - DEV_K8S_KV_NAME - KeyVaut to store the SPN secrets.
    # Its the same values above created for Terraform, git actions for Az login expects in this format. 
    - DEV_AZURE_CREDENTIALS - this should contain clientid, clientsecret, tenantid and subscriptionid in JSON format.
       {
        "clientId": "<GUID>",
        "clientSecret": "<GUID>",
        "subscriptionId": "<GUID>",
        "tenantId": "<GUID>"        
        }
        Refer https://github.com/Azure/login for more details. You can either use existing creds or if the SPN was created with script, checkout the creds from the respective KV
    - DEV_LA_NAME - LogAnalytics for Dev.
    - DEV_TF_STORAGE_NAME - Storage account for Terraform state - Dev resources only.
    # Prd:
    # The below is used by Terraform.
    - PRD_ARM_SUBSCRIPTION_ID - subscription ID in Azure.    
    - PRD_K8S_KV_NAME - KeyVaut to store the K8S secrets.
    # Its the same values above created for Terraform, git actions for Az login expects in this format. 
    - DEV_AZURE_CREDENTIALS - this should contain clientid, clientsecret, tenantid and subscriptionid in JSON format.
       {
        "clientId": "<GUID>",
        "clientSecret": "<GUID>",
        "subscriptionId": "<GUID>",
        "tenantId": "<GUID>"        
        }
        Refer https://github.com/Azure/login for more details. You can either use existing creds or if the SPN was created with script, checkout the creds from the respective KV
    - PRD_LA_NAME - LogAnalytics for Dev.
    - PRD_TF_STORAGE_NAME - Storage account for Terraform state - Dev resources only.

# Optional Secrets.
    A note on SSL/TLS cert requirements.
    
  # NGINX Secrets : To use TLS with NGINX as ingress controller 
    - The private key and public keys needs to be extracted to be fed into K8S as secrets
        Dont store the key file cert in Git(if its public repo), rather apply them imperatively or via pipeline by having them stored as secure vars. 
    - DEV_TLS_PRIVATE_KEY - This secret is required to convert the PFX into 2 files, one a key file that is passwordless and a public cert file in .crt format.
    - PRD_TLS_PRIVATE_KEY - This secret is required to convert the PFX into 2 files, one a key file that is passwordless and a public cert file in .crt format.
** If you are using the same cert for prod and dev, then the above secret values will be same. For example if you use *.cloudkube.xyz then the private key of this cert is shared between Dev and Prod if your URLs are going to be like dev.cloudkube.xyz and prod.cloudkube.xyz

# How to generate DEV_TLS_PRIVATE_KEY or PRD_TLS_PRIVATE_KEY :
To obtain the above key file from the PFX cert(password protected) that contains the private key, use the below steps
- First generate an encrypted private key file:
    openssl pkcs12 -in stardotcloudkubexyz.pfx  -out stardotcloudkubexyz.enc.key
    <Enter password if prompted> -- this is the PFX password created by whoever created/exported the PFX cert.
- Use the above output to get an un-encrypted private key file
    openssl rsa -in stardotcloudkubexyz.enc.key -outform PEM -out stardotcloudkubexyz.key
### Converting the key file to environment variable to be used in Git or locally. We dont want to store the key file in the repo as this is extremely sensitive and compromise a whole lot of other things(wildcard cert esp.)
    
    $base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$pwd\certs\stardotcloudkubexyz.key")) 
    This variable $base64string should be set to envvars or Git secrets $ENV:DEV_TLS_PRIVATE_KEY and $ENV:PRD_TLS_PRIVATE_KEY

    The below will be used the script to decode and is documented for information only.
    [IO.File]::WriteAllBytes("$pwd\certs\stardotcloudkubexyz.key", [Convert]::FromBase64String($base64string))
    Reading the key file as is with Get-Content and then dumping it into a file is messing with the format(new line character etc) and kubectl cant use that exported file and so we are using base64 encoded format.
     
To obtain the above crt file from the PFX cert that contains the public key, use the below steps
    openssl pkcs12 -in stardotcloudkubexyz.pfx -clcerts -nokeys -out stardotcloudkubexyz.crt
The .crt file doesnt need to be secured as its information is public.
   

Gotcha's

	- Audit logging can generate a lot of logs and the Log Analytics billing can be hefty, in an environment where nodes 
        and pods are getting created all the time based  on workload, the audit logs can be 100's of GB and will represent a significant portion of the AKS infrastructure. Keep only 30 days worth of logs in LA and archive the older items(if there is an audit requirement) to storage accounts.
	- Enable PIM and let all users use RBAC for PROD. Dont encourage using --admin(while logging in usin az aks get-credentials) 
        except for troubleshooting purposes. --admin will not capture the user id for k exec, k delete etc.
	- When enabling HPA dont be too agressive as the nodes will take about 3 - 5 minutes to spin up, set the HPA to be 30% or lower.
	- Make sure HPA works, if HPA reports unknown values, then the cluster will never expand 
        and it will be a disaster when the cluster cant handle the prod workload.
	- If possible warm up the clusters before business hours so that the cluster nodes can scale out 
        and be ready to handle the load when business hours start.
	- Have reports ready to ensure that the nodes are scaling out starting from 7 am to 9 am.
	- Split the workloads across nodepools - light weights vs heavy weights
    - If the admin logs in with --admin switch via az aks get-credentials login, then the audit file 
        will not capture actual user ID but the in-built service account's details. Only users with editor 
        access on AKS will be able to use this switch, so control editor access in prod via PIM.
        The audit trail of the alerts can be traced back to PIM access.
    - The container registries tier and capability can have an adverse performance issues, be sure to split the app's code into multiple ACR if required.
      For example, whether ACR is in Basic or Premium tier can have a significant impact when 100's of pods are trying to pull images during a scale out scenario.


