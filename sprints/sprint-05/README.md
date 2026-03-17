Voici une version **Markdown propre**, au niveau du Sprint 4, avec un peu plus de précision technique, sans éléments inutiles :

---

# Sprint 5 – Audit de sécurité

---

# 1. Les objectifs pris par le groupe sur le sprint 5

## 1.1 Prioritaire :

* FIREWALL - Gestion du traffic commun
* Audit surface d’attaque AD
* Active Directory - Gestion des objets AD
* SÉCURITÉ D’ACCÈS - Restriction d’utilisation
* ACTIVE DIRECTORY - Mise en place d’une gestion AD commune
* AD - Rôles FSMO
* Pentesting

## 1.2 Secondaire :

* AD - Nouveau fichier RH pour les utilisateurs de l'entreprise

## 1.3 Optionnel :

Aucun objectif optionnel défini sur ce sprint.

---

# 2. La finalité de ces objectifs à la fin du sprint

À la fin du Sprint 5 :

* Gestion du traffic inter-entreprises (Firewall) → Terminé
* Audit de sécurité Active Directory (PingCastle) → Terminé
* Gestion des objets Active Directory → Terminé
* Restriction d’accès via GPO → Terminé
* Mise en place d’une gestion AD commune → Terminé
* Gestion des rôles FSMO → Terminé
* Pentesting → En cours (25 %)
* Mise à jour du fichier RH AD → Terminé

Ce sprint est orienté sécurité et permet d’identifier les faiblesses potentielles de l’infrastructure.

---

# 3. Membres du groupe du sprint 5

## Répartition globale

| Membre    | Rôle principal                   |
| --------- | -------------------------------- |
| Christian | Sécurité / Active Directory      |
| Franck    | Active Directory / Audit         |
| Matthias  | Réseau / Firewall / Coordination |

---

# 4. Les problèmes rencontrés

* Complexité de la gestion du traffic inter-entreprises (règles firewall, flux autorisés)
* Difficulté de mise en place d’une gestion Active Directory commune (DNS, accès, cohérence)
* Ajustements nécessaires sur les GPO de restriction
* Temps d’analyse important pour l’audit de sécurité AD
* Avancement limité du pentesting en raison des autres priorités
* Coordination nécessaire entre les deux groupes pour les accès et les tests

---

# 5. Les décisions techniques

## Firewall / Interconnexion

* Mise en place de règles spécifiques pour autoriser les flux inter-entreprises
* Ouverture contrôlée des ports nécessaires :

  * 53 (DNS)
  * 88 (Kerberos)
  * 389 / 636 (LDAP / LDAPS)
  * 123 (NTP)
  * 22 (SSH)
  * 3389 (RDP)

## Active Directory

* Mise en place d’une gestion AD commune (configuration des accès inter-domaines)
* Réorganisation et nettoyage des objets AD
* Mise en place de scripts pour automatiser certaines tâches

## Sécurité

* Déploiement de GPO de restriction d’utilisation (contrôle des accès utilisateurs)
* Réalisation d’un audit Active Directory avec PingCastle
* Analyse de la surface d’attaque et identification des vulnérabilités

## Pentesting

* Déploiement d’une machine Kali Linux
* Utilisation d’outils de reconnaissance et d’analyse (nmap, enum4linux)
* Début des tests d’intrusion sur l’infrastructure

---

# 6. Ce qu'il reste à faire

* Finaliser le pentesting
* Analyser en détail les résultats de l’audit de sécurité
* Mettre en place des correctifs suite aux vulnérabilités identifiées
* Ajuster certaines règles de firewall si nécessaire
* Compléter la documentation technique détaillée

---
