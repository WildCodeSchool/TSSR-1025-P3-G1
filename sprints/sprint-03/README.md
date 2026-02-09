## Sommaire

1. [Les objectifs pris par le groupe sur le sprint 3](#1-lesobjectifsprisparlegroupesurlesprint3)
2. [La finalité de ces objectifs à la fin du sprint](#2-la-finalite-de-ces-objectifs-a-la-fin-du-sprint)
3. [Membres du groupe du sprint 3](#3-membres-du-groupe-du-sprint-3)
4. [Les problèmes rencontrés](#4-les-problemes-rencontres)
5. [Les décisions techniques](#5-les-decisions-techniques)
6. [Ce qu'il reste à faire](#6-ce-quil-reste-à-faire)


# 1. Les objectifs pris par le groupe sur le sprint 3

## 1.1 Prioritaire :
- Finalisation du PC dédié Administration
- Mettre en place d'un partage de fichier sur un serveur dédié
- Mettre en place d'une supervision avec la solution Zabbix
- Mettre en place d'une journalisation centralisé avec la solution Graylog


## 1.2 Secondaire :
- SAUVEGARDE - Mettre en place une sauvegarde de données
- ACTIVE DIRECTORY - Mettre en place une sauvegarde de données
- ACTIVE DIRECTORY - Gestion des objets AD
- SUPERVISION - Surveillance du pare-feu pfsense
- JOURNALISATION - Mise en place d'une journalisation des scripts PowerShell

## 1.3 Optionnel : 
- WEB - Mettre en place un serveur WEB INTERNE
- WEB - Mettre en place un serveur WEB EXTERNE
- STOCKAGE AVANCÉ - Mettre en place du RAID 1 sur un serveur
- STOCKAGE AVANCÉ - Mettre en place LVM sur un serveur Debian
- JOURNALISATION - Mise en place d'une journalisation des scripts PowerShell

# 2. La finalité de ces objectifs à la fin du sprint
- Mise en place du serveur Graylog - OK
- Mise en place du serveur Zabbix - OK
- Mise en place du PC dédié - OK
- Mise en place du partage de fichier - OK
- Mise en place du serveur WEB Interne - OK


# 3. Membres du groupe du sprint 3

## Semaine 1

| Membre    | Rôle       |
| --------- | ---------- |
| Christian | SM         |
| Franck    | Technicien |
| Matthias  | PO         |

## Semaine 2

| Membre    | Rôle       |
| --------- | ---------- |
| Christian | PO         |
| Franck    | SM         |
| Matthias  | Technicien |

# 4. Les problèmes rencontrés

- SSH sur windows Serveur 2022, problème d'installer par les outils Microsoft  
    > Solution : Installation par une procédure d'installation manuel avec github  
- Blocage compréhension GPO, partage de dossier individuel.  
    > Solution : Création de 2 GPO   

# 5. Les décisions techniques
Création des conteneurs : 
    - DOM-LOGS-01 - Graylog
    - DOM-WEBINT-01 - Site web interne
    
Création des VM : 
    - G1-DOM-ZABBIX-01

# 6. Ce qu'il reste à faire 









