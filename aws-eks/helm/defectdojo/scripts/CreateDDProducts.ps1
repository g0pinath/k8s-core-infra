param(      $product_name, 
            [ValidateSet("WebApps", "APIApps")]
            [String]
            $prod_type,
            $tags,
            $description,
            [ValidateSet("Production", "Construction")]
            [String]
            $lifecyle
    )
$Uri = "https://defectdojo.cloudkube.xyz/api/v2/products/" 
#leave it at https if its TLS enabled. Dont expect redirection to work.
$headers = @{
    'Authorization' = "Token $env:DEFECTDOJO_API_TOKEN"
            }
#Get ProductType ID 
$ProductTypeURI = "https://defectdojo.cloudkube.xyz/api/v2/product_types/?name=$prod_type"
$ProductTypeURI
$prod_id = ((Invoke-WebRequest -Uri $ProductTypeURI  -Method 'GET' -Headers $headers -SkipCertificateCheck).Content | convertfrom-json).results.id

$ProductURI = "https://defectdojo.cloudkube.xyz/api/v2/products/?name=$product_name"
$ProductURI
$prod_count = ((Invoke-WebRequest -Uri $ProductURI  -Method 'GET' -Headers $headers -SkipCertificateCheck).Content | ConvertFrom-Json).count
$prod_count
if($prod_count -eq 0)
{
    write-host "URI is $uri"
    $multipartContent = [System.Net.Http.MultipartFormDataContent]::new()

        $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
        $stringHeader.Name = "name"
        $StringContent = [System.Net.Http.StringContent]::new("$product_name")
        $StringContent.Headers.ContentDisposition = $stringHeader
        $multipartContent.Add($stringContent)

        $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
        $stringHeader.Name = "prod_type"
        $StringContent = [System.Net.Http.StringContent]::new("$prod_id")
        $StringContent.Headers.ContentDisposition = $stringHeader
        $multipartContent.Add($stringContent)

        $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
        $stringHeader.Name = "tags"
        $StringContent = [System.Net.Http.StringContent]::new("$tags")
        $StringContent.Headers.ContentDisposition = $stringHeader
        $multipartContent.Add($stringContent)

        
        $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
        $stringHeader.Name = "description"
        $StringContent = [System.Net.Http.StringContent]::new("$description")
        $StringContent.Headers.ContentDisposition = $stringHeader
        $multipartContent.Add($stringContent)

        
        $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
        $stringHeader.Name = "lifecycle"
        $StringContent = [System.Net.Http.StringContent]::new("$lifecycle")
        $StringContent.Headers.ContentDisposition = $stringHeader
        $multipartContent.Add($stringContent)

    Invoke-WebRequest -Uri $Uri -Body $multipartContent -Method 'POST' -Headers $headers -SkipCertificateCheck 
}    