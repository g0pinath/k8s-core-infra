param($product_type, $critical_product="true", $key_product="true")
$Uri = "https://defectdojo.cloudkube.xyz/api/v2/product_types/" 
#leave it at https if its TLS enabled. Dont expect redirection to work.
$headers = @{
    'Authorization' = "Token $env:DEFECTDOJO_API_TOKEN"
            }

write-host "URI is $uri"
$multipartContent = [System.Net.Http.MultipartFormDataContent]::new()

    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "name"
    $StringContent = [System.Net.Http.StringContent]::new("$product_type")
    $StringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)

    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "critical_product"
    $StringContent = [System.Net.Http.StringContent]::new("$critical_product")
    $StringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)

    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "key_product"
    $StringContent = [System.Net.Http.StringContent]::new("$key_product")
    $StringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)
#if product type already exists then skip

$ProductTypeURI = "https://defectdojo.cloudkube.xyz/api/v2/product_types/?name=$product_type"
$ProductTypeURI
$prod_id_count = (Invoke-WebRequest -Uri $ProductTypeURI  -Method 'GET' -Headers $headers -SkipCertificateCheck).Content.Count 
if($prod_id_count -eq 0)
{
    Invoke-WebRequest -Uri $Uri -Body $multipartContent -Method 'POST' -Headers $headers -SkipCertificateCheck
}
