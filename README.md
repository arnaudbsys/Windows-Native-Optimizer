# Optimisation-win11

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Configuration de la Fenêtre ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Windows Native Optimizer (Suivi de Progression)"
$form.Size = New-Object System.Drawing.Size(700, 750)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$form.ForeColor = [System.Drawing.Color]::White

$fontTitle = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$fontText = New-Object System.Drawing.Font("Segoe UI", 8)

# Fonction pour créer des boutons stylisés
function Create-Btn($text, $y, $color, $action) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Location = New-Object System.Drawing.Point(30, $y)
    $btn.Size = New-Object System.Drawing.Size(280, 40)
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderSize = 0
    $btn.BackColor = $color
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btn.Add_Click($action)
    $form.Controls.Add($btn)
}

# --- 1. VIE PRIVÉE & TÉLÉMÉTRIE ---
$lblT = New-Object System.Windows.Forms.Label
$lblT.Text = "1. Confidentialité & Télémétrie (Désactivation Native)"
$lblT.Location = New-Object System.Drawing.Point(30, 20)
$lblT.AutoSize = $true; $lblT.Font = $fontTitle; $form.Controls.Add($lblT)

Create-Btn "Désactiver Télémétrie & Pubs" 60 "DarkSlateGray" {
    # Bloque l'envoi de données de diagnostic (Télémétrie)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0
    # Désactive les expériences personnalisées (Pubs basées sur votre usage)
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0
    # Désactive l'ID de publicité pour les apps
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0
    # Désactive le suivi de lancement d'applications
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Value 0
    [System.Windows.Forms.MessageBox]::Show("Télémétrie et Publicités natives désactivées.")
}

# --- 2. OPTIMISATION GAMING ---
$lblG = New-Object System.Windows.Forms.Label
$lblG.Text = "2. Gaming & Performance"
$lblG.Location = New-Object System.Drawing.Point(30, 140)
$lblG.AutoSize = $true; $lblG.Font = $fontTitle; $form.Controls.Add($lblG)

Create-Btn "GameBar / DVR / Mode Jeu" 180 "DarkSlateBlue" {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1
    [System.Windows.Forms.MessageBox]::Show("Optimisations Gaming Appliquées.")
}

# --- 3. MAINTENANCE (Avec suivi de progression) ---
$lblM = New-Object System.Windows.Forms.Label
$lblM.Text = "3. Maintenance Système (Suivi en Temps Réel)"
$lblM.Location = New-Object System.Drawing.Point(30, 260)
$lblM.AutoSize = $true; $lblM.Font = $fontTitle; $form.Controls.Add($lblM)

# DISM avec fenêtre de progression
Create-Btn "Lancer DISM (Réparation Image)" 300 "Firebrick" {
    # On lance dans un nouveau processus pour voir la barre de progression native [########## 100%]
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "Write-Host 'Analyse DISM en cours...'; dism /online /cleanup-image /restorehealth" -Verb RunAs
}

# SFC avec fenêtre de progression
Create-Btn "Lancer SFC (Vérification Fichiers)" 350 "Firebrick" {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "Write-Host 'Analyse SFC en cours...'; sfc /scannow" -Verb RunAs
}

# Winget avec fenêtre de progression
Create-Btn "Lancer WINGET (Mise à jour Apps)" 400 "DodgerBlue" {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "Write-Host 'Recherche de mises à jour...'; winget upgrade --all --silent; Write-Host 'Terminé !'" -Verb RunAs
}

# --- 4. RACCOURCIS NATIFS ---
$lblR = New-Object System.Windows.Forms.Label
$lblR.Text = "4. Outils Windows Intégrés"
$lblR.Location = New-Object System.Drawing.Point(30, 500)
$lblR.AutoSize = $true; $lblR.Font = $fontTitle; $form.Controls.Add($lblR)

Create-Btn "Gérer le Démarrage" 540 "DimGray" { start "ms-settings:startupapps" }
Create-Btn "Optimiser Disques / SSD" 590 "DimGray" { start "dfrgui.exe" }

# --- DESCRIPTIONS ---
function Add-Desc($text, $y) {
    $l = New-Object System.Windows.Forms.Label
    $l.Text = $text
    $l.Location = New-Object System.Drawing.Point(330, $y)
    $l.Size = New-Object System.Drawing.Size(340, 50)
    $l.Font = $fontText
    $form.Controls.Add($l)
}

Add-Desc "Désactive l'envoi de rapports à Microsoft et les publicités ciblées dans Windows." 65
Add-Desc "Désactive la capture vidéo en fond (DVR) et force la priorité aux jeux (Mode Jeu)." 185
Add-Desc "Répare la base de données de Windows via Windows Update. Une barre de % s'affichera." 305
Add-Desc "Vérifie chaque fichier système. Répare si nécessaire. Suivi du % en direct." 355
Add-Desc "Met à jour proprement tous vos logiciels installés. Suivi visible en console." 405
Add-Desc "Ouvre l'interface pour empêcher les apps de se lancer toutes seules." 545
Add-Desc "Force le TRIM sur SSD ou défragmente les HDD pour un accès disque plus rapide." 595

$form.ShowDialog()
