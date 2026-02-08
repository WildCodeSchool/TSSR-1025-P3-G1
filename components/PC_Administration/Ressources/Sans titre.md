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