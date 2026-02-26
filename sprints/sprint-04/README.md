# Sprint 4 – Déploiement et Services

---

# 1. Les objectifs pris par le groupe sur le sprint 4

## 1.1 Prioritaire :

- WebEXT
- VOIP - Mettre en place un serveur de téléphonie sur IP
- SÉCURITÉ - WSUS Mettre en place un serveur de gestion des mises à jour
- MESSAGERIE - Mettre en place un serveur de messagerie
- GESTION DE PARC - WDS Utilisation de solution(s) de gestion de parc

## 1.2 Secondaire :

- AD - Rôles FSMO
- AD - Nouveau fichier RH pour les utilisateurs de l'entreprise
- AD - Intégration des machines Linux dans le domaine AD
- SAUVEGARDE - Mettre en place une sauvegarde de données
- Active Directory - Gestion des objets AD

## 1.3 Optionnel :

- SÉCURITÉ - Mettre en place un serveur de gestion de mot de passe
- SÉCURITÉ - Mettre en place un serveur bastion
- GESTION DE PROJET - Installation d'un suivi de proje

---

# 2. La finalité de ces objectifs à la fin du sprint

À la fin du Sprint 4 :


---

# 3. Membres du groupe du sprint 4

## Semaine 1

| Membre    | Rôle       |
|-----------|------------|
| Christian | Technicien |
| Franck    | PO         |
| Matthias  | SM         |

## Semaine 2

| Membre    | Rôle       |
|-----------|------------|
| Christian | SM         |
| Franck    | Technicien |
| Matthias  | PO         |

---

# 4. Les problèmes rencontrés

- Difficultés PXE (DHCP / options / firewall).
- Temps de synchronisation WSUS important.
- GPO recalcitrante
- Problème avec le Pare-feu
- Problème avec Certificat pour Thunderbird

---

# 5. Les décisions techniques

## Création des VM / CT

- DOM-WEBEXT-01 → Serveur Web externe (DMZ)
- DOM-WDS-01 → Serveur de déploiement
- DOM-WSUS-01 → Serveur de mises à jour
- DOM-MAIL-01 → Serveur Mail (iRedMail)
- DOM-VOIP-01 → Serveur VoIP

## Choix techniques

- Apache pour le serveur Web externe
- WDS intégré au domaine Active Directory
- WSUS piloté via GPO
- iRedMail sur serveur Linux dédié
- Scripts PowerShell pour automatisation AD
- FreePBX sur un serveur dédié

---

# 6. Ce qu'il reste à faire

Finaliser la documentation de plusieurs tâches.
---
