# Automated backup for Cowork projects + scheduled tasks -> GitHub
# Runs from C:\Users\britt\Claude. Reviews staged files for likely secrets
# before committing anything; skips (does not commit) anything suspicious
# and logs it instead of failing silently.

$repo = "C:\Users\britt\Claude"
Set-Location $repo

git add -A 2>&1 | Out-Null

$staged = git diff --cached --name-only
if (-not $staged) {
    Write-Output "$(Get-Date): No changes to back up."
    exit 0
}

# Match credential-SHAPED values, not bare words like "token"/"secret" --
# documentation that talks about tokens (e.g. setup guides) is legitimate
# and must not be flagged just for mentioning the word.
$secretContentPattern = '(api[_-]?key|secret|password|token)\s*[:=]\s*[''"]?[A-Za-z0-9_\-\.]{12,}|missive_pat-[A-Za-z0-9]+|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{20,}|sk-ant-[A-Za-z0-9\-]{20,}|-----BEGIN ([A-Z]+ )?PRIVATE KEY-----'
$secretNamePattern = 'token|secret|credential|\.pem$|id_rsa|\.env'
$binaryExt = '\.(docx|xlsx|pdf|png|jpg|jpeg|zip)$'
$selfExclude = @('backup-claude.ps1', 'backup-warnings.log')

$suspicious = @()
foreach ($f in $staged) {
    if ($selfExclude -contains (Split-Path $f -Leaf)) { continue }
    if ($f -match $secretNamePattern) { $suspicious += $f; continue }
    if ($f -match $binaryExt) { continue }
    if (Test-Path $f) {
        $content = [System.IO.File]::ReadAllText((Resolve-Path $f))
        if ($content -match $secretContentPattern) { $suspicious += $f }
    }
}

if ($suspicious.Count -gt 0) {
    git restore --staged $suspicious 2>&1 | Out-Null
    $msg = "$(Get-Date): Skipped possibly-sensitive file(s), NOT committed: $($suspicious -join ', ')"
    Add-Content -Path "$repo\backup-warnings.log" -Value $msg
    Write-Output $msg
}

$remaining = git diff --cached --name-only
if (-not $remaining) {
    Write-Output "$(Get-Date): Nothing safe left to commit after secret sweep."
    exit 0
}

git commit -m "Automated backup $(Get-Date -Format 'yyyy-MM-dd HH:mm')" 2>&1 | Out-Null
try {
    git push origin main
    Write-Output "$(Get-Date): Backup pushed."
} catch {
    Write-Output "$(Get-Date): Push failed: $_"
}
