# Script de synchronisation Active Directory depuis fichier RH (.csv)
# Auteur : Christian
# Description : Gère les arrivées, départs, modifications et changements hiérarchiques

# Sommaire
# 01 - VARIABLES
# 02 - TABLES DE MAPPING
# 03 - FONCTIONS UTILITAIRES
# 04 - VÉRIFICATIONS
# 05 - CHARGEMENT DES DONNÉES
# 06 - DÉTECTION DES CHANGEMENTS
# 07 - TRAITEMENT DES NOUVEAUX COLLABORATEURS
# 08 - TRAITEMENT DES DÉPARTS
# 09 - TRAITEMENT DES MODIFICATIONS
# 10 - MISE À JOUR DES MANAGERS
# 11 - RÉSUMÉ


#==========================================================
#region 01 - VARIABLES
#==========================================================

# Emplacement du fichier CSV RH
$SourceCSV = "C:\Scripts\rh_collaborateurs.csv"

# Configuration AD
$DomainDN     = "DC=billu,DC=lan"
$DomainName   = "@billu.lan"

# OU de destination pour les comptes désactivés
$DisabledOU   = "OU=Desactives,OU=BilluUsers,$DomainDN"

# Mot de passe par défaut pour les nouveaux comptes
$DefaultPassword = "Azerty1*"

# Champ utilisé comme identifiant unique RH (doit exister dans le CSV et dans AD)
# On utilise l'EmployeeID pour identifier un collaborateur de manière fiable
# (indépendant des changements de nom/prénom)
$IDField = "EmployeeID"

# Compteurs pour le résumé
$UsersCreated    = 0
$UsersDisabled   = 0
$UsersModified   = 0
$UsersSkipped    = 0
$ManagerUpdated  = 0
$ManagerErrors   = 0
$ErrorsList      = @()

# Stockage des comptes traités (pour la passe manager)
$CreatedAccounts = @{}

#endregion


#==========================================================
#region 02 - TABLES DE MAPPING
#==========================================================

$DepartementMapping = @{
    "Service Commercial"                   = "COMMERCIAL"
    "Communication et Relations publiques" = "COMMUNICATION"
    "Finance et Comptabilité"              = "COMPTABILITE"
    "Développement logiciel"               = "DEV"
    "Direction"                            = "DIRECTION"
    "DSI"                                  = "DSI"
    "Département Juridique"                = "JURIDIQUE"
    "QHSE"                                 = "QHSE"
    "Service recrutement"                  = "RH"
}

$ServiceMapping = @{
    # COMMERCIAL
    "ADV"                                  = "ADMINISTRATION_DES_VENTES"
    "B2B"                                  = "B2B"
    "Service achat"                        = "SERVICE_ACHAT"
    "Service Client"                       = "SERVICE_CLIENT"

    # COMMUNICATION
    "Relation Médias"                      = "RELATION_MEDIAS"
    "Communication interne"                = "COMMUNICATION_INTERNE"
    "Gestion des marques"                  = "GESTION_MARQUES"

    # COMPTABILITE
    "Finance"                              = "FINANCE"
    "Fiscalité"                            = "FISCALITE"
    "Service Comptabilité"                 = "SERVICE_COMPTABILITE"

    # DEVELOPPEMENT
    "analyse et conception"                = "ANALYSE_CONCEPTION"
    "Développement"                        = "DEVELOPPEMENT"
    "Recherche et Prototype"               = "RECHERCHE_PROTOTYPAGE"
    "Tests et qualité"                     = "TESTS_QUALITE"

    # DSI
    "Administration Systèmes et Réseaux"   = "ADMINISTRATION_SYSTEMES_RESEAUX"
    "Développement et Intégration"         = "DEVELOPPEMENT_INTEGRATION"
    "Exploitation"                         = "EXPLOITATION"
    "Support"                              = "SUPPORT"

    # JURIDIQUE
    "Droit des sociétés"                   = "DROIT_DES_SOCIETES"
    "Protection des données et conformité" = "PROTECTION_DONNEES_CONFORMITES"
    "Propriété intellectuelle"             = "PROPRIETES_INTELLECTUELLES"

    # QHSE
    "Certification"                        = "CERTIFICATION"
    "Contrôle Qualité"                     = "CONTROLE_QUALITE"
    "Gestion environnementale"             = "GESTION_ENVIRONNEMENTALE"
}

# Correspondance entre colonnes CSV et attributs AD pour la détection des modifications
# Format : "Colonne CSV" = "Attribut AD"
$AttributeMapping = @{
    "Prenom"             = "GivenName"
    "Nom"                = "Surname"
    "fonction"           = "Title"
    "Departement"        = "Department"
    "Societe"            = "Company"
    "Telephone fixe"     = "OfficePhone"
    "Telephone portable" = "MobilePhone"
}

#endregion


#==========================================================
#region 03 - FONCTIONS UTILITAIRES
#==========================================================

function Clean-Name {
    param([string]$Name)

    $Name = $Name -replace "[éèêë]", "e" -replace "[àâäá]", "a" -replace "[ôö]", "o" `
                  -replace "[ùûü]", "u" -replace "[ïî]", "i" -replace "[ç]", "c" `
                  -replace "[ÉÈÊË]", "E" -replace "[ÀÂÄÁ]", "A" -replace "[ÔÖ]", "O" `
                  -replace "[ÙÛÜ]", "U" -replace "[ÏÎ]", "I" -replace "[Ç]", "C"
    $Name = $Name -replace "[''\s-]", ""
    return $Name
}

function Get-SamAccountName {
    param(
        [string]$Prenom,
        [string]$Nom
    )

    $PrenomClean = Clean-Name -Name $Prenom
    $NomClean    = Clean-Name -Name $Nom
    $SamAccount  = "$PrenomClean.$NomClean".ToLower()

    if ($SamAccount.Length -gt 20) {
        $SamAccount = $SamAccount.Substring(0, 20)
    }

    $Counter        = 2
    $FinalSamAccount = $SamAccount

    while (Get-ADUser -Filter "SamAccountName -eq '$FinalSamAccount'" -ErrorAction SilentlyContinue) {
        $FinalSamAccount = "$SamAccount$Counter"
        if ($FinalSamAccount.Length -gt 20) {
            $BaseLength      = 20 - $Counter.ToString().Length
            $FinalSamAccount = $SamAccount.Substring(0, $BaseLength) + $Counter
        }
        $Counter++
    }

    return $FinalSamAccount
}

function Get-OUPath {
    param(
        [string]$Departement,
        [string]$Service
    )

    $DeptOU = $DepartementMapping[$Departement]

    if ([string]::IsNullOrWhiteSpace($DeptOU)) {
        throw "Département '$Departement' non trouvé dans le mapping"
    }

    if (-not [string]::IsNullOrWhiteSpace($Service)) {
        $ServiceOU = $ServiceMapping[$Service]
        if ([string]::IsNullOrWhiteSpace($ServiceOU)) {
            throw "Service '$Service' non trouvé dans le mapping"
        }
        return "OU=$ServiceOU,OU=$DeptOU,OU=BilluUsers,$DomainDN"
    }

    return "OU=$DeptOU,OU=BilluUsers,$DomainDN"
}

# Désactive un compte et le déplace dans l'OU des comptes désactivés
function Disable-DepartedUser {
    param([Microsoft.ActiveDirectory.Management.ADUser]$ADUser)

    # Désactivation du compte
    Disable-ADAccount -Identity $ADUser.DistinguishedName -ErrorAction Stop

    # Ajout d'une note dans la description avec la date de désactivation
    $DateDesactivation = Get-Date -Format "yyyy-MM-dd"
    Set-ADUser -Identity $ADUser.DistinguishedName `
               -Description "Compte désactivé le $DateDesactivation - Départ collaborateur" `
               -ErrorAction Stop

    # Retrait de tous les groupes (sauf Domain Users)
    $Groups = Get-ADPrincipalGroupMembership -Identity $ADUser.DistinguishedName -ErrorAction SilentlyContinue |
              Where-Object { $_.Name -ne "Domain Users" }

    foreach ($Group in $Groups) {
        try {
            Remove-ADGroupMember -Identity $Group.DistinguishedName `
                                 -Members $ADUser.DistinguishedName `
                                 -Confirm:$false `
                                 -ErrorAction Stop
        } catch {
            # On continue même si un groupe pose problème
        }
    }

    # Déplacement dans l'OU des désactivés
    Move-ADObject -Identity $ADUser.DistinguishedName `
                  -TargetPath $DisabledOU `
                  -ErrorAction Stop
}

#endregion


#==========================================================
#region 04 - VÉRIFICATIONS
#==========================================================

Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      Script de synchronisation AD - Fichier RH           ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Vérification du fichier CSV
Write-Host "[VÉRIFICATION] Fichier CSV ($SourceCSV)..." -NoNewline
if (-not (Test-Path $SourceCSV)) {
    Write-Host " ERREUR" -ForegroundColor Red
    Write-Host "Le fichier CSV n'existe pas : $SourceCSV" -ForegroundColor Red
    exit 1
}
Write-Host " OK" -ForegroundColor Green

# Vérification de l'OU des désactivés
Write-Host "[VÉRIFICATION] OU des comptes désactivés..." -NoNewline
try {
    Get-ADOrganizationalUnit -Identity $DisabledOU -ErrorAction Stop | Out-Null
    Write-Host " OK" -ForegroundColor Green
} catch {
    Write-Host " ERREUR" -ForegroundColor Red
    Write-Host "L'OU '$DisabledOU' n'existe pas. Veuillez la créer avant d'exécuter ce script." -ForegroundColor Red
    exit 1
}

Write-Host ""

#endregion


#==========================================================
#region 05 - CHARGEMENT DES DONNÉES
#==========================================================

# Import du CSV RH
$SourceData     = Import-Csv -Path $SourceCSV -Delimiter ";" -Encoding UTF8
$SecurePassword = ConvertTo-SecureString -String $DefaultPassword -AsPlainText -Force

# Récupération de tous les utilisateurs AD actifs dans BilluUsers (avec EmployeeID)
$ADUsers = Get-ADUser -Filter * `
           -SearchBase "OU=BilluUsers,$DomainDN" `
           -Properties SamAccountName, GivenName, Surname, EmployeeID, `
                       Department, Title, Company, OfficePhone, MobilePhone, `
                       Manager, DisplayName, EmailAddress, Enabled `
           -ErrorAction Stop

# Indexation des utilisateurs AD par EmployeeID pour accès rapide
$ADUsersById = @{}
foreach ($ADUser in $ADUsers) {
    if (-not [string]::IsNullOrWhiteSpace($ADUser.EmployeeID)) {
        $ADUsersById[$ADUser.EmployeeID] = $ADUser
    }
}

# Indexation des collaborateurs RH par EmployeeID
$RHUsersById = @{}
foreach ($RHUser in $SourceData) {
    if (-not [string]::IsNullOrWhiteSpace($RHUser.$IDField)) {
        $RHUsersById[$RHUser.$IDField] = $RHUser
    }
}

Write-Host "Collaborateurs dans le fichier RH : $($RHUsersById.Count)" -ForegroundColor Cyan
Write-Host "Comptes actifs dans AD             : $($ADUsersById.Count)" -ForegroundColor Cyan
Write-Host ""

#endregion


#==========================================================
#region 06 - DÉTECTION DES CHANGEMENTS
#==========================================================

# Nouveaux collaborateurs : présents dans le CSV mais pas dans AD
$NouveauxCollaborateurs = $RHUsersById.Keys | Where-Object { -not $ADUsersById.ContainsKey($_) }

# Collaborateurs partis : présents dans AD mais absents du CSV
$CollaborateursPartis = $ADUsersById.Keys | Where-Object { -not $RHUsersById.ContainsKey($_) }

# Collaborateurs communs : présents des deux côtés (vérification de modifications)
$CollaborateursCommuns = $RHUsersById.Keys | Where-Object { $ADUsersById.ContainsKey($_) }

Write-Host "Détection des changements :" -ForegroundColor Cyan
Write-Host "  → Nouveaux collaborateurs : $($NouveauxCollaborateurs.Count)" -ForegroundColor Green
Write-Host "  → Départs détectés        : $($CollaborateursPartis.Count)"   -ForegroundColor Yellow
Write-Host "  → À vérifier (existants)  : $($CollaborateursCommuns.Count)"  -ForegroundColor White
Write-Host ""

#endregion


#==========================================================
#region 07 - TRAITEMENT DES NOUVEAUX COLLABORATEURS
#==========================================================

if ($NouveauxCollaborateurs.Count -gt 0) {

    Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║              NOUVEAUX COLLABORATEURS                      ║" -ForegroundColor Green
    Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""

    foreach ($EmpID in $NouveauxCollaborateurs) {

        $User = $RHUsersById[$EmpID]

        if ([string]::IsNullOrWhiteSpace($User.Prenom) -or [string]::IsNullOrWhiteSpace($User.Nom)) {
            continue
        }

        try {
            $SamAccount = Get-SamAccountName -Prenom $User.Prenom -Nom $User.Nom
            $UPN        = "$SamAccount$DomainName"
            $OUPath     = Get-OUPath -Departement $User.Departement -Service $User.Service

            New-ADUser `
                -Name              "$($User.Prenom) $($User.Nom)" `
                -GivenName         $User.Prenom `
                -Surname           $User.Nom `
                -SamAccountName    $SamAccount `
                -UserPrincipalName $UPN `
                -DisplayName       "$($User.Prenom) $($User.Nom)" `
                -EmailAddress      $UPN `
                -Path              $OUPath `
                -AccountPassword   $SecurePassword `
                -Enabled           $true `
                -ChangePasswordAtLogon $true `
                -EmployeeID        $EmpID `
                -Department        $User.Departement `
                -Title             $User.Fonction `
                -Company           $User.Societe `
                -OfficePhone       $User.'Telephone fixe' `
                -MobilePhone       $User.'Telephone portable' `
                -ErrorAction Stop

            # Stocke pour la passe manager
            $UserKey                 = "$($User.Prenom) $($User.Nom)"
            $CreatedAccounts[$UserKey] = $SamAccount

            Write-Host "[CRÉÉ]    " -ForegroundColor Green -NoNewline
            Write-Host "$($User.Prenom) $($User.Nom)" -NoNewline
            Write-Host "  → $SamAccount" -ForegroundColor Yellow

            $UsersCreated++

        } catch {
            Write-Host "[ERREUR]  " -ForegroundColor Red -NoNewline
            Write-Host "$($User.Prenom) $($User.Nom)" -NoNewline
            Write-Host "  → $($_.Exception.Message)" -ForegroundColor Red

            $ErrorsList += [PSCustomObject]@{
                Action      = "CRÉATION"
                Utilisateur = "$($User.Prenom) $($User.Nom)"
                Erreur      = $_.Exception.Message
            }
            $UsersSkipped++
        }
    }

    Write-Host ""
}

#endregion


#==========================================================
#region 08 - TRAITEMENT DES DÉPARTS
#==========================================================

if ($CollaborateursPartis.Count -gt 0) {

    Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║              DÉPARTS DE COLLABORATEURS                    ║" -ForegroundColor Yellow
    Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
    Write-Host ""

    foreach ($EmpID in $CollaborateursPartis) {

        $ADUser = $ADUsersById[$EmpID]

        try {
            Disable-DepartedUser -ADUser $ADUser -ErrorAction Stop

            Write-Host "[DÉSACTIVÉ] " -ForegroundColor Yellow -NoNewline
            Write-Host "$($ADUser.DisplayName)" -NoNewline
            Write-Host "  → Compte désactivé et déplacé dans $DisabledOU" -ForegroundColor Gray

            $UsersDisabled++

        } catch {
            Write-Host "[ERREUR]    " -ForegroundColor Red -NoNewline
            Write-Host "$($ADUser.DisplayName)" -NoNewline
            Write-Host "  → $($_.Exception.Message)" -ForegroundColor Red

            $ErrorsList += [PSCustomObject]@{
                Action      = "DÉSACTIVATION"
                Utilisateur = $ADUser.DisplayName
                Erreur      = $_.Exception.Message
            }
        }
    }

    Write-Host ""
}

#endregion


#==========================================================
#region 09 - TRAITEMENT DES MODIFICATIONS
#==========================================================

Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              VÉRIFICATION DES MODIFICATIONS               ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

foreach ($EmpID in $CollaborateursCommuns) {

    $RHUser = $RHUsersById[$EmpID]
    $ADUser = $ADUsersById[$EmpID]

    $Modifications     = @{}
    $HasOUChange       = $false
    $UserHasChanges    = $false

    # --- Vérification des attributs simples ---
    foreach ($CSVField in $AttributeMapping.Keys) {
        $ADAttribute = $AttributeMapping[$CSVField]
        $ValCSV      = $RHUser.$CSVField
        $ValAD       = $ADUser.$ADAttribute

        # Normalise les nulls
        if ([string]::IsNullOrWhiteSpace($ValCSV)) { $ValCSV = "" }
        if ([string]::IsNullOrWhiteSpace($ValAD))  { $ValAD  = "" }

        if ($ValCSV -ne $ValAD) {
            $Modifications[$ADAttribute] = $ValCSV
            $UserHasChanges = $true
        }
    }

    # --- Vérification du changement d'OU (département ou service) ---
    try {
        $OUCible   = Get-OUPath -Departement $RHUser.Departement -Service $RHUser.Service
        $OUActuelle = ($ADUser.DistinguishedName -split ",", 2)[1]

        if ($OUCible -ne $OUActuelle) {
            $HasOUChange    = $true
            $UserHasChanges = $true
        }
    } catch {
        # Mapping introuvable : on ignore le déplacement d'OU pour cet utilisateur
    }

    # --- Application des modifications ---
    if ($UserHasChanges) {

        try {
            # Mise à jour des attributs modifiés
            if ($Modifications.Count -gt 0) {

                $SetParams = @{ Identity = $ADUser.DistinguishedName }

                if ($Modifications.ContainsKey("GivenName"))    { $SetParams["GivenName"]    = $Modifications["GivenName"] }
                if ($Modifications.ContainsKey("Surname"))      { $SetParams["Surname"]      = $Modifications["Surname"] }
                if ($Modifications.ContainsKey("Title"))        { $SetParams["Title"]        = $Modifications["Title"] }
                if ($Modifications.ContainsKey("Department"))   { $SetParams["Department"]   = $Modifications["Department"] }
                if ($Modifications.ContainsKey("Company"))      { $SetParams["Company"]      = $Modifications["Company"] }
                if ($Modifications.ContainsKey("OfficePhone"))  { $SetParams["OfficePhone"]  = $Modifications["OfficePhone"] }
                if ($Modifications.ContainsKey("MobilePhone"))  { $SetParams["MobilePhone"]  = $Modifications["MobilePhone"] }

                # Mise à jour du DisplayName si le prénom ou nom a changé
                if ($Modifications.ContainsKey("GivenName") -or $Modifications.ContainsKey("Surname")) {
                    $NewPrenom              = if ($Modifications.ContainsKey("GivenName")) { $Modifications["GivenName"] } else { $ADUser.GivenName }
                    $NewNom                 = if ($Modifications.ContainsKey("Surname"))   { $Modifications["Surname"]  } else { $ADUser.Surname }
                    $SetParams["DisplayName"] = "$NewPrenom $NewNom"
                }

                Set-ADUser @SetParams -ErrorAction Stop
            }

            # Déplacement dans la bonne OU si nécessaire
            if ($HasOUChange) {
                Move-ADObject -Identity $ADUser.DistinguishedName `
                              -TargetPath $OUCible `
                              -ErrorAction Stop
            }

            # Construction du résumé des champs modifiés
            $DetailChanges = ($Modifications.Keys + $(if ($HasOUChange) { @("OU") } else { @() })) -join ", "

            Write-Host "[MODIFIÉ]  " -ForegroundColor Cyan -NoNewline
            Write-Host "$($ADUser.DisplayName)" -NoNewline
            Write-Host "  → $DetailChanges" -ForegroundColor Gray

            $UsersModified++

        } catch {
            Write-Host "[ERREUR]   " -ForegroundColor Red -NoNewline
            Write-Host "$($ADUser.DisplayName)" -NoNewline
            Write-Host "  → $($_.Exception.Message)" -ForegroundColor Red

            $ErrorsList += [PSCustomObject]@{
                Action      = "MODIFICATION"
                Utilisateur = $ADUser.DisplayName
                Erreur      = $_.Exception.Message
            }
        }

    } else {
        Write-Host "[INCHANGÉ] " -ForegroundColor DarkGray -NoNewline
        Write-Host "$($ADUser.DisplayName)" -ForegroundColor DarkGray
    }
}

Write-Host ""

#endregion


#==========================================================
#region 10 - MISE À JOUR DES MANAGERS
#==========================================================

Write-Host "[INFO] Mise à jour des relations hiérarchiques..." -ForegroundColor Cyan
Write-Host ""

# On recharge les utilisateurs AD pour avoir les DN à jour (après déplacements éventuels)
$ADUsersRefresh = Get-ADUser -Filter * `
                  -SearchBase "OU=BilluUsers,$DomainDN" `
                  -Properties EmployeeID, Manager `
                  -ErrorAction Stop

$ADUsersByIdRefresh = @{}
foreach ($U in $ADUsersRefresh) {
    if (-not [string]::IsNullOrWhiteSpace($U.EmployeeID)) {
        $ADUsersByIdRefresh[$U.EmployeeID] = $U
    }
}

foreach ($EmpID in $RHUsersById.Keys) {

    $RHUser = $RHUsersById[$EmpID]

    # Ignore si pas de manager renseigné dans le CSV
    if ([string]::IsNullOrWhiteSpace($RHUser.'Manager-ID')) {
        continue
    }

    $ManagerID = $RHUser.'Manager-ID'

    # Ignore si l'utilisateur ou le manager n'existe pas dans AD
    if (-not $ADUsersByIdRefresh.ContainsKey($EmpID) -or
        -not $ADUsersByIdRefresh.ContainsKey($ManagerID)) {
        $ManagerErrors++
        continue
    }

    try {
        $ADUser    = $ADUsersByIdRefresh[$EmpID]
        $ADManager = $ADUsersByIdRefresh[$ManagerID]

        # Vérifie si le manager a changé
        if ($ADUser.Manager -ne $ADManager.DistinguishedName) {
            Set-ADUser -Identity $ADUser.DistinguishedName `
                       -Manager $ADManager.DistinguishedName `
                       -ErrorAction Stop

            Write-Host "  [MANAGER MIS À JOUR] " -ForegroundColor Cyan -NoNewline
            Write-Host "$($ADUser.Name)  → Manager : $($ADManager.Name)" -ForegroundColor Gray

            $ManagerUpdated++
        }

    } catch {
        Write-Host "  [ERREUR MANAGER] " -ForegroundColor Red -NoNewline
        Write-Host "$($ADUser.Name)  → $($_.Exception.Message)" -ForegroundColor Red
        $ManagerErrors++
    }
}

Write-Host ""

#endregion


#==========================================================
#region 11 - RÉSUMÉ
#==========================================================

Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                        RÉSUMÉ                             ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Collaborateurs dans le fichier RH  : $($RHUsersById.Count)"  -ForegroundColor White
Write-Host ""
Write-Host "  [+] Comptes créés (arrivées)      : $UsersCreated"          -ForegroundColor Green
Write-Host "  [-] Comptes désactivés (départs)  : $UsersDisabled"         -ForegroundColor Yellow
Write-Host "  [~] Comptes modifiés              : $UsersModified"         -ForegroundColor Cyan
Write-Host "  [!] Comptes en erreur             : $UsersSkipped"          -ForegroundColor Red
Write-Host ""
Write-Host "  [H] Relations manager mises à jour : $ManagerUpdated"       -ForegroundColor Cyan
Write-Host "  [H] Erreurs manager                : $ManagerErrors"        -ForegroundColor Yellow
Write-Host ""

if ($ErrorsList.Count -gt 0) {
    Write-Host "DÉTAIL DES ERREURS :" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Red
    $ErrorsList | Format-Table -AutoSize
}

Write-Host "Synchronisation terminée !" -ForegroundColor Green

#endregion
