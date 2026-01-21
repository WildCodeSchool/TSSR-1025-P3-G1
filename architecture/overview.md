# Architecture - Vue d'ensemble

## Sommaire
1. [Résumé du projet](#1-résumé-du-projet)
2. [Schéma Global de l'infrastructure](#2-schéma-global-de-linfrastructure)
3. [Liste des briques techniques](#3-liste-des-briques-techniques)
4. [Liens vers les autres documents HLD](#4-liens-vers-les-autres-documents-hld)

---  

##  1. Résumé du projet  

Le projet consiste en la refonte totale de l'infrastructure de la société **BillU**, filiale du groupe international **RemindMe**. 


### Objectifs Globaux : 
- Mettre en place d'une infrastructure sécurisé
- Déployer un domaine Active Directory pour centraliser la gestion des utilisateurs
- Mettre en place un ITSM **GLPI** pour gestion du parc informatique
- Mettre en place les services DHCP, DNS, Téléassistance (RDP...)

---  

## 2. Schéma Global de l'infrastructure

![image infra](ressources/topology.png)

---  

## 3. Liste des briques techniques

### Serveurs et services
|Services|Rôles| 
|--------|-----|
|DHCP|
|DNS|
|ADDS|
|GLPI|
|Téléassistance|
|Serveur de fichiers|


---  

## 4. Liens vers les autres documents HLD

[Lien vers document Context.md](context.md)  
[Lien vers document Scope.md](scope.md)  
[Lien vers document Network.md](network.md)  
[Lien vers document IP_Configuration.md](ip_configuration.md)  
[Lien vers document Security.md](security.md)  
[Lien vers document Services.md](services.md)


