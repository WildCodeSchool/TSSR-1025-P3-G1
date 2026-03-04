# Restriction des horaires de connexion

# Heures autorisees
$heuresStandard = [byte[]](
    0,   0,   0,    # Dimanche  - bloque
    128, 255, 15,   # Lundi     - 07h-20h
    128, 255, 15,   # Mardi     - 07h-20h
    128, 255, 15,   # Mercredi  - 07h-20h
    128, 255, 15,   # Jeudi     - 07h-20h
    128, 255, 15,   # Vendredi  - 07h-20h
    0,   31,  0     # Samedi    - 08h-13h
)

# Creation du groupe bypass si il n'existe pas
if (-not (Get-ADGroup -Filter {Name -eq "GRP_LogonBypass"} -ErrorAction SilentlyContinue)) {
    New-ADGroup -Name "GRP_LogonBypass" -GroupScope Global -GroupCategory Security -Path "OU=BilluUsers,DC=billu,DC=lan" -Description "Utilisateurs avec bypass horaires"
}

# Récupération des comptes à exclure
$admins = Get-ADGroupMember -Identity "Domain Admins" -Recursive | Select-Object -ExpandProperty SamAccountName
$bypass = Get-ADGroupMember -Identity "GRP_LogonBypass" -Recursive -ErrorAction SilentlyContinue | Select-Object -ExpandProperty SamAccountName

# Liste des OUs (ADMINISTRATION_SYSTEMES_RESEAUX pas inclus car acces illimite)
$ous = @(
    "OU=COMMERCIAL,OU=BilluUsers,DC=billu,DC=lan",
    "OU=COMMUNICATION,OU=BilluUsers,DC=billu,DC=lan",
    "OU=COMPTABILITE,OU=BilluUsers,DC=billu,DC=lan",
    "OU=DEV,OU=BilluUsers,DC=billu,DC=lan",
    "OU=DIRECTION,OU=BilluUsers,DC=billu,DC=lan",
    "OU=JURIDIQUE,OU=BilluUsers,DC=billu,DC=lan",
    "OU=QHSE,OU=BilluUsers,DC=billu,DC=lan",
    "OU=RH,OU=BilluUsers,DC=billu,DC=lan",
    "OU=SUPPORT,OU=DSI,OU=BilluUsers,DC=billu,DC=lan",
    "OU=EXPLOITATION,OU=DSI,OU=BilluUsers,DC=billu,DC=lan",
    "OU=DEVELOPPEMENT_INTEGRATION,OU=DSI,OU=BilluUsers,DC=billu,DC=lan"
)

# Application des restrictions
foreach ($ou in $ous) {
    Get-ADUser -Filter {Enabled -eq $true} -SearchBase $ou |
    ForEach-Object {
        if ($admins -notcontains $_.SamAccountName -and $bypass -notcontains $_.SamAccountName) {
            Set-ADUser $_ -Replace @{logonHours = $heuresStandard}
        }
    }
}
