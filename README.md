# Projet 3 – Construction d’une infrastructure réseau  

## Société : BillU

## Sommaire

1. [Présentation du projet](#1-présentation-du-projet)
2. [Contexte de l'entreprise](#2-contexte-de-lentreprise)
3. [Objectifs du projet](#3-objectifs-du-projet)
   - [Objectifs principaux](#31-objectifs-principaux)
   - [Objectifs secondaires](#32-objectifs-secondaires)
4. [Vue d'ensemble de l'infrastructure cible](#4-vue-densemble-de-linfrastructure-cible)
5. [Services et composants principaux](#5-services-et-composants-principaux)
6. [Organisation de la documentation](#6-organisation-de-la-documentation)
7. [Accès à la documentation](#7-accès-a-la-documentation)


## 1. Présentation du projet

Ce projet s'inscrit dans le cadre de la formation **TSSR - Technicien Supérieur Systèmes et Réseaux**.
Il a pour objectif la conception, la mise en place et la documentation complète d'une nouvelle infrastructure réseau pour la société **BillU**.

Le projet est mené en conditions proches d'un contexte professionnel réel, avec une organisation par sprints, une gestion des objectifs et une documentation structurée.

---

## 2. Contexte de l'entreprise


**BillU** est une société spécialisée dans le développement de solutions logicielles de facturation.  
Elle compte **217 collaborateurs**, répartis au sein de **9 départements**, et est filiale du groupe international **RemindMe**.

### Situation actuelle

L’infrastructure actuelle présente de nombreuses limites :
- Absence de serveurs internes
- Postes clients en workgroup
- Aucune gestion centralisée des identités
- Sécurité quasi inexistante
- Réseau basé sur une box FAI et des répéteurs WiFi
- Stockage et sauvegardes non professionnels

Ces contraintes rendent le système d’information :
- peu sécurisé,
- peu évolutif,
- difficile à administrer.

Une **refonte complète de l’infrastructure** est donc nécessaire afin de répondre aux enjeux de croissance, de sécurité et de conformité.

---

## 3. Objectifs du projet

### 3.1 Objectifs principaux
- Concevoir une **infrastructure réseau centralisée et segmentée**
- Mettre en place un **domaine Active Directory**
- Centraliser la gestion des utilisateurs, des groupes et des postes
- Structurer le réseau (VLAN, plan d’adressage IP)
- Mettre en place les services réseau essentiels (DNS, DHCP)
- Améliorer le niveau de sécurité global
- Mettre en place un stockage centralisé et sécurisé
- Documenter l’ensemble du système d’information

### 3.2 Objectifs secondaires
- Préparer l’infrastructure à une **évolution future** (croissance, partenariat)
- Faciliter l’exploitation et la maintenance du SI
- Mettre en place des bases solides pour l’automatisation et la supervision

---

## 4. Vue d'ensemble de l'infrastructure cible

L'infrastructure cible reposera sur :
- Une **architecture réseau segmentée** par VLANs
- Un **domaine Active Directory** pour la gestion centralisée des identités
- Des **services d’infrastructure dédiés** (DNS, DHCP, fichiers, sauvegarde)
- Une **séparation claire des rôles**
- Une infrastructure **sécurisée, évolutive et documentée**

Les détails techniques sont volontairement **non décrits ici** et sont disponibles dans la documentation dédiée.

---

## 5. Services et composants principaux

Les principaux services mis en place dans le cadre du projet sont :
- Active Directory Domain Service (AD DS)
- DNS
- DHCP
- Serveur de fichiers
- Services de sauvegarde
- Outils d'administration
- Infrastructure réseau (VLAN, routage, pare-feu)

La description détaillée de chaque service est disponible dans la documentation dédiée.

---

## 6. Organisation de la documentation

La documentation du projet est structurée selon le cycle de vie de l'infrastructure.

### Architecture (HLD)
- Vue globale de l'infrastructure
- Contexte, périmètre, réseau, sécurité
- Architecture réseau et sécuirté
- Choix de l'architecture

### Components (LLD)
- Conception technique détaillée
- Configuration des serveurs et services
- Paramètrage réseau et système

### Operations (DEX)
- Documentation d'exploitation
- Procédures d'administration
- Procédures utilisateur

---

## 7. Accès a la documentation

- **Nomenclature** : [naming.md](naming.md)
- **Architecture (HLD)** : [architecture](architecture/)
- **Conception technique (LLD)** : [components](components/)
- **Exploitation (DEX)** : [operations](operations/)
- **Organisation des sprints** : [sprints](sprints/)

---