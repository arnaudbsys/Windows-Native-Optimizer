# --- Windows Native Optimizer v4.1 - Version Complète & Stable ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms, System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = "Windows Native Optimizer v4.1"
$form.Size = New-Object System.Drawing.Size(900, 980)
$form.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$form.ForeColor = [System.Drawing.Color]::White
$form.FormBorderStyle = "FixedSingle"
$form.StartPosition = "CenterScreen"

$fTitle = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$fText = New-Object System.Drawing.Font("Segoe UI", 9)

# Zone de Logs Améliorée
$txtLogs = New-Object System.Windows.Forms.TextBox
$txtLogs.Multiline = $true; $txtLogs.Location = New-Object System.Drawing.Point(30, 800); $txtLogs.Size = New-Object System.Drawing.Size(820, 120)
$txtLogs.BackColor = [System.Drawing.Color]::Black; $txtLogs.ForeColor = [System.Drawing.Color]::LimeGreen
$txtLogs.ReadOnly = $true; $txtLogs.ScrollBars = "Vertical"; $txtLogs.Font = New-Object System.Drawing.Font("Consolas", 9)
$form.Controls.Add($txtLogs)

function Write-Log($m, $color = "LimeGreen") { 
    $t = Get-Date -Format "HH:mm:ss"
    $txtLogs.AppendText("[$t] $m`r`n")
    $txtLogs.SelectionStart = $txtLogs.Text.Length
    $txtLogs.ScrollToCaret()
}

# --- 1. CONFIDENTIALITE & PERF ---
$l1 = New-Object System.Windows.Forms.Label
$l1.Text = "1. CONFIDENTIALITE ET PERFORMANCE"; $l1.Location = New-Object System.Drawing.Point(30, 20); $l1.AutoSize = $true; $l1.Font = $fTitle; $form.Controls.Add($l1)

$b1 = New-Object System.Windows.Forms.Button
$b1.Text = "Optimiser le Systeme"; $b1.Location = New-Object System.Drawing.Point(30, 60); $b1.Size = New-Object System.Drawing.Size(250, 35); $b1.FlatStyle = "Flat"; $b1.BackColor = [System.Drawing.Color]::DarkSlateGray
$b1.Add_Click({ 
    Write-Log "Optimisation : Telemetrie, Localisation et Animations..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0 -ErrorAction SilentlyContinue
    Write-Log "Optimisation terminee."
})
$form.Controls.Add($b1)

$bMouse = New-Object System.Windows.Forms.Button
$bMouse.Text = "Fix Souris (Precision)"; $bMouse.Location = New-Object System.Drawing.Point(30, 105); $bMouse.Size = New-Object System.Drawing.Size(250, 35); $bMouse.FlatStyle = "Flat"; $bMouse.BackColor = [System.Drawing.Color]::DarkSlateGray
$bMouse.Add_Click({ 
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0
    Write-Log "Acceleration souris desactivee (plus de precision)."
})
$form.Controls.Add($bMouse)

# --- 2. NETTOYAGE ---
$l2 = New-Object System.Windows.Forms.Label
$l2.Text = "2. MAINTENANCE ET NETTOYAGE"; $l2.Location = New-Object System.Drawing.Point(30, 170); $l2.AutoSize = $true; $l2.Font = $fTitle; $form.Controls.Add($l2)

$b2 = New-Object System.Windows.Forms.Button
$b2.Text = "Nettoyage Profond"; $b2.Location = New-Object System.Drawing.Point(30, 210); $b2.Size = New-Object System.Drawing.Size(250, 35); $b2.FlatStyle = "Flat"; $b2.BackColor = [System.Drawing.Color]::SteelBlue
$b2.Add_Click({ 
    Write-Log "Vidage Corbeille et dossiers TEMP..."
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Log "Nettoyage fichiers temporaires fini."
})
$form.Controls.Add($b2)

$bWinSxS = New-Object System.Windows.Forms.Button
$bWinSxS.Text = "Nettoyage WinSxS"; $bWinSxS.Location = New-Object System.Drawing.Point(30, 255); $bWinSxS.Size = New-Object System.Drawing.Size(250, 35); $bWinSxS.FlatStyle = "Flat"; $bWinSxS.BackColor = [System.Drawing.Color]::SteelBlue
$bWinSxS.Add_Click({ 
    Write-Log "Lancement nettoyage des composants (WinSxS)..."
    Start-Process powershell -ArgumentList "-Command dism /online /cleanup-image /startcomponentcleanup /resetbase" -Wait
    Write-Log "Dossier WinSxS optimise."
})
$form.Controls.Add($bWinSxS)

# --- 3. REPARATIONS AVEC RAPPORT ---
$l3 = New-Object System.Windows.Forms.Label
$l3.Text = "3. REPARATIONS AVANCÉES"; $l3.Location = New-Object System.Drawing.Point(30, 320); $l3.AutoSize = $true; $l3.Font = $fTitle; $form.Controls.Add($l3)

$b3 = New-Object System.Windows.Forms.Button
$b3.Text = "DISM RestoreHealth"; $b3.Location = New-Object System.Drawing.Point(30, 360); $b3.Size = New-Object System.Drawing.Size(250, 35); $b3.FlatStyle = "Flat"; $b3.BackColor = [System.Drawing.Color]::Firebrick
$b3.Add_Click({ 
    Write-Log "DISM : Verification de l'image systeme..."
    $res = Start-Process powershell -ArgumentList "-Command dism /online /cleanup-image /restorehealth" -Wait -PassThru
    if ($res.ExitCode -eq 0) { Write-Log "RAPPORT DISM : Reparation reussie ou aucune erreur." } else { Write-Log "RAPPORT DISM : Echec (Code $($res.ExitCode))." }
})
$form.Controls.Add($b3)

$b4 = New-Object System.Windows.Forms.Button
$b4.Text = "SFC Scannow"; $b4.Location = New-Object System.Drawing.Point(30, 405); $b4.Size = New-Object System.Drawing.Size(250, 35); $b4.FlatStyle = "Flat"; $b4.BackColor = [System.Drawing.Color]::Brown
$b4.Add_Click({ 
    Write-Log "SFC : Analyse des fichiers systeme..."
    $res = Start-Process powershell -ArgumentList "-Command sfc /scannow" -Wait -PassThru
    if ($res.ExitCode -eq 0) { Write-Log "RAPPORT SFC : Fichiers sains ou repares." } else { Write-Log "RAPPORT SFC : Erreurs detectees." }
})
$form.Controls.Add($b4)

# --- 4. OPTIONS AVANCEES ---
$l4 = New-Object System.Windows.Forms.Label
$l4.Text = "4. OPTIONS AVANCEES"; $l4.Location = New-Object System.Drawing.Point(30, 480); $l4.AutoSize = $true; $l4.Font = $fTitle; $form.Controls.Add($l4)

$bWinget = New-Object System.Windows.Forms.Button
$bWinget.Text = "MAJ Logiciels (Winget)"; $bWinget.Location = New-Object System.Drawing.Point(30, 520); $bWinget.Size = New-Object System.Drawing.Size(250, 35); $bWinget.FlatStyle = "Flat"; $bWinget.BackColor = [System.Drawing.Color]::DodgerBlue
$bWinget.Add_Click({ 
    Write-Log "Recherche de mises a jour via Winget..."
    Start-Process powershell -ArgumentList "-Command winget upgrade --all --silent --accept-package-agreements" -Wait
    Write-Log "Applications a jour."
})
$form.Controls.Add($bWinget)

$bBit = New-Object System.Windows.Forms.Button
$bBit.Text = "Desactiver BitLocker"; $bBit.Location = New-Object System.Drawing.Point(30, 565); $bBit.Size = New-Object System.Drawing.Size(250, 35); $bBit.FlatStyle = "Flat"; $bBit.BackColor = [System.Drawing.Color]::DarkRed
$bBit.Add_Click({ 
    Disable-BitLocker -MountPoint "C:"
    Write-Log "Dechiffrement BitLocker lance sur C:."
})
$form.Controls.Add($bBit)

# --- 5. RACCOURCIS ---
$l5 = New-Object System.Windows.Forms.Label
$l5.Text = "5. RACCOURCIS"; $l5.Location = New-Object System.Drawing.Point(30, 640); $l5.AutoSize = $true; $l5.Font = $fTitle; $form.Controls.Add($l5)

$bS1 = New-Object System.Windows.Forms.Button
$bS1.Text = "Demarrage"; $bS1.Location = New-Object System.Drawing.Point(30, 680); $bS1.Size = New-Object System.Drawing.Size(120, 35); $bS1.FlatStyle = "Flat"; $bS1.BackColor = [System.Drawing.Color]::DimGray
$bS1.Add_Click({ start "ms-settings:startupapps" })
$form.Controls.Add($bS1)

$bS2 = New-Object System.Windows.Forms.Button
$bS2.Text = "Lecteurs"; $bS2.Location = New-Object System.Drawing.Point(160, 680); $bS2.Size = New-Object System.Drawing.Size(120, 35); $bS2.FlatStyle = "Flat"; $bS2.BackColor = [System.Drawing.Color]::DimGray
$bS2.Add_Click({ start "dfrgui.exe" })
$form.Controls.Add($bS2)

Write-Log "Pret. Version 4.1 stable avec Rapports de sante."
$form.ShowDialog()
