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


-------------

Parfait ! Le log révèle le problème : **Code d'erreur 1620** = "This installation package could not be opened"

Cela signifie que le fichier MSI est **corrompu** ou **incomplet**.

## Solution : Re-télécharger le fichier correctement

### Option A : Télécharger depuis votre PC puis copier

**C'est la méthode la plus fiable :**

1. **Sur votre PC avec interface graphique**, téléchargez NXLog :
   - Allez sur https://nxlog.co/products/nxlog-community-edition/download
   - Téléchargez la version Windows (MSI)

2. **Copiez le fichier vers le serveur Core** :
   - Ouvrez l'explorateur : `\\VOTRE_SERVEUR_CORE\C$\Temp\`
   - Collez le fichier `nxlog-ce-xxx.msi`

3. **Installez depuis PowerShell sur le serveur Core** :
   ```powershell
   msiexec /i "C:\Temp\nxlog-ce-xxx.msi" /qn /norestart
   ```

---

### Option B : Forcer un nouveau téléchargement

```powershell
# Supprimer le fichier corrompu
Remove-Item "C:\Temp\nxlog-ce.msi" -Force

# Télécharger avec plus d'options
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://dl.nxlog.co/dl/698c50fec4204"
$output = "C:\Temp\nxlog-ce.msi"
(New-Object System.Net.WebClient).DownloadFile($url, $output)

# Vérifier la taille (devrait être > 5 MB)
(Get-Item "C:\Temp\nxlog-ce.msi").Length / 1MB
```

---

**Je recommande l'Option A** car elle garantit un fichier valide. Une fois le bon fichier en place, l'installation devrait fonctionner sans problème !

---------------

OK, pas de problème ! Voici comment télécharger depuis Internet en contournant l'erreur SSL :

## Solution 1 : Utiliser curl (natif sur Windows Server 2022) ✅

```powershell
# curl est intégré à Windows Server 2022
curl.exe -k -L "https://dl.nxlog.co/dl/698c50fec4204" -o "C:\Temp\nxlog-ce.msi"

# Vérifier la taille
(Get-Item "C:\Temp\nxlog-ce.msi").Length / 1MB
```

---

## Solution 2 : Forcer TLS 1.2 et ignorer les certificats SSL

```powershell
# Activer TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Créer un client web qui ignore les erreurs SSL
$webClient = New-Object System.Net.WebClient
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

# Télécharger
$webClient.DownloadFile("https://dl.nxlog.co/dl/698c50fec4204", "C:\Temp\nxlog-ce.msi")

# Vérifier
(Get-Item "C:\Temp\nxlog-ce.msi").Length / 1MB
```

---

## Solution 3 : Utiliser BITS (Background Intelligent Transfer Service)

```powershell
# BITS gère mieux les certificats
Start-BitsTransfer -Source "https://dl.nxlog.co/dl/698c50fec4204" -Destination "C:\Temp\nxlog-ce.msi"

# Vérifier
(Get-Item "C:\Temp\nxlog-ce.msi").Length / 1MB
```

---

**Essayez la Solution 1 (curl)** en premier, c'est la plus simple ! Si ça ne marche pas, on passe à la suivante.

Dites-moi ce que ça donne ! 👍
