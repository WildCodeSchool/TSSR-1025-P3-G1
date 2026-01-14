# Architecture - Périmètre du projet

## Sommaire
1) [Eléments inclus dans le projet](#1-eléments-inclus-dans-le-projet)
2) [Elements hors scope](#2-elements-hors-scope)
3) [Périmètre réseau couvert](#3-périmètre-réseau-couvert)
4) [Périmètre temporel](#4-périmètre-temporel-par-sprint)
5) [Hypothèses de responsabilité](#5-hypothèses-de-responsabilité)

---  


## 1. Eléments inclus dans le projet

### 1.1 Infrastructure réseau
- Mise en place d'une architecture réseau segmentée (LAN, VLANs)
- Déploiement de matériels réseau professionnels (routeurs, switchs, points d'accès WiFi)
- Configuration d'un plan d'adressage IP cohérent et évolutif
- Remplacement de la box FAI et des répéteurs WiFi actuels

### 1.2 Services d'infrastructure
- Déploiement d'un domaine Active Directory (AD DS)
- Mise en place de services DNS et DHCP
- Création d'une structure organisationnelle (OU) reflétant les 9 départements
- Gestion centralisée des identités et des accès
- Mise en place de GPO (Group Policy Objects)

### 1.3 Gestion des utilisateurs et des équipements
- Intégration des 217 collaborateurs dans l'Active Directory
- Migration des 100% PC portables vers le domaine
- Création de groupes de sécurité par département et service
- Mise en place d'une nomenclature standardisée (utilisateurs, ordinateurs, groupes, OU, GPO)

### 1.4 Sécurité
- Mise en place d'une politique de sécurité d'identité
- Remplacement du système de mots de passe locaux
- Contrôle d'accès centralisé via Active Directory
- Segmentation réseau pour isoler les flux

### 1.5 Stockage et sauvegarde
- Refonte de l'architecture de stockage de données
- Mise en place d'une solution de sauvegarde professionnelle avec politique de rétention
- Remplacement du NAS grand public actuel

### 1.6 Documentation
- Documentation d'Architecture Technique (DAT)
- Documentation High Level Design (HLD)
- Documentation Low Level Design (LLD)
- Documentation d'Exploitation (DEX)
- Suivi chronologique par sprint

---  

## 2. Elements hors scope


---  

## 3. Périmètre réseau couvert

### 3.1 Périmètre géographique
- **Site unique** : Paris, 20ᵉ arrondissement
- **Nombre d'utilisateurs** : 217 collaborateurs
- **Nombre de départements** : 9 départements stratégiques

### 3.2 Périmètre technique
- Réseau actuel : 172.16.10.0/24
- Transition du modèle workgroup vers domaine Active Directory
- Migration des accès NAS limités vers une solution centralisée

---  

## 4. Périmètre temporel (par sprint)

### 4.1 Sprint 1
- Conception de l'architecture réseau globale (HLD)
- Définition du plan d'adressage IP
- Création de la nomenclature (domaine, OU, groupes, utilisateurs, ordinateurs, GPO)
- Planification de l'infrastructure serveurs/clients
- Documentation DAT et HLD

### 4.2 Sprint 2
- 
- 
- 
- 
- 

---  

## 5. Hypothèses de responsabilité


