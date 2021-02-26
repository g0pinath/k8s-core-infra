param($tags,  $engagement, $close_old_findings, $skip_duplicates, $multipartFile, $file_name, $baseURL,
            [ValidateSet("kube-bench Scan")]
            [string]
            $scan_type)

Function FindEngagementIDFromName($engagement, $baseURL)
{
    $engagementTypeURI = "$baseURL/api/v2/engagements/?active=true&name=$engagement"
    $engagement_ID = (((Invoke-WebRequest -Uri $engagementTypeURI  -Method 'GET' -Headers $headers -SkipCertificateCheck).Content | convertfrom-json).results | where {$_.Name -eq "$engagement"}).id
    Return $engagement_ID
}
#Fetch the token
$Uri = "$baseURL/api/v2/import-scan/"
$headers = @{
                  'username' = $env:DD_Admin_User; 'password' = $env:DD_Admin_Password
              }

$TokenRaw = Invoke-WebRequest -Uri $baseURL/api/v2/api-token-auth/ -Method 'POST'  -Body $headers
$Token = ($TokenRaw | ConvertFrom-Json).Token
$env:DEFECTDOJO_API_TOKEN = $Token
#Set headers using token.
$headers = @{
    'Authorization' = "Token $env:DEFECTDOJO_API_TOKEN"
            }
#Fetch the ID
$engagement_ID = FindEngagementIDFromName $engagement $baseURL
Write-Host "Engagement ID is $engagement_ID"

$multipartContent = [System.Net.Http.MultipartFormDataContent]::new()

    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "tags"
    $StringContent = [System.Net.Http.StringContent]::new("$tags")
    $StringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)

    
    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "scan_type"
    $StringContent = [System.Net.Http.StringContent]::new("$scan_type")
    $StringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)

    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "engagement"
    $StringContent = [System.Net.Http.StringContent]::new("$engagement_ID")
    $StringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)

    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "close_old_findings"
    $StringContent = [System.Net.Http.StringContent]::new("$close_old_findings")
    $StringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)

    $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $stringHeader.Name = "skip_duplicates"
    $StringContent = [System.Net.Http.StringContent]::new("$skip_duplicates")
    $StringContent.Headers.ContentDisposition = $stringHeader
    $multipartContent.Add($stringContent)



    
    $FileStream = [System.IO.FileStream]::new($multipartFile, [System.IO.FileMode]::Open)
    $fileHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $fileHeader.Name = "file"
    $fileHeader.FileName = $file_name
    $fileContent = [System.Net.Http.StreamContent]::new($FileStream)
    $fileContent.Headers.ContentDisposition = $fileHeader
    $fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse("image/png")
    $multipartContent.Add($fileContent)


Write-Output "uri is $Uri"
Invoke-WebRequest -Uri $Uri -Body $multipartContent -Method 'POST' -Headers $headers -SkipCertificateCheck