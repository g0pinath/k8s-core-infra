        
Param($K8S_NAME, $vulnerabilities, $htmlReportName)

$ReportTime = Get-Date -Format "dd-MM-yyyy - hh:mm tt"

#Generate HTML report with pie chart embedded.

Function HTMLHeader4Reports
{
    $ReportTitle = $args[0]
    $header = "
            <html>
            <head>
            <meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>
            <title>$ReportTitle</title>
            <STYLE TYPE='text/css'>
            <!--
            td {
                font-family: Tahoma;
                font-size: 11px;
                border-top: 1px solid #999999;
                border-right: 1px solid #999999;
                border-bottom: 1px solid #999999;
                border-left: 1px solid #999999;
                padding-top: 0px;
                padding-right: 0px;
                padding-bottom: 0px;
                padding-left: 0px;
            }
            body {
                margin-left: 5px;
                margin-top: 5px;
                margin-right: 0px;
                margin-bottom: 10px;
                table {
                border: thin solid #000000;
            }
            -->
            </style>
            </head>
            <body>
            <table width='100%'>
            <tr bgcolor='#CCCCCC'>
            <td colspan='7' height='25' align='center'>
            <font face='tahoma' color='#003399' size='4'><strong>$ReportTitle </strong></font>
            </td>
            </tr>
            </table>
    "
    Return $header
}

Function TableHeader4Reports 
{
    $argumentsCount = ($args |Measure-Object).Count
    $newline = "`n"
    $HeaderPrefix = "
    <table width='100%'><tbody>
        <tr bgcolor=#CCCCCC>"

    Foreach($arguments in $args)
    {
    [string]$ValueRows+= "<td width='10%' align='center'>$arguments</td>"+$newline
    }

    $BottomHeader = "</tr>"


    $FullTableHeader = $HeaderPrefix+$newline+$ValueRows+$BottomHeader


    Return $FullTableHeader
}
Function GenerateHTMLReport($csv)
{
    
#reporting stuff...
$redColor = "#FF0000"
$greenColor = "#01DF3A"
$orangeColor = "#FBB917"
$whiteColor = "#FFFFFF"
    
[string]$HeadingofReport="Kube-Hunter Vulnerability Report for $K8S_NAME - $ReportTime"

$HTMLTitleoutput = HTMLHeader4Reports  $HeadingofReport
$ColumnNameOutput = TableHeader4Reports "Category" "Severity" "vulnerability" "description" "evidence" "avd_reference" "vid"
#Create report file

New-Item -ItemType File -Name "$htmlReportName" -Force
Add-Content $htmlReportName $HTMLTitleoutput # this is thoe first row of the report containing the Title
Add-Content $htmlReportName $ColumnNameOutput # this is the second row of the report containing the headers

Foreach($item in $vulnerabilities)
{    
        
        
        $Category = $item.Category
        $Severity = $item.Severity
        $vulnerability= $item.vulnerability
        $description = $item.description
        $evidence = $item.evidence
        $avd_reference = $item.avd_reference
        $vid = $item.vid

        if($Severity -eq "medium")
        {
            $BGColor1=$orangecolor
        }
        elseif($Severity -eq "high")
        {
            $BGColor1=$redcolor
        }
    
        $dataRow = "
             <tr>

             <td width='10%' bgcolor=`'$BGColor1`'  align='center'>$Category</td>
             <td width='10%' bgcolor=`'$BGColor1`'  align='center'>$Severity</td>    
             <td width='10%' bgcolor=`'$whitecolor`'  align='center'>$vulnerability</td>     
             <td width='10%' bgcolor=`'$whitecolor`'  align='center'>$description</td>  
             <td width='10%' bgcolor=`'$whitecolor`'  align='center'>$evidence</td>        
             <td width='10%' bgcolor=`'$whitecolor`'  align='center'>$avd_reference</td>        
             <td width='10%' bgcolor=`'$whitecolor`'  align='center'>$vid</td>        
             </tr>
             "
        Add-Content $htmlReportName $dataRow 
        $BGColor1=''
 }    
     
}

GenerateHTMLReport  $csv
$body = Get-Content $htmlReportName -Raw

$emailAddresses = $ENV:EMAIL_TO
$emailAddresses = $emailAddresses -split ","
$EMAIL_SUBJECT = $ENV:EMAIL_SUBJECT + " - " + $ReportTime

Foreach($email_to in $emailAddresses)
{

#    Send-MailMessage -From $ENV:EMAIL_FROM -To $email_to -Subject $EMAIL_SUBJECT -Body $body -SmtpServer $ENV:EMAIL_SMTP `
#     -Port $ENV:EMAIL_PORT  -BodyAsHtml
}

#Cleanup
