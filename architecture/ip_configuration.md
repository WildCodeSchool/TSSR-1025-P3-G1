# Architecture - Configuration IP

## Sommaire

1. [Référence rapide des équipements fixes](#1-référence-rapide-des-équipements-fixes)
2. [Vue d'ensemble du plan d'adressage](#2-vue-densemble-du-plan-dadressage)
3. [Configuration IP par VLAN](#3-configuration-ip-par-vlan)
4. [Configuration IP des équipements réseau](#4-configuration-ip-des-équipements-réseau)
5. [Configuration DHCP](#5-configuration-dhcp)
6. [Configuration DNS](#6-configuration-dns)
7. [Récapitulatif de l'utilisation des adresses](#7-récapitulatif-de-lutilisation-des-adresses)
8. [Documentation des réservations DHCP](#8-documentation-des-réservations-dhcp)
9. [Plan de migration](#9-plan-de-migration)

---

## 1. Référence rapide des équipements fixes

### Serveurs VLAN 120 - Active Directory (172.16.12.0/28)

| Équipement | Adresse IP | Masque | Passerelle |
|------------|------------|--------|------------|
| ADDS | 172.16.12.1 | 255.255.255.240 | 172.16.12.14 |
| DHCP | 172.16.12.2 | 255.255.255.240 | 172.16.12.14 |
| WDS | 172.16.12.3 | 255.255.255.240 | 172.16.12.14 |
| Serveur de fichiers | 172.16.12.4 | 255.255.255.240 | 172.16.12.14 |
| WSUS | 172.16.12.5 | 255.255.255.240 | 172.16.12.14 |

### Serveurs VLAN 130 - Serveurs applicatifs (172.16.13.0/28)

| Équipement | Adresse IP | Masque | Passerelle |
|------------|------------|--------|------------|
| GLPI | 172.16.13.1 | 255.255.255.240 | 172.16.13.14 |
| Logs (Graylog) | 172.16.13.2 | 255.255.255.240 | 172.16.13.14 |
| Zabbix | 172.16.13.3 | 255.255.255.240 | 172.16.13.14 |
| MAIL | 172.16.13.5 | 255.255.255.240 | 172.16.13.14 |
| Web Interne | 172.16.13.6 | 255.255.255.240 | 172.16.13.14 |

### Imprimantes VLAN 90 - Impression (172.16.9.0/28)

| Équipement | Département | Adresse IP | Masque | Passerelle |
|------------|-------------|------------|--------|------------|
| Imprimante | DEV | 172.16.9.1 | 255.255.255.240 | 172.16.9.14 |
| Imprimante | COMMERCIAL | 172.16.9.2 | 255.255.255.240 | 172.16.9.14 |
| Imprimante | COMMUNICATION | 172.16.9.3 | 255.255.255.240 | 172.16.9.14 |
| Imprimante | JURIDIQUE | 172.16.9.4 | 255.255.255.240 | 172.16.9.14 |
| Imprimante | DSI | 172.16.9.5 | 255.255.255.240 | 172.16.9.14 |
| Imprimante | DIRECTION | 172.16.9.6 | 255.255.255.240 | 172.16.9.14 |
| Imprimante | COMPTABILITÉ | 172.16.9.7 | 255.255.255.240 | 172.16.9.14 |
| Imprimante | QHSE | 172.16.9.8 | 255.255.255.240 | 172.16.9.14 |
| Imprimante | RH | 172.16.9.9 | 255.255.255.240 | 172.16.9.14 |

### Téléphonie VoIP VLAN 40 (172.16.4.0/24)

| Équipement | Département | Adresse IP Fixe | Masque | Passerelle |
|------------|-------------|-----------------|--------|------------|
| | | | | |

---

## 2. Vue d'ensemble du plan d'adressage

### Objectifs du plan d'adressage

- Attribuer des plages IP adaptées à la taille de chaque département
- Anticiper la croissance future de l'entreprise
- Faciliter l'identification des équipements par leur adresse IP
- Optimiser l'utilisation des adresses disponibles

---

## 3. Configuration IP par VLAN

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
| **Adresse réseau** | 172.16.12.0/20 |
| **Masque de sous-réseau** | 255.255.255.240 |
| **Nombre de serveurs prévus** | 3 |
| **Adresses disponibles** | 5 |
| **Première adresse utilisable** | 172.16.12.1 |
| **Dernière adresse utilisable** | 172.16.12.13 |
| **Passerelle par défaut** | 172.16.12.14 |
| **Adresse de broadcast** | 172.16.12.15 |
| **Serveur DNS** | 172.16.12.1 |

#### VLAN 130 - Serveurs (SERVEURS)

| Paramètre | Valeur |
|-----------|--------|
| **Adresse réseau** | 172.16.13.0/28 |
| **Masque de sous-réseau** | 255.255.255.240 |
| **Nombre de serveurs prévus** | 4-13 |
| **Adresses disponibles** | 13 |
| **Première adresse utilisable** | 172.16.13.1 |
| **Dernière adresse utilisable** | 172.16.13.13 |
| **Passerelle par défaut** | 172.16.13.14 |
| **Adresse de broadcast** | 172.16.13.15 |
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

---

## 4. Configuration IP des équipements réseau

### Équipements d'infrastructure

| Équipement | Interface | VLAN | Adresse IP | Masque |
|------------|-----------|------|------------|--------|
| pfSense | WAN | - | IP Publique FAI | |
| pfSense | LAN-DMZ | - | 10.10.11.1 | /29 |
| pfSense | LAN | - | 10.10.10.1 | /30 |
| Router Core | LAN | - | 10.10.10.2 | /30 |
| Router Core | LAN-INTERNE | 150 | 172.16.15.62 | /26 |
| | VLAN 10 | 10 | 172.16.1.254 | /24 |
| | VLAN 20 | 20 | 172.16.2.62 | /26 |
| | VLAN 30 | 30 | 172.16.3.62 | /26 |
| | VLAN 40 | 40 | 172.16.4.254 | /24 |
| | VLAN 50 | 50 | 172.16.5.30 | /27 |
| | VLAN 60 | 60 | 172.16.6.30 | /27 |
| | VLAN 70 | 70 | 172.16.7.30 | /27 |
| | VLAN 80 | 80 | 172.16.8.14 | /28 |
| | VLAN 90 | 90 | 172.16.9.14 | /28 |
| | VLAN 100 | 100 | 172.16.10.14 | /28 |
| | VLAN 110 | 110 | 172.16.11.6 | /29 |
| | VLAN 120 | 120 | 172.16.12.14 | /28 |
| | VLAN 130 | 130 | 172.16.13.14 | /28 |
| | VLAN 140 | 140 | 172.16.14.62 | /26 |
| | VLAN 150 | 150 | 172.16.15.62 | /26 |

---

## 5. Configuration DHCP

### Pools DHCP par VLAN

| VLAN | Nom | Plage DHCP | Exclusions |
|------|-----|------------|------------|
| 10 | DEV | 172.16.1.1 - 172.16.1.250 | 172.16.1.1-9 |
| 20 | COMMER | 172.16.2.1 - 172.16.2.60 | 172.16.2.1-9 |
| 30 | COMMU | 172.16.3.1 - 172.16.3.60 | 172.16.3.1-9 |
| 40 | VOIP | 172.16.4.1 - 172.16.4.250 | 172.16.4.1-9 |
| 50 | JURI | 172.16.5.1 - 172.16.5.28 | 172.16.5.1-9 |
| 60 | DSI | 172.16.6.1 - 172.16.6.28 | 172.16.6.1-9 |
| 70 | COMPTA | 172.16.7.1 - 172.16.7.28 | 172.16.7.1-9 |
| 80 | DIREC | 172.16.8.1 - 172.16.8.12 | 172.16.8.1-4 |
| 90 | IMPRESSION | Adresses statiques uniquement | - |
| 100 | QHSE | 172.16.10.1 - 172.16.10.12 | 172.16.10.1-4 |
| 110 | RH | 172.16.11.1 - 172.16.11.4 | 172.16.11.1 |
| 140 | INVITE | 172.16.14.1 - 172.16.14.60 | 172.16.14.1-9 |

---

## 6. Configuration DNS

### Serveurs DNS



### Zones DNS



### Redirecteurs DNS



---

## 7. Récapitulatif de l'utilisation des adresses

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
| 172.16.12.0/28 | VLAN 120 (SERVEUR-AD) | 6 | 4-13 serveurs |
| 172.16.13.0/28 | VLAN 130 (SERVEURS) | 14 | 4-13 serveurs |
| 172.16.14.0/26 | VLAN 140 (INVITE) | 62 | Variable |
| 172.16.15.0/26 | VLAN 150 (ADMIN) | 62 | ~20 équipements |

---

## 8. Documentation des réservations DHCP



---

## 9. Plan de migration

### Migration depuis l'ancienne infrastructure


