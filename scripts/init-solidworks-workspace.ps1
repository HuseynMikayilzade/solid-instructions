<#
.SYNOPSIS
    Initializes a SOLIDWORKS Human-Like CAD workspace on any Windows PC and
    checks SOLIDWORKS 2026 COM, C# compiler, templates, and materials readiness.

.PARAMETER TargetWorkspace
    Optional path to initialize a new project folder. Defaults to current repo root.

.PARAMETER Global
    Also install rules, skills, and commands globally for Antigravity, Codex, Claude Code, and Gemini CLI.

.PARAMETER Force
    Overwrite existing AGENTS.md / CLAUDE.md / GEMINI.md files when initializing or installing globally.

.PARAMETER DryRun
    Preview actions without writing files.
#>
[CmdletBinding()]
param(
    [string]$TargetWorkspace = "",
    [switch]$Global,
    [switch]$Force,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Installer = Join-Path $PSScriptRoot "install-solidworks-agent.ps1"

Write-Host "=== SOLIDWORKS CAD Agent Init ===" -ForegroundColor Cyan

# 1. Workspace initialization (current or target folder)
if (-not [string]::IsNullOrWhiteSpace($TargetWorkspace)) {
    Write-Host "Initializing target workspace: $TargetWorkspace" -ForegroundColor Cyan
    $wsArgs = @{
        Platform        = "workspace"
        TargetWorkspace = $TargetWorkspace
    }
    if ($Force) { $wsArgs["Force"] = $true }
    if ($DryRun) { $wsArgs["DryRun"] = $true }
    & $Installer @wsArgs

    if (-not $DryRun) {
        New-Item -ItemType Directory -Path (Join-Path $TargetWorkspace "outputs") -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $TargetWorkspace "sources") -Force | Out-Null
        Copy-Item -Path (Join-Path $RepoRoot "init.cmd") -Destination (Join-Path $TargetWorkspace "init.cmd") -Force
        $destScripts = Join-Path $TargetWorkspace "scripts"
        New-Item -ItemType Directory -Path $destScripts -Force | Out-Null
        Copy-Item -Path (Join-Path $RepoRoot "scripts\*.ps1") -Destination $destScripts -Force
        $srcDocx = Join-Path $RepoRoot "sources\CAD-CAE-CAM-Serbest-Ish-2026.docx"
        if (Test-Path $srcDocx) {
            Copy-Item -Path $srcDocx -Destination (Join-Path $TargetWorkspace "sources\CAD-CAE-CAM-Serbest-Ish-2026.docx") -Force
        }
    }
    $CheckRoot = $TargetWorkspace
} else {
    if (-not $DryRun) {
        New-Item -ItemType Directory -Path (Join-Path $RepoRoot "outputs") -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $RepoRoot "sources") -Force | Out-Null
    }
    $CheckRoot = $RepoRoot
}

# 2. Optional global installation across AI platforms
if ($Global) {
    Write-Host "Installing globally across AI platforms..." -ForegroundColor Cyan
    $glArgs = @{ Platform = "all" }
    if ($Force) { $glArgs["Force"] = $true }
    if ($DryRun) { $glArgs["DryRun"] = $true }
    & $Installer @glArgs
}

# 3. Environment Readiness Check
Write-Host ""
Write-Host "--- Environment & SOLIDWORKS Readiness Check ---" -ForegroundColor Cyan

$comOk = Test-Path 'Registry::HKEY_CLASSES_ROOT\SldWorks.Application'
Write-Host ("  [COM]  SldWorks.Application ProgID : " + $(if ($comOk) { "OK" } else { "MISSING (use Priority 2 VBA fallback)" })) -ForegroundColor $(if ($comOk) { "Green" } else { "Yellow" })

$swSetup = Get-ItemProperty 'HKLM:\SOFTWARE\SolidWorks\SOLIDWORKS *\Setup' -ErrorAction SilentlyContinue | Select-Object -First 1
$swDir = if ($swSetup) { $swSetup.'SolidWorks Folder' } else { "" }
$interopOk = $false
$matOk = $false
if ($swDir) {
    $interopOk = (Test-Path (Join-Path $swDir "api\redist\SolidWorks.Interop.sldworks.dll")) -and (Test-Path (Join-Path $swDir "api\redist\SolidWorks.Interop.swconst.dll"))
    $matDb = Get-ChildItem (Join-Path $swDir "lang") -Filter "solidworks materials.sldmat" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    $matOk = ($null -ne $matDb)
}
Write-Host ("  [DIR]  SOLIDWORKS Folder           : " + $(if ($swDir) { $swDir } else { "Not detected" })) -ForegroundColor $(if ($swDir) { "Green" } else { "Yellow" })
Write-Host ("  [API]  Interop DLLs (api\redist)   : " + $(if ($interopOk) { "OK" } else { "MISSING" })) -ForegroundColor $(if ($interopOk) { "Green" } else { "Yellow" })
Write-Host ("  [MAT]  Materials DB (.sldmat)      : " + $(if ($matOk) { "OK" } else { "Not found" })) -ForegroundColor $(if ($matOk) { "Green" } else { "Yellow" })

$tmpl = Get-ChildItem "C:\ProgramData\SOLIDWORKS" -Filter "Part.PRTDOT" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
Write-Host ("  [TPL]  Part.PRTDOT Template        : " + $(if ($tmpl) { $tmpl.FullName } else { "Check Tools > Options > Default Templates" })) -ForegroundColor $(if ($tmpl) { "Green" } else { "Yellow" })

$csc = Get-ChildItem "C:\Windows\Microsoft.NET\Framework64\v4.0*\csc.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
Write-Host ("  [CSC]  .NET x64 C# Compiler        : " + $(if ($csc) { $csc.FullName } else { "Not found" })) -ForegroundColor $(if ($csc) { "Green" } else { "Yellow" })

$docxOk = Test-Path (Join-Path $CheckRoot "sources\CAD-CAE-CAM-Serbest-Ish-2026.docx")
Write-Host ("  [DOC]  Instructor Guide (.docx)    : " + $(if ($docxOk) { "OK" } else { "Optional (not in sources/)" })) -ForegroundColor $(if ($docxOk) { "Green" } else { "Yellow" })

$priorityMode = if ($comOk -and $interopOk -and $csc) { "Priority 1 (Live SOLIDWORKS COM + C# Automation)" } else { "Priority 2 (VBA Macro Fallback)" }
Write-Host ""
Write-Host ("Active Execution Mode : " + $priorityMode) -ForegroundColor Cyan
Write-Host ("Guidelines Loaded From: " + (Join-Path $CheckRoot "AGENTS.md")) -ForegroundColor Cyan
Write-Host "Init complete." -ForegroundColor Green
