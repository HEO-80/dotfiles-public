# Cyberpunk Theme

An optional cyberpunk-themed layer for the PowerShell setup.

Adds a **startup dashboard** and replaces the default prompt with the **NETWATCH Oh My Posh theme** — without modifying any existing settings.

## Preview

![Cyberpunk Dashboard](../../../../img/preview-cyberpunk.png)

## What it adds

| Feature | Description |
|---|---|
| Startup dashboard | System Info · Shortcuts · Features · Live Docker status |
| NETWATCH prompt | Oh My Posh theme with git branch, path, user, execution time |
| `Write-Cyber` | ANSI helper to print any hex color in PowerShell |
| Global palette `$CY` | Change the entire color scheme by editing 6 hex values |
| `Show-Dashboard` | Re-run the dashboard at any time |
| `help-ps` | Full help with tools, shortcuts and commands |

## Activation

Uncomment the last line in `user_profile.ps1`:

```powershell
. "$PSScriptRoot\themes\cyberpunk\cyberpunk.ps1"
```

## Customizing colors

Edit `$global:CY` at the top of `cyberpunk.ps1`:

```powershell
$global:CY = @{
    Yellow  = "#FCEE0A"   # Main accent
    Green   = "#39FF14"   # Success
    Cyan    = "#00F0FF"   # Info
    Magenta = "#C678DD"   # Separators
    Dark    = "#555555"   # Borders
    Dim     = "#888888"   # Muted text
}
```

## Reverting to original prompt

To keep the dashboard but use Takuya's original prompt,
comment out the Oh My Posh lines in `cyberpunk.ps1`:

```powershell
# $_ompTheme = Join-Path $PSScriptRoot "omp_cyberpunk.json"
# if (Test-Path $_ompTheme) {
#     oh-my-posh init pwsh --config $_ompTheme | Invoke-Expression
# }
```

## What it does NOT change

- `EditMode Emacs` — preserved
- `Ctrl+F / Ctrl+R` fzf chords — preserved  
- All existing aliases (`g`, `ll`, `vim`, `grep`, `tig`, `less`) — preserved
- `$env:GIT_SSH` and PATH additions — preserved
- `posh-git` module — preserved