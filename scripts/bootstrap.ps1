[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

Write-Host 'Installing Python dependencies...' -ForegroundColor Cyan
python -m pip install -r (Join-Path $repoRoot 'requirements-dev.txt') -e $repoRoot
if ($LASTEXITCODE -ne 0) {
    throw 'Python dependency installation failed.'
}

$pester = Get-Module -ListAvailable Pester |
    Where-Object Version -eq ([version]'5.7.1') |
    Select-Object -First 1
if (-not $pester) {
    Write-Host 'Installing Pester 5.7.1...' -ForegroundColor Cyan
    Install-Module Pester -RequiredVersion 5.7.1 -Scope CurrentUser -Force -SkipPublisherCheck
}

if (-not (Get-Command gitleaks -ErrorAction SilentlyContinue)) {
    if (Get-Command go -ErrorAction SilentlyContinue) {
        Write-Host 'Installing gitleaks 8.30.1 from the Go module registry...' -ForegroundColor Cyan
        go install github.com/zricethezav/gitleaks/v8@v8.30.1
        if ($LASTEXITCODE -ne 0) {
            throw 'Gitleaks installation failed.'
        }
        $goBin = Join-Path (go env GOPATH) 'bin'
        if ($env:PATH -notlike "*$goBin*") {
            $env:PATH = "$goBin$([IO.Path]::PathSeparator)$env:PATH"
        }
    }
    else {
        Write-Warning 'Install gitleaks 8.30.1 and add it to PATH before running verify.ps1.'
    }
}

Write-Host 'Bootstrap complete.' -ForegroundColor Green
