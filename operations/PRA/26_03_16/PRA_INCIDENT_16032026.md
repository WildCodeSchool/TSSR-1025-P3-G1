# PRA – Incident infrastructure réseau

## 1. Contexte de l’incident

Suite à un incident d’origine électrique, une partie de l’infrastructure informatique est devenue indisponible.  
Plusieurs machines virtuelles et équipements réseau ont été impactés, entraînant l’interruption de plusieurs services critiques du système d'information.

Cet incident a entraîné :
- la perte de plusieurs serveurs
- la corruption de certaines configurations réseau
- l’arrêt de services essentiels au fonctionnement du domaine Active Directory

Le maintien en condition opérationnelle (MCO) de l’infrastructure n’étant plus garanti, une procédure de **Plan de Reprise d’Activité (PRA)** a été déclenchée afin de restaurer les services dans un ordre logique de dépendance.

L’infrastructure est hébergée sur une plateforme de virtualisation **Proxmox**.

---
# 2. État des lieux initial

Après analyse de l’infrastructure, plusieurs anomalies ont été identifiées.

## 2.1 Services complètement indisponibles

Les machines suivantes étaient absentes ou détruites :

| Service | Machine       |
| ------- | ------------- |
| DHCP    | DOM-DHCP-01   |
| PDC     | DOM-AD-PDC-01 |
| Mail    | DOM-MAIL-01   |
| Webex   | DOM-WEBEXT-01 |
| Logs    | DOM-LOGS-01   |
| RID     | DOM-AD-RID-01 |

Ces serveurs devaient être recréés afin de restaurer les services associés.

---

## 2.2 Équipements réseau impactés

### Routeur VyOS

Problèmes identifiés :
- configuration réseau corrompue
- perte de configuration VLAN
- une seule carte réseau restante

Conséquences :
- interruption de la communication réseau entre les VLAN
- impossibilité pour certains équipements de communiquer

---

### Pare-feu pfSense

Problèmes identifiés :
- perte de l’interface réseau commune
- configuration réseau inutilisable

Conséquences :
- rupture de communication entre certains segments réseau

---

## 2.3 Active Directory

Plusieurs composants du domaine Active Directory étaient indisponibles.

|Élément|État|
|---|---|
|PDC|absent|
|RID Master|indisponible|

Conséquences :

- Pas de synchronisation des horaires
- perturbation de la gestion des utilisateurs
- dysfonctionnement des GPO
- impossibilité de créer de nouveaux objets AD

---

# 3. Analyse des dépendances

Les services de l’infrastructure présentent plusieurs dépendances logiques.

|Service|Dépendance|
|---|---|
|Communication réseau|Routeur VyOS|
|Attribution d'adresses IP|DHCP|
|Authentification|Active Directory|
|Gestion des politiques|PDC|
|Supervision|Zabbix|
|Centralisation des logs|Graylog|

La restauration des services devait respecter cet ordre de dépendance afin d’éviter des erreurs de configuration ou des services inopérants.

---

# 4. Priorisation des services

L’ordre de remise en service a été défini comme suit :

1. Restauration de la connectivité réseau
2. Mise en place du serveur DHCP
3. Restauration du pare-feu
4. Restauration du domaine Active Directory
5. Remise en service des services applicatifs

---

# 5. Plan de remise en service

## 5.1 Restauration du routeur VyOS

Actions réalisées :

- ajout d’une carte réseau
- reconfiguration complète des interfaces réseau
- reconfiguration des VLAN
- reconfiguration du routage inter-VLAN
- configuration du DHCP relay

La configuration a été recréée manuellement à partir de la documentation existante.

---

## 5.2 Mise en place du serveur DHCP

Le serveur **DOM-DHCP-01** a été recréé.

Actions réalisées :

- création de la machine virtuelle
- installation du service DHCP
- restauration manuelle de la configuration DHCP
- vérification de la distribution des adresses IP

---

## 5.3 Restauration du pare-feu pfSense

Actions réalisées :

- ajout d’une nouvelle interface réseau
- recréation de l’interface commune
- réactivation de la configuration existante

Les règles du pare-feu étant toujours présentes dans la configuration, aucune reconstruction complète des règles n’a été nécessaire.

---

## 5.4 Restauration de l’Active Directory

### Restauration du PDC

Le contrôleur de domaine principal **DOM-PDC-01** a été recréé.

Actions réalisées :
- Pas de synchronisation des horloges
- création de la machine virtuelle
- installation du rôle Active Directory
- réintégration dans l’infrastructure AD

---

### Restauration du rôle RID Master

Le rôle FSMO **RID Master** a été restauré.
Ce rôle est nécessaire pour la création de nouveaux objets dans Active Directory.

---

## 5.5 Restauration des services applicatifs

Une fois les services critiques restaurés, les services applicatifs ont été remis en fonctionnement :

- File Server
- Mail
- VOIP
- GLPI
- Graylog
- Zabbix
- WDS
- WSUS

Le serveur **DOM-LOGS-01** (Graylog) a été recréé.

---

## 5.6 Réintégration des agents de supervision

Suite à la panne, certaines machines ont été détruites.

Actions réalisées :

- réinstallation des agents **Zabbix**, **Graylog**
- reconnexion des machines au serveur de supervision

---

# 6. Chronologie de la reprise

| Heure | Action                                                   |
| ----- | -------------------------------------------------------- |
| 10h30 | Identification des impacts et des services indisponibles |
| 11h30 | Analyse des dépendances et priorisation des actions      |
| 12h30 | Début des opérations de restauration                     |
| 17h30 | Infrastructure entièrement restaurée                     |

---

# 7. État final de l’infrastructure

À la fin de l’intervention :

- l’ensemble des services critiques est opérationnel
- les services applicatifs sont fonctionnels
- la connectivité réseau est rétablie
- la supervision est de nouveau active

L’infrastructure est revenue dans un état opérationnel.

---

# 8. Faiblesses identifiées

L’incident a mis en évidence plusieurs faiblesses dans l’infrastructure.

### Sauvegarde de configuration réseau

La configuration du routeur VyOS n’était pas sauvegardée de manière centralisée.

Conséquence :
- nécessité de reconstruire la configuration manuellement.

---

### Duplication

Création de la redondance sur les serveurs.

---

### Serveur de sauvegarde

Création d'une politique de sauvegarde des machines critiques.

---
# 9. Améliorations recommandées

Afin d'améliorer la résilience de l'infrastructure, plusieurs mesures sont recommandées :

- mise en place de sauvegardes automatiques des configurations réseau
- mise en place de snapshots réguliers des machines virtuelles critiques
- automatisation du déploiement des agents de supervision
- duplication de serveurs
- vérification régulière des procédures PRA

Ces mesures permettront de réduire les temps de reprise lors d’un incident similaire.