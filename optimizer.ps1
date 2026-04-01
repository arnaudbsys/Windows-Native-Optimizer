# --- Version 1.4 - UTF-8 BOM & Full DISM Tools ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# --- Fenêtre ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Windows Native Optimizer & Cleaner v1.4"
$form.Size = New-Object System.Drawing.Size(900, 1000) 
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$form.ForeColor = [System.Drawing.Color]::White
$form.FormBorderStyle = "FixedSingle"

$fontTitle = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$fontText = New-Object System.Drawing.Font("Segoe UI", 9)
$fontConsole = New-Object System.Drawing.Font("Consolas", 8)

# --- Zone de Logs ---
$txtLogs = New-Object System.Windows.Forms.TextBox
$txtLogs.Multiline = $true
$txtLogs.Location = New-Object System.Drawing.Point(30, 810) 
$txtLogs.Size = New-Object System.Drawing.Size(820, 110)
$txtLogs.BackColor = [System.Drawing.Color]::Black
$txtLogs.ForeColor = [System.Drawing.Color]::LimeGreen
$txtLogs.ReadOnly = $true
$txtLogs.ScrollBars = "Vertical"
$txtLogs.Font = $fontConsole
$form.Controls.Add($txtLogs)

function Write-Log($msg) {
    $timestamp = Get-Date -Format "HH:mm:ss"
    $txtLogs.AppendText("[$timestamp] $msg`r`n")
    $txtLogs.SelectionStart = $txtLogs.Text.Length
    $txtLogs.ScrollToCaret()
}

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(30, 930)
$progressBar.Size = New-Object System.Drawing.Size(820, 10)
$form.Controls.Add($progressBar)

# --- Fonctions Boutons ---
function Create-Btn($text, $x, $y, $w, $h, $color, $action) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Location = New-Object System.Drawing.Point($x, $y)
    $btn.Size = New-Object System.Drawing.Size($w, $h)
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderSize = 0
    $btn.BackColor = $color
    $btn.Add_Click({
        $progressBar.Value = 30
        Write-Log "Lancement : $text..."
        &$action
        $progressBar.Value = 100
        Write-Log "Terminé : $text."
        Start-Sleep -Milliseconds 300
        $progressBar.Value = 0
    })
    $form.Controls.Add($btn)
}

function Add-Label($text, $x, $y, $font, $color = "White") {
    $l = New-Object System.Windows.Forms.Label
    $l.Text = $text
    $l.Location = New-Object System.Drawing.Point($x, $y)
    $l.AutoSize = $true
    $l.Font = $font
    $l.ForeColor = $color
    $form.Controls.Add($l)
}

# --- CONTENU ---

# 1. PRIVACY
Add-Label "1. CONFIDENTIALITÉ & PERFORMANCE" 30 20 $fontTitle
Create-Btn "Optimiser Système" 30 60 250 35 "DarkSlateGray" {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0
    Write-Log "Télémétrie et animations optimisées."
}
Add-Label "Désactive la télémétrie et les animations de fenêtres." 300 68 $fontText

# 2. NETTOYAGE
Add-Label "2. MAINTENANCE & NETTOYAGE" 30 130 $fontTitle
Create-Btn "Nettoyage Fichiers Temp" 30 170 250 35 "SteelBlue" {
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Log "Dossiers temporaires et corbeille nettoyés."
}
Add-Label "Supprime les fichiers temporaires et vide la corbeille." 300 178 $fontText

Create-Btn "Nettoyage Composants (WinSxS)" 30 215 250 35 "SteelBlue" {
    Write-Log "Nettoyage du magasin des composants (DISM StartComponentCleanup)..."
    dism /online /cleanup-image /startcomponentcleanup /resetbase
}
Add-Label "Réduit la taille du dossier Windows en supprimant les vieilles MAJ." 300 223 $fontText

# 3. RÉPARATIONS DISM / SFC
Add-Label "3. RÉPARATIONS SYSTÈME (DISM / SFC)" 30 290 $fontTitle

Create-Btn "DISM CheckHealth" 30 330 250 35 "Firebrick" {
    dism /online /cleanup-image /checkhealth
    Write-Log "Vérification de l'état de santé effectuée."
}
Add-Label "Vérifie si une corruption est détectée dans l'image système." 300 338 $fontText

Create-Btn "DISM ScanHealth" 30 375 250 35 "Firebrick" {
    Write-Log "Scan approfondi lancé (ScanHealth). Veuillez patienter..."
    dism /online /cleanup-image /scanhealth
}
Add-Label "Analyse complète pour détecter les corruptions masquées." 300 383 $fontText

Create-Btn "DISM RestoreHealth" 30 420 250 35 "Firebrick" {
    Write-Log "Réparation de l'image (RestoreHealth)... Connexion Internet requise."
    dism /online /cleanup-image /restorehealth
}
Add-Label "Répare l'image système via Windows Update." 300 428 $fontText "Orange"

Create-Btn "SFC Scannow" 30 465 250 35 "Brown" {
    Write-Log "Analyse SFC lancée..."
    sfc /scannow
}
Add-Label "Répare les fichiers système corrompus sur le disque local." 300 473 $fontText

# 4. OPTIONS AVANCÉES
Add-Label "4. OPTIONS AVANCÉES" 30 550 $fontTitle
Create-Btn "Mise à jour Winget" 30 590 250 35 "DodgerBlue" {
    Write-Log "Mise à jour des applications en cours..."
    winget upgrade --all --silent --accept-package-agreements
}
Add-Label "Met à jour nativement tous vos logiciels installés." 300 598 $fontText

Create-Btn "Désactiver BitLocker" 30 635 250 35 "DarkRed" {
    $confirm = [System.Windows.Forms.MessageBox]::Show("Voulez-vous désactiver BitLocker ?", "Confirmation", "YesNo")
    if($confirm -eq "Yes") { Disable-BitLocker -MountPoint "C:" }
}
Add-Label "ATTENTION : Supprime la protection par chiffrement du disque." 300 643 $fontText "Orange"

# 5. RACCOURCIS
Add-Label "5. RACCOURCIS UTILES" 30 710 $fontTitle
Create-Btn "Démarrage" 30 750 135 35 "DimGray" { start "ms-settings:startupapps" }
Create-Btn "Optimiser Lecteurs" 175 750 135 35 "DimGray" { start "dfrgui.exe" }

Write-Log "Prêt. Enregistré en UTF-8 BOM pour supporter les accents."
$form.ShowDialog()
