$ErrorActionPreference = "Stop"

Write-Host "== MemGuard GUI Release Build ==" -ForegroundColor Cyan

if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    Write-Host "未找到 cargo，请先安装 Rust。" -ForegroundColor Yellow
    exit 1
}

cargo build --release

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$exe = Join-Path $PSScriptRoot "target\release\memguard-gui.exe"

if (Test-Path $exe) {
    Write-Host ""
    Write-Host "构建完成：" -ForegroundColor Green
    Write-Host $exe
}
