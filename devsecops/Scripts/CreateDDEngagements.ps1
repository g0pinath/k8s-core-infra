param(      $product_name, 
            [ValidateSet("k8s-scans")]
            [String]
            $prod_type,
            $tags,
            $description,
            [ValidateSet("Production", "Development")]
            [String]
            $lifecyle,
            $baseURL
    )
$Uri = "$baseURL" + "/api/v2/engagements/" 
$target_start = Get-Date -format yyyy-MM-dd
$target_end = Get-Date (Get-Date).AddDays(365) -format yyyy-MM-dd
$status = "In Progress" # default is Not Started, this will make it inactive engagement.

#leave it at https if its TLS enabled. Dont expect redirection to work.
$headers = @{
    'Authorization' = "Token $env:DEFECTDOJO_API_TOKEN"
            }
#Get ProductType ID 
$ProductURI = $baseURL + "/api/v2/products/?name=$product_name"
$ProductURI
$prod_id = ((Invoke-WebRequest -Uri $ProductURI  -Method 'GET' -Headers $headers -SkipCertificateCheck).Content | convertfrom-json).results.id
#Get Engagement Count
$engagementURI = $baseURL + "/api/v2/engagements/?product=$prod_id"
$engagementURI
$engagement_count = ((Invoke-WebRequest -Uri $engagementURI  -Method 'GET' -Headers $headers -SkipCertificateCheck).Content | ConvertFrom-Json).count
$engagement_count
if($engagement_count -eq 0)
{
    write-host "URI is $uri"
    $multipartContent = [System.Net.Http.MultipartFormDataContent]::new()

        $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
        $stringHeader.Name = "name"
        $StringContent = [System.Net.Http.StringContent]::new("$product_name")
        $StringContent.Headers.ContentDisposition = $stringHeader
        $multipartContent.Add($stringContent)

        $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
        $stringHeader.Name = "tags"
        $StringContent = [System.Net.Http.StringContent]::new("$product_name")
        $StringContent.Headers.ContentDisposition = $stringHeader
        $multipartContent.Add($stringContent)

        $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
        $stringHeader.Name = "description"
        $StringContent = [System.Net.Http.StringContent]::new("$product_name")
        $StringContent.Headers.ContentDisposition = $stringHeader
        $multipartContent.Add($stringContent)

        
        $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
        $stringHeader.Name = "product"
        $StringContent = [System.Net.Http.StringContent]::new("$prod_id")
        $StringContent.Headers.ContentDisposition = $stringHeader
        $multipartContent.Add($stringContent)

        
        $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
        $stringHeader.Name = "target_start"
        $StringContent = [System.Net.Http.StringContent]::new("$target_start")
        $StringContent.Headers.ContentDisposition = $stringHeader
        $multipartContent.Add($stringContent)

        $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
        $stringHeader.Name = "target_end"
        $StringContent = [System.Net.Http.StringContent]::new("$target_end")
        $StringContent.Headers.ContentDisposition = $stringHeader
        $multipartContent.Add($stringContent)

        $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
        $stringHeader.Name = "status"
        $StringContent = [System.Net.Http.StringContent]::new("$status")
        $StringContent.Headers.ContentDisposition = $stringHeader
        $multipartContent.Add($stringContent)

    Invoke-WebRequest -Uri $Uri -Body $multipartContent -Method 'POST' -Headers $headers -SkipCertificateCheck 
}    