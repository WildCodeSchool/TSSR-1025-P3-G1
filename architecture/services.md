# Infrastructure - Services

Sommaire :  
1) [Introduction](#1-introduction)  
2) [Liste des services déployés](#2-liste-des-services-déployés)  
    - [Active Directory Domain Services](#21-active-directory-domain-services-ad-ds)  
    - [Domain Name System](#22-domain-name-system-dns)  
    - [Dynamic Host Configuration Protocol](#23-dynamic-host-configuration-protocol-dhcp)  
    - [Serveur de fichiers](#24-serveur-de-fichiers)  
    - [Group Policy Management](#25-group-policy-management-gpo)  
    - [Windows Server Update Services](#26-windows-server-update-services-wsus)  
3) [Ordre logique de mise en place](#3-ordre-logique-de-mise-en-place)

---  

## 1. Introduction

Ce document présente la vue globale des services qui seront déployés dans l'infrastructure de BillU. Il décrit le rôle de chaque service, leurs interdépendances et leur ordre logique de mise en place.

## 2. Liste des services déployés

### 2.1. Active Directory Domain Services (AD DS)

**Rôle :**
- Service d'annuaire centralisé pour la gestion des identités et des accès
- Authentification unique (SSO) pour tous les utilisateurs
- Gestion centralisée des ressources réseau (utilisateurs, ordinateurs, groupes)

**Interdépendances :**
- Dépend de : DNS, réseau VLAN configuré
- Prérequis pour : tous les autres services d'infrastructure

**Exposition :**
- Interne uniquement (LAN)
- Pas d'exposition externe directe


---

### 2.2. Domain Name System (DNS)

**Rôle :**
- Résolution de noms de domaine en adresses IP
- Gestion de la zone DNS interne 
- Support pour les enregistrements AD DS (SRV, A, PTR)

**Interdépendances :**
- Dépend de : réseau IP fonctionnel
- Requis par : AD DS, tous les services réseau

**Exposition :**
- Interne (DNS interne)

---

### 2.3. Dynamic Host Configuration Protocol (DHCP)

**Rôle :**
- Attribution automatique des adresses IP aux postes clients
- Distribution des configurations réseau (passerelle, DNS, masque)
- Gestion centralisée du plan d'adressage

**Interdépendances :**
- Dépend de : DNS, AD DS
- Utilisé par : tous les postes clients

**Exposition :**
- Interne uniquement


---

### 2.4. Serveur de fichiers

**Rôle :**
- Stockage centralisé des données d'entreprise
- Remplacement du NAS grand public actuel
- Gestion des partages réseau avec contrôle d'accès basé sur AD

**Interdépendances :**
- Dépend de : AD DS, DNS
- Utilisé par : tous les départements selon les droits

**Exposition :**
- Interne uniquement (LAN)
- Accès via SMB/CIFS


---

### 2.5. Group Policy Management (GPO)

**Rôle :**
- Configuration centralisée des postes clients et serveurs
- Déploiement de stratégies de sécurité
- Automatisation des configurations utilisateurs et ordinateurs

**Interdépendances :**
- Dépend de : AD DS
- Appliqué à : tous les objets du domaine

**Exposition :**
- Interne uniquement (intégré à AD DS)


---

### 2.6. Windows Server Update Services (WSUS)

**Rôle :**
- Gestion centralisée des mises à jour Windows
- Contrôle et planification des déploiements de correctifs

**Interdépendances :**
- Dépend de : AD DS, GPO
- Sert : tous les postes Windows du domaine

**Exposition :**
- Interne uniquement
- Connexion Internet sortante pour télécharger les MAJ


---

## 3. Ordre logique de mise en place

L'ordre de déploiement suivant respecte les dépendances techniques entre services :

### Phase 1 - Infrastructure réseau de base
1. **Configuration réseau** (VLANs, routage, pare-feu)
2. **DNS** - premier service critique
3. **AD DS** - domaine et contrôleurs de domaine
4. **DHCP** - automatisation réseau

### Phase 2 - Services de gestion
5. **GPO** - création des stratégies de base
6. **WSUS** - gestion des mises à jour
7. **Serveur de fichiers** - migration depuis le NAS

### Phase 3 - Services additionnels
8. **Sauvegarde** - protection des données
9. **Serveur d'impression** - gestion des imprimantes
10. **Services optionnels** (RDS, VPN) - selon planification

