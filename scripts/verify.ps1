[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Push-Location $repoRoot
try {
    $requiredFiles = @(
        'ACCEPTANCE.md',
        'OPEN_QUESTIONS.md',
        'README.md',
        'schema/ReleaseChangeV1.schema.json',
        'src/bpa_release_validate/cli.py',
        'src/SubmitBpaReleaseChange/SubmitBpaReleaseChange.psd1',
        'samples/release-change-workflow.json',
        'samples/user-note.md',
        'samples/developer-note.md',
        'tests/python/test_validator.py',
        'tests/powershell/SubmitBpaReleaseChange.Tests.ps1',
        '.github/workflows/verify.yml'
    )
    foreach ($file in $requiredFiles) {
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
            throw "Required file is missing: $file"
        }
    }
    Write-Host 'Required files passed.' -ForegroundColor Green

    & (Join-Path $PSScriptRoot 'Test-Privacy.ps1')

    $env:PYTHONPATH = Join-Path $repoRoot 'src'
    python -m unittest discover -s tests/python -p 'test_*.py' -v
    if ($LASTEXITCODE -ne 0) {
        throw 'Python tests failed.'
    }

    python -m bpa_release_validate --quiet samples/release-change-workflow.json
    if ($LASTEXITCODE -ne 0) {
        throw 'Sample validation failed.'
    }

    Import-Module Pester -RequiredVersion 5.7.1 -Force
    $pesterResult = Invoke-Pester -Path 'tests/powershell' -PassThru -Output Detailed
    if ($pesterResult.FailedCount -ne 0) {
        throw 'Pester tests failed.'
    }

    $gitleaks = Get-Command gitleaks -ErrorAction SilentlyContinue
    if (-not $gitleaks) {
        $candidate = Join-Path (go env GOPATH) 'bin\gitleaks.exe'
        if (Test-Path -LiteralPath $candidate) {
            $gitleaks = Get-Item $candidate
        }
    }
    if (-not $gitleaks) {
        throw 'Gitleaks 8.30.1 is required. Run scripts/bootstrap.ps1.'
    }
    $gitleaksPath = if ($gitleaks -is [Management.Automation.CommandInfo]) {
        $gitleaks.Source
    } else {
        $gitleaks.FullName
    }
    $version = & $gitleaksPath version
    if ($version -notmatch '8\.30\.1') {
        $buildMetadata = if (Get-Command go -ErrorAction SilentlyContinue) {
            go version -m $gitleaksPath 2>$null
        } else {
            ''
        }
        $buildMetadataText = $buildMetadata -join "`n"
        if ($buildMetadataText -notmatch 'gitleaks/v8\s+v8\.30\.1') {
            throw "Expected gitleaks 8.30.1, found: $version"
        }
    }

    & $gitleaksPath dir --no-banner --redact --config .gitleaks.toml .
    if ($LASTEXITCODE -ne 0) {
        throw 'Gitleaks working-tree scan failed.'
    }

    git rev-parse --verify HEAD *> $null
    if ($LASTEXITCODE -eq 0) {
        & $gitleaksPath git --no-banner --redact --config .gitleaks.toml .
        if ($LASTEXITCODE -ne 0) {
            throw 'Gitleaks history scan failed.'
        }
    }
    else {
        Write-Warning 'Git history scan skipped because the repository has no commits yet.'
    }

    $unchecked = Select-String -Path 'ACCEPTANCE.md' -Pattern '^\s*-\s*\[\s\]'
    if ($unchecked) {
        throw 'ACCEPTANCE.md still contains unchecked items.'
    }

    Write-Host 'All verification checks passed.' -ForegroundColor Green
}
finally {
    Pop-Location
}
