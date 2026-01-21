1. [Structure organisationnelle (OU)](#1-structure-organisationnelle-ou) 
	- [1.1 Arborescence des OU](#11-arborescence-des-ou) 
		- [1.1.1 Arborescence des sous- OU de BilluComputers](#111-arborescence-des-sous-ou-de-billucomputers) 
		-  [1.1.2 Arborescence des sous- OU de BilluUsers](#112-arborescence-des-sous-ou-de-billuusers)
	- [1.2 Création des OU](#12-creation-des-ou) 
	- [1.3 Création des sous-OU](#13-creation-des-sous-ou) 
		- [1.3.1 Création des sous-OU-BilluComputers](#131-creation-des-sous-ou-billucomputers)
		- [1.3.2 Création des sous-OU-BilluUsers](#132-creation-des-sous-ou-billuusers)

2. [Création des utilisateurs](#2-creation-des-utilisateurs)
	- [2.1 Utilisateurs administrateurs](#21-utilisateurs-administrateurs) 
	- [2.2 Utilisateurs par service](#22-utilisateurs-par-service) 
3. [Création des groupes](#3-creation-des-groupes) 
	- [3.1 Groupes de sécurité](#31-groupes-de-securite) 
	- [3.2 Groupes de distribution](#32-groupes-de-distribution) 
4. [Stratégies de groupe (GPO)](#4-strategies-de-groupe-gpo)
	- [4.1 GPO de sécurité](#41-gpo-de-securite) 
		- [4.11 GPO]()
		- [4.12 GPO]()
		- [4.13 GPO]()
		- [4.14 GPO]()
		- [4.15 GPO]()
		- [4.16 GPO]()
		- [4.17 GPO]()
	- [4.2 GPO standard](#42-gpo-standard)
		- [4.21 GPO]()
		- [4.22 GPO]()
		- [4.23 GPO]()
5. [Délégation d'administration](#5-delegation-dadministration) 
6. [Tests et validation](#6-tests-et-validation)

## 1. Structure organisationnelle (OU)

L'arborescence des Unités d'Organisation (OU) du domaine billu.lan a été conçue selon une approche fonctionnelle. La structure repose sur trois **OU** principales permettant une séparation claire des objets Active Directory par type et fonction.
#### 1.1 Arborescence des OU

| OU | Chemin DN | Objets contenus |
|---|---|---|
| **BilluComputers** | OU=BilluComputers,DC=billu,DC=lan | Comptes ordinateurs (workstations, laptops, serveurs membres) |
| **BilluUsers** | OU=BilluUsers,DC=billu,DC=lan | Comptes utilisateurs (tous services confondus) |
| **BilluSecurity** | OU=BilluSecurity,DC=billu,DC=lan | Groupes de sécurité, groupes de distribution, comptes de service |

#### 1.1.1 Arborescense des sous-OU de BilluComputers

| Sous-OU | Chemin DN | Service |
|---------|-----------|---------|
| **DEV** | OU=DEV,OU=BilluComputers,DC=billu,DC=lan | Développement |
| **COMMERCIAL** | OU=COMMERCIAL,OU=BilluComputers,DC=billu,DC=lan | Commercial |
| **COMMUNICATION** | OU=COMMUNICATION,OU=BilluComputers,DC=billu,DC=lan | Communication |
| **JURIDIQUE** | OU=JURIDIQUE,OU=BilluComputers,DC=billu,DC=lan | Juridique |
| **DIRECTION** | OU=DIRECTION,OU=BilluComputers,DC=billu,DC=lan | Direction |
| **COMPTABILITE** | OU=COMPTABILITE,OU=BilluComputers,DC=billu,DC=lan | Comptabilité |
| **QHSE** | OU=QHSE,OU=BilluComputers,DC=billu,DC=lan | Qualité Hygiène Sécurité Environnement |
| **RH** | OU=RH,OU=BilluComputers,DC=billu,DC=lan | Ressources Humaines |
| **DSI** | OU=DSI,OU=BilluComputers,DC=billu,DC=lan | Direction des Systèmes d'Information |

#### 1.1.2 Arborescence des sous-OU de BilluUsers

| Sous-OU           | Chemin DN                                      | Service                                |
| ----------------- | ---------------------------------------------- | -------------------------------------- |
| **DEV**           | OU=DEV,OU=BilluUsers,DC=billu,DC=lan           | Développement                          |
| **COMMERCIAL**    | OU=COMMERCIAL,OU=BilluUsers,DC=billu,DC=lan    | Commercial                             |
| **COMMUNICATION** | OU=COMMUNICATION,OU=BilluUsers,DC=billu,DC=lan | Communication                          |
| **JURIDIQUE**     | OU=JURIDIQUE,OU=BilluUsers,DC=billu,DC=lan     | Juridique                              |
| **DIRECTION**     | OU=DIRECTION,OU=BilluUsers,DC=billu,DC=lan     | Direction                              |
| **COMPTABILITE**  | OU=COMPTABILITE,OU=BilluUsers,DC=billu,DC=lan  | Comptabilité                           |
| **QHSE**          | OU=QHSE,OU=BilluUsers,DC=billu,DC=lan          | Qualité Hygiène Sécurité Environnement |
| **RH**            | OU=RH,OU=BilluUsers,DC=billu,DC=lan            | Ressources Humaines                    |
| **DSI**           | OU=DSI,OU=BilluUsers,DC=billu,DC=lan           | Direction des Systèmes d'Information   |

### 1.2 Création des OU

Dans le Server Manager ==> Dashboard :
- Cliquer sur **"Tools"** et **"Active Directory Users and Computers"**

![[Ressources/Screenshots-Installation/01_creation_ou.png]]


- Dans le volet de gauche , clic droit sur **"billu.lan"**
- Sélectionner **"New"** ==> **"Organizational Unit"**

![[02_creation_ou.png]]

Dans la fênetre qui s'ouvre :
- Case **"Name"** : **"BilluComputers"**
- Cocher **"Protect container from accidental deletion"**
- Cliquer sur **"OK"**

![[03_creation_ou.png]]

**"OU"** BilluComputers à été créé.

Même procédure pour les autres **"OU"**
- Case **"Name"** : **"BilluUsers"**
- Case **"Name"** : **"BilluSecurity"**

![[04_creation_ou.png]]
Voila nos **"OU"** de créés dans la forêt de **"billu.lan"**.

#### 1.3 Création des sous-OU
#### 1.3.1 Création des sous-OU de BilluComputers

- Dans le volet de gauche , clic droit sur **"billuComputers"**
- Sélectionner **"New"** ==> **"Organizational Unit"**

![[01-sous_ou_billucomputers.png]]

Dans la fênetre qui s'ouvre :
- Case **"Name"** : **"DEV"**
- Cocher **"Protect container from accidental deletion"**
- Cliquer sur **"OK"**

![[2-sous_ou_billucomputers.png]]
La **"SOUS-OU"** **"DEV"** a été créé dans **"OU"** BilluComputers.

Même procédure pour les autres **"SOUS-OU"**
- Case **"Name"** : **"COMMERCIAL"**
- Case **"Name"** : **"COMMUNICATION"**
- Case **"Name"** : **"JURIDIQUE"**
-  Case **"Name"** : **"DIRECTION"**
-  Case **"Name"** : **"COMPTABILITE"**
-  Case **"Name"** : **"QHSE"**
-  Case **"Name"** : **"RH"**
-  Case **"Name"** : **"DSI"**

![[03-sous_ou_billucomputers.png]]
Voilà nos **"SOUS-OU"** de créés dans **"OU"** **"BilluComputers"**.

#### 1.3.2 Création des sous-OU de BilluUsers

- Dans le volet de gauche , clic droit sur **"billuUsers"**
- Sélectionner **"New"** ==> **"Organizational Unit"**

![[01-sous_ou_billuUsers.png]]

Dans la fênetre qui s'ouvre :
- Case **"Name"** : **"COMMERCIAL"**
- Cocher **"Protect container from accidental deletion"**
- Cliquer sur **"OK"**

![[02-sous_ou_billuUsers.png]]
La **"SOUS-OU"** **"COMMERCIAL"** a été créé dans **"OU"** BilluUsers.

Même procédure pour les autres **"SOUS-OU"**
-  Case **"Name"** : **"COMMUNICATION"**
-  Case **"Name"** : **"COMPTABILITE"**
-  Case **"Name"** : **"DEV"**
-  Case **"Name"** : **"DIRECTION"**
-  Case **"Name"** : **"DSI"**
-  Case **"Name"** : **"JURIDIQUE"**
-  Case **"Name"** : **"QHSE"**
-  Case **"Name"** : **"RH"**

![[03-sous_ou_billuUsers.png]]
Voilà nos **"SOUS-OU"** de créés dans **"OU"** **"BilluUsers"**.

---
## 2. Création des utilisateurs

#### 2.1 Utilisateurs administrateurs

#### 2.2 Utilisateurs par service

---
## 3. Création des groupes

#### 3.1 Groupes de sécurité

#### 3.2 Groupes de distributions

---
## 4. Stratégies de groupe (GPO)

#### 4.1 GPO de sécurité

#### 4.2 GPO standard

---
## 5. Délégation d'administration

---
## 6. Test et validation

---
