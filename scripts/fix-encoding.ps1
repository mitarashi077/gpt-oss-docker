# PowerShell script to fix batch file encoding
# Convert UTF-8 batch files to Shift-JIS (Windows default)

Write-Host "========================================" -ForegroundColor Green
Write-Host "Batch File Encoding Fixer" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$batFiles = Get-ChildItem -Path $scriptPath -Filter "*.bat"

Write-Host "Found $($batFiles.Count) batch files to process..." -ForegroundColor Yellow

foreach ($file in $batFiles) {
    try {
        Write-Host "Processing: $($file.Name)" -ForegroundColor Cyan
        
        # Read content as UTF-8
        $content = Get-Content -Path $file.FullName -Encoding UTF8 -Raw
        
        # Write as Shift-JIS (Default encoding in Windows)
        $content | Out-File -FilePath $file.FullName -Encoding Default -NoNewline
        
        Write-Host "  -> Converted to Shift-JIS" -ForegroundColor Green
    }
    catch {
        Write-Host "  -> Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Green
Write-Host "Encoding conversion completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "All batch files have been converted to Shift-JIS encoding." -ForegroundColor White
Write-Host "This should fix character display issues on Windows." -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")