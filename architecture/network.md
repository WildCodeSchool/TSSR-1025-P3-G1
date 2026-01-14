# Architecture - Réseau

## 1. Vue d'ensemble du réseau

### Contexte actuel

**Infrastructure existante :**
- Réseau wifi domestique (box FAI + répéteurs)
- Plage IP actuelle : 172.16.10.0/24
- Aucune segmentation réseau
- Aucun équipement réseau professionnel

**Nouvelle infrastructure :**
- Réseau segmenté par VLANs (départements/services)
- Plage réseau globale : 172.16.0.0/22
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
| 1        | *Supprimé* | Sécurité | Non utilisé  |
| 10       | VLAN-DEV | Utilisateurs | Développement logiciel |
| 20       | VLAN-COMMERCIAL | Utilisateurs | Service Commercial | 
| 30       | VLAN-COMMUNICATION | Utilisateurs | Communication et RP | 
| 40       | VLAN-VOIP | Fonctionnel | Téléphonie IP |  
| 50       | VLAN-JURIDIQUE | Utilisateurs | Département Juridique | 
| 60       | VLAN-DSI | Utilisateurs | DSI | 
| 70       | VLAN-COMPTA | Utilisateurs | Comptabilité et Finance | 
| 80       | VLAN-DIRECTION | Utilisateurs | Direction | 
| 90       | VLAN-IMPRESSION | Fonctionnel | Services d'impression |
| 99       | VLAN-ADMIN | Infrastructure | Administration infrastructure | 
| 100      | VLAN-QHSE | Utilisateurs | Département QHSE |
| 110      | VLAN-RH | Utilisateurs | Ressources Humaines | 

### Zone Serveurs - VLANs Production

| VLAN ID  | Nom du VLAN | Usage |
|----------|-------------|-------|
| 200      | VLAN-SERVEURS | Serveurs principaux (AD, DNS, DHCP)| 
| 210      | VLAN-FICHIERS | Serveur de fichiers| 
| 220      | VLAN-MESSAGERIE | Serveur de messagerie| 
| 230      | VLAN-GLPI | Serveur GLPI (ticketing)| 

### Zone Serveurs - VLANs Backup

| VLAN ID  | Nom du VLAN | Usage |
|----------|-------------|-------|
| 300      | VLAN-BKP-SERVEURS | Backup serveurs principaux | 
| 310      | VLAN-BKP-FICHIERS | Backup serveur fichiers| 
| 320      | VLAN-BKP-MESSAGERIE | Backup messagerie| 
| 330      | VLAN-BKP-GLPI | Backup GLPI| 

### Zone Invités

| VLAN ID  | Nom du VLAN | Usage |
|----------|-------------|-------|
| 400      | VLAN-INVITE | Réseau invité isolé | 

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

#### VLAN 99 - Administration infrastructure
- **Fonction :** Gestion des équipements réseau et serveurs
- **Usage :** Interfaces d'administration (switches, firewalls, hyperviseurs)

#### VLAN 100 - QHSE
- **Utilisateurs :** Équipe qualité (3 services)
- **Usage :** Documentation qualité et certifications

#### VLAN 110 - Ressources Humaines
- **Utilisateurs :** Service RH et recrutement
- **Usage :** SIRH et gestion des données personnelles

### VLANs Serveurs - Production (200-230)

#### VLAN 200 - Serveurs principaux
- **Fonction :** Services d'annuaire et réseau de base
- **Usage :** Active Directory, DNS, DHCP

#### VLAN 210 - Serveur de fichiers
- **Fonction :** Stockage centralisé
- **Usage :** Partages de fichiers départementaux

#### VLAN 220 - Serveur de messagerie
- **Fonction :** Messagerie interne
- **Usage :** Service de mail d'entreprise

#### VLAN 230 - Serveur GLPI
- **Fonction :** Gestion des incidents et assets IT
- **Usage :** Ticketing et inventaire

### VLANs Serveurs - Backup (300-330)

#### VLAN 300 à 330 - Zone de sauvegarde
- **Fonction :** Infrastructure de backup
- **Usage :** Réplication et sauvegarde des serveurs de production

### VLAN Invité (400)

#### VLAN 400 - Réseau invité
- **Fonction :** Accès internet pour visiteurs
- **Usage :** Connexion temporaire invités et partenaires

---  

## 4. Flux principaux entre zones

### Principes de communication

**Architecture générale :**
- Les VLANs utilisateurs communiquent avec les VLANs serveurs selon leurs besoins métier
- La DSI dispose d'accès complets pour l'administration
- Les VLANs backup sont isolés (accès admin uniquement)
- Le VLAN invité est complètement isolé du réseau interne

### Matrice de flux simplifiée

| Source | Destination | Type de flux | Règle |
|--------|-------------|--------------|-------|
| VLANs utilisateurs | VLAN Serveurs (200-230) | Services métier (AD, fichiers, mail, GLPI) | Autorisé |
| VLANs utilisateurs | VLAN Impression | Services d'impression | Autorisé |
| VLANs utilisateurs | Internet | Navigation et services cloud | Autorisé |
| VLAN DSI | VLAN Admin | Administration infrastructure | Autorisé |
| VLAN DSI | Tous VLANs | Support et administration | Autorisé |
| VLANs Serveurs production | VLANs Backup | Réplication et sauvegarde | Autorisé |
| VLAN Invité | Internet | Navigation web | Autorisé |
| VLAN Invité | VLANs internes | Tous | **Interdit** |
| VLANs utilisateurs | VLANs backup | Tous | **Interdit** |
| VLANs utilisateurs | VLAN Admin | Administration | **Interdit** (sauf DSI) |


---  

## 5. Schéma réseau logique

![Schéma réseau logique]()


---  

## 6. Principes de routage et filtrage

### Routage inter-VLANs

**Approche retenue :**
- Routage sur switch L3 core


**Architecture de routage :**
- Switch L3 core assure le routage entre tous les VLANs internes
- Séparation logique entre zones (utilisateurs / serveurs / backup / invités)
- Firewall périmétrique pour la sortie internet et filtrage externe

### Passerelle Internet

**Configuration générale :**
- Firewall périmétrique pour la sortie internet (ou routeur dédié)
- NAT pour tous les VLANs (masquage d'adresses internes)
- Filtrage des flux entrants/sortants vers internet
- Connexion entre switch L3 core et firewall/box internet

---  

## 7. Adressage réseau

**Remarque :** Les détails complets de l'adressage IP se trouvent dans le fichier [ip_configuration.md](ip_configuration.md)

### Plan d'adressage global

- **Plage globale retenue :** 172.16.0.0/22 (1024 adresses disponibles)
- **Répartition :** Un sous-réseau par VLAN, dimensionné selon les besoins
- **Réserves :** Anticipation de la croissance et du partenariat futur

### Principes de découpage

- VLANs utilisateurs : dimensionnés selon effectifs départementaux
- VLAN VoIP : dimensionnement large, tous les utilisateurs de l'entreprise
- VLANs serveurs : sous-réseaux de petite taille
- VLANs backup : sous-réseaux de petite taille

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
- Zone backup isolée (pas d'accès utilisateurs)
- VLAN invité totalement séparé du réseau interne

**Contrôle d'accès :**
- Filtrage inter-VLANs par ACL
- VLAN Admin accessible uniquement par la DSI
- Principe du moindre privilège (flux autorisés au strict nécessaire)

**Protection infrastructure :**
- VLAN Administration dédié (99) pour la gestion
- VLANs backup non accessibles directement

