# Architecture - Contexte et Besoins

## Sommaire

1) [Contexte de l'entreprise](#1-contexte-de-lentreprise)
2) [Situation actuelle](#2-situation-actuelle)
3) [Besoins principaux](#3-besoins-principaux)
4) [Besoins secondaires](#4-besoins-secondaires)
5) [Public cible](#5-public-cible)

---  


## 1. Contexte de l'entreprise

### Présentation de BillU

**BillU** est une filiale dynamique du groupe international **RemindMe**, un acteur majeur comptant plus de 2000 collaborateurs répartis sur plusieurs continents.

**Informations clés :**
- **Secteur d'activité** : Développement de logiciels, spécialisé dans la facturation
- **Localisation** : Paris, 20ᵉ arrondissement
- **Effectif** : 217 collaborateurs
- **Structure** : 9 départements stratégiques
- **Groupe parent** : RemindMe (2000+ collaborateurs internationaux)


### Organisation interne (départements et services)

- **Communication et Relations publiques**
  - Relation Médias
  - Communication interne
  - Gestion des marques

- **Département Juridique**
  - Droit des sociétés
  - Protection des données et conformité
  - Propriété intellectuelle

- **Développement logiciel**
  - Analyse et conception
  - Développement
  - Recherche et prototype
  - Tests et qualité

- **Direction**

- **DSI**
  - Administration Systèmes et Réseaux
  - Développement et intégration
  - Exploitation
  - Support

- **Finance et Comptabilité**
  - Finance
  - Fiscalité
  - Service Comptabilité

- **QHSE**
  - Certification
  - Contrôle Qualité
  - Gestion environnementale

- **Service Commercial**
  - ADV
  - B2B
  - Service Achat
  - Service Client

- **Service Recrutement**

### Contexte du projet

BillU connaît une phase de croissance importante. Un partenariat stratégique est actuellement en cours de négociation et pourrait aboutir dans les prochains mois. Cette évolution, combinée à l'augmentation des effectifs et aux enjeux de sécurité liés au secteur de la facturation, nécessite une refonte complète de l'infrastructure réseau actuelle.

L'infrastructure doit être capable de :
- Supporter la croissance des effectifs et l'extension potentielle 
- Garantir la sécurité des données sensibles 
- Faciliter la collaboration inter-départements et avec de futurs partenaires
- Répondre aux exigences de conformité réglementaire (RGPD, protection des données)

---  

## 2. Situation actuelle

### Infrastructure existante

**Parc informatique :**
- 100% PC portables de marques très hétérogènes
- Aucun serveur dédié
- 1 NAS grand public pour le stockage

**Réseau :**
- Réseau wifi domestique fourni par une box FAI avec répéteurs wifi
- Plage d'adressage : 172.16.10.0/24
- Aucun équipement réseau professionnel (pas de switch managé, routeur, firewall)

**Messagerie :**
- Messagerie hébergée en cloud (format : prenom.nom@billu.com)

**Sécurité et gestion des accès :**
- Configuration en workgroups (pas de domaine Active Directory)
- Comptes locaux avec mots de passe stockés localement
- Pas de politique de sécurité centralisée
- Turnover élevé (stagiaires, alternants, CDD) entraînant la réutilisation des anciens mots de passe

**Stockage et données :**
- NAS accessible uniquement aux encadrants (responsables et directeurs) et au département Développement logiciel
- Autres collaborateurs : utilisation de drives cloud personnels
- Pas de redondance matérielle

**Sauvegardes :**
- Effectuées ponctuellement sur le NAS
- Pas de politique de rétention définie

**Téléphonie :**
- Téléphonie fixe et mobile aléatoire selon les utilisateurs

**Mobilité :**
- Pas de télétravail mis en place
- Aucun accès aux données en dehors du site (sauf messagerie cloud)

---  

## 3. Besoins principaux


## 4. Besoins secondaires


## 5. Public cible


