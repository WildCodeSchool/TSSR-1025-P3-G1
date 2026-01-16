# Security - Principes de sécurité

Sommaire : 
1) [Vue d'ensemble](#1-vue-densemble)
2) [Principes de sécurité retenus](#2-principes-de-sécurité-retenus)
3) [Zones de sécurité et segmentation](#3-zones-de-sécurité-et-segmentation)
4) [Politique d'accès](#4-politique-daccès)
5) [Journalisation et traçabilité](#5-journalisation-et-traçabilité)
6) [Sauvegardes](#6-sauvegardes)
7) [Sécurité des postes de travail](#7-sécurité-des-postes-de-travail)

---  

## 1. Vue d'ensemble

Ce document présente les principes de sécurité retenus pour l'infrastructure réseau de BillU. Il définit la stratégie globale de protection des ressources, des données et des accès au système d'information.

### 1.1. Contexte actuel

L'infrastructure actuelle de BillU présente des vulnérabilités importantes :
- Absence de gestion centralisée des identités
- Workgroups avec mots de passe locaux réutilisés
- Réseau plat sans segmentation
- Accès WiFi via box FAI grand public
- Pas de contrôle d'accès ni de traçabilité
- Stockage de données non sécurisé (NAS grand public)
- Sauvegardes ponctuelles sans politique définie

### 1.2. Objectifs de sécurité

La nouvelle infrastructure vise à :
- Mettre en place une gestion centralisée et sécurisée des identités
- Segmenter le réseau pour limiter les risques de propagation
- Renforcer le contrôle d'accès aux ressources
- Assurer la traçabilité des actions
- Protéger les données sensibles
- Garantir la disponibilité et l'intégrité des services critiques

---  

## 2. Principes de sécurité retenus

### 2.1. Principes de sécurité

L'infrastructure repose sur plusieurs niveaux de sécurité :
- **Périmètre** : pare-feu, filtrage des flux entrants/sortants
- **Réseau** : segmentation par VLAN, isolation des zones sensibles
- **Accès** : authentification centralisée
- **Données** : chiffrement, contrôle d'accès, sauvegardes
- **Surveillance** : journalisation, monitoring

### 2.2. Principe du moindre privilège

- Chaque utilisateur dispose uniquement des droits nécessaires à ses fonctions
- Les comptes administrateurs sont distincts des comptes utilisateurs
- Les accès aux ressources sensibles sont restreints par département/service
- Les groupes de sécurité AD définissent les permissions

### 2.3. Séparation des rôles

- Distinction claire entre administrateurs et utilisateurs
- Contrôle des actions à privilèges élevés

### 2.4. Authentification forte

- Mise en place d'Active Directory pour la gestion centralisée
- Politique de mots de passe robuste
- Suppression des mots de passe locaux réutilisés
- Verrouillage de compte après tentatives échouées

---  

## 3. Zones de sécurité et segmentation

### 3.1. Découpage par zones

Le réseau est divisé en zones de confiance distinctes :

| Zone | Description | 
|------|-------------|
| **LAN Utilisateurs** | Postes de travail standards |
| **VLAN Administration** | Infrastructure système et réseau | 
| **VLAN Serveurs** | Serveurs métier et services | 
| **VLAN Développement** | Environnement de développement logiciel |
| **VLAN Direction** | Équipements direction et données sensibles | 
| **VLAN Invités** | Accès temporaires |
| **DMZ** | Services exposés | 

### 3.2. Zones sensibles identifiées

Les départements suivants nécessitent une protection renforcée :
- **Direction** : données stratégiques et confidentielles
- **Juridique** : contrats, propriété intellectuelle
- **Finance et Comptabilité** : données financières, fiscales
- **Développement** : code source, prototypes
- **DSI** : infrastructure critique, comptes à privilèges

---  

## 4. Politique d'accès

### 4.1. Accès administrateurs

- **Comptes nominatifs** : traçabilité des actions administratives
- **Comptes à privilèges séparés** : `admin-prenom.nom` distinct du compte utilisateur
- **Accès restreint** : uniquement depuis le VLAN Administration
- **Session timeout** : déconnexion automatique après inactivité
- **Audit** : journalisation de toutes les actions privilégiées

### 4.2. Accès utilisateurs

- **Authentification unique (SSO)** : via Active Directory
- **Contrôle d'accès basé sur les rôles (RBAC)** : groupes de sécurité AD
- **Accès réseau** : Authentification WiFi/filaire
- **Accès aux fichiers** : permissions NTFS basées sur les groupes AD
- **Sessions utilisateur** : GPO pour sécuriser les postes de travail

### 4.3. Accès prestataires externes

- **Réseau isolé** : VLAN Invités sans accès aux ressources internes
- **Accès limité dans le temps** : désactivation automatique
- **Supervision** : traçabilité complète des actions
- **Validation** : autorisation préalable du DSI ou responsable métier

### 4.4. Accès distant
A FAIRE

---  

## 5. Journalisation et traçabilité

### 5.1. Événements journalisés

- **Active Directory** : connexions, modifications de droits, création/suppression objets
- **Serveurs** : accès fichiers, modifications configuration, erreurs système
- **Pare-feu** : connexions bloquées/autorisées, tentatives d'intrusion
- **Postes de travail** : connexions utilisateurs, installations logiciels

### 5.2. Centralisation des logs

- Serveur de collecte centralisé (syslog/SIEM)
- Alertes automatiques sur événements critiques (optionnelle)

### 5.3. Surveillance et monitoring

- Supervision temps réel de l'infrastructure
- Détection des comportements anormaux
- Tableau de bord pour le DSI

## 6. Sauvegardes

### 6.1. Stratégie de sauvegarde

Remplacement des sauvegardes ponctuelles par une politique structurée :

| Type de données | Fréquence |Destination |
|----------------|-----------|-----------|
| Active Directory | Quotidienne |  Serveur backup  |
| Serveurs critiques | Quotidienne |  Serveur backup  |
| Données utilisateurs | Quotidienne |  Serveur backup |
| Développement/Code source | Quotidienne | Serveur backup  |
| Sauvegarde complète | Hebdomadaire |  Serveur backup |

### 6.2. Principes de sauvegarde



### 6.3. Plan de continuité


---  

## 7. Sécurité des postes de travail

### 7.1. Configuration standard via GPO

- Antivirus/antimalware obligatoire et à jour
- Pare-feu Windows activé
- Mises à jour automatiques Windows Update
- Désactivation des ports USB pour supports amovibles (sauf exception)
- Verrouillage automatique après inactivité



