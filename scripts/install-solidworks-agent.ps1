<#
.SYNOPSIS
    Installs the SOLIDWORKS Human-Like CAD Agent instruction and skill system
    into a target project workspace or global AI agent directories.

.PARAMETER Platform
    Target platform(s): all, antigravity, codex, claude, gemini, workspace.

.PARAMETER TargetWorkspace
    Destination project directory when -Platform workspace is used.

.PARAMETER Force
    Overwrite existing global AGENTS.md / CLAUDE.md / GEMINI.md files if present.

.PARAMETER DryRun
    Preview file operations without writing changes.
#>
[CmdletBinding()]
param(
    [ValidateSet("all", "antigravity", "codex", "claude", "gemini", "workspace")]
    [string]$Platform = "all",
    [string]$TargetWorkspace = "",
    [switch]$Force,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$SkillName = "solidworks-photo-to-cad"
$CanonicalSkillDir = Join-Path $RepoRoot ".agents\skills\$SkillName"
$CanonicalRefsDir = Join-Path $CanonicalSkillDir "references"
$AgentsFile = Join-Path $RepoRoot "AGENTS.md"

if (-not (Test-Path $AgentsFile) -or -not (Test-Path $CanonicalSkillDir)) {
    throw "Canonical files missing under $RepoRoot. Run this script from inside the instruction repository."
}

function Copy-FileSafe {
    param([string]$Source, [string]$Destination, [bool]$AllowOverwrite)
    $destDir = Split-Path -Parent $Destination
    if ((Test-Path $Destination) -and -not $AllowOverwrite) {
        Write-Host "[SKIP] Existing file preserved (use -Force to overwrite): $Destination" -ForegroundColor Yellow
        return
    }
    if ($DryRun) {
        Write-Host "[DRY-RUN] Copy $Source -> $Destination" -ForegroundColor Cyan
        return
    }
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    Copy-Item -Path $Source -Destination $Destination -Force
    Write-Host "[OK] $Destination" -ForegroundColor Green
}

function Install-SkillBundle {
    param([string]$SkillEntryFile, [string]$DestSkillDir)
    $destRefs = Join-Path $DestSkillDir "references"
    Copy-FileSafe -Source $SkillEntryFile -Destination (Join-Path $DestSkillDir "SKILL.md") -AllowOverwrite $true
    if ($DryRun) {
        Write-Host "[DRY-RUN] Copy references -> $destRefs" -ForegroundColor Cyan
        return
    }
    New-Item -ItemType Directory -Path $destRefs -Force | Out-Null
    Copy-Item -Path (Join-Path $CanonicalRefsDir "*") -Destination $destRefs -Recurse -Force
    Write-Host "[OK] References copied to $destRefs" -ForegroundColor Green
}

if ($Platform -eq "workspace") {
    if ([string]::IsNullOrWhiteSpace($TargetWorkspace)) {
        throw "Provide -TargetWorkspace <path> when using -Platform workspace."
    }
    Copy-FileSafe -Source $AgentsFile -Destination (Join-Path $TargetWorkspace "AGENTS.md") -AllowOverwrite $Force
    Copy-FileSafe -Source (Join-Path $RepoRoot "CLAUDE.md") -Destination (Join-Path $TargetWorkspace "CLAUDE.md") -AllowOverwrite $Force
    Copy-FileSafe -Source (Join-Path $RepoRoot "GEMINI.md") -Destination (Join-Path $TargetWorkspace "GEMINI.md") -AllowOverwrite $Force
    Install-SkillBundle -SkillEntryFile (Join-Path $CanonicalSkillDir "SKILL.md") -DestSkillDir (Join-Path $TargetWorkspace ".agents\skills\$SkillName")
    Copy-FileSafe -Source (Join-Path $RepoRoot ".claude\skills\$SkillName\SKILL.md") -Destination (Join-Path $TargetWorkspace ".claude\skills\$SkillName\SKILL.md") -AllowOverwrite $true
    Copy-FileSafe -Source (Join-Path $RepoRoot ".gemini\skills\$SkillName\SKILL.md") -Destination (Join-Path $TargetWorkspace ".gemini\skills\$SkillName\SKILL.md") -AllowOverwrite $true
    exit 0
}

$HomeDir = $env:USERPROFILE

if ($Platform -in @("all", "antigravity")) {
    $agConfig = Join-Path $HomeDir ".gemini\config"
    Install-SkillBundle -SkillEntryFile (Join-Path $CanonicalSkillDir "SKILL.md") -DestSkillDir (Join-Path $agConfig "skills\$SkillName")
    Copy-FileSafe -Source $AgentsFile -Destination (Join-Path $agConfig "rules\solidworks-cad-agent.md") -AllowOverwrite $Force
}

if ($Platform -in @("all", "codex")) {
    $codexDir = Join-Path $HomeDir ".codex"
    Copy-FileSafe -Source $AgentsFile -Destination (Join-Path $codexDir "AGENTS.md") -AllowOverwrite $Force
    Install-SkillBundle -SkillEntryFile (Join-Path $CanonicalSkillDir "SKILL.md") -DestSkillDir (Join-Path $codexDir "skills\$SkillName")
}

if ($Platform -in @("all", "claude")) {
    $claudeDir = Join-Path $HomeDir ".claude"
    Copy-FileSafe -Source $AgentsFile -Destination (Join-Path $claudeDir "CLAUDE.md") -AllowOverwrite $Force
    Install-SkillBundle -SkillEntryFile (Join-Path $RepoRoot ".claude\skills\$SkillName\SKILL.md") -DestSkillDir (Join-Path $claudeDir "skills\$SkillName")
}

if ($Platform -in @("all", "gemini")) {
    $geminiDir = Join-Path $HomeDir ".gemini"
    Copy-FileSafe -Source $AgentsFile -Destination (Join-Path $geminiDir "GEMINI.md") -AllowOverwrite $Force
    Install-SkillBundle -SkillEntryFile (Join-Path $RepoRoot ".gemini\skills\$SkillName\SKILL.md") -DestSkillDir (Join-Path $geminiDir "skills\$SkillName")
}
