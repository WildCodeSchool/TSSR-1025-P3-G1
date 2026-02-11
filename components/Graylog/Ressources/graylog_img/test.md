Parfait ! Alors on va rester sur **NXLog**, qui fonctionne très bien et que vous connaissez déjà. Voici comment l'installer sur **Windows Server Core 2022**.

## Installation de NXLog sur Windows Server Core

### 1. Télécharger NXLog

Depuis PowerShell (en administrateur) :

```powershell
# Créer un dossier temporaire
New-Item -Path "C:\Temp" -ItemType Directory -Force

# Télécharger NXLog Community Edition
$url = "https://nxlog.co/system/files/products/files/348/nxlog-ce-3.2.2329.msi"
$output = "C:\Temp\nxlog-ce.msi"
Invoke-WebRequest -Uri $url -OutFile $output
```

### 2. Installer NXLog en mode silencieux

```powershell
# Installation silencieuse
msiexec /i "C:\Temp\nxlog-ce.msi" /quiet /norestart
```

### 3. Configurer NXLog

Le fichier de configuration est ici : `C:\Program Files\nxlog\conf\nxlog.conf`

```powershell
# Éditer le fichier de configuration
notepad "C:\Program Files\nxlog\conf\nxlog.conf"
```

**Exemple de configuration** (adaptez selon votre setup existant) :

```conf
## Configuration NXLog pour Windows Server Core

define ROOT C:\Program Files\nxlog

Moduledir %ROOT%\modules
CacheDir %ROOT%\data
Pidfile %ROOT%\data\nxlog.pid
SpoolDir %ROOT%\data
LogFile %ROOT%\data\nxlog.log

# Module pour lire les Event Logs Windows
<Input eventlog>
    Module      im_msvistalog
    # Collecter les logs System, Application, Security
    Query <QueryList>\
            <Query Id="0">\
                <Select Path="Application">*</Select>\
                <Select Path="System">*</Select>\
                <Select Path="Security">*</Select>\
            </Query>\
          </QueryList>
</Input>

# Module de sortie TCP vers Graylog
<Output graylog>
    Module      om_tcp
    Host        VOTRE_IP_GRAYLOG
    Port        5140
    OutputType  GELF_TCP
</Output>

# Route : envoyer les logs vers Graylog
<Route 1>
    Path        eventlog => graylog
</Route>
```

### 4. Démarrer le service NXLog

```powershell
# Démarrer le service
Start-Service nxlog

# Vérifier le statut
Get-Service nxlog

# Configurer le démarrage automatique
Set-Service -Name nxlog -StartupType Automatic
```

### 5. Vérifier les logs NXLog (en cas de problème)

```powershell
Get-Content "C:\Program Files\nxlog\data\nxlog.log" -Tail 50
```

### 6. Ouvrir le firewall (si nécessaire)

```powershell
# Autoriser la communication sortante vers Graylog
New-NetFirewallRule -DisplayName "NXLog to Graylog" -Direction Outbound -Action Allow -Protocol TCP -RemotePort 5140
```

---

## Points importants :

- **Remplacez `VOTRE_IP_GRAYLOG`** et le **port** par ceux de votre Input Graylog
- Assurez-vous que l'**Input GELF TCP** est bien créé et actif dans Graylog (même port)
- Le format **GELF_TCP** est recommandé pour Graylog

Vous avez des questions sur la configuration ou vous voulez adapter certains paramètres ?
