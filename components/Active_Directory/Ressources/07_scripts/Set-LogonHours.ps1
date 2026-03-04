# Restriction des horaires de connexion
# Lun-Ven 07h-20h / Samedi 08h-13h / Dimanche bloque

$heuresStandard = [byte[]](
    0,   0,   0,    # Dimanche  - bloque
    128, 255, 15,   # Lundi     - 07h-20h
    128, 255, 15,   # Mardi     - 07h-20h
    128, 255, 15,   # Mercredi  - 07h-20h
    128, 255, 15,   # Jeudi     - 07h-20h
    128, 255, 15,   # Vendredi  - 07h-20h
    0,   31,  0     # Samedi    - 08h-13h
)

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

foreach ($ou in $ous) {
    Get-ADUser -Filter {Enabled -eq $true} -SearchBase $ou |
    ForEach-Object { Set-ADUser $_ -Replace @{logonHours = $heuresStandard} }
}
