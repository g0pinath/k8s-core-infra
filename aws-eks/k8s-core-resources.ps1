Param(
  [ValidateSet("EFKinCluster", "Loki", "None")]
        [String]
        $K8SLogMonitoringType="Loki",
  [ValidateSet("HAPrometheus-Thanos",  "SingleInstancePrometheus", "None")]
        [String]
        $K8SMetricsMonitoringType="HAPrometheus-Thanos",        
    [ValidateSet("true","false")]
        [String]
        $requireDefectDojo = "true",
    [ValidateSet("true","false")]
        [String]
        $requireSonarQube = "true",
    [ValidateSet("true","false")]
        [String]
        $requireGateKeeper = "true",
        $k8sName="cloudkube-eks-nonprod",
        $AWSRegion="ap-southeast-2",
        [ValidateSet("Nginx","HAProxy")]
        [String]
        $IngressController = "HAProxy",
        [ValidateSet("NONPROD","PRD")]
        $environment = "NONPROD",
        $GRAFANA_URL = "https://dev-grafana.cloudkube.xyz"
  )

Function BuildK8STFInfra($K8SMonitoringType)
{
  cd  ./aws-eks/k8s-infra/tf   
  terraform init
  terraform apply --auto-approve     
  cd ../../..
}


Function LogintoK8S($k8sName,$AWSRegion)
{
   aws eks --region $AWSRegion update-kubeconfig --name $k8sName
}

Function SetupHelm()
{
      
      helm repo remove oteemocharts # Sometimes existing chart is giving issues -- the pod logs shows sonar is registering rules forever.
      helm repo add grafana https://grafana.github.io/helm-charts
      helm repo add oteemocharts https://oteemo.github.io/charts #for sonarqube
      # Add the stable repo for Helm 3
      helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
      helm repo add stable https://charts.helm.sh/stable
      helm repo add loki https://grafana.github.io/loki/charts #deprecated
      helm repo add grafana https://grafana.github.io/helm-charts
      helm repo add haproxytech https://haproxytech.github.io/helm-charts
      
      helm repo add nginx-stable https://helm.nginx.com/stable
      helm repo add linkerd https://helm.linkerd.io/stable
      helm repo add linkerd-edge https://helm.linkerd.io/edge
      helm repo update
}
#helm upgrade --install linkerd2  --set-file global.identityTrustAnchorsPEM=./linkerd-helm-sshpair/ca.crt --set-file identity.issuer.tls.crtPEM=./linkerd-helm-sshpair/issuer.crt --set-file identity.issuer.tls.keyPEM=./linkerd-helm-sshpair/issuer.key --set identity.issuer.crtExpiry=$exp  --set global.prometheusUrl="http://prometheus-server.  devsecops.svc.cluster.local" --set meta.helm.sh/release-namespace=linkerd   linkerd/linkerd2
#Use the above if you have another standalone prometheus server where you want to forward the metrics to.
#Install linkerd
Function InstallLinkerd()
{
    $exp="2021-11-16T02:33:31Z"
    
    #helm upgrade --install linkerd2  --set-file global.identityTrustAnchorsPEM=./k8s-yml-templates/core/linkerd-helm-sshpair/ca.crt --set-file identity.issuer.tls.crtPEM=./k8s-yml-templates/core/linkerd-helm-sshpair/issuer.crt --set-file identity.issuer.tls.keyPEM=./k8s-yml-templates/core/linkerd-helm-sshpair/issuer.key --set identity.issuer.crtExpiry=$exp  --set meta.helm.sh/release-namespace=linkerd     --set prometheusUrl=prometheus-server.  devsecops.svc.cluster.local:9090 linkerd/linkerd2
    helm upgrade --install linkerd2  --set-file global.identityTrustAnchorsPEM=./aws-eks/k8s-yml-templates/core/linkerd-helm-sshpair/ca.crt `
    --set-file identity.issuer.tls.crtPEM=./aws-eks/k8s-yml-templates/core/linkerd-helm-sshpair/issuer.crt `
    --set-file identity.issuer.tls.keyPEM=./aws-eks/k8s-yml-templates/core/linkerd-helm-sshpair/issuer.key --set identity.issuer.crtExpiry=$exp `
    --set meta.helm.sh/release-namespace=linkerd2  --set prometheus.enabled=true linkerd/linkerd2 
  #doesnt honor release-namespace -- it goes to linkerd NS. Linkerd NS shouldnt exist and be created by helm
}

#To use the prometheus instance that comes with linkerd use the above
#linkerd ns needs to be managed by helm, so dont create the NS yet.
Function ApplyK8SCoreTemplates()
{
  cd ./aws-eks/k8s-yml-templates/core
  #Create Namespaces, RBAC and other core components.
  kubectl apply -f namespaces.yaml
  kubectl apply -f .

  #To reboot the patched nodes on a schedule. 
  kubectl apply -f ../../k8s-yml-templates/add-ons/.
  kubectl apply -f ../../k8s-yml-templates/voting-app-prereq/$environment/.
  cd ../..
  #TLS_PRIVATE_KEY is a secret stored in Git. Te generate the value for this variable use the steps below
  #openssl pkcs12 -in Metricon_WC.pfx  -out Metricon_WC.enc.key  # extract private key from PFX
  # openssl rsa -in Metricon_WC.enc.key -outform PEM -out Metricon_WC.key # convert the encrypted key to unencrypted key.
  #$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$pwd/certs/Metricon_WC.key")) 
  #The value of $base64string should be set for $env:TLS_PRIVATE_KEY or Git secret TLS_PRIVATE_KEY
  [IO.File]::WriteAllBytes("$pwd/stardotcloudkubexyz.key", [Convert]::FromBase64String($ENV:DEV_TLS_PRIVATE_KEY))
  
  
  kubectl delete secret acr-registry -n devsecops
  
  #kubectl delete secret ingress-secret-tls -n ingress
    kubectl delete secret tls ingress-secret-tls  -n dev 
    kubectl delete secret tls ingress-secret-tls  -n devops-addons
    kubectl delete secret tls ingress-secret-tls  -n ingress
    kubectl delete secret tls ingress-secret-tls  -n monitoring

    kubectl create secret tls ingress-secret-tls --key certs/stardotcloudkubexyz.key --cert ./certs/stardotcloudkubexyz.crt -n dev 
    kubectl create secret tls ingress-secret-tls --key certs/stardotcloudkubexyz.key --cert ./certs/stardotcloudkubexyz.crt -n devops-addons
    kubectl create secret tls ingress-secret-tls --key certs/stardotcloudkubexyz.key --cert ./certs/stardotcloudkubexyz.crt -n ingress
    kubectl create secret tls ingress-secret-tls --key certs/stardotcloudkubexyz.key --cert ./certs/stardotcloudkubexyz.crt -n monitoring

  #kubectl create secret tls ingress-secret-tls --key ./Metricon_WC.key --cert ./certs/Metricon_WC.crt -n ingress
  #Create PAT secret for GIT Runner
  kubectl create secret generic git-pat --from-literal=git_pat=$env:GIT_PAT -n devsecops
  kubectl create secret docker-registry acr-secret --namespace dev `
    --docker-server=$env:ACR.azurecr.io `
    --docker-username=$env:ACR `
    --docker-password=$env:ACR_PASSWORD

    
  
}

Function HelmInstallIngress($IngressController)
{
    if($IngressController -eq "Nginx")
    {
      #helm upgrade --install nginx nginx-stable/nginx-ingress -n ingress 
    }elseif($IngressController -eq "HAProxy")
    {
      helm upgrade --install haproxy haproxytech/kubernetes-ingress -f ./helm/ingress/values.yml -n devsecops 
    }
    #-f ./az-aks/helm/nginx/ingress-internal.yml -- not working. The private IP is not reachable from a VM in the same VNET, need more investigation.
  
  #For AWS internal
  #--set controller.service.annotations="service.beta.kubernetes.io/aws-load-balancer-type: nlb" `
  #--set controller.service.annotations='service.beta.kubernetes.io/aws-load-balancer-internal: "true"' -n ingress
}
Function InstallDefectDojo()
{

  if($requireDefectDojo -eq "true")
  {
        
        #Install DefectDojo
        cd ./helm/defectdojo
        #helm upgrade --install defectdojo . --set django.ingress.enabled=true --set django.ingress.activateTLS=false --set createSecret=true --set createRabbitMqSecret=true --set createRedisSecret=true --set createMysqlSecret=true --set createPostgresqlSecret=true -n   devsecops
        helm upgrade --install defectdojo . --set django.ingress.activateTLS=false --set createSecret=true --set createRabbitMqSecret=true  `
        --set createRedisSecret=true --set createMysqlSecret=true --set createPostgresqlSecret=true `
        --set extraConfigs.DD_SOCIAL_AUTH_AZUREAD_TENANT_OAUTH2_KEY=$ENV:DD_AZ_CLIENT_ID `
        --set extraConfigs.DD_SOCIAL_AUTH_AZUREAD_TENANT_OAUTH2_TENANT_ID=$ENV:DD_AZ_TENANT_ID `
        --set extraSecrets.DD_SOCIAL_AUTH_AZUREAD_TENANT_OAUTH2_SECRET=$ENV:DD_AZ_CLIENT_SECRET `
        --set admin.password=$env:DD_ADMIN_PWD `
        -n   devops-addons 
        
        cd ../..

  }
}

Function SetupK8SLogging($K8SLogMonitoringType)
{
      #Most popular image https://hub.docker.com/r/fluent/fluentd-kubernetes-daemonset/tags?page=1&ordering=last_updated -- 100M pulls
      switch($K8SLogMonitoringType)
      {
        "EFKinCluster"
        {
              # kubectl apply -f ./k8s-yml-templates/efk-logging/. # dont apply all at once, wait for ES to be present and then deploy kibana
            kubectl apply -f ./k8s-yml-templates/efk-logging/elastic/.
            kubectl apply -f ./k8s-yml-templates/efk-logging/fluent/.
            $esCount = (kubectl get pods | select-string "es-cluster" | Measure).Count
            $timeWaited=0
            #dont install kibana before ES is up and running.
            do
            {
              Start-Sleep -s 1
              $esCount = (kubectl get pods -n monitoring | select-string "es-cluster"  | Measure).Count
              $timeWaited+=1
            }while($esCount -ne 3 -and $timeWaited -lt 300)
            Start-Sleep -s 30 #wait for the 3rd ES cluster pod to be online.
            kubectl apply -f ./k8s-yml-templates/efk-logging/kibana/.
        }
        "ElasticInCloud"
        {
            kubectl apply -f ./k8s-yml-templates/efk-logging/fluent/.
        }
        "Loki"
        {

            helm upgrade --install loki --namespace=monitoring grafana/loki-stack --set grafana.enabled=false `
            --set prometheus.enabled=false `
            --set loki.persistence.enabled=true `
            --set loki.persistence.storageClassName="gp2" `
            --set loki.persistence.size=5Gi -n monitoring
        }
      }
}


Function SetupK8SMetricsMonitoring($K8SMetricsMonitoringType, $K8SLogMonitoringType)
{

        #THANOS_LTR_SAKEY is a secret stored in Git. This is the storage account key in Azure for THanos LTR
        $yml = get-content "$pwd/helm/prometheus-grafana/object-store-template.yml" | ConvertFrom-Yaml
        $yml.config.storage_account_key = $env:THANOS_LTR_SAKEY
        $yml=$yml | ConvertTo-Yaml
        $yml | out-file "$pwd/helm/prometheus-grafana/object-store.yml"
      #Most popular image https://hub.docker.com/r/fluent/fluentd-kubernetes-daemonset/tags?page=1&ordering=last_updated -- 100M pulls
      switch($K8SMetricsMonitoringType)
       {
        
          "SingleInstancePrometheus-Thanos"
          {
                
            #create Thanos components # https://observability.thomasriley.co.uk/prometheus/using-thanos/high-availability/ -- working setup
            #to use the quay.io image instead of the image in the above url, disable externallabel property in promtheus-thanos-values.yml
            kubectl apply -f ./k8s-yml-templates/prometheus-grafana/thanos.yml
            #create object store secret 
            $ThanosStorageConfig = "./helm/prometheus-grafana/object-store.yml"
            kubectl -n monitoring create secret generic thanos-objstore-config --from-file=thanos.yml=$ThanosStorageConfig
            #steps for Thanos with 2 prometheus instances -- inject thanos as side car.
            helm upgrade --install prometheus prometheus-community/kube-prometheus-stack `
            -f ./helm/prometheus-grafana/prometheus-thanos-values.yml `
            --set prometheusOperator.tlsProxy.enabled=false `
            --set ruleNamespaceSelector.any=true `
            --set alertmanager.config.global.smtp_auth_password=$env:smtp_auth_password `
            --set prometheus.prometheusSpec.replicas=1 -n monitoring
             #https://github.com/helm/charts/issues/18765 --WIP Azure AD authentication ------
            #DONT use double quotes in PS 
            #####################################################################
            #####Install Grafana with AAD ############
            #####################################################################
            helm upgrade --install grafana grafana/grafana --set persistence.enabled=true  `
            -f ./k8s-yml-templates/prometheus-grafana/grafana-values/values.yml  `
            --set grafana\.ini.auth\.azuread.client_id="$ENV:GRAFANA_AZ_CLIENT_ID"   `
            --set grafana\.ini.server.root_url="$GRAFANA_URL" `
            --set grafana\.ini.auth\.azuread.client_secret="$ENV:GRAFANA_AZ_CLIENT_SECRET" -n monitoring   
            #root_url must match the reply URL's in the SPN (the SPN may have additiona URI like /aad/blabla, the base domain must match.)
            #If the grafana url is like https://grafana.metricon.com.au/ then the SPN's reply URL can be like https://grafana.metricon.com.au/aad/blabla
            kubectl apply -f ./k8s-yml-templates/prometheus-grafana/.  # to setup ingress  - the ingress URL must match grafana URL.
            remove-item $pwd/helm/prometheus-grafana/object-store.yml -force
            #####################################################################
            #####Install Prometheus Operator for custom metrics############
            #####################################################################
            helm upgrade --install prometheus-adapter prometheus-community/prometheus-adapter -f .\helm\prometheus-grafana\prom-adapter-values.yml -n monitoring
          }
          "HAPrometheus-Thanos"
          {
            
            #create Thanos components # https://observability.thomasriley.co.uk/prometheus/using-thanos/high-availability/ -- working setup
            #to use the quay.io image instead of the image in the above url, disable externallabel property in promtheus-thanos-values.yml
            kubectl apply -f ./k8s-yml-templates/prometheus-grafana/thanos.yml
            #create object store secret 
            $ThanosStorageConfig = "./helm/prometheus-grafana/object-store.yml"
            kubectl delete secret "thanos-objstore-config" -n monitoring
            kubectl -n monitoring create secret generic thanos-objstore-config --from-file=thanos.yml=$ThanosStorageConfig
            #steps for Thanos with 2 prometheus instances -- inject thanos as side car.
            helm upgrade --install prometheus prometheus-community/kube-prometheus-stack `
            -f ./helm/prometheus-grafana/prometheus-thanos-values.yml `
            --set ruleNamespaceSelector.any=true `
            --set prometheusOperator.tlsProxy.enabled=false `
            --set alertmanager.config.global.slack_api_url=$env:K8S_SLACK_NOTIFICATIONS_URL `
            --set prometheus.prometheusSpec.replicas=2 -n monitoring 
            
             #https://github.com/helm/charts/issues/18765 --WIP Azure AD authentication ------
            #DONT use double quotes in PS 
            helm upgrade --install grafana grafana/grafana --set persistence.enabled=true  `
         -f ./k8s-yml-templates/prometheus-grafana/grafana-values/values.yml  `
         --set grafana\.ini.auth\.azuread.client_id="$ENV:GRAFANA_CLIENT_ID"   `
         --set adminPassword="$env:GRAFANA_ADMIN_PASSWORD" `
         --set grafana\.ini.server.root_url="$GRAFANA_URL" `
         --set grafana\.ini.auth\.azuread.auth_url="https://login.microsoftonline.com/$env:ARM_TENANT_ID/oauth2/v2.0/authorize"   `
          --set grafana\.ini.auth\.azuread.token_url="https://login.microsoftonline.com/$env:ARM_TENANT_ID/oauth2/v2.0/token"   `
         --set grafana\.ini.auth\.azuread.client_secret="$ENV:GRAFANA_CLIENT_SECRET" -n monitoring   #persistent is disabled by default.
         
                kubectl apply -f ./k8s-yml-templates/prometheus-grafana/.  # to setup ingress    
            remove-item $pwd/helm/prometheus-grafana/object-store.yml -force   
            
  #if the cluster is too big and you want to send metrics of only certain apps based on labels - podMonitorSelector, serviceMonitorSelector
          }
          "None"
          {
          
          }
       }
}

Function InstallSonarQube()
{
   #--set postgresql.enabled=false --set postgresql.postgresqlServer='sonar-db01.postgres.database.azure.com'  `
   # --set postgresql.postgresqlUsername='sonaradmin@sonar-db01' `
   # --set postgresql.postgresqlPassword=$env:postgres_db_pwd --set postgresql.postgresqlDatabase='postgres'  -n   devsecops 
   helm upgrade --install sonarqube oteemocharts/sonarqube `
   --set extraConfig.account.adminPassword=$env:sonar_admin_password `
   --set extraConfig.account.currentAdminPassword=$env:sonar_admin_password `
   --set sonarProperties.sonar.forceAuthentication="true" --set postgresql.persistence.size="6Gi" `
   --set resources.requests.memory=3000Mi --set persistence.enabled=true `
   -n devops-addons
   #sonarProperties.sonar.forceAuthentication="true" -- disable anonymous users from seeing project info.
   # to let the DB run in the cluster as stateful set.
   #with external DB, it can take upto one hour to load after upgrade. It will be stuck on registerrules for an hour or so.
   #This problem doesnt exist if the DB is a stateful set and exists in cluster and uses the image by helm chart
   #Issue: [o.s.s.r.registerrules] register rules -- sonarqube logs show stuck on this. Maintenance page keeps coming up.
   # remove the local repo using helm repo remove oteemocharts and also delete the namespace and recreate.
}

Function InstallGateKeeper()
{
      kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
      kubectl apply -f .\k8s-yml-templates\core\gatekeeper-policies\constraint-templates\.
      start-sleep -s 30 # wait for a moment before the templates are available for constraints
      kubectl apply -f .\k8s-yml-templates\core\gatekeeper-policies\constraints\.
}

BuildK8STFInfra $K8SMonitoringType
LogintoK8S $k8sName $AWSRegion
SetupHelm
InstallLinkerd
ApplyK8SCoreTemplates
HelmInstallIngress $IngressController

if($requireDefectDojo -eq "true")
{
  InstallDefectDojo
}

if($requireGateKeeper -eq "true")
{
  InstallGateKeeper
}
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module powershell-yaml -Force
Import-Module powershell-yaml
#Log monitoring
SetupK8SLogging $K8SLogMonitoringType #only for logs

#Metrics monitoring
SetupK8SMetricsMonitoring $K8SMetricsMonitoringType $K8SLogMonitoringType 

if($requireSonarQube -eq "true")
{
  InstallSonarQube 
}
#Install Metrics 
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
#Reapply after SQ and DD - sometimes ing is broken for sonarqube
kubectl  delete -f ./k8s-yml-templates/core/sonarIng.yml
start-sleep -s 30
kubectl  apply -f ./k8s-yml-templates/core/sonarIng.yml
#deploy auto scaler its not included by default.
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false" --overwrite
