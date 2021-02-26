## References
https://www.magalix.com/blog/integrating-open-policy-agent-opa-with-kubernetes-a-deep-dive-tutorial

## Compatability
- These templates cant be used in conjunction with Azure Policies. Disable Azure policies before applying your templates and constraints.

## Using DIY policies
- If you disabled Azure policies add-on then you need to install gatekeeper first before applying the templates and constraints.

### installing gatekeeper
- Using the templates.
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml


### Where can I find more templates and constraints instead of having to write it myself?

https://github.com/Azure/azure-policy/tree/master/built-in-references/Kubernetes


### To view OPA logs.

From Grafana use Loki as source and use explore pane to review the logs.
https://zigmax.net/aks-opa-gatekeeper-monitoring/

### Scoping the contraints - word of caution.

If you were ever an AD admin, you would have realized that while GPO's give you more control, it comes with a cost - slower login times.
Similarly applying the constraints on the PODS directly will apply brakes on the auto scaler since each pod has to pass through the OPA policies you have set.
Try applying the policies at a higher level like namespace or deployment. For example if you enfore the deployment to have labels, then we can be guaranteed that the pods in the deployment will also have labels, instead of go checking each POD when its getting created.
This may not work for all constraints, for example, container limits check won't honor deployment KINDS in the constraints.
https://github.com/open-policy-agent/gatekeeper/issues/316 -- this works for labels but not container specific contraints.

### Applying newer contraints

Be sure to set the contraints in DRYRUN mode instead of DENY. Ensure that you are not breaking production and if any workload is not matching your policies, gently remind the team to fix it up before enforcing the policies via DENY. If you decide to just put it in Deny straightaway, you will hit the iceberg!!

### What are the policies that are enforced.

| ConstraintDefinition | Action | 
  | - | - |
  azure-block-automount | deny  <br>
  container-allowed-capabilities | deny  <br>
  container-no-privilege | deny  <br>
  k8sallowedrepos_constraints | deny  <br>
  k8scontainterlimits_constraints | dryrun  <br>
  k8srequiredlabels_constraints | dryrun  <br>
  k8srequiredprobes_constraints | dryrun  <br>
  psp-host-filesystem | deny  <br>
  psp-host-namespace | deny  <br>
  psp-host-network-ports | deny  <br>

Some policies may be unacceptable from security perspective and needs to be denied at all the times. Use this judiciously or you will end up breaking more stuff in prod.
For instace, denying a prod release because a developer forgot to add limits or probes may not be acceptable and looks too harsh. Rather catch them by sending the constraints output to a dashboard - say DefectDojo. There is no OPA integration yet, but you could massage the output and make it look like say kube-bench and publish under that category.
  