# Architecture - Réseau

Sommaire :  
1) [Vue d'ensemble du réseau](#1-vue-densemble-du-réseau)  
2) [Découpage en zones réseau](#2-découpage-en-zones-réseau)  
3) [Rôle de chaque VLAN](#3-rôle-de-chaque-vlan)  
4) [Flux principaux entre zones](#4-flux-principaux-entre-zones)  
5) [Schéma réseau logique](#5-schéma-réseau-logique)  
6) [Principes de routage et filtrage](#6-principes-de-routage-et-filtrage)  
7) [Adressage réseau](#7-adressage-réseau)  
8) [Équipements réseau](#8-équipements-réseau)  
9) [Sécurité réseau](#9-sécurité-réseau)

---  

## 1. Vue d'ensemble du réseau

### Contexte actuel

**Infrastructure existante :**
- Réseau wifi domestique (box FAI + répéteurs)
- Plage IP actuelle : 172.16.10.0/24
- Aucune segmentation réseau
- Aucun équipement réseau professionnel

**Nouvelle infrastructure :**
- Réseau segmenté par VLANs (départements/services)
- Équipements réseau professionnels
- Architecture évolutive

### Objectifs réseau

- Segmenter le réseau pour améliorer la sécurité
- Isoler les différents départements et services
- Faciliter l'administration et la supervision
- Préparer l'infrastructure à l'évolution et au partenariat futur

---  

## 2. Découpage en zones réseau

### Zone LAN - VLANs Utilisateurs

Segmentation du réseau par département pour améliorer la sécurité et faciliter l'administration.

| VLAN ID  | Nom du VLAN | Catégorie | Usage |
|----------|-------------|-----------|-------|
| 1        | *Supprimé* | - | Non utilisé  |
| 10       | VLAN-DEV | Utilisateurs | Développement logiciel |
| 20       | VLAN-COMMER | Utilisateurs | Service Commercial | 
| 30       | VLAN-COMMU | Utilisateurs | Communication et RP | 
| 40       | VLAN-VOIP | Fonctionnel | Téléphonie IP |  
| 50       | VLAN-JURI | Utilisateurs | Département Juridique | 
| 60       | VLAN-DSI | Utilisateurs | DSI | 
| 70       | VLAN-COMPTA | Utilisateurs | Comptabilité et Finance | 
| 80       | VLAN-DIREC | Utilisateurs | Direction | 
| 90       | VLAN-IMPRESSION | Fonctionnel | Services d'impression |
| 100      | VLAN-QHSE | Utilisateurs | Département QHSE |
| 110      | VLAN-RH | Utilisateurs | Ressources Humaines | 

### Zone Serveurs - VLANs Production

| VLAN ID  | Nom du VLAN | Usage |
|----------|-------------|-------|
| 120      | VLAN-SERVEUR-AD | Serveurs Active Directory (AD, DNS, DHCP)| 
| 130      | VLAN-SERVEURS | Serveurs messagerie, fichiers, GLPI, BDD| 

### Zone Administration et Invités

| VLAN ID  | Nom du VLAN | Usage |
|----------|-------------|-------|
| 140      | VLAN-INVITE | Réseau invité isolé | 
| 150      | VLAN-ADMIN | Administration infrastructure | 

---  

## 3. Rôle de chaque VLAN

### VLANs Utilisateurs (10-110)

#### VLAN 10 - Développement logiciel
- **Utilisateurs :** Équipes de développement (4 services)
- **Usage :** Accès aux environnements de développement et outils de collaboration

#### VLAN 20 - Service Commercial
- **Utilisateurs :** Équipes commerciales (4 services)
- **Usage :** Accès CRM et outils métier de vente

#### VLAN 30 - Communication et RP
- **Utilisateurs :** Équipes communication (3 services)
- **Usage :** Outils marketing et gestion de contenu

#### VLAN 40 - VoIP
- **Fonction :** Téléphonie IP d'entreprise
- **Usage :** Téléphones IP de tous les collaborateurs

#### VLAN 50 - Département Juridique
- **Utilisateurs :** Équipe juridique (3 services)
- **Usage :** Gestion documentaire juridique et conformité

#### VLAN 60 - DSI
- **Utilisateurs :** Équipe informatique (4 services)
- **Usage :** Administration et support de l'infrastructure

#### VLAN 70 - Comptabilité et Finance
- **Utilisateurs :** Équipe finance et comptabilité (3 services)
- **Usage :** Logiciels financiers et comptables

#### VLAN 80 - Direction
- **Utilisateurs :** Direction générale
- **Usage :** Accès à l'ensemble des ressources métier

#### VLAN 90 - Services d'impression
- **Fonction :** Imprimantes et copieurs réseau
- **Usage :** Impression départementale

#### VLAN 100 - QHSE
- **Utilisateurs :** Équipe qualité (3 services)
- **Usage :** Documentation qualité et certifications

#### VLAN 110 - Ressources Humaines
- **Utilisateurs :** Service RH et recrutement
- **Usage :** SIRH et gestion des données personnelles

### VLANs Serveurs - Production (120-130)

#### VLAN 120 - Serveurs Active Directory
- **Fonction :** Services d'annuaire et réseau de base
- **Usage :** Active Directory, DNS, DHCP

#### VLAN 130 - Serveurs métier
- **Fonction :** Services applicatifs et stockage
- **Usage :** Messagerie, fichiers, GLPI, bases de données

### VLANs Administration et Invités (140-150)

#### VLAN 140 - Réseau invité
- **Fonction :** Accès internet pour visiteurs
- **Usage :** Connexion temporaire invités et partenaires

#### VLAN 150 - Administration infrastructure
- **Fonction :** Gestion des équipements réseau et serveurs
- **Usage :** Interfaces d'administration (switches, firewalls, hyperviseurs)

---  

## 4. Flux principaux entre zones

### Principes de communication

**Architecture générale :**
- Les VLANs utilisateurs communiquent avec les VLANs serveurs selon leurs besoins métier
- La DSI dispose d'accès complets pour l'administration
- Le VLAN invité est complètement isolé du réseau interne

### Matrice de flux simplifiée

| Source | Destination | Type de flux | Règle |
|--------|-------------|--------------|-------|
| VLANs utilisateurs | VLAN Serveurs (120-130) | Services métier (AD, fichiers, mail, GLPI) | Autorisé |
| VLANs utilisateurs | VLAN Impression | Services d'impression | Autorisé |
| VLANs utilisateurs | Internet | Navigation et services cloud | Autorisé |
| VLAN DSI | VLAN Admin | Administration infrastructure | Autorisé |
| VLAN DSI | Tous VLANs | Support et administration | Autorisé |
| VLAN Invité | Internet | Navigation web | Autorisé |
| VLAN Invité | VLANs internes | Tous | **Interdit** |
| VLANs utilisateurs | VLAN Admin | Administration | **Interdit** (sauf DSI) |


---  

## 5. Schéma réseau logique

![image infra](ressources/topology.png)


---  

## 6. Principes de routage et filtrage

### Routage inter-VLANs

**Approche retenue :**
- Routage sur routeur core


**Architecture de routage :**
- Routeur core assure le routage entre tous les VLANs internes
- Séparation logique entre zones (utilisateurs / serveurs / invités)
- Firewall périmétrique pour la sortie internet et filtrage externe

### Passerelle Internet

**Configuration générale :**
- Firewall périmétrique pour la sortie internet 
- NAT pour tous les VLANs
- Filtrage des flux entrants/sortants vers internet
- Connexion entre le Routeur Core et firewall/box internet

---  

## 7. Adressage réseau

**Remarque :** Les détails complets de l'adressage IP se trouvent dans le fichier [ip_configuration.md](ip_configuration.md)

### Plan d'adressage global

- **Répartition :** Un sous-réseau par VLAN, dimensionné selon les besoins
- **Réserves :** Anticipation de la croissance et du partenariat futur

### Principes de découpage

- VLANs utilisateurs : dimensionnés selon effectifs départementaux
- VLAN VoIP : dimensionnement large, tous les utilisateurs de l'entreprise
- VLANs serveurs : sous-réseaux de petite taille

---  

## 8. Équipements réseau

### Architecture matérielle

**Équipements principaux nécessaires :**
- Firewall périmétrique (routeur) : sécurité internet, NAT
- Switch cœur de réseau (L3) : routage inter-VLANs, distribution, agrégation
- Switches d'accès (L2 manageables) : connexion postes utilisateurs, segmentation VLANs
- Points d'accès WiFi : couverture wifi sécurisée

**Rôle de chaque niveau :**
- **Firewall/Routeur périmétrique** : filtrage internet, NAT, première barrière de sécurité
- **Switch L3 core** : routage inter-VLANs (cœur de l'architecture réseau interne)
- **Switches L2 access** : distribution VLANs aux postes utilisateurs

---  

## 9. Sécurité réseau

### Principes de sécurité appliqués

**Segmentation :**
- Isolation stricte par VLANs départementaux
- VLAN 1 désactivé 
- VLAN invité totalement séparé du réseau interne

**Contrôle d'accès :**
- Filtrage inter-VLANs par ACL
- VLAN Admin accessible uniquement par la DSI
- Principe du moindre privilège (flux autorisés au strict nécessaire)

**Protection infrastructure :**
- VLAN Administration dédié (150) pour la gestion

