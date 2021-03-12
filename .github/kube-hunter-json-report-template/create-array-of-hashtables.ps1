
Function ConvertToHT($hashtabletoConvert)
{
    $StringReturned = ''
Write-Host "Hashtables: @("

foreach($hashtable in $Hashtables){
    Write-Host "  @{"
    $StringReturned += "  @{" 
    foreach($entry in $hashtable.GetEnumerator()){
        Write-Host "    " $entry.Key = $entry.Value
        $StringReturned += "    " + $entry.Key + "=" + $entry.Value
    }
    Write-Host "  }"
    $StringReturned += "  }" 
}
Write-Host ")"

}
$hts = Get-Content C:\temp\kube-hunter-converted.json
$hts = $hts | convertfrom-json
$finalstring = '@("'
Foreach($item in $hts)
{   
    $htactual = @{}
    $hashtabletoConvert = $item.psobject.properties | Foreach { $htactual[$_.Name] = $_.Value }
    $StringReturned = ConvertToHT $hashtabletoConvert
    $finalstring += $StringReturned 
}
$finalstring += '")"'
Write-output "Final string $finalstring"