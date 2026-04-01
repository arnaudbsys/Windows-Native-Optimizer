# --- Vérification des privilèges Administrateur ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# --- Configuration de la Fenêtre ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Windows Native Optimizer & Cleaner (Pro)"
$form.Size = New-Object System.Drawing.Size(800, 850)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$form.ForeColor = [System.Drawing.Color]::White
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

$fontTitle = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$fontText = New-Object System.Drawing.Font("Segoe UI", 9)
$fontWarn = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Italic)

# Fonction pour créer des boutons
function Create-Btn($text, $y, $color, $action) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Location = New-Object System.Drawing.Point(30, $y)
    $btn.Size = New-Object System.Drawing.Size(280, 35)
    $btn.FlatStyle = "Flat"
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btn.FlatAppearance.BorderSize = 0
    $btn.BackColor = $color
    $btn.Add_Click($action)
    $form.Controls.Add($btn)
}

function Add-Desc($text, $y, $color = "White") {
    $l = New-Object System.Windows.Forms.Label
    $l.Text = $text
    $l.Location = New-Object System.Drawing.Point(330, $y)
    $l.Size = New-Object System.Drawing.Size(430, 45)
    $l.Font = $fontText
    $l.ForeColor = $color
    $form.Controls.Add($l)
}

# --- 1. VIE PRIVÉE & TÉLÉMÉTRIE ---
$lblT = New-Object System.Windows.Forms.Label
$lblT.Text = "1. Confidentialité & Localisation"
$lblT.Location = New-Object System.Drawing.Point(30, 20); $lblT.AutoSize = $true; $lblT.Font = $fontTitle; $form.Controls.Add($lblT)

Create-Btn "Désactiver Télémétrie & Loc" 60 "DarkSlateGray" {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny" -ErrorAction SilentlyContinue
    [System.Windows.Forms.MessageBox]::Show("Télémétrie et Localisation désactivées.")
}
Add-Desc "Coupe l'envoi de données et l'accès à votre position par les applications." 60

# --- 2. PERFORMANCE & APPARENCE ---
$lblP = New-Object System.Windows.Forms.Label
$lblP.Text = "2. Performance & Visuel"
$lblP.Location = New-Object System.Drawing.Point(30, 120); $lblP.AutoSize = $true; $lblP.Font = $fontTitle; $form.Controls.Add($lblP)

Create-Btn "Optimiser l'Apparence" 160 "DarkOliveGreen" {
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
    [System.Windows.Forms.MessageBox]::Show("Animations désactivées pour plus de réactivité.")
}
Add-Desc "Désactive les animations de fenêtres pour un bureau instantané." 165

Create-Btn "Désactiver Accélération Souris" 205 "DarkOliveGreen" {
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value 0
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value 0
    [System.Windows.Forms.MessageBox]::Show("Accélération désactivée (Entrée 1:1).")
}
Add-Desc "Désactive la 'Précision du pointeur' pour une visée constante." 210

# --- 3. MAINTENANCE & NETTOYAGE ---
$lblM = New-Object System.Windows.Forms.Label
$lblM.Text = "3. Nettoyage & Maintenance"
$lblM.Location = New-Object System.Drawing.Point(30, 280); $lblM.AutoSize = $true; $lblM.Font = $fontTitle; $form.Controls.Add($lblM)

Create-Btn "NETTOYAGE COMPLET" 320 "SteelBlue" {
    $tempPaths = @("$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*")
    foreach ($path in $tempPaths) { Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue }
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Clear-DnsClientCache
    [System.Windows.Forms.MessageBox]::Show("Fichiers temporaires, Prefetch, DNS et Corbeille nettoyés.")
}
Add-Desc "Supprime les fichiers inutiles et vide le cache DNS pour fluidifier le réseau." 325

Create-Btn "Réparations (SFC / DISM)" 365 "Firebrick" {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "Write-Host 'Analyse Système...'; dism /online /cleanup-image /restorehealth; sfc /scannow" -Verb RunAs
}
Add-Desc "Lance les outils natifs de réparation des fichiers système corrompus." 370

Create-Btn "Mise à jour Apps (Winget)" 410 "DodgerBlue" {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "winget upgrade --all --silent --accept-package-agreements --accept-source-agreements" -Verb RunAs
}
Add-Desc "Met à jour tous vos logiciels (Steam, Chrome, VLC...) automatiquement." 415

# --- 4. SÉCURITÉ & CHIFFREMENT ---
$lblS = New-Object System.Windows.Forms.Label
$lblS.Text = "4. Paramètres Avancés"
$lblS.Location = New-Object System.Drawing.Point(30, 500); $lblS.AutoSize = $true; $lblS.Font = $fontTitle; $form.Controls.Add($lblS)

Create-Btn "Désactiver BitLocker" 540 "DarkRed" {
    $confirm = [System.Windows.Forms.MessageBox]::Show("Voulez-vous vraiment désactiver BitLocker ? Le déchiffrement peut être long.", "Attention", "YesNo", "Warning")
    if ($confirm -eq "Yes") { 
        Disable-BitLocker -MountPoint "C:" 
        [System.Windows.Forms.MessageBox]::Show("Déchiffrement lancé.")
    }
}
Add-Desc "Réduit la charge CPU et évite les blocages de clé de récupération. Moins sécurisé." 540 "Orange"

# --- 5. RACCOURCIS SYSTÈME ---
$lblR = New-Object System.Windows.Forms.Label
$lblR.Text = "5. Raccourcis Utiles"
$lblR.Location = New-Object System.Drawing.Point(30, 650); $lblR.AutoSize = $true; $lblR.Font = $fontTitle; $form.Controls.Add($lblR)

Create-Btn "Applis au Démarrage" 690 "DimGray" { start "ms-settings:startupapps" }
Create-Btn "Optimiser Disques" 735 "DimGray" { start "dfrgui.exe" }

$form.ShowDialog()