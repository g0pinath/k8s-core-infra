## For Slack
| Name | Description |
| - | - |
| SLACK_WEBHOOK_GITHUBDEPLOYMENTS_PROD  | Production deployments and releases  |
| SLACK_WEBHOOK_GITHUBDEPLOYMENTS_NONPROD  | Only Nonprod deployment updates will be received.  |
| SLACK_WEBHOOK_GITHUB_REPO_ACTIVITIES  | Receive notifications about code checkin etc - Verbose  |
-----------------------------------------------------------------------------------------------------
## For Azure - common for PROD and NonProd
| Name | Description |
| - | - |
| ARM_TENANT_ID  | Azure Directory/Tenant ID  |
-----------------------------------------------------------------------------------------------------
## For Azure - common for both regions in PROD i.e., needs to be created for deploying AKS in single region or multiple region
| Name | Description |
| - | - |
| PRD_DD_ADMIN_PWD |  DefectDojo admin password for login. If none provided, you will need to retrieve the password using kubectl get secret command |
| PRD_AZURE_CREDENTIALS | Refer https://github.com/Azure/login and https://github.com/g0pinath/k8s-core-infra/blob/develop/az-aks/readme.md - retrieve the values from the corresponding KV - git actions for Az login requires in this format. |
| PRD_TLS_PRIVATE_KEY | Private portion of the TLS cert in base64 encoded format  - refer https://github.com/g0pinath/k8s-core-infra/blob/develop/az-aks/readme.md - How to generate DEV_TLS_PRIVATE_KEY or PRD_TLS_PRIVATE_KEY |
-----------------------------------------------------------------------------------------------------
## For Azure NonProd
| Name | Description |
| - | - |
| DEV_ARM_SUBSCRIPTION_ID | Azure subscription ID for Dev cluster  |
| DEV_AZURE_CREDENTIALS | Refer https://github.com/Azure/login and https://github.com/g0pinath/k8s-core-infra/blob/develop/az-aks/readme.md - use the same values as that of DEV_ARM_CLIENT_ID AND DEV_ARM_CLIENT_SECRET as above - git actions for Az login requires in this format. |
| DEV_DD_ADMIN_PWD |  DefectDojo admin password for login. If none provided, you will need to retrieve the password using kubectl get secret command |
| DEV_K8S_KV_NAME | KeyVault that contains the K8S SPN and DefectDojo SPN values. Since you ran the script locally, this KV would have been already created with the value you supplied. Update this value in Git Secrets/ |
| DEV_K8S_NAME | Dev Cluster Name - has to be unique  |
| DEV_LA_NAME | Log Analytics for Dev - even if you intend to use EFK, populate a value for LA - this has to be unique. |
| DEV_TF_STORAGE_NAME | Storage account to maintain terraform state - also used for Thanos LTR storage.  |
| DEV_TLS_PRIVATE_KEY | Private portion of the TLS cert in base64 encoded format  - refer https://github.com/g0pinath/k8s-core-infra/blob/develop/az-aks/readme.md - How to generate DEV_TLS_PRIVATE_KEY or PRD_TLS_PRIVATE_KEY |
-----------------------------------------------------------------------------------------------------
## For Azure Prod (If only primary region is only required)
| Name | Description |
| - | - |
| PRD_A_ARM_SUBSCRIPTION_ID | Azure subscription ID for Dev cluster  |
| PRD_A_K8S_KV_NAME | KeyVault that contains the K8S SPN and DefectDojo SPN values. Since you ran the script locally, this KV would have been already created with the value you supplied. Update this value in Git Secrets/ |
| PRD_A_K8S_NAME | Dev Cluster Name - has to be unique  |
| PRD_A_LA_NAME | Log Analytics for Dev - even if you intend to use EFK, populate a value for LA - this has to be unique. |
| PRD_A_TF_STORAGE_NAME | Storage account to maintain terraform state - also used for Thanos LTR storage.  |
-----------------------------------------------------------------------------------------------------
## For Azure Prod (ONLY required if you need AKS in the secondary region)
| Name | Description |
| - | - |
| PRD_B_ARM_SUBSCRIPTION_ID | Azure subscription ID for Dev cluster  |
| PRD_B_K8S_KV_NAME | KeyVault that contains the K8S SPN and DefectDojo SPN values. Since you ran the script locally, this KV would have been already created with the value you supplied. Update this value in Git Secrets/ |
| PRD_B_K8S_NAME | Dev Cluster Name - has to be unique  |
| PRD_B_LA_NAME | Log Analytics for Dev - even if you intend to use EFK, populate a value for LA - this has to be unique. |
| PRD_B_TF_STORAGE_NAME | Storage account to maintain terraform state - also used for Thanos LTR storage.  |
-----------------------------------------------------------------------------------------------------
