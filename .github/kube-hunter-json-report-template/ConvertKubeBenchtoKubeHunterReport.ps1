param($kubeHunterJson, $KubeBenchTemplateJson)

$template=get-content .\kube-bench-template.json

$templatejson  = $template | ConvertFrom-Json 

$finalOutput = @()

$convertedjson = $convertedjson | ConvertFrom-Json