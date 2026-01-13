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
L'entreprise compte plus de 200 collaborateurs répartis en plusieurs départements (DSI, Développement, finance, etc.).

L'infrastructure actuelle présente de nombreuses limites :
- Absence de serveurs internes
- Postes en workgroup
- Sécurité quasi inexistante
- Gestion des comptes utilisateurs non centralisée
- Réseau basé sur une simple box FAI

Ces contraintes rendent l'infrastructure peu sécurisée, peu évolutive et difficile à administrer.

---

## 3. Objectifs du projet

### 3.1 Objectifs principaux
- Concevoir une **Infrastructure réseau centralisée**
- Mettre en place un **domaine Active Directory**
- Centraliser la gestion des utilisateurs et des ordinateurs
- Structurer le réseau (VLAN, adressage IP)
- Améliorer le niveau de sécurité global
- Documenter l'ensemble de l'infrastructure
- 
-
-

### 3.2 Objectifs secondaires
- Préparer l'infrastructure à une future évolution
- 
-
-

---

## 4. Vue d'ensemble de l'infrastructure cible

L'infrastructure cible reposera sur :
-
-
-

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
- 
- 
- 

La description détaillée de chaque service est disponible dans la documentation dédiée.

---

## 6. Organisation de la documentation

La documentation du projet est structurée selon le cycle de vie de l'infrastructure.

### Architecture (HLD)
- Vue globale de l'infrastructure
- Contexte, périmètre, réseau, sécurité
- Choix de l'architecture

### Components (LLD)
- Conception technique détaillée
- Configuration des serveurs et services
- Détails matériels et logiciels

### Operations (DEX)
- Documentation d'exploitation
- Procédures d'utilisation quotidienne

---

## 7. Accès a la documentation

- **Nomenclature** : `naming.md`
- **Architecture** : `/architecture`
- **Conception Technique** : `/components`
- **Exploitation** : `/operations`
- **Organisation des Sprints** : `/Sprints`

---