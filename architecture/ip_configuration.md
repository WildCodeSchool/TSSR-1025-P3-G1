# Architecture - Configuration IP

Sommaire : 
1) [Vue d'ensemble du plan d'adressage](#1-vue-densemble-du-plan-dadressage)
2) [Configuration IP par VLAN](#2-configuration-ip-par-vlan)
3) [Configuration IP des équipements réseau](#3-configuration-ip-des-équipements-réseau)
4) [Configuration DHCP](#4-configuration-dhcp)
5) [Configuration DNS](#5-configuration-dns)
6) [Récapitulatif de l'utilisation des adresses](#6-récapitulatif-de-lutilisation-des-adresses)
7) [Documentation des réservations DHCP](#7-documentation-des-réservations-dhcp)
8) [Plan de migration](#8-plan-de-migration)

---  

## 1. Vue d'ensemble du plan d'adressage

### Objectifs du plan d'adressage

- Attribuer des plages IP adaptées à la taille de chaque département
- Anticiper la croissance future de l'entreprise
- Faciliter l'identification des équipements par leur adresse IP
- Optimiser l'utilisation des adresses disponibles

---

## 2. Configuration IP par VLAN

### VLANs Utilisateurs

#### VLAN 10 - Développement logiciel (DEV)

| Paramètre | Valeur |
|-----------|--------|
| **Adresse réseau** | 172.16.1.0/24 |
| **Masque de sous-réseau** | 255.255.255.0 |
| **Nombre d'utilisateurs prévus** | 113 |
| **Adresses disponibles** | 253 |
| **Première adresse utilisable** | 172.16.1.1 |
| **Dernière adresse utilisable** | 172.16.1.253 |
| **Passerelle par défaut** | 172.16.1.254 |
| **Adresse de broadcast** | 172.16.1.255 |
| **Serveur DNS** | 172.16.12.1 |

#### VLAN 20 - Service Commercial (COMMER)

| Paramètre | Valeur |
|-----------|--------|
| **Adresse réseau** | 172.16.2.0/26 |
| **Masque de sous-réseau** | 255.255.255.192 |
| **Nombre d'utilisateurs prévus** | 29 |
| **Adresses disponibles** | 61 |
| **Première adresse utilisable** | 172.16.2.1 |
| **Dernière adresse utilisable** | 172.16.2.61 |
| **Passerelle par défaut** | 172.16.2.62 |
| **Adresse de broadcast** | 172.16.2.63 |
| **Serveur DNS** | 172.16.12.1 |

#### VLAN 30 - Communication et RP (COMMU)

| Paramètre | Valeur |
|-----------|--------|
| **Adresse réseau** | 172.16.3.0/26 |
| **Masque de sous-réseau** | 255.255.255.192 |
| **Nombre d'utilisateurs prévus** | 21 |
| **Adresses disponibles** | 61 |
| **Première adresse utilisable** | 172.16.3.1 |
| **Dernière adresse utilisable** | 172.16.3.61 |
| **Passerelle par défaut** | 172.16.3.62 |
| **Adresse de broadcast** | 172.16.3.63 |
| **Serveur DNS** | 172.16.12.1 |

#### VLAN 40 - Téléphonie IP (VOIP)

| Paramètre | Valeur |
|-----------|--------|
| **Adresse réseau** | 172.16.4.0/24 |
| **Masque de sous-réseau** | 255.255.255.0 |
| **Nombre d'équipements prévus** | 213 |
| **Adresses disponibles** | 253 |
| **Première adresse utilisable** | 172.16.4.1 |
| **Dernière adresse utilisable** | 172.16.4.253 |
| **Passerelle par défaut** | 172.16.4.254 |
| **Adresse de broadcast** | 172.16.4.255 |
| **Serveur DNS** | 172.16.12.1 |

#### VLAN 50 - Département Juridique (JURI)

| Paramètre | Valeur |
|-----------|--------|
| **Adresse réseau** | 172.16.5.0/27 |
| **Masque de sous-réseau** | 255.255.255.224 |
| **Nombre d'utilisateurs prévus** | 16 |
| **Adresses disponibles** | 29 |
| **Première adresse utilisable** | 172.16.5.1 |
| **Dernière adresse utilisable** | 172.16.5.29 |
| **Passerelle par défaut** | 172.16.5.30 |
| **Adresse de broadcast** | 172.16.5.31 |
| **Serveur DNS** | 172.16.12.1 |

#### VLAN 60 - DSI

| Paramètre | Valeur |
|-----------|--------|
| **Adresse réseau** | 172.16.6.0/27 |
| **Masque de sous-réseau** | 255.255.255.224 |
| **Nombre d'utilisateurs prévus** | 12-15 |
| **Adresses disponibles** | 29 |
| **Première adresse utilisable** | 172.16.6.1 |
| **Dernière adresse utilisable** | 172.16.6.29 |
| **Passerelle par défaut** | 172.16.6.30 |
| **Adresse de broadcast** | 172.16.6.31 |
| **Serveur DNS** | 172.16.12.1 |

#### VLAN 70 - Comptabilité et Finance (COMPTA)

| Paramètre | Valeur |
|-----------|--------|
| **Adresse réseau** | 172.16.7.0/27 |
| **Masque de sous-réseau** | 255.255.255.224 |
| **Nombre d'utilisateurs prévus** | 11 |
| **Adresses disponibles** | 29 |
| **Première adresse utilisable** | 172.16.7.1 |
| **Dernière adresse utilisable** | 172.16.7.29 |
| **Passerelle par défaut** | 172.16.7.30 |
| **Adresse de broadcast** | 172.16.7.31 |
| **Serveur DNS** | 172.16.12.1 |

#### VLAN 80 - Direction (DIREC)

| Paramètre | Valeur |
|-----------|--------|
| **Adresse réseau** | 172.16.8.0/28 |
| **Masque de sous-réseau** | 255.255.255.240 |
| **Nombre d'utilisateurs prévus** | 6 |
| **Adresses disponibles** | 13 |
| **Première adresse utilisable** | 172.16.8.1 |
| **Dernière adresse utilisable** | 172.16.8.13 |
| **Passerelle par défaut** | 172.16.8.14 |
| **Adresse de broadcast** | 172.16.8.15 |
| **Serveur DNS** | 172.16.12.1 |

#### VLAN 90 - Services d'impression (IMPRESSION)

| Paramètre | Valeur |
|-----------|--------|
| **Adresse réseau** | 172.16.9.0/28 |
| **Masque de sous-réseau** | 255.255.255.240 |
| **Nombre d'équipements prévus** | 9 |
| **Adresses disponibles** | 13 |
| **Première adresse utilisable** | 172.16.9.1 |
| **Dernière adresse utilisable** | 172.16.9.13 |
| **Passerelle par défaut** | 172.16.9.14 |
| **Adresse de broadcast** | 172.16.9.15 |
| **Serveur DNS** | 172.16.12.1 |

#### VLAN 100 - QHSE

| Paramètre | Valeur |
|-----------|--------|
| **Adresse réseau** | 172.16.10.0/28 |
| **Masque de sous-réseau** | 255.255.255.240 |
| **Nombre d'utilisateurs prévus** | 6 |
| **Adresses disponibles** | 13 |
| **Première adresse utilisable** | 172.16.10.1 |
| **Dernière adresse utilisable** | 172.16.10.13 |
| **Passerelle par défaut** | 172.16.10.14 |
| **Adresse de broadcast** | 172.16.10.15 |
| **Serveur DNS** | 172.16.12.1 |

#### VLAN 110 - Ressources Humaines (RH)

| Paramètre | Valeur |
|-----------|--------|
| **Adresse réseau** | 172.16.11.0/29 |
| **Masque de sous-réseau** | 255.255.255.248 |
| **Nombre d'utilisateurs prévus** | 3 |
| **Adresses disponibles** | 5 |
| **Première adresse utilisable** | 172.16.11.1 |
| **Dernière adresse utilisable** | 172.16.11.5 |
| **Passerelle par défaut** | 172.16.11.6 |
| **Adresse de broadcast** | 172.16.11.7 |
| **Serveur DNS** | 172.16.12.1 |

---

### VLANs Serveurs

#### VLAN 120 - Serveurs Active Directory (SERVEUR-AD)

| Paramètre | Valeur |
|-----------|--------|
| **Adresse réseau** | 172.16.12.0/29 |
| **Masque de sous-réseau** | 255.255.255.248 |
| **Nombre de serveurs prévus** | 3 |
| **Adresses disponibles** | 5 |
| **Première adresse utilisable** | 172.16.12.1 |
| **Dernière adresse utilisable** | 172.16.12.5 |
| **Passerelle par défaut** | 172.16.12.6 |
| **Adresse de broadcast** | 172.16.12.7 |
| **Serveur DNS** | 172.16.12.1 |



#### VLAN 130 - Serveurs (SERVEURS)

| Paramètre | Valeur |
|-----------|--------|
| **Adresse réseau** | 172.16.13.0/29 |
| **Masque de sous-réseau** | 255.255.255.248 |
| **Nombre de serveurs prévus** | 4-5 |
| **Adresses disponibles** | 5 |
| **Première adresse utilisable** | 172.16.13.1 |
| **Dernière adresse utilisable** | 172.16.13.5 |
| **Passerelle par défaut** | 172.16.13.6 |
| **Adresse de broadcast** | 172.16.13.7 |
| **Serveur DNS** | 172.16.12.1 |


---

### VLANs Administration et Invités

#### VLAN 140 - Réseau invité (INVITE)

| Paramètre | Valeur |
|-----------|--------|
| **Adresse réseau** | 172.16.14.0/26 |
| **Masque de sous-réseau** | 255.255.255.192 |
| **Nombre d'invités prévus** | Variable |
| **Adresses disponibles** | 61 |
| **Première adresse utilisable** | 172.16.14.1 |
| **Dernière adresse utilisable** | 172.16.14.61 |
| **Passerelle par défaut** | 172.16.14.62 |
| **Adresse de broadcast** | 172.16.14.63 |
| **Serveur DNS** | DNS publics (8.8.8.8) |

#### VLAN 150 - Administration infrastructure (ADMIN)

| Paramètre | Valeur |
|-----------|--------|
| **Adresse réseau** | 172.16.15.0/26 |
| **Masque de sous-réseau** | 255.255.255.192 |
| **Nombre d'équipements prévus** | Variable |
| **Adresses disponibles** | 61 |
| **Première adresse utilisable** | 172.16.15.1 |
| **Dernière adresse utilisable** | 172.16.15.61 |
| **Passerelle par défaut** | 172.16.15.62 |
| **Adresse de broadcast** | 172.16.15.63 |
| **Serveur DNS** | 172.16.12.1 |

**Affectation des équipements serveurs :**

| Équipement | Interface | Adresse IP Fixe | Masque | Passerelle | 
| --- | --- | --- | --- | --- |
| ADDS | VLAN 120 | 172.16.12.1 | 255.255.255.248 | 172.16.12.6 |
| DHCP | VLAN 120 | 172.16.12.2 | 255.255.255.248 | 172.16.12.6 |
| Serveur | VLAN 130 | 172.16.13.1 | 255.255.255.248 | 172.16.13.6 |


**Affectation des équipements impression :** 

| Équipement | Interface | Département | Adresse IP Fixe | Masque | Passerelle | 
| --- | --- | --- | --- | --- | --- |
| Imprimante | VLAN 90 | DEV |172.16.9.1 | 255.255.255.240 | 172.16.9.14 |
| Imprimante | VLAN 90 | COMMERCIAL |172.16.9.2 | 255.255.255.240 | 172.16.9.14 |
| Imprimante | VLAN 90 | COMMUNICATION |172.16.9.3 | 255.255.255.240 | 172.16.9.14 |
| Imprimante | VLAN 90 | JURIDIQUE |172.16.9.4 | 255.255.255.240 | 172.16.9.14 |
| Imprimante | VLAN 90 | DSI |172.16.9.5 | 255.255.255.240 | 172.16.9.14 |
| Imprimante | VLAN 90 | DIRECTION |172.16.9.6 | 255.255.255.240 | 172.16.9.14 |
| Imprimante | VLAN 90 | COMPTABILITÉ |172.16.9.7 | 255.255.255.240 | 172.16.9.14 |
| Imprimante | VLAN 90 | QHSE |172.16.9.8 | 255.255.255.240 | 172.16.9.14 |
| Imprimante | VLAN 90 | RH |172.16.9.9 | 255.255.255.240 | 172.16.9.14 |

**Affectation des équipements VoIP :** 
| Équipement | Interface | Département | Adresse IP Fixe | Masque | Passerelle | 
| --- | --- | --- | --- | --- | --- |




---

## 3. Configuration IP des équipements réseau

### Équipements d'infrastructure

| Équipement | Interface | VLAN | Adresse IP | Masque | Passerelle |
|------------|-----------|------|------------|--------|------------|
| pfSense1 | WAN | - | IP Publique FAI | - | Box FAI |
| | LAN-DMZ | - | 10.10.10.7 | /29 |  |
| pfSense2 | LAN-DMZ | - | 10.10.10.6 | /29 | |
| | LAN | - | 172.16.0.254 | /24 |   |
| Router Core | Management | 150 | 172.16.15.2 | /26 | 172.16.15.62 |
| | VLAN 10 | 10 | 172.16.1.254 | /24 | - |
| | VLAN 20 | 20 | 172.16.2.62 | /26 | - |
| | VLAN 30 | 30 | 172.16.3.62 | /26 | - |
| | VLAN 40 | 40 | 172.16.4.254 | /24 | - |
| | VLAN 50 | 50 | 172.16.5.30 | /27 | - |
| | VLAN 60 | 60 | 172.16.6.30 | /27 | - |
| | VLAN 70 | 70 | 172.16.7.30 | /27 | - |
| | VLAN 80 | 80 | 172.16.8.14 | /28 | - |
| | VLAN 90 | 90 | 172.16.9.14 | /28 | - |
| | VLAN 100 | 100 | 172.16.10.14 | /28 | - |
| | VLAN 110 | 110 | 172.16.11.6 | /29 | - |
| | VLAN 120 | 120 | 172.16.12.6 | /29 | - |
| | VLAN 130 | 130 | 172.16.13.6 | /29 | - |
| | VLAN 140 | 140 | 172.16.14.62 | /26 | - |
| | VLAN 150 | 150 | 172.16.15.62 | /26 | - |

---

## 4. Configuration DHCP

### Pools DHCP par VLAN

| VLAN | Nom | Plage DHCP | Exclusions |
|------|-----|------------|------------|
| 10 | DEV | 172.16.1.10 - 172.16.1.250 | 172.16.1.1-9 (réservations) |
| 20 | COMMER | 172.16.2.10 - 172.16.2.60 | 172.16.2.1-9 (réservations) |
| 30 | COMMU | 172.16.3.10 - 172.16.3.60 | 172.16.3.1-9 (réservations) |
| 40 | VOIP | 172.16.4.10 - 172.16.4.250 | 172.16.4.1-9 (réservations) |
| 50 | JURI | 172.16.5.10 - 172.16.5.28 | 172.16.5.1-9 (réservations) |
| 60 | DSI | 172.16.6.10 - 172.16.6.28 | 172.16.6.1-9 (réservations) |
| 70 | COMPTA | 172.16.7.10 - 172.16.7.28 | 172.16.7.1-9 (réservations) |
| 80 | DIREC | 172.16.8.5 - 172.16.8.12 | 172.16.8.1-4 (réservations) |
| 90 | IMPRESSION | Adresses statiques uniquement | - |
| 100 | QHSE | 172.16.10.5 - 172.16.10.12 | 172.16.10.1-4 (réservations) |
| 110 | RH | 172.16.11.2 - 172.16.11.4 | 172.16.11.1 (réservation) |
| 140 | INVITE | 172.16.14.10 - 172.16.14.60 | 172.16.14.1-9 (réservé) |


---

## 5. Configuration DNS

### Serveurs DNS



### Zones DNS



### Redirecteurs DNS


---

## 6. Récapitulatif de l'utilisation des adresses

### Statistiques d'utilisation

| Plage | VLANs | Adresses totales | Adresses allouées |
|-------|-------|------------------|-------------------|
| 172.16.1.0/24 | VLAN 10 (DEV) | 254 | 113 utilisateurs | 
| 172.16.2.0/26 | VLAN 20 (COMMER) | 62 | 29 utilisateurs | 
| 172.16.3.0/26 | VLAN 30 (COMMU) | 62 | 21 utilisateurs | 
| 172.16.4.0/24 | VLAN 40 (VOIP) | 254 | 213 téléphones |
| 172.16.5.0/27 | VLAN 50 (JURI) | 30 | 16 utilisateurs | 
| 172.16.6.0/27 | VLAN 60 (DSI) | 30 | 12-15 utilisateurs | 
| 172.16.7.0/27 | VLAN 70 (COMPTA) | 30 | 11 utilisateurs | 
| 172.16.8.0/28 | VLAN 80 (DIREC) | 14 | 6 utilisateurs | 
| 172.16.9.0/28 | VLAN 90 (IMPRESSION) | 14 | 9 imprimantes | 
| 172.16.10.0/28 | VLAN 100 (QHSE) | 14 | 6 utilisateurs |
| 172.16.11.0/29 | VLAN 110 (RH) | 6 | 3 utilisateurs | 
| 172.16.12.0/29 | VLAN 120 (SERVEUR-AD) | 6 | 3 serveurs | 
| 172.16.13.0/29 | VLAN 130 (SERVEURS) | 6 | 4-5 serveurs |
| 172.16.14.0/26 | VLAN 140 (INVITE) | 62 | Variable |
| 172.16.15.0/26 | VLAN 150 (ADMIN) | 62 | ~20 équipements | 


---

## 7. Documentation des réservations DHCP



---

## 8. Plan de migration

### Migration depuis l'ancienne infrastructure






