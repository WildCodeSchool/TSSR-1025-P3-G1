## Correction : Supprimer les permissions en trop
```powershell
# Recharger l'ACL
$acl = Get-Acl C:\ProgramData\ssh\administrators_authorized_keys

# Désactiver l'héritage et supprimer toutes les règles héritées
$acl.SetAccessRuleProtection($true, $false)

# Supprimer TOUTES les règles d'accès existantes
$acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) | Out-Null }

# Ajouter uniquement SYSTEM
$systemRule = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM","FullControl","Allow")
$acl.SetAccessRule($systemRule)

# Ajouter uniquement Administrators
$adminRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")
$acl.SetAccessRule($adminRule)

# Appliquer
Set-Acl -Path C:\ProgramData\ssh\administrators_authorized_keys -AclObject $acl
```

## Configuration SSH sur DOM-DHCP
```powershell
# Ajouter une ligne vide
Add-Content -Path C:\ProgramData\ssh\sshd_config -Value ""

# Ajouter PubkeyAuthentication
Add-Content -Path C:\ProgramData\ssh\sshd_config -Value "PubkeyAuthentication yes"

# Ajouter PasswordAuthentication
Add-Content -Path C:\ProgramData\ssh\sshd_config -Value "PasswordAuthentication no"

# Redémarrer SSH
Restart-Service sshd
```

## Test de connexion
```powershell
# Déconnexion
exit

# Test depuis PC Admin
ssh administrateur@172.16.12.2
```


## Diagnostic complet sur DOM-DHCP

### 1️⃣ Réactiver temporairement le mot de passe
```powershell
(Get-Content C:\ProgramData\ssh\sshd_config) -replace 'PasswordAuthentication no','PasswordAuthentication yes' | Set-Content C:\ProgramData\ssh\sshd_config

Restart-Service sshd
```

### 2️⃣ Vérifier le contenu de la clé
```powershell
Get-Content C:\ProgramData\ssh\administrators_authorized_keys
```

La clé doit être **sur une seule ligne** et commencer par `ssh-ed25519`.

### 3️⃣ Vérifier les permissions
```powershell
Get-Acl C:\ProgramData\ssh\administrators_authorized_keys | Select-Object -ExpandProperty Access
```

Tu dois voir **UNIQUEMENT** :
- `NT AUTHORITY\SYSTEM` avec `FullControl`
- `BUILTIN\Administrators` avec `FullControl`

### 4️⃣ Vérifier la configuration SSH
```powershell
Get-Content C:\ProgramData\ssh\sshd_config | Select-String -Pattern "Match Group|AuthorizedKeysFile|PubkeyAuthentication"
```

**Important** : Il doit y avoir ces lignes à la fin :
```
Match Group administrators
       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
```

### 5️⃣ Si ces lignes manquent, ajoute-les
```powershell
Add-Content -Path C:\ProgramData\ssh\sshd_config -Value ""
Add-Content -Path C:\ProgramData\ssh\sshd_config -Value "Match Group administrators"
Add-Content -Path C:\ProgramData\ssh\sshd_config -Value "       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys"

Restart-Service sshd
```