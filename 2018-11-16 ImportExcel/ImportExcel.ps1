Install-Module -Name ImportExcel
Get-Command -Module ImportExcel

#region simple imports

Import-Excel -Path 'c:\Users\Marco\OneDrive\Scripts\ImportExcel\eventlog.xlsx' -WorksheetName Tabelle1

Import-Excel -Path 'c:\Users\Marco\OneDrive\Scripts\ImportExcel\excel2.xlsx' -WorksheetName Data -StartRow 4 -EndRow 23 -StartColumn 3 -EndColumn 11 | Format-Table

Import-Excel -Path 'c:\Users\Marco\OneDrive\Scripts\ImportExcel\excel2.xlsx' -WorksheetName Data -StartRow 4 -EndRow 23 -StartColumn 3 -EndColumn 7 -HeaderName EventID, User, ProcessID, Computer | Format-Table

#endregion

#region some more excel magic

Copy-ExcelWorkSheet -SourceWorkbook 'C:\Users\marco\OneDrive\Scripts\ImportExcel\eventlog.xlsx' -SourceWorkSheet Tabelle1 -DestinationWorkSheet Sheet2 -DestinationWorkbook 'C:\Users\marco\OneDrive\Scripts\ImportExcel\Workbook2.xlsx'

ConvertFrom-ExcelToSQLInsert -Path 'C:\Users\marco\OneDrive\Scripts\ImportExcel\eventlog.xlsx' -WorkSheetname Tabelle1 -ConvertEmptyStringsToNull -TableName Test -DataOnly

ConvertFrom-ExcelSheet -Path 'C:\Users\marco\OneDrive\Scripts\ImportExcel\eventlog.xlsx' -SheetName Tabelle1 -OutputPath 'C:\Users\marco\OneDrive\Scripts\ImportExcel\' -Encoding ASCII -Delimiter ';'

Get-ExcelSheetInfo -Path 'C:\Users\marco\OneDrive\Scripts\ImportExcel\eventlog.xlsx'

#endregion

#region begin example simple export to excel

$xlfile = 'C:\Users\marco\OneDrive\Scripts\ImportExcel\Processes.xlsx' 
Get-Process |
Select-Object -Property Company, Handles, PM, NPM |
Export-Excel -Path $xlfile -Show  -AutoSize -CellStyleSB {
  param(
    $workSheet,
    $totalRows,
    $lastColumn
) 

  Set-CellStyle -WorkSheet $workSheet -Row 1 -LastColumn $lastColumn -Pattern Solid -Color Cyan

  foreach($row in (2..$totalRows |
      Where-Object {
        $_ % 2 -eq 0
  })) 
  {
    Set-CellStyle -WorkSheet $workSheet -Row $row -LastColumn $lastColumn -Pattern Solid -Color Gray
  }

  foreach($row in (2..$totalRows |
      Where-Object {
        $_ % 2 -eq 1
  })) 
  {
    Set-CellStyle -WorkSheet $workSheet -Row $row -LastColumn $lastColumn -Pattern Solid -Color LightGray
  }
}
#endregion

#region begin example export to excel transposed to columns and Pivot

$xlfile = 'C:\Users\marco\OneDrive\Scripts\ImportExcel\Process_Pivot.xlsx' 
Get-Process |
Where-Object -Property company |
Select-Object -Property Company, PagedMemorySize, PeakPagedMemorySize |
Export-Excel -Path $xlfile -Show -AutoSize `
-IncludePivotTable `
-IncludePivotChart `
-ChartType ColumnClustered `
-PivotRows Company `
-PivotData @{
  PagedMemorySize     = 'sum'
  PeakPagedMemorySize = 'sum'
}

#endregion

#region begin example excel-export passthrou

$xlfile = 'C:\Users\marco\OneDrive\Scripts\ImportExcel\passthru.xlsx'
Remove-Item -Path $xlfile -ErrorAction Ignore

$xlPkg = $(
  New-PSItem north 10
  New-PSItem east  20
  New-PSItem west  30
  New-PSItem south 40
) | Export-Excel -Path $xlfile -PassThru

$ws = $xlPkg.Workbook.Worksheets[1]

$ws.Cells['A3'].Value = 'Hello World'
$ws.Cells['B3'].Value = 'Updating cells'
$ws.Cells['D1:D5'].Value = 'Data'

$ws.Cells.AutoFitColumns()

$xlPkg.Save()
$xlPkg.Dispose()

Invoke-Item -Path $xlfile

#endregion

#region begin example excel-export with Pie

$xlfile = 'C:\Users\marco\OneDrive\Scripts\ImportExcel\chart.xlsx'
Get-Process -Module -Name excel | Tee-Object -Variable Proc
$Proc |
Select-Object -ExpandProperty @props |
Export-Excel -Path $xlfile -WorksheetName 'Data' -ChartType Pie3D -PieChart -ShowCategory -ShowPercent -TableName 'proc_data' -TableStyle Dark1 -AutoSize -Show

#or better with splatting

$exportexcel = @{
  Path          = 'C:\Users\marco\OneDrive\Scripts\ImportExcel\chart.xlsx'
  WorksheetName = 'Data'
  ChartType     = 'Pie'
  PieChart      = $true
  ShowCategory  = $true
  ShowPercent   = $true
  TableName     = 'proc_data'
  TableStyle    = 'Dark1'
  AutoSize      = $true
  Show          = $true
}
$Proc |
Select-Object -ExpandProperty @props |
Export-Excel @exportexcel

#endregion

##https://github.com/dfinke/ImportExcel

##EPPlus is a .NET library that reads and writes Excel files using the Office Open XML format (xlsx)
##https://github.com/JanKallman/EPPlus