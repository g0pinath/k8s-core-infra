# Introduction 
The below are some notes to setup DevSecOps tool set.

# Grafana Dashboards - nice to have.

https://grafana.com/grafana/dashboards/10956 -- for OMS logs projection.

https://grafana.com/grafana/dashboards/13042 -- for fluentd

https://grafana.com/grafana/dashboards/3831 -- autoscaler activity. -- not working in EKS

https://grafana.com/grafana/dashboards/1860 -- node exporter

https://grafana.com/grafana/dashboards/8010 -- alert manager dashboard -- needs extra plugin

https://grafana.com/grafana/dashboards/7249 -- k8s high level dashboard.

https://grafana.com/grafana/dashboards/12019 -- loki dashboard quick search


https://github.com/grafana/helm-charts/blob/main/charts/grafana/values.yaml -- add more plugins if some dashboards need them.

###

To create effective monitoring using filters, ensure that all deployments/pods/statefulsets/daemonsets - basically anything that writes container logs - to have the following labels.

In general the labels makes it easier for monitoring and reporting.

 app: <appname> # this needs to be unique within the namespace.
 appVersion: <appVersion> # for reporting.
 appBuildiD: <BuildID> # for reporting.
 appTier: <Web|Mid> # this is to facilitate network policies.
 release: <helm Release name> Match this with app
 chart: helm chart version, let this be same as appVersion. You can roll back the entire release if you have to.

 ### Thanos

 - Depending on how many dashboards you have and how hard Thanos is being hit, you need to adjust the resources section for Thanos components.
 - Thanos compact especially is resource intensive and the memory it needs is directly proportional to the number of days for which you want to retain and how much the Grafana dashboard is pulling from S3 or blob storage using Thanos.
- The number of days to retain is controlled using below parameters -- https://thanos.io/v0.16/components/compact.md/
        - "--retention.resolution-raw=10d"
        - "--retention.resolution-5m=5d"
        - "--retention.resolution-1h=10d"
 ### Grafana-Loki query examples.

 - To get the list of all constraints that have violation count of greater than 1
 {control_plane="audit-controller", stream="stderr" } | json | count > 1

 - To search for specific errors in the logs
 {control_plane="audit-controller", stream="stderr" } |= "status violations"

 - To search for specific errors in the logs and also be concerned if the count is too high

 {control_plane="audit-controller", stream="stderr" } |= "status violations" |  json | count > 5

 - Number of errors returned in the last 5 minutes filtered by label
 sum(count_over_time({control_plane="audit-controller", stream="stderr"}[5m]))

 - Check if the pod that has a label of control_plane=audit-controller logged more than 100 errors in the last 5 minutes.
 count_over_time({control_plane="audit-controller", stream="stderr"}[5m]) > 100

 ### HPA using metrics other than simple CPU and Memory.

 - Install Prometheus Adapter which installs around 3850 rules by default. Look at the available rules using the below.
   (kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | ConvertFrom-Json  | select resources).resources
- One example is memory_rss, you can use this as shown below to trigger HPA
        apiVersion: autoscaling/v2beta2
        kind: HorizontalPodAutoscaler
        metadata:
        name: github-runner
        namespace: devsecops
        spec:
        scaleTargetRef:
            apiVersion: apps/v1
            kind: Deployment
            name: github-runner
        minReplicas: 2
        maxReplicas: 4
        metrics:
        - type: Resource
            resource:
            name: cpu
            target:
                type: Utilization
                averageUtilization: 50
        - type: Pods
            pods:
            metric:
                name: memory_rss
            target:
                type: AverageValue
                averageValue: 262144000
### scrape config in prometheus.
- The values file in the default prometheus operator installation doesnt scrape from all namespaces. Be sure to add additional namespaces as required. One example is shown below
  prometheus:
    prometheusSpec:  
        additionalScrapeConfigs:
          - job_name: 'votingapp'
            kubernetes_sd_configs:
              - role: pod
                namespaces:
                  names: ['dev']            
### Prometheus service monitor
- Updating the prometheus-thanos-values.yml with scrape configs is one way to enable services/endpoints for prometheus scrapping.
The other option is to create service monitors directly using kubectl like you create a deployment. This in turn updates the scrapeconfigs
https://medium.com/kubernetes-tutorials/simple-management-of-prometheus-monitoring-pipeline-with-the-prometheus-operator-b445da0e0d1a

## Issues with Prometheus

- I created a service monitor but its not picked up by prometheus operator and I dont see it under /targets.
  - Ensure that the service is named correctly. An example is as below, the below has to be created in monitoring namespace
     Servicemonitor.yml 
      apiVersion: monitoring.coreos.com/v1
      kind: ServiceMonitor
      metadata:
        labels:
          app: v2-app
          prometheus: kube-prometheus ## this label is mandatory see https://github.com/prometheus-operator/prometheus-operator/issues/890
        name: v2-app
      spec:
        endpoints:
        - path: /metrics
          port: web  ## this must match the name of the port in the service.
        namespaceSelector:
          matchNames:
          - dev  
        selector:
          matchLabels:
            app: v2-app
      - Ensure that the server name is matching spec.endpoints.port in the above monitor.
          Name:              v2-app
          Namespace:         dev
          Labels:            app=v2-app
                            app.kubernetes.io/managed-by=Helm
                            chart=v2-app-v2.0.1
                            heritage=Helm
                            release=v2-app
          Annotations:       meta.helm.sh/release-name: v2-app
                            meta.helm.sh/release-namespace: dev
          Selector:          app=v2-app
          Type:              ClusterIP
          IP:                172.20.110.58
          Port:              web  8080/TCP
          TargetPort:        8080/TCP
          Endpoints:         10.10.2.109:8080,10.10.4.54:8080
          Session Affinity:  None
          Events:            <none>
** If you are using linkerd
If the app doesnt expose any metrics on /metrics then the above service monitor will show as failed in the targets in prometheus. We can make use of linkerd to without any code changes, linkerd exposes them on port 4191 so the service monitor should be as below.
    apiVersion: monitoring.coreos.com/v1
    kind: ServiceMonitor
    metadata:
      labels:
        app: v2-app
        prometheus: kube-prometheus
      name: v2-app
    spec:
      endpoints:
      - path: /metrics
        #port: web #if the app exposes prom metrics in /metrics then you can use this.
        targetPort: 4191 ## if you are using linkerd
      namespaceSelector:
        matchNames:
        - dev  
      selector:
        matchLabels:
          app: v2-app
*** Fluentbit doesnt send pod name to log analytics.
https://github.com/fluent/fluent-bit/issues/1399 -- Kube_Tag_Prefix      kube.var.log.containers.
https://docs.fluentbit.io/manual/installation/upgrade-notes#fluent-bit-v-1-1

*** How much traffic/logs does fluentbit generate?
With 10 nodes and 500 pods, 150 MB per hour was generated ~ translates to 120 AUD per month approx(with scaling down nodes and pods during business hours.)