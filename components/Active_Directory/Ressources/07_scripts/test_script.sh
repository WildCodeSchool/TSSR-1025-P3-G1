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

# Emplacement du fichier CSV RH (nouveau fichier fourni par les RH)
$SourceCSV = "C:\Users\Administrator\Documents\s04-a02-BillU-ListeRHCollaborateurs.csv"

# Configuration AD
$DomainDN    = "DC=billu,DC=lan"
$DomainName  = "@billu.lan"

# OU racine où sont stockés les utilisateurs actifs
$UsersOU     = "OU=BilluUsers,$DomainDN"

# OU de destination pour les comptes désactivés (départs)
$DisabledOU  = "OU=UsersDeactived,$DomainDN"

# Mot de passe par défaut pour les nouveaux comptes
$DefaultPassword = "Azerty1*"

# Compteurs pour le résumé
$UsersCreated   = 0
$UsersDisabled  = 0
$UsersModified  = 0
$UsersSkipped   = 0
$ManagerUpdated = 0
$ManagerErrors  = 0
$ErrorsList     = @()

# Stockage des SamAccountName créés lors de cette exécution
# Clé = "Prenom Nom" (original, avec accents), Valeur = SamAccountName
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

# Correspondance colonnes CSV → attributs AD (pour la détection des modifications)
# Prenom et Nom sont gérés séparément car ils impactent aussi le DisplayName
$AttributeMapping = @{
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

# Supprime les accents et caractères spéciaux pour générer un SamAccountName propre
function Clean-Name {
    param([string]$Name)

    $Name = $Name -replace "[éèêë]", "e" -replace "[àâäá]", "a" -replace "[ôö]", "o" `
                  -replace "[ùûü]", "u" -replace "[ïî]", "i" -replace "[ç]", "c" `
                  -replace "[ÉÈÊË]", "E" -replace "[ÀÂÄÁ]", "A" -replace "[ÔÖ]", "O" `
                  -replace "[ÙÛÜ]", "U" -replace "[ÏÎ]", "I" -replace "[Ç]", "C"
    # Supprime apostrophes, espaces et tirets
    $Name = $Name -replace "[''\s-]", ""
    return $Name
}

# Calcule uniquement la base "prenom.nom" nettoyée, SANS vérifier les doublons dans AD.
# Utilisé pour retrouver un compte existant à partir d'un nom CSV.
function Get-SamBase {
    param(
        [string]$Prenom,
        [string]$Nom
    )
    $Sam = "$(Clean-Name $Prenom).$(Clean-Name $Nom)".ToLower()
    if ($Sam.Length -gt 20) { $Sam = $Sam.Substring(0, 20) }
    return $Sam
}

# Génère un SamAccountName unique (avec gestion des doublons) pour la création d'un nouveau compte.
function Get-SamAccountName {
    param(
        [string]$Prenom,
        [string]$Nom
    )

    $SamBase = Get-SamBase -Prenom $Prenom -Nom $Nom
    $Counter = 2
    $Final   = $SamBase

    while (Get-ADUser -Filter "SamAccountName -eq '$Final'" -ErrorAction SilentlyContinue) {
        $Final = "$SamBase$Counter"
        if ($Final.Length -gt 20) {
            $Final = $SamBase.Substring(0, 20 - $Counter.ToString().Length) + $Counter
        }
        $Counter++
    }

    return $Final
}

# Construit le chemin de l'OU cible dans AD à partir du département et du service
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
        return "OU=$ServiceOU,OU=$DeptOU,$UsersOU"
    }

    return "OU=$DeptOU,$UsersOU"
}

# Désactive un compte AD, retire ses groupes et le déplace dans l'OU des désactivés
function Disable-DepartedUser {
    param([Microsoft.ActiveDirectory.Management.ADUser]$ADUser)

    Disable-ADAccount -Identity $ADUser.DistinguishedName -ErrorAction Stop

    $DateDesactivation = Get-Date -Format "yyyy-MM-dd"
    Set-ADUser -Identity $ADUser.DistinguishedName `
               -Description "Compte désactivé le $DateDesactivation - Départ collaborateur" `
               -ErrorAction Stop

    # Retrait de tous les groupes sauf Domain Users
    $Groups = Get-ADPrincipalGroupMembership -Identity $ADUser.DistinguishedName -ErrorAction SilentlyContinue |
              Where-Object { $_.Name -ne "Domain Users" }

    foreach ($Group in $Groups) {
        try {
            Remove-ADGroupMember -Identity $Group.DistinguishedName `
                                 -Members $ADUser.DistinguishedName `
                                 -Confirm:$false -ErrorAction Stop
        } catch { }
    }

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

Write-Host "[VÉRIFICATION] Fichier CSV..." -NoNewline
if (-not (Test-Path $SourceCSV)) {
    Write-Host " ERREUR" -ForegroundColor Red
    Write-Host "Fichier introuvable : $SourceCSV" -ForegroundColor Red
    exit 1
}
Write-Host " OK" -ForegroundColor Green

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
# IMPORTANT : le fichier est encodé en Windows-1252 (Latin), pas en UTF-8
$SourceData     = Import-Csv -Path $SourceCSV -Delimiter ";" -Encoding Default
$SecurePassword = ConvertTo-SecureString -String $DefaultPassword -AsPlainText -Force

Write-Host "[INFO] $($SourceData.Count) ligne(s) chargée(s) depuis le CSV RH." -ForegroundColor Cyan

# -----------------------------------------------------------------------
# Indexation des utilisateurs du CSV par leur SamBase (prenom.nom nettoyé)
# C'est la même logique que le script de création : cette clé correspond
# exactement au SamAccountName stocké dans AD.
# -----------------------------------------------------------------------
$RHUsersBySam = @{}

foreach ($RHUser in $SourceData) {
    if ([string]::IsNullOrWhiteSpace($RHUser.Prenom) -or [string]::IsNullOrWhiteSpace($RHUser.Nom)) {
        continue
    }
    $SamBase = Get-SamBase -Prenom $RHUser.Prenom -Nom $RHUser.Nom
    $RHUsersBySam[$SamBase] = $RHUser
}

Write-Host "[INFO] $($RHUsersBySam.Count) collaborateur(s) identifié(s) dans le CSV (clé SamBase)." -ForegroundColor Cyan

# -----------------------------------------------------------------------
# Chargement des comptes AD actifs depuis l'OU BilluUsers
# -----------------------------------------------------------------------
$ADUsers = Get-ADUser -Filter * `
           -SearchBase $UsersOU `
           -Properties SamAccountName, GivenName, Surname, DisplayName, `
                       Department, Title, Company, OfficePhone, MobilePhone, `
                       Manager, EmailAddress, Enabled `
           -ErrorAction Stop

Write-Host "[INFO] $($ADUsers.Count) compte(s) trouvé(s) dans AD ($UsersOU)." -ForegroundColor Cyan
Write-Host ""

# Indexation des comptes AD par SamAccountName
$ADUsersBySam = @{}
foreach ($ADUser in $ADUsers) {
    $ADUsersBySam[$ADUser.SamAccountName] = $ADUser
}

#endregion


#==========================================================
#region 06 - DÉTECTION DES CHANGEMENTS
#==========================================================

# Nouveaux : SamBase présent dans le CSV mais aucun compte AD correspondant
$NouveauxCollaborateurs = $RHUsersBySam.Keys | Where-Object { -not $ADUsersBySam.ContainsKey($_) }

# Départs : compte AD présent dans BilluUsers mais SamAccountName absent du CSV
$CollaborateursPartis   = $ADUsersBySam.Keys | Where-Object { -not $RHUsersBySam.ContainsKey($_) }

# Communs : présents dans les deux → vérification de modifications
$CollaborateursCommuns  = $RHUsersBySam.Keys | Where-Object { $ADUsersBySam.ContainsKey($_) }

Write-Host "Détection des changements :" -ForegroundColor Cyan
Write-Host "  → Nouveaux collaborateurs : $($NouveauxCollaborateurs.Count)" -ForegroundColor Green
Write-Host "  → Départs détectés        : $($CollaborateursPartis.Count)"   -ForegroundColor Yellow
Write-Host "  → Comptes à vérifier      : $($CollaborateursCommuns.Count)"  -ForegroundColor White
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

    foreach ($SamBase in $NouveauxCollaborateurs) {

        $User = $RHUsersBySam[$SamBase]

        try {
            # Génère un SamAccountName unique (gère les éventuels doublons)
            $SamAccount = Get-SamAccountName -Prenom $User.Prenom -Nom $User.Nom
            $UPN        = "$SamAccount$DomainName"
            $OUPath     = Get-OUPath -Departement $User.Departement -Service $User.Service

            New-ADUser `
                -Name                  "$($User.Prenom) $($User.Nom)" `
                -GivenName             $User.Prenom `
                -Surname               $User.Nom `
                -SamAccountName        $SamAccount `
                -UserPrincipalName     $UPN `
                -DisplayName           "$($User.Prenom) $($User.Nom)" `
                -EmailAddress          $UPN `
                -Path                  $OUPath `
                -AccountPassword       $SecurePassword `
                -Enabled               $true `
                -ChangePasswordAtLogon $true `
                -Department            $User.Departement `
                -Title                 $User.fonction `
                -Company               $User.Societe `
                -OfficePhone           $User.'Telephone fixe' `
                -MobilePhone           $User.'Telephone portable' `
                -ErrorAction Stop

            # Mémorise le SamAccountName pour la passe manager
            $CreatedAccounts["$($User.Prenom) $($User.Nom)"] = $SamAccount

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

    foreach ($Sam in $CollaborateursPartis) {

        $ADUser = $ADUsersBySam[$Sam]

        try {
            Disable-DepartedUser -ADUser $ADUser

            Write-Host "[DÉSACTIVÉ] " -ForegroundColor Yellow -NoNewline
            Write-Host "$($ADUser.DisplayName)" -NoNewline
            Write-Host "  → Désactivé + déplacé vers $DisabledOU" -ForegroundColor Gray

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

foreach ($Sam in $CollaborateursCommuns) {

    $RHUser         = $RHUsersBySam[$Sam]
    $ADUser         = $ADUsersBySam[$Sam]
    $Modifications  = @{}
    $HasOUChange    = $false
    $UserHasChanges = $false

    # --- Vérification du prénom et du nom ---
    if ($RHUser.Prenom -ne $ADUser.GivenName) {
        $Modifications["GivenName"] = $RHUser.Prenom
        $UserHasChanges = $true
    }
    if ($RHUser.Nom -ne $ADUser.Surname) {
        $Modifications["Surname"] = $RHUser.Nom
        $UserHasChanges = $true
    }

    # --- Vérification des autres attributs via le mapping ---
    foreach ($CSVField in $AttributeMapping.Keys) {
        $ADAttribute = $AttributeMapping[$CSVField]
        $ValCSV      = if ([string]::IsNullOrWhiteSpace($RHUser.$CSVField)) { "" } else { $RHUser.$CSVField }
        $ValAD       = if ([string]::IsNullOrWhiteSpace($ADUser.$ADAttribute)) { "" } else { $ADUser.$ADAttribute }

        if ($ValCSV -ne $ValAD) {
            $Modifications[$ADAttribute] = $ValCSV
            $UserHasChanges = $true
        }
    }

    # --- Vérification du changement d'OU (département / service) ---
    try {
        $OUCible    = Get-OUPath -Departement $RHUser.Departement -Service $RHUser.Service
        $OUActuelle = ($ADUser.DistinguishedName -split ",", 2)[1]

        if ($OUCible -ne $OUActuelle) {
            $HasOUChange    = $true
            $UserHasChanges = $true
        }
    } catch {
        # Mapping département/service introuvable : déplacement ignoré pour cet utilisateur
    }

    # --- Application des modifications ---
    if ($UserHasChanges) {

        try {
            if ($Modifications.Count -gt 0) {

                $SetParams = @{ Identity = $ADUser.DistinguishedName }

                if ($Modifications.ContainsKey("GivenName"))   { $SetParams["GivenName"]   = $Modifications["GivenName"] }
                if ($Modifications.ContainsKey("Surname"))     { $SetParams["Surname"]     = $Modifications["Surname"] }
                if ($Modifications.ContainsKey("Title"))       { $SetParams["Title"]       = $Modifications["Title"] }
                if ($Modifications.ContainsKey("Department"))  { $SetParams["Department"]  = $Modifications["Department"] }
                if ($Modifications.ContainsKey("Company"))     { $SetParams["Company"]     = $Modifications["Company"] }
                if ($Modifications.ContainsKey("OfficePhone")) { $SetParams["OfficePhone"] = $Modifications["OfficePhone"] }
                if ($Modifications.ContainsKey("MobilePhone")) { $SetParams["MobilePhone"] = $Modifications["MobilePhone"] }

                # Si le prénom ou le nom a changé → mise à jour du DisplayName aussi
                if ($Modifications.ContainsKey("GivenName") -or $Modifications.ContainsKey("Surname")) {
                    $NewPrenom                = if ($Modifications.ContainsKey("GivenName")) { $Modifications["GivenName"] } else { $ADUser.GivenName }
                    $NewNom                   = if ($Modifications.ContainsKey("Surname"))   { $Modifications["Surname"]  } else { $ADUser.Surname }
                    $SetParams["DisplayName"] = "$NewPrenom $NewNom"
                }

                Set-ADUser @SetParams -ErrorAction Stop
            }

            # Déplacement d'OU si le département ou service a changé
            if ($HasOUChange) {
                Move-ADObject -Identity $ADUser.DistinguishedName `
                              -TargetPath $OUCible `
                              -ErrorAction Stop
            }

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

# Rechargement des comptes AD avec leurs DN à jour (après déplacements éventuels)
$ADUsersRefresh = Get-ADUser -Filter * `
                  -SearchBase $UsersOU `
                  -Properties SamAccountName, GivenName, Surname, Manager `
                  -ErrorAction Stop

# Index par SamAccountName pour résoudre l'utilisateur
$ADUsersBySamRefresh = @{}
foreach ($U in $ADUsersRefresh) {
    $ADUsersBySamRefresh[$U.SamAccountName] = $U
}

# Index par "Prenom Nom" pour résoudre le manager (référencé par nom dans le CSV)
$ADUsersByDisplayRefresh = @{}
foreach ($U in $ADUsersRefresh) {
    $DisplayKey = "$($U.GivenName) $($U.Surname)"
    if (-not [string]::IsNullOrWhiteSpace($DisplayKey.Trim())) {
        $ADUsersByDisplayRefresh[$DisplayKey] = $U
    }
}

foreach ($RHUser in $SourceData) {

    if ([string]::IsNullOrWhiteSpace($RHUser.Prenom) -or [string]::IsNullOrWhiteSpace($RHUser.Nom)) {
        continue
    }

    # Ignore si pas de manager renseigné dans le CSV
    if ([string]::IsNullOrWhiteSpace($RHUser.'Manager-Prenom') -or
        [string]::IsNullOrWhiteSpace($RHUser.'Manager-Nom')) {
        continue
    }

    $UserSam    = Get-SamBase -Prenom $RHUser.Prenom -Nom $RHUser.Nom
    $ManagerKey = "$($RHUser.'Manager-Prenom') $($RHUser.'Manager-Nom')"

    # Cherche l'utilisateur dans AD (avec fallback sur les comptes créés ce run)
    if (-not $ADUsersBySamRefresh.ContainsKey($UserSam)) {
        $CreatedSam = $CreatedAccounts["$($RHUser.Prenom) $($RHUser.Nom)"]
        if ($CreatedSam -and $ADUsersBySamRefresh.ContainsKey($CreatedSam)) {
            $UserSam = $CreatedSam
        } else {
            $ManagerErrors++
            continue
        }
    }

    # Cherche le manager dans AD par GivenName + Surname
    if (-not $ADUsersByDisplayRefresh.ContainsKey($ManagerKey)) {
        $ManagerErrors++
        continue
    }

    try {
        $ADUser    = $ADUsersBySamRefresh[$UserSam]
        $ADManager = $ADUsersByDisplayRefresh[$ManagerKey]

        # Mise à jour uniquement si le manager a changé
        if ($ADUser.Manager -ne $ADManager.DistinguishedName) {
            Set-ADUser -Identity $ADUser.DistinguishedName `
                       -Manager $ADManager.DistinguishedName `
                       -ErrorAction Stop

            Write-Host "  [MANAGER MIS À JOUR] " -ForegroundColor Cyan -NoNewline
            Write-Host "$($ADUser.Name)  → $($ADManager.Name)" -ForegroundColor Gray

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
Write-Host "Collaborateurs dans le fichier RH  : $($RHUsersBySam.Count)"  -ForegroundColor White
Write-Host ""
Write-Host "  [+] Comptes créés  (arrivées)     : $UsersCreated"           -ForegroundColor Green
Write-Host "  [-] Comptes désactivés (départs)  : $UsersDisabled"          -ForegroundColor Yellow
Write-Host "  [~] Comptes modifiés              : $UsersModified"          -ForegroundColor Cyan
Write-Host "  [!] Comptes en erreur             : $UsersSkipped"           -ForegroundColor Red
Write-Host ""
Write-Host "  [H] Relations manager mises à jour : $ManagerUpdated"        -ForegroundColor Cyan
Write-Host "  [H] Erreurs manager                : $ManagerErrors"         -ForegroundColor Yellow
Write-Host ""

if ($ErrorsList.Count -gt 0) {
    Write-Host "DÉTAIL DES ERREURS :" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Red
    $ErrorsList | Format-Table -AutoSize
}

Write-Host "Synchronisation terminée !" -ForegroundColor Green

#endregion
