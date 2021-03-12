## References
https://www.magalix.com/blog/integrating-open-policy-agent-opa-with-kubernetes-a-deep-dive-tutorial

## Compatability
- These templates cant be used in conjunction with Azure Policies. Disable Azure policies before applying your templates and constraints.

## Using DIY policies
- If you disabled Azure policies add-on then you need to install gatekeeper first before applying the templates and constraints.

### installing gatekeeper
- Using the templates.
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml


### Where can I find more templates and constraints instead of having to write it myself?sss

https://github.com/Azure/azure-policy/tree/master/built-in-references/Kubernetes
