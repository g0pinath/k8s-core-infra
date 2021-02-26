param($product_name, $active="true", $baseURL)

#leave it at https if its TLS enabled. Dont expect redirection to work.
$headers = @{
                  'username' = $env:DD_Admin_User; 'password' = $env:DD_ADMIN_PWD
              }
#Fetch tokens using creds
$TokenRaw = Invoke-WebRequest -Uri $baseURL/api/v2/api-token-auth/ -Method 'POST'  -Body $headers
$Token = ($TokenRaw | ConvertFrom-Json).Token
$env:DEFECTDOJO_API_TOKEN = $Token

$headers = @{
    'Authorization' = "Token $env:DEFECTDOJO_API_TOKEN"
            }

Function FindProductIDFromName($product_name)
{
    $ProductTypeURI = "$baseURL/api/v2/products/?name=$product_name"
    $Product_ID = ((Invoke-WebRequest -Uri $ProductTypeURI  -Method 'GET' -Headers $headers -SkipCertificateCheck).Content | convertfrom-json).results.id
    Return $Product_ID
}

$Product_ID = FindProductIDFromName $product_name
$Uri = "$baseURL/api/v2/findings/?active=$active&test__engagement__product=$Product_ID" 

Function CloseFindings($Uri, $headers, $baseURL, $fullURL)
{
    $output = Invoke-WebRequest -Uri $Uri  -Method 'GET' -Headers $headers -SkipCertificateCheck

    $json = ($output.content |convertfrom-Json).Results
    $UpdateURLPrefix = "$baseURL/api/v2/findings/"
     Foreach($item in $json)
     {
        $id = $item.id
        $fullURL = $UpdateURLPrefix + $id + "/"
        $multipartContent = [System.Net.Http.MultipartFormDataContent]::new()
        $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
        $stringHeader.Name = "verified"
        $StringContent = [System.Net.Http.StringContent]::new("true")
        $StringContent.Headers.ContentDisposition = $stringHeader
        $multipartContent.Add($stringContent)
    
        $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
        $stringHeader.Name = "active"
        $StringContent = [System.Net.Http.StringContent]::new("false")
        $StringContent.Headers.ContentDisposition = $stringHeader
        $multipartContent.Add($stringContent)
    
         #Invoke-WebRequest -Uri $fullURL  -Method 'PUT' -Headers $headers
         Invoke-WebRequest -Uri $fullURL -Body $multipartContent -Method 'PATCH' -Headers $headers -SkipCertificateCheck
     }
    
}
CloseFindings $Uri $headers $baseURL $fullURL #takes care of high, medium and low category findings.
 #For whatever reason the findings under info category wont get closed along with others. We need to run it again after closing high, medium and low category findings.
 Start-sleep -s 60
CloseFindings $Uri $headers $baseURL $fullURL # takes care of informational category findings.