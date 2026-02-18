# 📧 Tutoriel Complet — iRedMail + Active Directory
### Projet TSSR | Infrastructure billu.lan
**Version** : 2.0 | **OS** : Debian 11/12 | **Backend** : OpenLDAP ← *Requis pour l'intégration AD*

---

> ⚠️ **IMPORTANT** : Ce tutoriel suit la **documentation officielle iRedMail**.
> L'intégration Active Directory nécessite **obligatoirement** le backend **OpenLDAP**.
> Ne pas choisir MariaDB ou PostgreSQL lors de l'installation.

---

## 📑 Table des matières

1. [Prérequis et infrastructure](#1-prérequis-et-infrastructure)
2. [Préparation du serveur Debian](#2-préparation-du-serveur-debian)
3. [Installation d'iRedMail avec OpenLDAP](#3-installation-diredmail-avec-openldap)
4. [Vérification post-installation](#4-vérification-post-installation)
5. [Préparation Active Directory](#5-préparation-active-directory)
6. [Intégration AD dans Postfix](#6-intégration-ad-dans-postfix)
7. [Intégration AD dans Dovecot](#7-intégration-ad-dans-dovecot)
8. [Intégration AD dans Roundcube (carnet d'adresses global)](#8-intégration-ad-dans-roundcube-carnet-dadresses-global)
9. [Configuration Thunderbird](#9-configuration-thunderbird)
10. [Tests et validation](#10-tests-et-validation)
11. [Dépannage](#11-dépannage)
12. [Récapitulatif de l'architecture](#12-récapitulatif-de-larchitecture)

---

## 1. Prérequis et infrastructure

### 1.1 Schéma d'infrastructure

```
┌──────────────────────────────────────────────────────────┐
│                    Réseau billu.lan                       │
│                                                          │
│  ┌─────────────────┐         ┌─────────────────────┐    │
│  │  DOM-AD-01      │ LDAP    │  DOM-MAIL-01         │    │
│  │  172.16.12.1    │◄───────►│  172.16.13.5         │    │
│  │  Windows Srv    │  :389   │  Debian 11/12        │    │
│  │  2022 (AD/DNS)  │         │  iRedMail (OpenLDAP) │    │
│  └─────────────────┘         └─────────────────────┘    │
│           ▲                           ▲                  │
│           │ Auth Windows              │ Webmail / IMAP   │
│  ┌────────┴──────────────────────────┴────────┐         │
│  │           Postes clients Windows             │         │
│  │  Thunderbird / Navigateur (Roundcube)        │         │
│  └──────────────────────────────────────────────┘        │
└──────────────────────────────────────────────────────────┘
```

### 1.2 Tableau des serveurs

| Rôle | Nom | IP | OS |
|------|-----|----|----|
| Active Directory + DNS | DOM-AD-01 | 172.16.12.1 | Windows Server 2022 |
| Serveur Mail | DOM-MAIL-01 | 172.16.13.5 | Debian 11 ou 12 |

### 1.3 Informations AD

| Paramètre | Valeur |
|-----------|--------|
| Domaine AD | `billu.lan` |
| NetBIOS | `BILLU` |
| Base DN | `DC=billu,DC=lan` |
| OU utilisateurs | `OU=BilluUsers,DC=billu,DC=lan` |
| Compte de service | `svc-mail@billu.lan` |
| Mot de passe svc | `Azerty1*` |

> ⚠️ **Note** : Le mot de passe `Azerty1*` contient un `*`. La documentation iRedMail précise de **ne pas utiliser `#`** dans le mot de passe (traité comme commentaire). Le `*` est autorisé.

### 1.4 Prérequis système

- ✅ Debian 11 (Bullseye) ou 12 (Bookworm) en **installation minimale et fraîche**
- ✅ RAM : minimum **2 Go** (4 Go recommandés)
- ✅ Disque : minimum **20 Go**
- ✅ Hostname FQDN : `DOM-MAIL-01.billu.lan`
- ✅ Port 389 ouvert vers le serveur AD (172.16.12.1)
- ✅ Ports mail : 25, 587, 465, 143, 993

---

## 2. Préparation du serveur Debian

### 2.1 Configurer le hostname

```bash
hostnamectl set-hostname DOM-MAIL-01.billu.lan

# Vérifier
hostname        # → DOM-MAIL-01.billu.lan
hostname -f     # → DOM-MAIL-01.billu.lan  (FQDN complet)
```

> ⚠️ **CRITIQUE** : `hostname -f` doit retourner le FQDN complet. iRedMail se base dessus pour configurer tous les services.

### 2.2 Configurer /etc/hosts

```bash
nano /etc/hosts
```

```
127.0.0.1       localhost
172.16.13.5     DOM-MAIL-01.billu.lan    DOM-MAIL-01

# Contrôleur de domaine AD
172.16.12.1     DOM-AD-01.billu.lan      DOM-AD-01
```

### 2.3 Configurer le DNS

```bash
nano /etc/resolv.conf
```

```
domain billu.lan
search billu.lan
nameserver 172.16.12.1
nameserver 8.8.8.8
```

### 2.4 Vérifications réseau préalables

```bash
# Installer les outils nécessaires
apt update && apt install -y ldap-utils net-tools dnsutils curl wget nano

# Test de connectivité vers l'AD
ping -c 3 172.16.12.1

# Test du port LDAP (INDISPENSABLE)
nc -zv 172.16.12.1 389
# Attendu : Connection to 172.16.12.1 389 port [tcp/ldap] succeeded!

# Test LDAP avec le compte de service
ldapsearch -x -H ldap://172.16.12.1 \
  -D "svc-mail@billu.lan" \
  -w 'Azerty1*' \
  -b "OU=BilluUsers,DC=billu,DC=lan" \
  "(objectClass=user)" sAMAccountName userPrincipalName | head -20

# Compter les utilisateurs trouvés
ldapsearch -x -H ldap://172.16.12.1 \
  -D "svc-mail@billu.lan" \
  -w 'Azerty1*' \
  -b "OU=BilluUsers,DC=billu,DC=lan" \
  "(&(objectClass=user)(objectCategory=person))" dn 2>/dev/null \
  | grep "^dn:" | wc -l
```

> Ne passez à l'étape suivante que si le test LDAP retourne bien des utilisateurs.

### 2.5 Mise à jour du système

```bash
apt update && apt upgrade -y
reboot
```

---

## 3. Installation d'iRedMail avec OpenLDAP

### 3.1 Télécharger iRedMail

```bash
cd /root

# Télécharger la dernière version
# Vérifier la version actuelle sur https://www.iredmail.org/download.html
wget https://github.com/iredmail/iRedMail/archive/refs/tags/1.6.8.tar.gz
tar xvf 1.6.8.tar.gz
cd iRedMail-1.6.8
```

### 3.2 Lancer l'installateur

```bash
chmod +x iRedMail.sh
bash iRedMail.sh
```

### 3.3 Assistant d'installation — Réponses complètes

**Étape 1 — Répertoire de stockage des mails**
```
/var/vmail     ← Laisser par défaut
```

**Étape 2 — Serveur web**
```
[*] Nginx      ← Sélectionner Nginx
```

**Étape 3 — Backend de stockage**
```
[ ] MariaDB
[*] OpenLDAP   ← OBLIGATOIRE pour l'intégration AD
[ ] PostgreSQL
```

**Étape 4 — Suffixe LDAP**

iRedMail va vous demander le suffixe LDAP pour son annuaire interne :
```
LDAP suffix: dc=billu,dc=lan
```

**Étape 5 — Mot de passe administrateur OpenLDAP**
```
Azerty1*
(mot de passe du cn=Manager,dc=billu,dc=lan)
```

**Étape 6 — Domaine mail principal**
```
billu.lan
```

**Étape 7 — Mot de passe administrateur mail**
```
Compte : postmaster@billu.lan
Mot de passe : Azerty1*

```

**Étape 8 — Composants optionnels**
```
[*] Roundcube Webmail    ← Cocher (obligatoire pour le webmail)
[*] iRedAdmin            ← Cocher (interface d'administration)
[*] Fail2Ban             ← Recommandé
[ ] ClamAV               ← Optionnel (consomme de la RAM)
[*] SpamAssassin         ← Recommandé
```

**Confirmation finale :**
```
Continue? [y|N]  →  y
```

### 3.4 Ce qu'iRedMail installe et configure automatiquement

Avec le backend OpenLDAP, iRedMail va :
- Installer et configurer **OpenLDAP** (slapd) avec son propre annuaire interne
- Créer les comptes LDAP de service : `cn=vmail` (lecture) et `cn=vmailadmin` (écriture)
- Configurer **Postfix** pour interroger OpenLDAP
- Configurer **Dovecot** pour s'authentifier via OpenLDAP
- Générer le fichier `/root/iRedMail-x.x.x/iRedMail.tips` avec tous les mots de passe

> ⚠️ L'installation prend environ 10-20 minutes.

### 3.5 Conserver les informations d'installation

```bash
# IMPORTANT : lire et sauvegarder ce fichier immédiatement après l'installation
cat /root/iRedMail-1.6.8/iRedMail.tips
```

Ce fichier contient tous les mots de passe générés. **Copiez-le dans un endroit sûr.**

### 3.6 Redémarrer après installation

```bash
reboot
```

---

## 4. Vérification post-installation

### 4.1 Vérifier les services

```bash
# Tous ces services doivent être "active (running)"
systemctl status postfix
systemctl status dovecot
systemctl status slapd      # ← OpenLDAP interne d'iRedMail
systemctl status nginx
systemctl status amavis
```

### 4.2 Vérifier les ports

```bash
ss -tlnp | grep -E "25|587|465|143|993|80|443|389"
```

```
LISTEN  *:25       ← SMTP
LISTEN  *:587      ← SMTP soumission
LISTEN  *:143      ← IMAP
LISTEN  *:993      ← IMAPS
LISTEN  *:443      ← HTTPS (Roundcube / iRedAdmin)
LISTEN  *:389      ← OpenLDAP interne iRedMail (slapd)
```

> 💡 Deux services LDAP coexistent : l'OpenLDAP interne d'iRedMail (port 389 local) ET l'AD Windows (172.16.12.1:389). Ils sont indépendants.

### 4.3 Vérifier l'accès web

- **Roundcube** : https://172.16.13.5/mail/
  - Login : `postmaster@billu.lan` / `Azerty1*`
- **iRedAdmin** : https://172.16.13.5/iredadmin/
  - Login : `postmaster@billu.lan` / `Azerty1*`

> Acceptez l'exception de certificat SSL auto-signé.

### 4.4 Vérifier l'OpenLDAP interne d'iRedMail

```bash
# Lire les credentials depuis le fichier tips
grep -A2 "LDAP" /root/iRedMail-1.6.8/iRedMail.tips | head -20

# Tester l'annuaire OpenLDAP interne d'iRedMail
ldapsearch -x -H ldap://127.0.0.1 \
  -D "cn=vmail,dc=billu,dc=lan" \
  -w 'MOT_DE_PASSE_VMAIL' \
  -b "o=domains,dc=billu,dc=lan" \
  "(objectClass=*)" | head -30
```

---

## 5. Préparation Active Directory

### 5.1 Vérifier le compte de service svc-mail

Le compte `svc-mail@billu.lan` doit déjà exister dans l'AD. Si ce n'est pas encore fait :

```powershell
# Sur le DC Windows (PowerShell en tant qu'administrateur)
New-ADUser `
  -Name "svc-mail" `
  -SamAccountName "svc-mail" `
  -UserPrincipalName "svc-mail@billu.lan" `
  -Path "OU=DSI,OU=BilluUsers,DC=billu,DC=lan" `
  -AccountPassword (ConvertTo-SecureString "Azerty1*" -AsPlainText -Force) `
  -PasswordNeverExpires $true `
  -CannotChangePassword $true `
  -Enabled $true `
  -Description "Compte de service iRedMail - Lecture LDAP"
```

### 5.2 Vérifier la connexion depuis le serveur mail

La documentation officielle stipule que cette commande doit fonctionner avant de continuer :

```bash
# Test avec le compte de service
ldapsearch -x \
  -H ldap://172.16.12.1 \
  -D "svc-mail@billu.lan" \
  -w 'Azerty1*' \
  -b "OU=BilluUsers,DC=billu,DC=lan" \
  "(objectClass=user)" \
  sAMAccountName userPrincipalName

# Si ça affiche les utilisateurs → on peut continuer ✅
# Si erreur "Invalid credentials" → vérifier le mot de passe de svc-mail
```

> 💡 **Port alternatif** : Si le port 389 ne fonctionne pas, essayez le port **3268** (Global Catalog AD). Remplacez `ldap://172.16.12.1` par `ldap://172.16.12.1:3268`.

---

## 6. Intégration AD dans Postfix

On va remplacer les requêtes OpenLDAP interne d'iRedMail par des requêtes vers l'AD Windows.

### 6.1 Sauvegarder la configuration Postfix

```bash
cp /etc/postfix/main.cf /etc/postfix/main.cf.bak
```

### 6.2 Désactiver les paramètres iRedMail non utilisés avec l'AD

La documentation officielle iRedMail indique d'exécuter ces commandes :

```bash
postconf -e virtual_alias_maps=''
postconf -e sender_bcc_maps=''
postconf -e recipient_bcc_maps=''
postconf -e relay_domains=''
postconf -e relay_recipient_maps=''
postconf -e sender_dependent_relayhost_maps=''
```

### 6.3 Configurer le domaine et le transport

```bash
# Déclarer le domaine mail
postconf -e smtpd_sasl_local_domain='billu.lan'
postconf -e virtual_mailbox_domains='billu.lan'

# Utiliser le fichier transport (pour livraison locale via Dovecot)
postconf -e transport_maps='hash:/etc/postfix/transport'
```

### 6.4 Pointer Postfix vers les fichiers AD (à créer)

```bash
# Vérification des expéditeurs SMTP
postconf -e smtpd_sender_login_maps='proxy:ldap:/etc/postfix/ad_sender_login_maps.cf'

# Vérification des boîtes mail locales
postconf -e virtual_mailbox_maps='proxy:ldap:/etc/postfix/ad_virtual_mailbox_maps.cf'

# Gestion des groupes/listes de diffusion AD
postconf -e virtual_alias_maps='proxy:ldap:/etc/postfix/ad_virtual_group_maps.cf'
```

### 6.5 Créer le fichier transport

```bash
nano /etc/postfix/transport
```

```
billu.lan   dovecot
```

```bash
# Compiler le fichier transport
postmap hash:/etc/postfix/transport
```

### 6.6 Créer le fichier ad_sender_login_maps.cf

Ce fichier permet à Postfix de vérifier que l'expéditeur SMTP correspond bien à un compte AD actif.

```bash
nano /etc/postfix/ad_sender_login_maps.cf
```

```ini
server_host     = 172.16.12.1
server_port     = 389
version         = 3
bind            = yes
start_tls       = no
bind_dn         = svc-mail@billu.lan
bind_pw         = Azerty1*
search_base     = OU=BilluUsers,DC=billu,DC=lan
scope           = sub
query_filter    = (&(userPrincipalName=%s)(objectClass=person)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))
result_attribute= userPrincipalName
debuglevel      = 0
```

### 6.7 Créer le fichier ad_virtual_mailbox_maps.cf

Ce fichier permet à Postfix de vérifier qu'un destinataire existe dans l'AD et de construire le chemin de sa boîte mail.

```bash
nano /etc/postfix/ad_virtual_mailbox_maps.cf
```

```ini
server_host     = 172.16.12.1
server_port     = 389
version         = 3
bind            = yes
start_tls       = no
bind_dn         = svc-mail@billu.lan
bind_pw         = Azerty1*
search_base     = OU=BilluUsers,DC=billu,DC=lan
scope           = sub
query_filter    = (&(objectClass=person)(userPrincipalName=%s))
result_attribute= userPrincipalName
result_format   = %d/%u/Maildir/
debuglevel      = 0
```

> 💡 `result_format = %d/%u/Maildir/` construit le chemin de boîte mail :
> `%d` = domaine (billu.lan), `%u` = utilisateur (marie.meyer)
> → Résultat : `billu.lan/marie.meyer/Maildir/`

### 6.8 Créer le fichier ad_virtual_group_maps.cf

Ce fichier gère les groupes AD comme des listes de diffusion mail.

```bash
nano /etc/postfix/ad_virtual_group_maps.cf
```

```ini
server_host     = 172.16.12.1
server_port     = 389
version         = 3
bind            = yes
start_tls       = no
bind_dn         = svc-mail@billu.lan
bind_pw         = Azerty1*
search_base     = OU=BilluUsers,DC=billu,DC=lan
scope           = sub
query_filter    = (&(objectClass=group)(mail=%s))
special_result_attribute = member
leaf_result_attribute = mail
result_attribute= userPrincipalName
debuglevel      = 0
```

### 6.9 Supprimer l'intégration iRedAPD de Postfix

iRedAPD (policy daemon) se base sur le schéma OpenLDAP interne d'iRedMail, il devient inutile avec l'AD.

```bash
nano /etc/postfix/main.cf
```

Chercher et **supprimer** cette ligne (si elle existe) :
```
check_policy_service inet:127.0.0.1:7777
```

### 6.10 Redémarrer Postfix et vérifier

```bash
postfix check
systemctl restart postfix
systemctl status postfix
```

### 6.11 Vérifier les requêtes Postfix vers l'AD

```bash
# Vérifier qu'un utilisateur est bien trouvé
postmap -q marie.meyer@billu.lan ldap:/etc/postfix/ad_virtual_mailbox_maps.cf
# Attendu : billu.lan/marie.meyer/Maildir/

# Vérifier la vérification d'expéditeur
postmap -q marie.meyer@billu.lan ldap:/etc/postfix/ad_sender_login_maps.cf
# Attendu : marie.meyer@billu.lan
```

Si aucune réponse, activer le debug temporairement :

```bash
# Dans /etc/postfix/ad_virtual_mailbox_maps.cf
# Changer debuglevel = 0  →  debuglevel = 1
# Puis relancer postmap et regarder les logs
postmap -q marie.meyer@billu.lan ldap:/etc/postfix/ad_virtual_mailbox_maps.cf
tail -20 /var/log/mail.log
# Remettre debuglevel = 0 après
```

---

## 7. Intégration AD dans Dovecot

C'est l'étape qui permet aux utilisateurs de se connecter avec leur **mot de passe Windows AD**.

### 7.1 Sauvegarder la configuration Dovecot

```bash
cp /etc/dovecot/dovecot-ldap.conf /etc/dovecot/dovecot-ldap.conf.bak
```

### 7.2 Modifier /etc/dovecot/dovecot-ldap.conf

Selon la documentation officielle iRedMail, voici la configuration complète à mettre en place :

```bash
nano /etc/dovecot/dovecot-ldap.conf
```

Remplacer **tout le contenu** par :

```ini
# =============================================================
# Dovecot LDAP — Authentification via Active Directory
# Documentation officielle : https://docs.iredmail.org/active.directory.html
# =============================================================

# --- Connexion au contrôleur de domaine AD ---
hosts           = 172.16.12.1:389

# Protocole LDAP v3 (obligatoire pour AD)
ldap_version    = 3

# --- Authentification par bind direct ---
# Dovecot effectue un "bind" LDAP avec les credentials de l'utilisateur.
# C'est AD lui-même qui valide le mot de passe → méthode la plus sécurisée.
auth_bind       = yes

# --- Compte de service (pour les recherches préalables) ---
dn              = svc-mail@billu.lan
dnpass          = Azerty1*

# --- Base de recherche ---
# Toute la branche BilluUsers, sous-OU incluses
base            = OU=BilluUsers,DC=billu,DC=lan
scope           = subtree
deref           = never

# --- Itération des boîtes (requis pour doveadm mailbox) ---
iterate_attrs   = userPrincipalName=user
iterate_filter  = (&(userPrincipalName=*)(objectClass=person)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))

# --- Filtres de recherche ---
# Cherche par UPN (format user@domain), exclut les comptes désactivés
user_filter     = (&(userPrincipalName=%u)(objectClass=person)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))
pass_filter     = (&(userPrincipalName=%u)(objectClass=person)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))

# --- Attributs ---
pass_attrs      = userPassword=password
default_pass_scheme = CRYPT

# Mappage des attributs utilisateur vers les variables Dovecot
# %Ld = domaine en minuscules, %Ln = login en minuscules
user_attrs      = mail=master_user,mail=user,=home=/var/vmail/vmail1/%Ld/%Ln/,=mail=maildir:~/Maildir/
```

**Explication du filtre `userAccountControl:1.2.840.113556.1.4.803:=2` :**
- C'est un filtre bitwise spécifique à Active Directory
- Le bit 2 = ACCOUNTDISABLE (compte désactivé)
- Le `!` (NOT) exclut les comptes désactivés

### 7.3 Quota global (optionnel mais recommandé)

Puisqu'on n'utilise plus les quotas par utilisateur stockés dans l'OpenLDAP interne, on peut définir un quota global pour tous les utilisateurs AD.

```bash
nano /etc/dovecot/dovecot.conf
```

Chercher la section `plugin {` et ajouter :

```ini
plugin {
    # ... autres paramètres existants ...

    # Quota global pour tous les utilisateurs AD : 1 Go
    quota_rule = *:storage=1G
}
```

### 7.4 Redémarrer Dovecot

```bash
systemctl restart dovecot
systemctl status dovecot
```

### 7.5 Vérifier l'authentification via telnet

La documentation officielle utilise telnet pour vérifier :

```bash
telnet localhost 143
```

Une fois connecté, taper (le point `.` au début est obligatoire) :

```
. login marie.meyer@billu.lan Azerty1*
```

**Résultat attendu :**
```
. OK [CAPABILITY ...] Logged in
```

Pour quitter : `Ctrl+]` puis `quit`

**Alternative avec doveadm :**
```bash
doveadm auth test marie.meyer@billu.lan 'Azerty1*'
# Attendu : passdb: marie.meyer@billu.lan auth succeeded
```

---

## 8. Intégration AD dans Roundcube (carnet d'adresses global)

Cette configuration permet aux utilisateurs de Roundcube de **rechercher des contacts directement dans l'AD** (autocomplétion des adresses).

### 8.1 Modifier la configuration Roundcube

```bash
nano /opt/www/roundcubemail/config/config.inc.php
```

Chercher la configuration LDAP existante (ajoutée par iRedMail) et la **commenter**, puis ajouter la configuration AD :

```php
<?php

# Carnets d'adresses disponibles :
# "sql" = carnet personnel stocké dans la base Roundcube
# "global_ldap_abook" = carnet global depuis l'AD
$config['autocomplete_addressbooks'] = array("sql", "global_ldap_abook");

# Si Roundcube retourne 'user@127.0.0.1' comme adresse, décommenter :
# $config['mail_domain'] = '%d';

#
# Carnet d'adresses global — Active Directory billu.lan
#
$config['ldap_public']["global_ldap_abook"] = array(
    'name'          => 'Annuaire billu.lan',
    'hosts'         => array("172.16.12.1"),    // IP du contrôleur AD
    'port'          => 389,
    'use_tls'       => false,
    'ldap_version'  => '3',
    'network_timeout' => 10,
    'user_specific' => false,

    'base_dn'       => "OU=BilluUsers,DC=billu,DC=lan",
    'bind_dn'       => "svc-mail@billu.lan",
    'bind_pass'     => "Azerty1*",
    'writable'      => false,   // Lecture seule — ne pas modifier l'AD depuis Roundcube

    'search_fields' => array('mail', 'cn', 'sAMAccountName', 'displayname', 'sn', 'givenName'),

    // Correspondance des champs Roundcube → attributs AD
    'fieldmap' => array(
        'name'          => 'cn',
        'displayname'   => 'displayName',
        'surname'       => 'sn',
        'firstname'     => 'givenName',
        'jobtitle'      => 'title',
        'department'    => 'department',
        'company'       => 'company',
        'email'         => 'mail:*',
        'phone:work'    => 'telephoneNumber',
        'phone:home'    => 'homePhone',
        'phone:mobile'  => 'mobile',
        'phone:workfax' => 'facsimileTelephoneNumber',
        'phone:pager'   => 'pager',
        'phone:other'   => 'ipPhone',
        'street:work'   => 'streetAddress',
        'zipcode:work'  => 'postalCode',
        'locality:work' => 'l',
        'region:work'   => 'st',
        'country:work'  => 'c',
        'notes'         => 'description',
        'photo'         => 'jpegPhoto',
        'website'       => 'wWWHomePage',
    ),
    'sort'          => 'cn',
    'scope'         => 'sub',
    // Filtre : utilisateurs et groupes actifs uniquement
    'filter'        => "(&(|(objectclass=person)(objectclass=group))(!(userAccountControl:1.2.840.113556.1.4.803:=2)))",
    'fuzzy_search'  => true,
    'vlv'           => false,
    'sizelimit'     => '0',
    'timelimit'     => '0',
    'referrals'     => false,
);
```

### 8.2 Tester le carnet d'adresses dans Roundcube

1. Se connecter à https://172.16.13.5/mail/ avec `marie.meyer@billu.lan` / `Azerty1*`
2. Créer un nouveau message
3. Dans le champ "À", taper les premières lettres d'un collègue
4. L'autocomplétion doit proposer des adresses issues de l'AD

---

## 9. Configuration Thunderbird

### 9.1 Paramètres de configuration manuelle

Dans Thunderbird, lors de la création du compte : **"Configure manually"** / **"Configuration manuelle"**

#### Réception — IMAP

| Champ | Valeur |
|-------|--------|
| Server hostname | `172.16.13.5` |
| Port | `993` |
| Connection security | `SSL/TLS` |
| Authentication method | `Normal password` |
| Username | `marie.meyer@billu.lan` |

#### Envoi — SMTP

| Champ | Valeur |
|-------|--------|
| Server hostname | `172.16.13.5` |
| Port | `587` |
| Connection security | `STARTTLS` |
| Authentication method | `Normal password` |
| Username | `marie.meyer@billu.lan` |

### 9.2 Gestion du certificat auto-signé

Lors de la première connexion, Thunderbird affiche un avertissement de certificat :

1. Cliquer sur **"Confirm Security Exception"** / **"Confirmer l'exception de sécurité"**
2. Cocher **"Permanently store this exception"** / **"Mémoriser cette exception en permanence"**
3. Valider

### 9.3 Fichier autoconfig (déploiement en masse)

Pour configurer Thunderbird automatiquement sur tous les postes :

```bash
mkdir -p /opt/www/roundcubemail/mail
nano /opt/www/roundcubemail/mail/config-v1.1.xml
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<clientConfig version="1.1">
  <emailProvider id="billu.lan">
    <domain>billu.lan</domain>
    <displayName>Messagerie billu.lan</displayName>
    <displayShortName>billu</displayShortName>

    <incomingServer type="imap">
      <hostname>172.16.13.5</hostname>
      <port>993</port>
      <socketType>SSL</socketType>
      <authentication>password-cleartext</authentication>
      <username>%EMAILADDRESS%</username>
    </incomingServer>

    <outgoingServer type="smtp">
      <hostname>172.16.13.5</hostname>
      <port>587</port>
      <socketType>STARTTLS</socketType>
      <authentication>password-cleartext</authentication>
      <username>%EMAILADDRESS%</username>
    </outgoingServer>
  </emailProvider>
</clientConfig>
```

> Thunderbird cherchera automatiquement ce fichier à `http://autoconfig.billu.lan/mail/config-v1.1.xml` si le DNS est configuré.

---

## 10. Tests et validation

### 10.1 Plan de tests complet

```
TEST 1 — Connectivité réseau
─────────────────────────────
□ ping 172.16.12.1 réussit
□ nc -zv 172.16.12.1 389 réussit (port LDAP AD)

TEST 2 — LDAP vers l'AD
─────────────────────────
□ ldapsearch avec svc-mail@billu.lan retourne des utilisateurs
□ marie.meyer@billu.lan est trouvée dans l'AD

TEST 3 — Postfix → AD
──────────────────────
□ postmap -q marie.meyer@billu.lan ldap:/etc/postfix/ad_virtual_mailbox_maps.cf
  → retourne : billu.lan/marie.meyer/Maildir/

□ postmap -q marie.meyer@billu.lan ldap:/etc/postfix/ad_sender_login_maps.cf
  → retourne : marie.meyer@billu.lan

TEST 4 — Dovecot → AD (CRITIQUE)
──────────────────────────────────
□ telnet localhost 143 puis ". login marie.meyer@billu.lan Azerty1*"
  → retourne : . OK [...] Logged in
OU
□ doveadm auth test marie.meyer@billu.lan 'Azerty1*'
  → retourne : passdb: marie.meyer@billu.lan auth succeeded

TEST 5 — Roundcube
────────────────────
□ Connexion https://172.16.13.5/mail/ avec marie.meyer@billu.lan / Azerty1*
□ Interface webmail s'affiche
□ Autocomplétion carnet d'adresses AD fonctionne

TEST 6 — Thunderbird
──────────────────────
□ Connexion IMAP réussie (dossiers visibles)
□ Connexion SMTP réussie
□ Envoi et réception d'un email de test

TEST 7 — Compte désactivé (optionnel mais recommandé)
───────────────────────────────────────────────────────
□ Désactiver un compte dans l'AD
□ Vérifier que ce compte ne peut plus se connecter
```

### 10.2 Commandes de test rapides

```bash
# Test complet en une séquence

echo "=== TEST 1 - Réseau ===" 
ping -c 2 172.16.12.1 && echo "OK" || echo "ECHEC"
nc -zv 172.16.12.1 389 2>&1 | grep -E "succeeded|refused"

echo "=== TEST 2 - LDAP AD ==="
ldapsearch -x -H ldap://172.16.12.1 -D "svc-mail@billu.lan" -w 'Azerty1*' \
  -b "OU=BilluUsers,DC=billu,DC=lan" \
  "(userPrincipalName=marie.meyer@billu.lan)" \
  userPrincipalName 2>&1 | grep -E "result|userPrincipalName"

echo "=== TEST 3 - Postfix ==="
postmap -q marie.meyer@billu.lan ldap:/etc/postfix/ad_virtual_mailbox_maps.cf

echo "=== TEST 4 - Dovecot ==="
doveadm auth test marie.meyer@billu.lan 'Azerty1*'
```

---

## 11. Dépannage

### 11.1 Dovecot — auth failed

```bash
# Activer les logs détaillés
nano /etc/dovecot/conf.d/10-logging.conf
# Ajouter/modifier :
# auth_verbose = yes
# auth_debug = yes
# auth_debug_passwords = yes   ← JAMAIS en production

systemctl restart dovecot
tail -f /var/log/dovecot.log &
doveadm auth test marie.meyer@billu.lan 'Azerty1*'
```

| Message dans les logs | Cause | Solution |
|---|---|---|
| `Can't contact LDAP server` | AD injoignable | Vérifier `nc -zv 172.16.12.1 389` |
| `Invalid credentials` | Mauvais mot de passe svc-mail | Vérifier `dnpass` dans dovecot-ldap.conf |
| `No such object` | Base DN incorrecte | Vérifier `base =` |
| `user not found` | Filtre trop restrictif | Tester avec filtre simplifié `(userPrincipalName=%u)` |
| Aucun log | Config non prise en compte | Vérifier `doveconf -n` et relancer dovecot |

### 11.2 Postfix — postmap ne retourne rien

```bash
# Activer le debug dans le fichier .cf
# debuglevel = 1

postmap -q marie.meyer@billu.lan ldap:/etc/postfix/ad_virtual_mailbox_maps.cf
tail -20 /var/log/mail.log

# Vérifier la syntaxe du fichier
cat /etc/postfix/ad_virtual_mailbox_maps.cf

# Tester la connexion LDAP manuellement avec les mêmes paramètres
ldapsearch -x -H ldap://172.16.12.1 \
  -D "svc-mail@billu.lan" -w 'Azerty1*' \
  -b "OU=BilluUsers,DC=billu,DC=lan" \
  "(userPrincipalName=marie.meyer@billu.lan)" userPrincipalName
```

### 11.3 Roundcube — Login Failed

```bash
# 1. Vérifier que Dovecot répond
doveadm auth test marie.meyer@billu.lan 'Azerty1*'

# 2. Vérifier les logs Roundcube
tail -50 /opt/www/roundcubemail/logs/errors.log

# 3. Vérifier la config IMAP
grep "imap_host" /opt/www/roundcubemail/config/config.inc.php
```

### 11.4 Port 389 bloqué — utiliser le port 3268

Si le port 389 est filtré, essayer le port **3268** (Global Catalog AD) :

```bash
nc -zv 172.16.12.1 3268

# Si ça fonctionne, remplacer dans tous les fichiers :
# 172.16.12.1:389  →  172.16.12.1:3268
# Dans : dovecot-ldap.conf et les 3 fichiers ad_*.cf de Postfix
```

### 11.5 Réinitialisation complète

```bash
# Restaurer les sauvegardes
cp /etc/dovecot/dovecot-ldap.conf.bak /etc/dovecot/dovecot-ldap.conf
cp /etc/postfix/main.cf.bak /etc/postfix/main.cf

systemctl restart dovecot postfix
```

---

## 12. Récapitulatif de l'architecture

### 12.1 Flux d'authentification

```
Utilisateur entre : marie.meyer@billu.lan / Azerty1*
           │
           ▼ IMAPS :993
     Dovecot
           │
           │ 1. Recherche LDAP (avec svc-mail@billu.lan)
           │    Filtre : (userPrincipalName=marie.meyer@billu.lan)
           ▼
     Active Directory (172.16.12.1:389)
           │
           │ 2. Bind LDAP avec marie.meyer@billu.lan / Azerty1*
           │    AD valide directement le mot de passe Windows
           ▼
     Active Directory
           │
           │ 3. Bind OK → auth succeeded
           ▼
     Dovecot ouvre la boîte
           │ /var/vmail/vmail1/billu.lan/marie.meyer/Maildir/
           ▼
     ✅ Utilisateur connecté
```

### 12.2 Flux d'envoi/réception

```
Envoi (Thunderbird → Postfix)          Réception (Internet → Postfix)
──────────────────────────────         ──────────────────────────────
Thunderbird SMTP:587                   Postfix reçoit le mail sur :25
       │                                       │
       ▼ SASL auth via Dovecot                 ▼
  Postfix vérifie l'expéditeur         Postfix vérifie le destinataire
  via ad_sender_login_maps.cf          via ad_virtual_mailbox_maps.cf
       │ (AD consulté)                         │ (AD consulté)
       ▼                                       ▼
  Amavis (spam/virus)               Amavis (spam/virus)
       │                                       │
       ▼                                       ▼
  Postfix livre le mail             Dovecot dépose en boîte
       │                            /var/vmail/vmail1/billu.lan/
       ▼                                destinataire/Maildir/new/
  ✅ Mail envoyé                         ✅ Mail reçu
```

### 12.3 Fichiers de configuration modifiés

| Fichier | Rôle | Section |
|---------|------|---------|
| `/etc/postfix/main.cf` | Paramètres globaux Postfix | §6.2 à §6.4 |
| `/etc/postfix/transport` | Transport mail pour billu.lan | §6.5 |
| `/etc/postfix/ad_sender_login_maps.cf` | Vérification expéditeurs SMTP | §6.6 |
| `/etc/postfix/ad_virtual_mailbox_maps.cf` | Vérification destinataires + chemin boîte | §6.7 |
| `/etc/postfix/ad_virtual_group_maps.cf` | Groupes AD comme listes de diffusion | §6.8 |
| `/etc/dovecot/dovecot-ldap.conf` | Auth Dovecot via AD | §7.2 |
| `/opt/www/roundcubemail/config/config.inc.php` | Carnet d'adresses global AD | §8.1 |

### 12.4 Ports et protocoles

| Port | Protocole | Usage |
|------|-----------|-------|
| 389 | LDAP | Requêtes vers l'AD (172.16.12.1) |
| 993 | IMAPS | Clients mail (SSL/TLS) ← Recommandé |
| 143 | IMAP | Clients mail (STARTTLS) |
| 587 | SMTP | Envoi authentifié (STARTTLS) |
| 25 | SMTP | Réception MX |
| 443 | HTTPS | Roundcube / iRedAdmin |

---

## 🔗 Références

- [Documentation officielle iRedMail — Intégration AD](https://docs.iredmail.org/active.directory.html)
- [Guide d'installation iRedMail sur Debian](https://docs.iredmail.org/install.iredmail.on.debian.ubuntu.html)
- [Documentation Dovecot LDAP](https://doc.dovecot.org/configuration_manual/authentication/ldap/)

---

*Tutoriel basé sur la documentation officielle iRedMail*
*Backend : OpenLDAP | Serveur mail : DOM-MAIL-01 (172.16.13.5) | AD : DOM-AD-01 (172.16.12.1)*
*Domaine : billu.lan | Compte de service : svc-mail@billu.lan*

```
Get-ADUser -Filter * -SearchBase "OU=BilluUsers,DC=billu,DC=lan" `
  -Properties UserPrincipalName, EmailAddress | ForEach-Object {
    $newUPN   = $_.UserPrincipalName -replace "billU\.lan", "billu.lan"
    $newEmail = $_.EmailAddress      -replace "billU\.lan", "billu.lan"
    Set-ADUser $_ -UserPrincipalName $newUPN -EmailAddress $newEmail
}
```

``` 
# Sur le DC Windows
Add-DnsServerResourceRecordCName -ZoneName "billu.lan" `
  -Name "autoconfig" -HostNameAlias "DOM-MAIL-01.billu.lan"
```

---

C'est parce que Thunderbird essaie de détecter automatiquement la configuration mais n'y arrive pas — il récupère juste le domaine `.billu.lan` sans le nom du serveur.

La solution c'est le fichier **autoconfig** que j'ai mentionné dans le tutoriel. Il faut deux choses :

---

### 1. Créer l'entrée DNS autoconfig sur le DC

```powershell
# Sur le DC Windows
Add-DnsServerResourceRecordCName -ZoneName "billu.lan" `
  -Name "autoconfig" -HostNameAlias "DOM-MAIL-01.billu.lan"
```

### 2. Créer le fichier autoconfig sur le serveur mail

```bash
# Sur DOM-MAIL-01
mkdir -p /opt/www/roundcubemail/autoconfig/mail
nano /opt/www/roundcubemail/autoconfig/mail/config-v1.1.xml
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<clientConfig version="1.1">
  <emailProvider id="billu.lan">
    <domain>billu.lan</domain>
    <displayName>Messagerie billu.lan</displayName>
    <incomingServer type="imap">
      <hostname>172.16.13.5</hostname>
      <port>993</port>
      <socketType>SSL</socketType>
      <authentication>password-cleartext</authentication>
      <username>%EMAILADDRESS%</username>
    </incomingServer>
    <outgoingServer type="smtp">
      <hostname>172.16.13.5</hostname>
      <port>587</port>
      <socketType>STARTTLS</socketType>
      <authentication>password-cleartext</authentication>
      <username>%EMAILADDRESS%</username>
    </outgoingServer>
  </emailProvider>
</clientConfig>
```

### 3. Configurer Nginx pour servir ce fichier

```bash
nano /etc/nginx/sites-available/autoconfig
```

```nginx
server {
    listen 80;
    server_name autoconfig.billu.lan;

    location /mail/config-v1.1.xml {
        alias /opt/www/roundcubemail/autoconfig/mail/config-v1.1.xml;
        default_type text/xml;
    }
}
```

```bash
ln -s /etc/nginx/sites-available/autoconfig /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

---

Après ça, quand un utilisateur entre `matthias.chicaud@billu.lan` dans Thunderbird, le nom d'hôte `172.16.13.5` se remplira automatiquement. ✅
