[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Push-Location $repoRoot
try {
    $files = git ls-files --cached --others --exclude-standard
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not enumerate repository files.'
    }

    $patterns = [ordered]@{
        'email or UPN' = '(?i)\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b'
        'canonical GUID' = '\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}\b'
        'tenant URL or domain' = '(?i)(share' + 'point\.com|onmicro' + 'soft\.com|dev\.azure\.com|dynamics\.com|crm\d*\.dynamics\.com)'
        'credential assignment' = '(?i)(client[_-]?secret|access[_-]?token|api[_-]?key|password)\s*[:=]\s*["'']?[^\s"'']{8,}'
        'bearer token' = '(?i)\bBear' + 'er\s+[A-Za-z0-9._-]{16,}'
        'private key' = '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE ' + 'KEY-----'
        'absolute user path' = '(?i)([A-Z]:\\Us' + 'ers\\[^\\\s]+|/ho' + 'me/[^/\s]+)'
    }

    $violations = @()
    foreach ($relativePath in $files) {
        $path = Join-Path $repoRoot $relativePath
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            continue
        }
        $bytes = [IO.File]::ReadAllBytes($path)
        if ($bytes -contains 0) {
            continue
        }
        $content = [Text.Encoding]::UTF8.GetString($bytes)
        foreach ($entry in $patterns.GetEnumerator()) {
            if ($content -match $entry.Value) {
                $violations += "${relativePath}: $($entry.Key)"
            }
        }
    }

    if ($violations) {
        $violations | ForEach-Object { Write-Error $_ }
        throw 'Privacy scan found prohibited content.'
    }
    Write-Host 'Privacy scan passed.' -ForegroundColor Green
}
finally {
    Pop-Location
}
