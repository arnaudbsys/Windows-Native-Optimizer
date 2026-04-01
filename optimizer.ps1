# --- Force l'encodage en UTF8 pour les accents ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- Auto-élévation Administrateur ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# --- Fenêtre Principale ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Windows Native Optimizer & Cleaner v1.1"
$form.Size = New-Object System.Drawing.Size(850, 950)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.ForeColor = [System.Drawing.Color]::White
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# Polices
$fontTitle = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$fontText = New-Object System.Drawing.Font("Segoe UI", 9)
$fontConsole = New-Object System.Drawing.Font("Consolas", 8)

# --- Zone de Log (Console interne) ---
$txtLogs = New-Object System.Windows.Forms.TextBox
$txtLogs.Multiline = $true
$txtLogs.Location = New-Object System.Drawing.Point(30, 780)
$txtLogs.Size = New-Object System.Drawing.Size(770, 100)
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

# --- Barre de Progression ---
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(30, 890)
$progressBar.Size = New-Object System.Drawing.Size(770, 15)
$progressBar.Style = "Continuous"
$form.Controls.Add($progressBar)

# --- Fonctions Utiles ---
function Create-Btn($text, $y, $color, $action) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Location = New-Object System.Drawing.Point(30, $y)
    $btn.Size = New-Object System.Drawing.Size(280, 35)
    $btn.FlatStyle = "Flat"
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btn.FlatAppearance.BorderSize = 0
    $btn.BackColor = $color
    $btn.Add_Click({
        $progressBar.Value = 20
        Write-Log "Lancement : $text..."
        &$action
        $progressBar.Value = 100
        Write-Log "Terminé : $text."
        Start-Sleep -Milliseconds 500
        $progressBar.Value = 0
    })
    $form.Controls.Add($btn)
}

function Add-Desc($text, $y, $color = "White") {
    $l = New-Object System.Windows.Forms.Label
    $l.Text = $text
    $l.Location = New-Object System.Drawing.Point(330, $y)
    $l.Size = New-Object System.Drawing.Size(480, 45)
    $l.Font = $fontText
    $l.ForeColor = $color
    $form.Controls.Add($l)
}

# --- SECTION 1 : PRIVACY ---
$lbl1 = New-Object System.Windows.Forms.Label
$lbl1.Text = "1. CONFIDENTIALITÉ"
$lbl1.Location = New-Object System.Drawing.Point(30, 20); $lbl1.AutoSize = $true; $lbl1.Font = $fontTitle; $form.Controls.Add($lbl1)

Create-Btn "Optimiser la Vie Privée" 60 "DarkSlateGray" {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny" -ErrorAction SilentlyContinue
    Write-Log "Télémétrie et Localisation désactivées avec succès."
}
Add-Desc "Désactive la télémétrie Windows et l'accès à la position géographique." 60

# --- SECTION 2 : PERFORMANCE ---
$lbl2 = New-Object System.Windows.Forms.Label
$lbl2.Text = "2. PERFORMANCE"
$lbl2.Location = New-Object System.Drawing.Point(30, 130); $lbl2.AutoSize = $true; $lbl2.Font = $fontTitle; $form.Controls.Add($lbl2)

Create-Btn "Mode Bureau Instantané" 170 "DarkOliveGreen" {
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
    Write-Log "Animations système désactivées."
}
Add-Desc "Retire les animations inutiles pour une interface plus nerveuse." 170

Create-Btn "Désactiver l'accélération souris" 215 "DarkOliveGreen" {
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0
    Write-Log "Précision du pointeur désactivée (1:1)."
}
Add-Desc "Désactive la 'Précision du pointeur' pour une meilleure visée en jeu." 215

# --- SECTION 3 : NETTOYAGE ---
$lbl3 = New-Object System.Windows.Forms.Label
$lbl3.Text = "3. NETTOYAGE & MAINTENANCE"
$lbl3.Location = New-Object System.Drawing.Point(30, 290); $lbl3.AutoSize = $true; $lbl3.Font = $fontTitle; $form.Controls.Add($lbl3)

Create-Btn "Nettoyage Profond" 330 "SteelBlue" {
    $paths = @("$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*")
    foreach ($p in $paths) { 
        Write-Log "Nettoyage de $p..."
        Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue 
    }
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Log "Fichiers temporaires et corbeille vidés."
}
Add-Desc "Supprime les fichiers temporaires, le prefetch et vide la corbeille." 335

Create-Btn "Mise à jour Winget" 375 "DodgerBlue" {
    Write-Log "Recherche de mises à jour via Winget..."
    Start-Process powershell -ArgumentList "-Command", "winget upgrade --all --silent --accept-package-agreements" -NoNewWindow -Wait
    Write-Log "Mises à jour terminées."
}
Add-Desc "Met à jour toutes vos applications installées automatiquement." 380

# --- SECTION 4 : AVANCÉ ---
$lbl4 = New-Object System.Windows.Forms.Label
$lbl4.Text = "4. OUTILS AVANCÉS"
$lbl4.Location = New-Object System.Drawing.Point(30, 500); $lbl4.AutoSize = $true; $lbl4.Font = $fontTitle; $form.Controls.Add($lbl4)

Create-Btn "Réparer Windows (SFC)" 540 "Firebrick" {
    Write-Log "Lancement de SFC Scannow (cela peut être long)..."
    sfc /scannow
    Write-Log "Analyse terminée."
}
Add-Desc "Vérifie et répare les fichiers système Windows corrompus." 545

Create-Btn "Désactiver BitLocker" 585 "DarkRed" {
    $res = [System.Windows.Forms.MessageBox]::Show("Voulez-vous désactiver BitLocker ?", "Sécurité", "YesNo", "Warning")
    if ($res -eq "Yes") { 
        Disable-BitLocker -MountPoint "C:" 
        Write-Log "Déchiffrement BitLocker lancé sur C:."
    }
}
Add-Desc "ATTENTION : Désactive le chiffrement de vos fichiers." 590 "Orange"

# --- SECTION 5 : RACCOURCIS ---
$lbl5 = New-Object System.Windows.Forms.Label
$lbl5.Text = "5. RACCOURCIS RAPIDES"
$lbl5.Location = New-Object System.Drawing.Point(30, 680); $lbl5.AutoSize = $true; $lbl5.Font = $fontTitle; $form.Controls.Add($lbl5)

Create-Btn "Gestionnaire de démarrage" 720 "DimGray" { start "ms-settings:startupapps" }
Create-Btn "Optimiser les lecteurs" 760 "DimGray" { start "dfrgui.exe" }

# Message d'accueil dans les logs
Write-Log "Application prête. Prêt pour l'optimisation."
Write-Log "Système : $([Environment]::OSVersion)"

$form.ShowDialog()
