# --- Windows Native Optimizer v7.0 - Interface propre & actions réversibles ---
# Forcer l'encodage UTF-8 pour la console
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Auto-élévation admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms, System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = "Windows Native Optimizer v7.0 - Réversible & personnalisable"
$form.Size = New-Object System.Drawing.Size(1100, 900)
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.ForeColor = [System.Drawing.Color]::White
$form.FormBorderStyle = "FixedSingle"
$form.StartPosition = "CenterScreen"
$form.MinimumSize = $form.Size

$fTitle = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$fGroup = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fText = New-Object System.Drawing.Font("Segoe UI", 9)

# Panel principal avec scroll
$mainPanel = New-Object System.Windows.Forms.Panel
$mainPanel.Location = New-Object System.Drawing.Point(10, 10)
$mainPanel.Size = New-Object System.Drawing.Size(1060, 760)
$mainPanel.AutoScroll = $true
$form.Controls.Add($mainPanel)

$flow = New-Object System.Windows.Forms.FlowLayoutPanel
$flow.Location = New-Object System.Drawing.Point(0, 0)
$flow.Size = New-Object System.Drawing.Size(1040, 2000)
$flow.FlowDirection = "TopDown"
$flow.AutoSize = $true
$flow.AutoSizeMode = "GrowAndShrink"
$mainPanel.Controls.Add($flow)

# ---------- Zone de logs (en bas) ----------
$txtLogs = New-Object System.Windows.Forms.TextBox
$txtLogs.Multiline = $true
$txtLogs.Location = New-Object System.Drawing.Point(10, 780)
$txtLogs.Size = New-Object System.Drawing.Size(1060, 80)
$txtLogs.BackColor = [System.Drawing.Color]::Black
$txtLogs.ForeColor = [System.Drawing.Color]::LimeGreen
$txtLogs.ReadOnly = $true
$txtLogs.ScrollBars = "Vertical"
$txtLogs.Font = New-Object System.Drawing.Font("Consolas", 9)
$form.Controls.Add($txtLogs)

function Write-Log($message, $color = "LimeGreen") {
    $time = Get-Date -Format "HH:mm:ss"
    $txtLogs.AppendText("[$time] $message`r`n")
    $txtLogs.SelectionStart = $txtLogs.Text.Length
    $txtLogs.ScrollToCaret()
}

# ---------- Fonctions d'action et restauration ----------
function Set-Telemetry { Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -ErrorAction SilentlyContinue; Write-Log "Télémétrie désactivée (valeur 0)." }
function Reset-Telemetry { Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -ErrorAction SilentlyContinue; Write-Log "Télémétrie restaurée (valeur par défaut)." }

function Set-Animations { Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0 -ErrorAction SilentlyContinue; Write-Log "Animations désactivées." }
function Reset-Animations { Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 1 -ErrorAction SilentlyContinue; Write-Log "Animations restaurées." }

function Set-MouseAccel { Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0 -ErrorAction SilentlyContinue; Write-Log "Accélération souris désactivée." }
function Reset-MouseAccel { Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 1 -ErrorAction SilentlyContinue; Write-Log "Accélération souris restaurée." }

function Set-PowerHigh { powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null; Write-Log "Plan haute performance activé." }
function Reset-PowerBalanced { powercfg -setactive a1841308-3541-4fab-bc81-f71556f20b4a 2>$null; Write-Log "Plan équilibré restauré." }

function Set-NagleOff {
    $interfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    foreach ($if in $interfaces) {
        Set-ItemProperty -Path $if.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $if.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    }
    Write-Log "Algorithme de Nagle désactivé (latence réseau réduite)."
}
function Reset-Nagle {
    $interfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    foreach ($if in $interfaces) {
        Remove-ItemProperty -Path $if.PSPath -Name "TcpAckFrequency" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $if.PSPath -Name "TCPNoDelay" -ErrorAction SilentlyContinue
    }
    Write-Log "Paramètres Nagle restaurés."
}

function Set-GameBarOff {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -ErrorAction SilentlyContinue
    Write-Log "Game Bar / Game DVR désactivés."
}
function Reset-GameBar {
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -ErrorAction SilentlyContinue
    Write-Log "Game Bar restaurée (paramètres par défaut)."
}

function Set-VisualFX { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -ErrorAction SilentlyContinue; Write-Log "Effets visuels désactivés (performance)." }
function Reset-VisualFX { Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 1 -ErrorAction SilentlyContinue; Write-Log "Effets visuels restaurés." }

# ---------- Fonction pour créer un groupe d'options ----------
function Add-OptionGroup {
    param(
        [string]$Title,
        [array]$Options  # chaque option = [hashtable]@{Name, Description, ActionSet, ActionReset, DefaultChecked=$false}
    )
    $group = New-Object System.Windows.Forms.GroupBox
    $group.Text = $Title
    $group.Font = $fGroup
    $group.AutoSize = $true
    $group.AutoSizeMode = "GrowAndShrink"
    $group.Padding = New-Object System.Windows.Forms.Padding(10)
    $group.FlatStyle = "Flat"
    $group.ForeColor = [System.Drawing.Color]::White
    $flow.Controls.Add($group)

    $innerTable = New-Object System.Windows.Forms.TableLayoutPanel
    $innerTable.AutoSize = $true
    $innerTable.AutoSizeMode = "GrowAndShrink"
    $innerTable.ColumnCount = 4
    $innerTable.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 30)))   # CheckBox
    $innerTable.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 40)))  # Label
    $innerTable.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 100))) # Bouton Activer
    $innerTable.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 100))) # Bouton Restaurer
    $innerTable.Padding = New-Object System.Windows.Forms.Padding(5)
    $group.Controls.Add($innerTable)

    $row = 0
    foreach ($opt in $Options) {
        $chk = New-Object System.Windows.Forms.CheckBox
        $chk.AutoSize = $true
        $chk.Checked = $opt.DefaultChecked
        $chk.Tag = $opt.Name
        $innerTable.Controls.Add($chk, 0, $row)

        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Text = "$($opt.Name) : $($opt.Description)"
        $lbl.AutoSize = $true
        $lbl.Font = $fText
        $lbl.ForeColor = [System.Drawing.Color]::LightGray
        $innerTable.Controls.Add($lbl, 1, $row)

        $btnSet = New-Object System.Windows.Forms.Button
        $btnSet.Text = "Activer"
        $btnSet.Size = New-Object System.Drawing.Size(90, 28)
        $btnSet.FlatStyle = "Flat"
        $btnSet.BackColor = [System.Drawing.Color]::DarkGreen
        $btnSet.Add_Click($opt.ActionSet)
        $innerTable.Controls.Add($btnSet, 2, $row)

        $btnReset = New-Object System.Windows.Forms.Button
        $btnReset.Text = "Restaurer"
        $btnReset.Size = New-Object System.Drawing.Size(90, 28)
        $btnReset.FlatStyle = "Flat"
        $btnReset.BackColor = [System.Drawing.Color]::DarkRed
        $btnReset.Add_Click($opt.ActionReset)
        $innerTable.Controls.Add($btnReset, 3, $row)

        $row++
    }
}

# ---------- Construction de l'interface avec les groupes ----------
Add-OptionGroup -Title "1. CONFIDENTIALITÉ & PERFORMANCE" -Options @(
    @{Name="Télémétrie"; Description="Désactiver l'envoi de données à Microsoft"; ActionSet={Set-Telemetry}; ActionReset={Reset-Telemetry}; DefaultChecked=$true},
    @{Name="Animations fenêtres"; Description="Désactiver les animations (MinAnimate)"; ActionSet={Set-Animations}; ActionReset={Reset-Animations}; DefaultChecked=$true},
    @{Name="Accélération souris"; Description="Désactiver l'accélération pour plus de précision"; ActionSet={Set-MouseAccel}; ActionReset={Reset-MouseAccel}; DefaultChecked=$false}
)

Add-OptionGroup -Title "2. OPTIMISATIONS GAMING & LATENCE" -Options @(
    @{Name="Plan haute performance"; Description="Forcer le processeur à plein régime"; ActionSet={Set-PowerHigh}; ActionReset={Reset-PowerBalanced}; DefaultChecked=$true},
    @{Name="Désactiver Nagle (TCP)"; Description="Réduit la latence réseau (jeux en ligne)"; ActionSet={Set-NagleOff}; ActionReset={Reset-Nagle}; DefaultChecked=$true},
    @{Name="Désactiver Game Bar / DVR"; Description="Supprime une source de ralentissements"; ActionSet={Set-GameBarOff}; ActionReset={Reset-GameBar}; DefaultChecked=$true},
    @{Name="Désactiver effets visuels"; Description="Améliore la fluidité générale"; ActionSet={Set-VisualFX}; ActionReset={Reset-VisualFX}; DefaultChecked=$true}
)

# Groupe spécial pour les outils système (pas de case à cocher, juste des boutons)
$groupSys = New-Object System.Windows.Forms.GroupBox
$groupSys.Text = "3. OUTILS SYSTÈME (DISM, SFC, NETTOYAGE)"
$groupSys.AutoSize = $true
$groupSys.Font = $fGroup
$groupSys.ForeColor = [System.Drawing.Color]::White
$flow.Controls.Add($groupSys)

$sysPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$sysPanel.AutoSize = $true
$sysPanel.FlowDirection = "LeftToRight"
$sysPanel.WrapContents = $true
$groupSys.Controls.Add($sysPanel)

function Add-SysButton($text, $color, $action) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Size = New-Object System.Drawing.Size(180, 35)
    $btn.FlatStyle = "Flat"
    $btn.BackColor = $color
    $btn.ForeColor = "White"
    $btn.Add_Click($action)
    $sysPanel.Controls.Add($btn)
}

Add-SysButton "Nettoyer fichiers temporaires" ([System.Drawing.Color]::SteelBlue) {
    Write-Log "Nettoyage des fichiers temporaires..."
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Log "Nettoyage terminé."
}
Add-SysButton "Nettoyer WinSxS (DISM)" ([System.Drawing.Color]::SteelBlue) {
    Write-Log "Nettoyage WinSxS via DISM..."
    Start-Process -FilePath "dism.exe" -ArgumentList "/online /cleanup-image /startcomponentcleanup /resetbase" -Wait -NoNewWindow
    Write-Log "Nettoyage WinSxS terminé."
}
Add-SysButton "DISM /CheckHealth" ([System.Drawing.Color]::Firebrick) {
    Write-Log "DISM CheckHealth..."
    Start-Process -FilePath "dism.exe" -ArgumentList "/online /cleanup-image /checkhealth" -Wait -NoNewWindow
}
Add-SysButton "DISM /ScanHealth" ([System.Drawing.Color]::Firebrick) {
    Write-Log "DISM ScanHealth (peut être long)..."
    Start-Process -FilePath "dism.exe" -ArgumentList "/online /cleanup-image /scanhealth" -Wait -NoNewWindow
}
Add-SysButton "DISM /RestoreHealth" ([System.Drawing.Color]::DarkRed) {
    Write-Log "DISM RestoreHealth (réparation)..."
    Start-Process -FilePath "dism.exe" -ArgumentList "/online /cleanup-image /restorehealth" -Wait -NoNewWindow
}
Add-SysButton "SFC /SCANNOW" ([System.Drawing.Color]::Brown) {
    Write-Log "Lancement de SFC /SCANNOW..."
    $output = & sfc /scannow | Out-String
    if ($output -match "Aucune violation d'intégrité") { Write-Log "✅ SFC : Aucune violation." -color "LimeGreen" }
    elseif ($output -match "fichiers endommagés ont été réparés") { Write-Log "⚠️ SFC : Réparations effectuées." -color "Yellow" }
    else { Write-Log "SFC terminé. Voir le détail ci-dessus." }
}
Add-SysButton "Màj logiciels (Winget)" ([System.Drawing.Color]::DodgerBlue) {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Start-Process -FilePath "winget" -ArgumentList "upgrade --all --silent --accept-package-agreements" -Wait -NoNewWindow
        Write-Log "Mises à jour Winget appliquées."
    } else { Write-Log "Winget non disponible." -color "Red" }
}
Add-SysButton "Désactiver BitLocker (C:)" ([System.Drawing.Color]::DarkRed) {
    if (Get-Command Disable-BitLocker -ErrorAction SilentlyContinue) {
        $confirm = [System.Windows.Forms.MessageBox]::Show("Déchiffrer C: ? Opération longue.", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($confirm -eq "Yes") { Disable-BitLocker -MountPoint "C:" -ErrorAction SilentlyContinue; Write-Log "Déchiffrement lancé." }
    } else { Write-Log "BitLocker non disponible." -color "Red" }
}

# Bouton pour appliquer toutes les options cochées en masse
$applyAllBtn = New-Object System.Windows.Forms.Button
$applyAllBtn.Text = "▶ APPLIQUER LES OPTIONS COCHÉES CI-DESSUS"
$applyAllBtn.Size = New-Object System.Drawing.Size(400, 40)
$applyAllBtn.BackColor = [System.Drawing.Color]::DarkGoldenrod
$applyAllBtn.FlatStyle = "Flat"
$applyAllBtn.Font = $fGroup
$applyAllBtn.Add_Click({
    Write-Log "Application des optimisations sélectionnées..." -color "Cyan"
    # Parcourir tous les groupes et checkboxes
    foreach ($group in $flow.Controls | Where-Object { $_ -is [System.Windows.Forms.GroupBox] }) {
        $table = $group.Controls[0]  # le TableLayoutPanel
        if ($table -is [System.Windows.Forms.TableLayoutPanel]) {
            for ($row = 0; $row -lt $table.RowCount; $row++) {
                $chk = $table.GetControlFromPosition(0, $row)
                if ($chk -is [System.Windows.Forms.CheckBox] -and $chk.Checked) {
                    $btnActiver = $table.GetControlFromPosition(2, $row)
                    if ($btnActiver -is [System.Windows.Forms.Button]) {
                        $btnActiver.PerformClick()
                    }
                }
            }
        }
    }
    Write-Log "Optimisations sélectionnées appliquées." -color "LimeGreen"
})
$flow.Controls.Add($applyAllBtn)

# Bouton fermer
$closeBtn = New-Object System.Windows.Forms.Button
$closeBtn.Text = "Fermer l'utilitaire"
$closeBtn.Size = New-Object System.Drawing.Size(150, 35)
$closeBtn.BackColor = [System.Drawing.Color]::FromArgb(64,64,64)
$closeBtn.FlatStyle = "Flat"
$closeBtn.Add_Click({ $form.Close() })
$flow.Controls.Add($closeBtn)

Write-Log "Windows Native Optimizer v7.0 chargé. Cochez les options souhaitées, puis 'Appliquer' ou utilisez les boutons individuels."
Write-Log "Chaque tweak est réversible via son bouton 'Restaurer'."

$form.ShowDialog()
