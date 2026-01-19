# Projet 3 – Construction d’une infrastructure réseau  

## Société : BillU

## Sommaire

1. [Présentation du projet](#1-présentation-du-projet)

---

## 1. Objectif du document

Ce document définit l'ensemble des **règles de nommage** utilisées dans la cadre du projet d'infratructure réseau de la société **BillU**.

Ces conventions s'appliquent :
- Aux éléments existants
- Aux éléments créés durant le projet
- Aux futures évolutions de l'infrasctructure

Toute ressource ne respectant pas ces règles est considérée comme **non conforme**.

---

## 2. Principes généraux de nommages

Les règles suivantes s'appliquent à **tous les éléments** :

- Noms en MAJUSCULES pour les éléments techniques (serveurs, postes, groupes, réseau)
- Noms en minuscules pour les comptes utilisateurs
- Pas d'espaces
- Pas d'accents
- Séparation par des `-`
- Nom explicite et non ambigu
- Longueur raisonnable
- Un nom = un seul rôle
- Un nom n’est jamais réutilisé

---

## 3. Nommage des sites

| Éléments | Convention | Exemple |
|-------|----------|--------|
| Site principal | `SITE-<VILLES>` | `SITE-PARIS` |

---

## 4. Nommage des serveurs
### 4.1. Convention générale

Convention :
`SRV-<ROLE>-<ID>`

| Éléments | Description |
|-------|----------|
| DOM | Machine serveur |
| ROLE | Rôle principal du serveur |
| ID | Numéro unique |

#### Exemples 
- DOM-AD-01
- DOM-FILE-01
- DOM-GLPI-01
- DOM-BACKUP-01

### 4.2. Serveurs du projet
| Nom | Rôle |
|-------|------|
| DOM-AD-01 | Contrôleur de domaine / DNS |
| DOM-FILE-01 | Serveur de fichiers |
| DOM-GLPI-01 | Serveur GLPI |
| DOM-BACKUP-01 | Serveur de sauvegarde |

---

## 5. Nommage des postes clients

Convention :
`PC-<SERVICE>-<ID>`

### 5.1. Convention générale
| Éléments | Description |
|-------|----------|
| PC | Poste client |
| SERVICE | Département |
| ID | Numéro unique |

#### Exemples 
- PC-DEV-01
- PC-COM-01
- PC-DSI-01

### 5.2. Poste clients du projet
| Nom | Service |
|-------|----------|
| PC-DEV-01 | Développement |
| PC-COM-01 | Commercial |
| PC-DSI-01 | DSI |


---

## 6. Nommage des utilisateurs Active Directory
### 6.1 Convention générale
#### 6.1.1. Comptes utilisateurs standards

Format : `prenom.nom`

- en minuscules
- sans accents
- sans espaces
- sans caractères spéciaux

En cas d’homonymie : `prenom.nomX (X = chiffre incrémental)`

Les comptes utilisateurs sont personnels et non partagés.

##### Exemples 
- matthias.chicaud
- jean.dupont
- jean.dupont2

#### 6.1.2. Comptes administrateur

Les comptes administrateur sont distincts des comptes utilisateurs standards.
Ils ne sont pas utilisés pour la messagerie ou la navigation.

`prenom.nom.admin`

##### Exemples
- `matthias.chicaud.admin`

### 6.2. Comptes utilisateurs
| Type | Nom |
|-------|----------|
| Utilisateur | matthias.chicaud |
| Administrateur | matthias.chicaud.admin |
---

## 7. Nommage des groupes Active Directory
### 7.1. Convention générale

Convention :
`GRP-<TYPE>-<CIBLE>-<ROLE>`

| Élément | Description |
|-------|------------|
| GRP | Groupe Active Directory |
| TYPE | Type de groupe (SEC = sécurité) |
| CIBLE | Service ou ressource |
| ROLE | Fonction du groupe |


#### Exemples 
- GRP-SEC-DEV-USERS
- GRP-SEC-FILE-ACCESS
- GRP-SEC-DSI-ADMINS

---

## 8. Nommage des Unités d'Organisation (OU)

Les Unités d’Organisation (OU) sont structurées par rôle et par service.
Elles servent à l’application des GPO et à l’organisation logique de l’Active Directory.

## 8.1. Convention générale

Convention :
`OU-<TYPE>-<NOM>`

#### Exemples :

- OU-USERS
- OU-COMPUTERS
- OU-SERVERS
- OU-GROUPES
- OU-DEV
- OU-DSI

---

## 9. Nommage des GPO
### 9.1. Convention générale

Convention :
`<ETAT>-<CIBLE>-<ROLE>`

#### Exemples :

- TEST-USERS-SECURITY
- TEST-COMPUTERS-HARDENING
- PROD-USERS-PROXY
- PROD-COMPUTERS-UPDATES

---

## 10. Nommage réseau
### 10.1. VLAN

Convention :
`VLAN<ID>-<NOM>`

- VLAN10-DEV
- VLAN20-COMMERCIAL
- VLAN30-COMMUNICATION
- VLAN40-VOIP
- VLAN50-JURIDIQUE
- VLAN60-DSI
- VLAN70-COMPTA
- VLAN80-DIRECTION
- VLAN90-IMPRESSION
- VLAN100-QHSE
- VLAN110-RH
- VLAN120-SERVEURAD
- VLAN130-SERVEUR
- VLAN140-INVITE
- VLAN150-ADMIN



---
