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