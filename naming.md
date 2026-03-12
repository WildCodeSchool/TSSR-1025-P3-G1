# Projet 3 – Construction d’une infrastructure réseau  

## Société : BillU

## Sommaire

1. [Objectif du document](#1-objectif-du-document)
2. [Principes généraux de nommages](#2-principes-généraux-de-nommages)
3. [Nommage des sites](#3-nommage-des-sites)
4. [Nommage des serveurs](#4-nommage-des-serveurs)
5. [Nommage des postes clients](#5-nommage-des-postes-clients)
6. [Nommage des utilisateurs Active Directory](#6-nommage-des-utilisateurs-active-directory)
7. [Nommage des groupes Active Directory](#7-nommage-des-groupes-active-directory)
8. [Nommage des Unités d'Organisation (OU)](#8-nommage-des-unités-dorganisation-ou)
9. [Nommage des GPO](#9-nommage-des-gpo)
10. [Nommage réseau](#10-nommage-réseau)

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

#### COMMERCIAL

|Service|Code|Exemple|
|---|---|---|
|Département Commercial|COMMER|PC-COMMER-001|
|Administration des ventes|ADV|PC-ADV-001|
|B2B|B2B|PC-B2B-001|
|Service achat|SA|PC-SA-001|
|Service client|SCL|PC-SCL-001|

---

#### COMMUNICATION

|Service|Code|Exemple|
|---|---|---|
|Département Communication|COMMU|PC-COMMU-001|
|Communication interne|CI|PC-CI-001|
|Gestion des marques|GDM|PC-GDM-001|
|Relation média|RM|PC-RM-001|

---

#### COMPTABILITÉ

|Service|Code|Exemple|
|---|---|---|
|Département Comptabilité|COMPT|PC-COMPT-001|
|Finance|FIN|PC-FIN-001|
|Fiscalité|FIS|PC-FIS-001|
|Service comptabilité|SCO|PC-SCO-001|

---

#### DÉVELOPPEMENT

|Service|Code|Exemple|
|---|---|---|
|Département Développement|DEV|PC-DEV-001|
|Analyse conception|AC|PC-AC-001|
|Développement|DV|PC-DV-001|
|Recherche et prototypage|RP|PC-RP-001|
|Tests qualité|TQ|PC-TQ-001|

---

#### DIRECTION

|Service|Code|Exemple|
|---|---|---|
|Direction|DIR|PC-DIR-001|

---

#### DSI

|Service|Code|Exemple|
|---|---|---|
|Département DSI|DSI|PC-DSI-001|
|Administration systèmes et réseaux|ASR|PC-ASR-001|
|Développement intégration|DI|PC-DI-001|
|Exploitation|EXP|PC-EXP-001|
|Support|SUP|PC-SUP-001|

---

#### JURIDIQUE

|Service|Code|Exemple|
|---|---|---|
|Département juridique|JUR|PC-JUR-001|
|Droits des sociétés|DDS|PC-DDS-001|
|Propriété intellectuelle|PI|PC-PI-001|
|Protection des données et conformité|PDC|PC-PDC-001|

---

#### QHSE

|Service|Code|Exemple|
|---|---|---|
|Département QHSE|QHSE|PC-QHSE-001|
|Certification|CER|PC-CER-001|
|Contrôle qualité|CQ|PC-CQ-001|
|Gestion environnementale|GE|PC-GE-001|

---

#### RESSOURCES HUMAINES

|Service|Code|Exemple|
|---|---|---|
|Ressources humaines|RH|PC-RH-001|

---

### Numérotation

La numérotation est séquentielle sur **3 chiffres**.

Exemples :

```
001  
002  
003  
...
```

Exemple de machines :

```
PC-DEV-001  
PC-DEV-002  
PC-DEV-003
```

---

#### Exemples complets

|Machine|Description|
|---|---|
|PC-ADV-001|Poste Administration des ventes|
|PC-ASR-002|Poste Administrateur système|
|PC-RH-001|Poste service RH|
|PC-FIN-003|Poste service finance|
|PC-SUP-001|Poste support IT|
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
`GRP_<TYPE>_<CIBLE>_<ROLE>`

| Élément | Description |
|-------|------------|
| GRP | Groupe Active Directory |
| TYPE | Type de groupe (SEC = sécurité) |
| CIBLE | Service ou ressource |
| ROLE | Fonction du groupe |


#### Exemples 
- GRP_SEC_DEV_USERS
- GRP_SEC_FILE_ACCESS
- GRP_SEC_DSI_ADMINS

---

## 8. Nommage des Unités d'Organisation (OU)

Les Unités d’Organisation (OU) sont structurées par rôle et par service.
Elles servent à l’application des GPO et à l’organisation logique de l’Active Directory.

## 8.1. Convention générale

Convention :
`OU_<TYPE>_<NOM>`

#### Exemples :

- OU_USERS
- OU_COMPUTERS

---

## 9. Nommage des GPO
### 9.1. Convention générale

Convention :
`<ETAT>_<CIBLE>_<ROLE>`

#### Exemples :

- TEST_USERS_SECURITY
- TEST_COMPUTERS_HARDENING
- PROD_USERS_PROXY
- PROD_COMPUTERS_UPDATES

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
