# dotfiles install script for Windows
# Run as Administrator: powershell -ExecutionPolicy Bypass -File install.ps1

$dotfiles = Split-Path -Parent $MyInvocation.MyCommand.Path

function New-Symlink {
  param($target, $link)

  if (Test-Path $link) {
    Write-Host "Already exists, skipping: $link"
    return
  }

  $dir = Split-Path -Parent $link
  if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }

  New-Item -ItemType SymbolicLink -Path $link -Target $target | Out-Null
  Write-Host "Linked: $link -> $target"
}

# WezTerm
New-Symlink "$dotfiles\wezterm\.wezterm.lua" "$env:USERPROFILE\.wezterm.lua"

Write-Host "`nDone. Restart WezTerm to apply."
