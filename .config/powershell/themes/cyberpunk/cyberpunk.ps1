# ================================================================= #
#   Cyberpunk theme for craftzdog/dotfiles-public                   #
#   Adds: NETWATCH Oh My Posh prompt + startup dashboard            #
#                                                                   #
#   Respects all existing settings from user_profile.ps1:          #
#   - EditMode Emacs is preserved                                   #
#   - Ctrl+f / Ctrl+r fzf chords are preserved                     #
#   - All existing aliases are preserved                            #
# ================================================================= #

# ── ANSI color helper ─────────────────────────────────────────────
function Write-Cyber {
    param(
        [string]$Text,
        [string]$Color = "#FCEE0A",
        [switch]$NoNewline
    )
    $esc   = [char]27
    $r     = [Convert]::ToInt32($Color.Substring(1,2), 16)
    $g     = [Convert]::ToInt32($Color.Substring(3,2), 16)
    $b     = [Convert]::ToInt32($Color.Substring(5,2), 16)
    $ansi  = "${esc}[38;2;${r};${g};${b}m"
    $reset = "${esc}[0m"
    if ($NoNewline) { Write-Host "$ansi$Text$reset" -NoNewline }
    else            { Write-Host "$ansi$Text$reset" }
}

# ── Global color palette — edit hex values to restyle everything ──
$global:CY = @{
    Yellow  = "#FCEE0A"   # Main accent
    Green   = "#39FF14"   # Success / git clean
    Cyan    = "#00F0FF"   # Info / values
    Magenta = "#C678DD"   # Separators / secondary
    Dark    = "#555555"   # Borders
    Dim     = "#888888"   # Muted text
}

# ── Oh My Posh — NETWATCH theme ───────────────────────────────────
# Replaces the default takuya prompt with the NETWATCH cyberpunk prompt.
# To revert to Takuya's original prompt, comment out these 2 lines:
$_ompTheme = Join-Path $PSScriptRoot "omp_cyberpunk.json"
if (Test-Path $_ompTheme) {
    oh-my-posh init pwsh --config $_ompTheme | Invoke-Expression
}

# ── Startup dashboard ─────────────────────────────────────────────
function Show-Dashboard {
    $c = $global:CY

    $cpuName = (Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue)?.Name `
        -replace 'AMD |Intel\(R\) | \d+-Core| Processor| @.*$', ''

    $sysInfo = [ordered]@{
        "Started" = (Get-Date -Format "yyyy-MM-dd HH:mm")
        "Shell"   = "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor) $($PSVersionTable.PSEdition)"
        "CPU"     = if ($cpuName) { $cpuName.Trim() } else { "N/A" }
        "RAM"     = "{0:N2} GB" -f ((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
        "User"    = "$env:USERNAME"
        "OS"      = (Get-CimInstance Win32_OperatingSystem).Caption
    }

    # Edit shortcuts to match your own tools
    $shortcuts = @(
        @{ Label = "VS Code   (vsc)";  Value = "code ." }
        @{ Label = "Neovim    (vim)";  Value = "nvim ." }
        @{ Label = "Git log   (gl)";   Value = "git log --oneline" }
        @{ Label = "Help      (help-ps)"; Value = "show all commands" }
    )

    $features = @(
        @{ Key = "ls / dir";   Desc = "Terminal-Icons   ->  icons next to files" }
        @{ Key = "Ctrl+F";     Desc = "Fzf Search       ->  interactive file finder" }
        @{ Key = "Ctrl+R";     Desc = "Fzf History      ->  search command history" }
        @{ Key = "Arrow  ->";  Desc = "Autocomplete     ->  accept grey suggestion" }
        @{ Key = "which cmd";  Desc = "which            ->  find command path" }
        @{ Key = "help-ps";    Desc = "Help             ->  list all commands" }
    )

    $sep  = "=" * 80
    $sep2 = "-" * 80

    Write-Cyber $sep $c.Magenta
    Write-Host ""
    Write-Cyber "$("System Info".PadRight(38))| Shortcuts" $c.Green
    Write-Host ""

    $maxLines = [Math]::Max($sysInfo.Count, $shortcuts.Count)
    $sysKeys  = @($sysInfo.Keys)

    for ($i = 0; $i -lt $maxLines; $i++) {
        if ($i -lt $sysKeys.Count) {
            $k = $sysKeys[$i]
            Write-Cyber "$($k.PadRight(10))" $c.Yellow -NoNewline
            Write-Cyber ": " $c.Magenta -NoNewline
            Write-Cyber "$("$($sysInfo[$k])".PadRight(24))" $c.Cyan -NoNewline
        } else {
            Write-Host "".PadRight(38) -NoNewline
        }
        if ($i -lt $shortcuts.Count) {
            Write-Cyber "| " $c.Magenta -NoNewline
            Write-Cyber "$($shortcuts[$i].Label.PadRight(18))" $c.Yellow -NoNewline
            Write-Cyber " $($shortcuts[$i].Value)" $c.Cyan
        } else { Write-Host "" }
    }

    Write-Host ""
    Write-Cyber $sep2 $c.Magenta
    Write-Host ""
    Write-Cyber "  Features" $c.Green
    Write-Host ""
    foreach ($f in $features) {
        Write-Cyber "  $($f.Key.PadRight(14))" $c.Yellow -NoNewline
        Write-Cyber "  $($f.Desc)" $c.Cyan
    }

    # Docker status
    Write-Host ""
    Write-Cyber $sep2 $c.Magenta
    Write-Host ""
    Write-Cyber "  Docker" $c.Green
    Write-Host ""

    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Cyber "  Docker not installed or not in PATH." $c.Dim
    } else {
        try {
            $containers = docker ps --format "{{.Names}}|{{.Image}}|{{.Status}}|{{.Ports}}" 2>$null
            if ($containers) {
                Write-Cyber "  $("NAME".PadRight(22)) $("IMAGE".PadRight(25)) $("STATUS".PadRight(20)) PORTS" $c.Cyan
                Write-Cyber "  $("-" * 76)" $c.Dark
                foreach ($line in $containers) {
                    $p = $line -split "\|"
                    Write-Cyber "  $($p[0].PadRight(22)) " $c.Yellow -NoNewline
                    Write-Cyber "$($p[1].PadRight(25)) " $c.Cyan -NoNewline
                    Write-Cyber "$($p[2].PadRight(20)) " $c.Green -NoNewline
                    Write-Cyber "$(if ($p[3]) { $p[3] } else { '-' })" $c.Dim
                }
            } else {
                Write-Cyber "  No active containers." $c.Dim
            }
        } catch {
            Write-Cyber "  Could not connect to Docker daemon." $c.Dim
        }
    }

    Write-Host ""
    Write-Cyber $sep $c.Magenta
    Write-Host ""
}

# ── Help ──────────────────────────────────────────────────────────
function Show-Help {
    $c   = $global:CY
    $bar = "=" * 65

    $tools = @(
        @{ Name = "posh-git";       Use = "(automatic)";   Desc = "Git status in prompt" }
        @{ Name = "Terminal-Icons"; Use = "ls / dir";       Desc = "Icons next to files and folders" }
        @{ Name = "fzf (PSFzf)";   Use = "Ctrl+F";         Desc = "Interactive fuzzy file finder" }
        @{ Name = "fzf history";   Use = "Ctrl+R";         Desc = "Search command history" }
        @{ Name = "PSReadLine";    Use = "Arrow right";    Desc = "Accept autocomplete suggestion" }
        @{ Name = "z (zoxide)";    Use = "z folder";       Desc = "Jump to frecent directories" }
        @{ Name = "Oh My Posh";    Use = "(automatic)";    Desc = "NETWATCH cyberpunk prompt" }
    )

    $keys = @(
        @{ Key = "Tab";             Desc = "Autocomplete commands and paths" }
        @{ Key = "Ctrl+F";          Desc = "Open fzf file finder" }
        @{ Key = "Ctrl+R";          Desc = "Search history with fzf" }
        @{ Key = "Ctrl+D";          Desc = "Delete char (Emacs mode)" }
        @{ Key = "Ctrl+A / Ctrl+E"; Desc = "Go to start / end of line" }
        @{ Key = "Alt+D";           Desc = "Delete word forward" }
        @{ Key = "Ctrl+W";          Desc = "Delete word backward" }
    )

    $cmds = @(
        @{ Cmd = "Show-Dashboard";  Desc = "Show system dashboard" }
        @{ Cmd = "which <cmd>";     Desc = "Find path of a command" }
        @{ Cmd = "vim / nvim";      Desc = "Open Neovim" }
        @{ Cmd = "g";               Desc = "git alias" }
        @{ Cmd = "ll";              Desc = "ls alias" }
        @{ Cmd = "help-ps";         Desc = "Show this help screen" }
    )

    Write-Host ""
    Write-Cyber $bar $c.Magenta
    Write-Cyber "  INSTALLED TOOLS" $c.Green
    Write-Cyber $bar $c.Magenta
    foreach ($t in $tools) {
        Write-Cyber "  $($t.Name.PadRight(18))" $c.Yellow -NoNewline
        Write-Cyber "$($t.Use.PadRight(18))" $c.Cyan -NoNewline
        Write-Cyber "$($t.Desc)" $c.Dim
    }
    Write-Host ""
    Write-Cyber $bar $c.Magenta
    Write-Cyber "  KEYBOARD SHORTCUTS" $c.Green
    Write-Cyber $bar $c.Magenta
    foreach ($k in $keys) {
        Write-Cyber "  $($k.Key.PadRight(22))" $c.Yellow -NoNewline
        Write-Cyber "$($k.Desc)" $c.Cyan
    }
    Write-Host ""
    Write-Cyber $bar $c.Magenta
    Write-Cyber "  COMMANDS" $c.Green
    Write-Cyber $bar $c.Magenta
    foreach ($cmd in $cmds) {
        Write-Cyber "  $($cmd.Cmd.PadRight(22))" $c.Yellow -NoNewline
        Write-Cyber "$($cmd.Desc)" $c.Cyan
    }
    Write-Host ""
}

Set-Alias help-ps Show-Help

# Show dashboard on startup
Show-Dashboard
