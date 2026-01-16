## Sommaire

1. [Les objectifs pris par le groupe sur le sprint 1](#1-lesobjectifsprisparlegroupesurlesprint1)
2. [La finalité de ces objectifs à la fin du sprint](#2-la-finalite-de-ces-objectifs-a-la-fin-du-sprint)
3. [Membres du groupe du sprint 1](#3-membres-du-groupe-du-sprint-1)
4. [Les problèmes rencontrés](#4-les-problemes-rencontres)
5. [Les décisions techniques](#5-les-decisions-techniques)
6. [Ce qu'il reste à faire](#6-ce-quil-reste-à-faire)


# 1. Les objectifs pris par le groupe sur le sprint

- Analyser en détail le contexte de l’entreprise BillU 
- Créer l’arborescence complète du dépôt GitHub de documentation 
- Remplir les fichiers de base (niveau DAT + début HLD) 
- Réaliser une première topologie du futur réseau 
- Estimer la charge globale du projet (méthode bottom-up)

# 2. La finalité de ces objectifs à la fin du sprint

Nous avons atteints les objectifs 1-2-4-5 à 100%
L'objectif 3 est atteins à 50 %

# 3. Membres du groupe du sprint 1

| Membre    | Rôle       |
| --------- | ---------- |
| Christian | PO         |
| Franck    | SM         |
| Matthias  | Technicien |
# 4. Les problèmes rencontrés

Au cours de ce premier sprint, notre équipe a rencontré un point de blocage majeur concernant l'adressage IP du réseau de l'entreprise BillU. Face à ce blocage technique, nous avons sollicité l'intervention de notre formateur qui nous a permis de clarifier les bonnes pratiques en matière de plan d'adressage IP et de débloquer la situation. Cette intervention nous a permis de progresser sur la rédaction du fichier IP_configuration.md et d'établir une topologie réseau cohérente.

# 5. Les décisions techniques

La Partie matérielle :

- **Pour la salle serveur :**
	- 1 Windows Serveur graphique : ADDS
	- 3 Windows Serveur core : DHCP,DNS,Serveur de fichiers
	- 1 Serveur Debian : GLPI
	- 1 BDD : optionnel
	- 1 Laptop
	- 1 Switch L2
	- 2 Switcht L3
	- 1 PFSENSE : routeur , VPN
	- 1 Serveur de messagerie

- **Pour la salle serveur Backup si on a le budget**

	Idem que pour la salle serveur

- **Pour le service DEV**
	- 4 Switches L2
	- 1 Laptop par utilisateur
	- 1 Borne WIFI
	- 1 VOIP par utilisateur
	- 1 imprimante

- **Pour les services Commercial,Communication,Juridique,DSI,Compta,Direction,QHSE,RH**
	- 1 Switches L2 /service
	- 1 Laptop par utilisateur /services
	- 1 Borne WIFI /services
	- 1 VOIP par utilisateur /services
	- 1 imprimante /services

# 6. Ce qu'il reste à faire 

Les tâches suivantes n'ont pas pu être finalisées durant ce Sprint 1 :

- **Adressage IP statique :**
    - Lister tous les équipements nécessitant une IP fixe
    - Définir les plages d'adresses réservées
    - Documenter l'attribution dans IP_configuration.md
- **Complétion de la documentation :**
    - Finaliser certaines sections des fichiers HLD
    - Compléter les fichiers LLD
    - Enrichir les procédures d'installation et de configuration
