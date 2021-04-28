        
Param($numofRunners=1, $gitcsv)
#Check if all runner reports are generated.
$ReportTime = Get-Date -Format "dd-MM-yyyy - hh:mm tt"
Copy-Item RUNNER1TaskReport.txt c:\temp
Copy-Item TESTREPORT_CHUIVersion.txt c:\temp
Copy-Item TESTREPORT_CHDBVersion.txt c:\temp
do
{
    Start-Sleep -Seconds 10
    $timeWaited+=1
}while((Get-ChildItem c:\temp | where {$_.Name -like "*TaskReport.txt*"} |measure).Count -ne $numofRunners -and $timeWaited -lt 180)

$csv=@()
Set-Location c:\temp
#Consolidate individual runner reports
for($i=1;$i -le $numofRunners;$i++)
{
    $csvFileName = "Runner"+$i+"TaskReport.txt"
    $csv += Import-Csv $csvFileName
} 
$TESTREPORT_CHUIVersion = get-content TESTREPORT_CHUIVersion.txt 
$TESTREPORT_CHDBVersion = get-content TESTREPORT_CHDBVersion.txt 
$TotalPassed = ($csv | where {$_.Result -eq "Passed"} | Measure).Count
$TotalFailed = ($csv | where {$_.Result -eq "Failed"} | Measure).Count

#Generate a CSV file that can be used for pie chart.
$final=@() 
$obj = New-Object -TypeName psobject
$obj | Add-Member -MemberType NoteProperty -Name TestStatus -Value "Success"
$obj | Add-Member -MemberType NoteProperty -Name Count -Value $TotalPassed
$final+=$obj
$obj = New-Object -TypeName psobject
$obj | Add-Member -MemberType NoteProperty -Name TestStatus -Value "Fail"
$obj | Add-Member -MemberType NoteProperty -Name Count -Value $TotalFailed
$final+=$obj
$final | export-csv -NoTypeInformation TestConsolidatedReport.csv   

#Refer https://github.com/proxb/PoshCharts
Function Out-PieChart {
    <#
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER InputObject

        .PARAMETER XField

        .PARAMETER YField

        .PARAMETER Title

        .PARAMETER IncludeLegend

        .NOTES
            Name: Out-PieChart
            Author: Boe Prox
            Version History;
                1.0 //Boe Prox - 08/20/2016
                    - Initial Version

        .EXAMPLE
            Get-Process | Sort-Object WS -Descending | 
            Select-Object -First 10 | Out-PieChart -XField Name `
            -YField WS -Title 'Top 10 Processes By Working Set Memory' -IncludeLegend -Enable3D

        .EXAMPLE
            Get-Process | Sort-Object WS -Descending | 
            Select-Object -First 10 | Out-PieChart -XField Name `
            -YField WS -ToFile "C:\users\proxb\desktop\File.jpeg" -IncludeLegend `
            -Title 'Top 10 Processes By Working Set Memory'

        .EXAMPLE
            Get-WMIObject -Class Win32_PerfFormattedData_PerfProc_Process -Filter "Name != '_Total' AND Name != 'Idle' AND PercentProcessorTime != '0'"|
            Sort PercentProcessorTime -Descending  | Select -First 10 | 
            Out-PieChart -XField Name -YField PercentProcessorTime -Title 'Top 10 Processes By CPU Usage (if applicable)' -IncludeLegend
    #>
    [cmdletbinding(
        DefaultParameterSetName = 'UI'
    )]
    Param (
        [parameter(ValueFromPipeline=$True)]
        $InputObject,
        [parameter()]
        [string]$XField,
        [parameter()]
        [string]$YField,
        [parameter()]
        [string]$Title = 'Test Title',
        [parameter()]
        [switch]$IncludeLegend,
        [parameter()]
        [switch]$Enable3D,
        [parameter(ParameterSetName='File')]
        [ValidateScript({
            $UsedExt = $_ -replace '.*\.(.*)','$1'
            $Extensions = "Jpeg", "Png", "Bmp", "Tiff", "Gif", "Emf", "EmfDual", "EmfPlus"
            If ($Extensions -contains $UsedExt) {
                $True
            } 
            Else {
                Throw "The extension '$UsedExt' is not valid! Valid extensions are $($Extensions -join ', ')."
            }
        })]
        [string]$ToFile
    )
    Begin {
        #region Helper Functions
        function ConvertTo-Hashtable
        { 
            param([string]$key, $value) 

            Begin 
            { 
                $hash = @{} 
            } 
            Process 
            { 
                $thisKey = $_.$Key
                $hash.$thisKey = $_.$Value 
            } 
            End 
            { 
                Write-Output $hash 
            }

        }
        Function Invoke-SaveDialog {
            $FileTypes = [enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')| ForEach {
                $_.Insert(0,'*.')
            }
            $SaveFileDlg = New-Object System.Windows.Forms.SaveFileDialog
            $SaveFileDlg.DefaultExt='PNG'
            $SaveFileDlg.Filter="Image Files ($($FileTypes))|$($FileTypes)|All Files (*.*)|*.*"
            $return = $SaveFileDlg.ShowDialog()
            If ($Return -eq 'OK') {
                [pscustomobject]@{
                    FileName = $SaveFileDlg.FileName
                    Extension = $SaveFileDlg.FileName -replace '.*\.(.*)','$1'
                }
        
            }
        }
        #endregion Helper Functions
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Windows.Forms.DataVisualization
        $Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
        $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea 
        $Series = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.Series
        $ChartTypes = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]
        $Series.ChartType = $ChartTypes::Pie
        $Chart.Series.Add($Series)
        $Chart.ChartAreas.Add($ChartArea)

        If ($PSBoundParameters.ContainsKey('Enable3D')) {
            $ChartArea.Area3DStyle.Enable3D=$True
            $ChartArea.Area3DStyle.Inclination = 50
        }

        $IsPipeline=$True
        $Data = New-Object System.Collections.ArrayList
        If ($PSBoundParameters.ContainsKey('InputObject')) {
            $Data.AddRange($InputObject)
            $IsPipeline=$False
        }
    }
    Process {
        If ($IsPipeline) {
            [void]$Data.Add($_)
        }
    }
    End {
        $HashTable = $Data | ConvertTo-Hashtable -key $XField -value $YField
        #region MSChart Build
        $Chart.Series['Series1'].Points.DataBindXY($HashTable.Keys, $HashTable.Values)
        $Chart.Series['Series1']['PieLabelStyle'] = 'Outside'
        $Chart.Series['Series1'].Label = "#VALX (#VALY)"
        $chart.Series["Series1"].LegendText = "#VALX"
        $Chart.Series['Series1']['PieLineColor'] = 'Black'
        #endregion MSChart Build

        #region MSChart Configuration
        $Chart.Width = 700 
        $Chart.Height = 400 
        $Chart.Left = 10 
        $Chart.Top = 10
        $Chart.BackColor = [System.Drawing.Color]::White
        $Chart.BorderColor = 'Black'
        $Chart.BorderDashStyle = 'Solid'

        $ChartTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title
        $ChartTitle.Text = $Title
        $Font = New-Object System.Drawing.Font @('Microsoft Sans Serif','12', [System.Drawing.FontStyle]::Bold)
        $ChartTitle.Font =$Font
        $Chart.Titles.Add($ChartTitle)    
        #endregion MSChart Configuration

        If ($PSBoundParameters.ContainsKey('IncludeLegend')) {
            #region Create Legend
            $Legend = New-Object System.Windows.Forms.DataVisualization.Charting.Legend
            $Legend.IsEquallySpacedItems = $True
            $Legend.BorderColor = 'Black'
            $Chart.Legends.Add($Legend)
            #endregion Create Legend
        }

        If ($PSBoundParameters.ContainsKey('ToFile')) {
            $Extension = $ToFile -replace '.*\.(.*)','$1'
            $Chart.SaveImage($ToFile, $Extension)
        } 
        Else {
            #region Windows Form to Display Chart
            $AnchorAll = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor 
                [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
            $Form = New-Object Windows.Forms.Form  
            $Form.Width = 740 
            $Form.Height = 490 
            $Form.controls.add($Chart) 
            $Chart.Anchor = $AnchorAll

            # add a save button 
            $SaveButton = New-Object Windows.Forms.Button 
            $SaveButton.Text = "Save" 
            $SaveButton.Top = 420 
            $SaveButton.Left = 600 
            $SaveButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
            # [enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat') 
            $SaveButton.add_click({
                $Result = Invoke-SaveDialog
                If ($Result) {
                    $Chart.SaveImage($Result.FileName, $Result.Extension)
                }
            }) 

            $Form.controls.add($SaveButton)
            $Form.Add_Shown({$Form.Activate()}) 
            [void]$Form.ShowDialog()
            #endregion Windows Form to Display Chart  
        }
    } 
}

#Generate pie chart image.
import-csv TestConsolidatedReport.csv   | Out-PieChart -XField TestStatus `
             -YField Count -ToFile "c:\temp\CHReportFile.jpeg"  `
             -Title "ClickHome Automated Tests Summary - $ReportTime
                     CHUIVerion: $TESTREPORT_CHUIVersion CHDBVersion: $TESTREPORT_CHDBVersion " -Enable3D  

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
    

$images = Get-ChildItem "c:\temp\CHReportFile.jpeg"
$ImageHTML = $images | % {
  $ImageBits = [Convert]::ToBase64String((Get-Content $_ -Encoding Byte))
  "<img src=data:image/png;base64,$($ImageBits) alt='My Image'/>"
}


#reporting stuff...
$redColor = "#FF0000"
$greenColor = "#01DF3A"
$orangeColor = "#FBB917"
$whiteColor = "#FFFFFF"
    
[string]$HeadingofReport="CH Automated Testing Report CHUIVerion: $TESTREPORT_CHUIVersion CHDBVersion: $TESTREPORT_CHDBVersion - $ReportTime"

$HTMLTitleoutput = HTMLHeader4Reports  $HeadingofReport
$ColumnNameOutput = TableHeader4Reports "Test Name" "Test Result" "Parameters Used"	"Description"
#Create report file
Set-Location c:\temp
New-Item -ItemType File -Name "ch_auto_reports.html" -Force
ConvertTo-Html -Body $style -PreContent $imageHTML | Out-File "ch_auto_reports.html"
Add-Content ch_auto_reports.html $HTMLTitleoutput # this is thoe first row of the report containing the Title
Add-Content ch_auto_reports.html $ColumnNameOutput # this is the second row of the report containing the headers

Foreach($item in $csv)
{    
        $TestName = $item.TestName
        $TestResult = $item.Result
        $ParametersUsed = ($gitcsv | where {$_."Scenario Name" -eq $TestName})."Test Parameters"
        $Description = ($gitcsv | where {$_."Scenario Name" -eq $TestName})."Test Description"
        if($TestResult -ne "Passed" -and $TestResult -ne "TestNotFound")
        {
            $BGColor1=$redColor
        }
        else
        {
            $BGColor1=$greenColor
        }
    
        $dataRow = "
             <tr>

             <td width='10%' bgcolor=`'$whitecolor`'  align='center'>$TestName</td>
             <td width='10%' bgcolor=`'$BGColor1`'  align='center'>$TestResult</td>    
             <td width='10%' bgcolor=`'$whitecolor`'  align='center'>$ParametersUsed</td>     
             <td width='10%' bgcolor=`'$whitecolor`'  align='center'>$Description</td>        
              

             </tr>
             "
        Add-Content ch_auto_reports.html $dataRow 
        $BGColor1=''
 }    
     
}

GenerateHTMLReport  $csv
$body = Get-Content ch_auto_reports.html -Raw

$emailAddresses = $ENV:EMAIL_TO
$emailAddresses = $emailAddresses -split ","
$EMAIL_SUBJECT = $ENV:EMAIL_SUBJECT + " - " + $ReportTime

Foreach($email_to in $emailAddresses)
{

    Send-MailMessage -From $ENV:EMAIL_FROM -To $email_to -Subject $EMAIL_SUBJECT -Body $body -SmtpServer $ENV:EMAIL_SMTP `
     -Port $ENV:EMAIL_PORT  -BodyAsHtml
}

#Cleanup
Get-ChildItem | where {$_.Name -like "*TaskReport.txt*"} | Remove-Item -Force

Remove-item "c:\temp\ch_auto_reports.html" -Force
Remove-item  "c:\temp\CHReportFile.jpeg" -Force
Remove-item "c:\temp\TESTREPORT_CHUIVersion.txt" -Force
Remove-item  "c:\temp\TESTREPORT_CHDBVersion.txt" -Force