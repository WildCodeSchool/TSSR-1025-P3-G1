# Script d'installation de GLPI Agent par GPO

# Variables
$GlpiServer = "http://172.16.13.1"
$InstallerPath = "\\DOM-FS-01\departements\dsi\scripts\GLPI-Agent-1.15-x64.msi"
$LogPath = "C:\Windows\Temp\glpi-agent-install.log"

# Vérifier si déjà installé
if (Test-Path "C:\Program Files\GLPI-Agent\glpi-agent.bat") {
    "Agent GLPI déjà installé." | Out-File -FilePath $LogPath -Append
    exit 0
}

# Installation
"Installation de GLPI Agent en cours..." | Out-File -FilePath $LogPath -Append

# Paramètres d'installation
$MsiArguments = @(
    "/i"
    "`"$InstallerPath`""
    "/quiet"
    "/norestart"
    "SERVER=`"$GlpiServer`""
    "ADD_FIREWALL_EXCEPTION=1"
    "RUNNOW=1"
    "TAG=`"GPO-Deploy`""
    "/L*v"
    "`"$LogPath`""
)

$Process = Start-Process -FilePath "msiexec.exe" -ArgumentList $MsiArguments -Wait -PassThru -WindowStyle Hidden

# Vérifier le résultat
if ($Process.ExitCode -eq 0) {
    "Installation réussie." | Out-File -FilePath $LogPath -Append
} else {
    "Erreur lors de l'installation. Code: $($Process.ExitCode)" | Out-File -FilePath $LogPath -Append
}

exit $Process.ExitCode