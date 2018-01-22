#region 0: iTextSharp herunterladen

    <# https://sourceforge.net/projects/itextsharp/

    iTextSharp besteht aus folgenden DLLs:
    ======================================

    itextsharp.dll: the core library
    itextsharp.xtra.dll: extra functionality (PDF 2!)
    itextsharp.pdfa.dll: PDF/A-related functionality
    itextsharp.xmlworker.dll: XML (and HTML) functionality

    #>

#endregion

#region 1: Eigenschaften eines PDFs 

Add-Type -Path .\itextsharp.dll
$reader = New-Object iTextSharp.text.pdf.pdfreader -ArgumentList $(Join-Path "$($pwd)" "JSPopupCalendar.pdf")
$reader.Info
$reader.JavaScript

#endregion

#region 2: PDF-Dateien generieren

$pdf  = New-Object iTextSharp.text.Document
$file = $(Join-Path "$($pwd)" "MeinNeuesPDF.pdf")
$pdf.SetPageSize([iTextSharp.text.PageSize]::A4)
$pdf.SetMargins(20,20,20,20)
[void][iTextSharp.text.pdf.PdfWriter]::GetInstance($pdf, [System.IO.File]::Create($file))
$pdf.AddAuthor("Hans Dampf")
$pdf.AddSubject("Mein erstes PDF mit iTextSharp")

$p = New-Object iTextSharp.text.Paragraph
$p.Font = [iTextSharp.text.FontFactory]::GetFont("Arial", "20")
$p.Add("Hallo Welt!")

$img = [iTextSharp.text.Image]::GetInstance($(Join-Path "$($pwd)" "PowerShell.png"))

$pdf.Open()
$pdf.Add($p)
$pdf.Add($img)
$pdf.Dispose()

$r = New-Object iTextSharp.text.pdf.PdfReader -ArgumentList $(Join-Path "$($pwd)" "MeinNeuesPDF.pdf")
$r.Info

#endregion

#region 3: PDF mit Ausgabe eines PowerShell-Befehls

$pdf  = New-Object iTextSharp.text.Document
$file = Join-Path "$($pwd)" "MeinReport.pdf"
$pdf.SetPageSize([iTextSharp.text.PageSize]::A4)
$pdf.SetMargins(20,20,20,20)
[void][iTextSharp.text.pdf.PdfWriter]::GetInstance($pdf, [System.IO.File]::Create($file))
$pdf.AddAuthor("Hans Dampf")
$pdf.AddSubject("Report Prozesse")

$pdf.Open()

$processes = @()
Get-Process | ForEach-Object { $processes += $_.Processname; 
    $processes += "" + $_.Starttime;
    $processes += "" + $_.CPU; 
    $processes += "" + $_.Path 
    }
$t = New-Object iTextSharp.text.pdf.PDFPTable(4)
$t.SpacingBefore = 5
$t.SpacingAfter = 5
if(!$Centered) { $t.HorizontalAlignment = 0 }
$c = New-Object iTextSharp.text.pdf.PdfPCell("Name:")
$c.Border = 0
$t.AddCell($c)
$c = New-Object iTextSharp.text.pdf.PdfPCell("Startzeit:")
$c.Border = 0
$t.AddCell($c)
$c = New-Object iTextSharp.text.pdf.PdfPCell("CPU:")
$c.Border = 0
$t.AddCell($c)
$c = New-Object iTextSharp.text.pdf.PdfPCell("Pfad:")
$c.Border = 0
$t.AddCell($c)
for ($i = 0; $i -le 3; $i++)
{
    $c = New-Object iTextSharp.text.pdf.PdfPCell("========")
    $c.Border = 0
    $t.AddCell($c)
}
foreach($p in $processes)
{
    $c = New-Object iTextSharp.text.pdf.PdfPCell($p)
    $c.Border = 0
    $t.AddCell($c)
}
$pdf.Add($t)
$pdf.Dispose()

#endregion

#region 4: Text aus PDF auslesen

$reader = New-Object iTextSharp.text.pdf.pdfreader -ArgumentList $(Join-Path "$($pwd)" "JSPopupCalendar.pdf")

$text = @()
for ($page = 1; $page -le $reader.NumberOfPages; $page++) {
 $lines = [char[]]$reader.GetPageContent($page) -join "" -split "`n"
 foreach ($line in $lines) {
 #$line
  if ($line -match "^\[") {  
   $line = $line -replace "\\([\S])"
   $line = $line -replace "^\[\(|\)\]TJ$", "" -split "\)\-?\d+\.?\d*\(" -join ""
   $line = $line -replace "\)\] TJ", "" 
   $text += $line -replace "\[\<.{4}\>\] TJ" 
  }
 }
}
$text

#endregion

#region 5: PDF rotieren

$pdfreader  = New-Object iTextSharp.text.pdf.pdfreader($(Join-Path "$($pwd)" "Franz.pdf"))
$output = $(Join-Path "$($pwd)" "FranzRotiert.pdf")

$rotate = New-Object iTextSharp.text.pdf.PdfName('Rotate')
$pdfNumber = New-Object iTextSharp.text.pdf.PdfNumber($degrees=90)
$pageCount = $pdfreader.NumberOfPages
for ($i = 1; $i -le $pageCount; $i++) {
        $pageDict = $pdfreader.GetPageN($i)
        $pageDict.Put($rotate, $pdfNumber)
}

$memoryStream = New-Object System.IO.MemoryStream
$stamper = New-Object iTextSharp.text.pdf.PdfStamper($pdfreader, $memoryStream)
$stamper.Dispose()
$bytes = $memoryStream.ToArray()
$memoryStream.Dispose()
$pdfreader.Dispose()
[System.IO.File]::WriteAllBytes($output, $bytes)

#endregion

#region 6: Wasserzeichen in PDF einfügen

$source = $(Join-Path "$($pwd)" "Franz.pdf")
$destination = $(Join-Path "$($pwd)" "FranzKopie.pdf")
$watermarklocation = $(Join-Path "$($pwd)" "Kopie.png")

$pdfreader  = New-Object iTextSharp.text.pdf.pdfreader($source)

$memoryStream = New-Object System.IO.MemoryStream
$pdfStamper = New-Object iTextSharp.text.pdf.PdfStamper($pdfreader, $memoryStream)

$img = [iTextSharp.text.Image]::GetInstance($watermarklocation)
$img.SetAbsolutePosition(100, 300)
[iTextSharp.text.pdf.PdfContentByte]$waterMark

$pageIndex = $pdfreader.NumberOfPages
for ($i = 1; $i -le $pageIndex; $i++) {
    $waterMark = $pdfStamper.GetOverContent($i)
    $waterMark.AddImage($img)
}
$pdfStamper.FormFlattening = $true
$pdfStamper.Dispose()

$bytes = $memoryStream.ToArray()
$memoryStream.Dispose()
$pdfreader.Dispose()
[System.IO.File]::WriteAllBytes($destination, $bytes)

#endregion

#region 7: PDFs zusammenführen

$output = $(Join-Path "$($pwd)" "MergedPDFs.pdf")
$fileStream = New-Object System.IO.FileStream($output, [System.IO.FileMode]::OpenOrCreate)
$document = New-Object iTextSharp.text.Document
$pdfCopy = New-Object iTextSharp.text.pdf.PdfCopy($document, $fileStream)
$document.Open()

$pdfs = @("Franz.pdf", "TestPDF.pdf")

foreach ($pdf in $pdfs) {
    $reader = New-Object iTextSharp.text.pdf.PdfReader($pdf)
    $pdfCopy.AddDocument($reader)
    $reader.Dispose()
}

$pdfCopy.Dispose()
$document.Dispose()
$fileStream.Dispose()

#endregion

#region 8: PDFs splitten

$pdfreader  = New-Object iTextSharp.text.pdf.pdfreader($(Join-Path "$($pwd)" "Franz.pdf"))
$pageCount = $pdfreader.NumberOfPages

for ($i = 1; $i -le $pageCount; $i++) {
    $doc = New-Object iTextSharp.text.Document($pdfreader.GetPageSizeWithRotation(1))
    $pdfcopy = New-Object iTextSharp.text.pdf.PdfCopy($doc, $(New-Object System.IO.FileStream("Neu$i.pdf", [System.IO.FileMode]::Create)))
    $doc.Open()
    $page = $pdfcopy.GetImportedPage($pdfreader, $i)
    $pdfcopy.AddPage([iTextSharp.text.pdf.PdfImportedPage]$page)
    $doc.Dispose()
}
$pdfreader.Dispose()

#endregion

