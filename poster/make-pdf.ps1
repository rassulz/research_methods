# Собирает poster.html в PDF формата A1 (594 x 841 мм).
# Запуск:  powershell -ExecutionPolicy Bypass -File poster\make-pdf.ps1
# Результат: Aktobe_Poster_A1.pdf в корне репозитория.

$ErrorActionPreference = "Stop"

$repo   = Split-Path -Parent $PSScriptRoot
$html   = Join-Path $PSScriptRoot "poster.html"
$outPdf = Join-Path $repo "Aktobe_Poster_A1.pdf"

# Ищем Chrome или Edge — подойдёт любой на движке Chromium
$candidates = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
)
$browser = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) { throw "Не найден Chrome или Edge. Установи один из них." }

Write-Host "Браузер: $browser"
Write-Host "Исходник: $html"

& $browser --headless=new --disable-gpu --no-sandbox --no-pdf-header-footer `
           --print-to-pdf="$outPdf" "file:///$($html -replace '\\','/')" | Out-Null

if (Test-Path $outPdf) {
  $kb = [math]::Round((Get-Item $outPdf).Length / 1KB)
  Write-Host ""
  Write-Host "Готово: $outPdf  ($kb KB)" -ForegroundColor Green
  Write-Host "Проверь размер страницы — должно быть 594 x 841 мм."
} else {
  throw "PDF не создан."
}
