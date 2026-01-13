# Projet 3 – Construction d’une infrastructure réseau  

## Société : BillU

## Sommaire

1. [Présentation du projet](#1-présentation-du-projet)

---

## 1. Objectif du document

Ce document définit l'ensemble des **règles de nomage** utilisées dans la cadre du projet d'infrastructure réseau de la société **BillU**.

Ces conventions s'appliquent :
- Aux éléments existants
- Aux éléments créés durant le projet
- Aux futures évolutions de l'infrasctructure

Toute ressource ne respectant pas ces règles est considérée comme **non conforme**.

---

## 2. Principes généraux de nomages

Les règles suivantes s'appliquent à **tous les éléments** :

- Noms en .....
- Pas d'espaces
- Pas d'accents
- Séparation par des ......
- Nom explicite et non ambigu
- Longueur raisonnable

---

## 3. Nomage des sites

| Éléments | Convention | Exemple |
|-------|----------|--------|
| Sites principal | `SITES-<VILLES>` | `SITE-PARIS` |

---

## 4. Nomage des serveurs
### 4.1. Convention générale
| Éléments | Description |
|-------|----------|
| SRV | Machine serveur |
| ROLE | Rôle principal |
| ID | Numéro unique |

#### Exemples 
- `SRV-AD-01`
-
-

### 4.2. Serveurs du projet
| Nom | Rôle |
|-------|----------|
| SRV-AD-01 | Controle de domaine |
| SRV-AD-01 | Controle de domaine |
| SRV-AD-01 | Controle de domaine |
| SRV-AD-01 | Controle de domaine |

---

## 5. Nomage des postes clients
### 5.1. Convention générale
| Éléments | Description |
|-------|----------|
| PC | Poste client |
| SERVICE | Département |
| ID | Numéro unique |

#### Exemples 
- `PC-DEV-01`
-
-

### 5.2. Poste clients du projet
| Nom | Service |
|-------|----------|
| PC-DEV-01 | Developpement |
| PC-DEV-01 | Developpement |
| PC-DEV-01 | Developpement |

---

## 6. Nomage des utilisateurs Active Directory
### 6.1 Convention générale
#### 6.1.1. Comptes utilisateurs standards

`prenom.nom`

chiffre si plusieurs ? quoi quoi ou quoi ?
##### Exemples 
- `matthias.chicaud`
-
-

#### 6.1.2. Comptes administrateur

`admin.prenom.nom`

##### Exemples
- `admin.matthias.chicaud`

### 6.2. Comptes utilisateurs
| Type | Nom |
|-------|----------|
| Utilisateur | matthias.chicaud |
| Administrateur | admin.matthias.chicaud |
---

## 7. Nomage des groupes Active Directory
### 7.1. Convention générale

`NOM-DE-GROUPE-AD`

| Éléments | Description |
|-------|----------|
| TYPE | Poste client |
| CIBLE | Service ou ressources |
| TRUC | JENECPA |

#### Exemples 
- `NOM-DE-GROUPE-AD`
-
-

---

## 8. Nomage des Unité d'Organisation (OU)
### 8.1. Convention générale

COMME CE QUE NOUS A MONTRER DOMINIQUE ?

---

## 9. Nomage des GPO
### 9.1. Convention générale

COMME CE QUE NOUS A MONTRER DOMINIQUE ?

---

## 10. Nomage réseau
### 10.1. VLAN

`VLAN<ID>-<NOM>`

#### Exemples
- `VLAN10-ADMIN`
-
-

---