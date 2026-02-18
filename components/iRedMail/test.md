```
ldapsearch -x -h 172.16.12.1 -D "svc-mail@billu.lan" -W -b "OU=BilluUsers,DC=billu,DC=lan" "(sAMAccountName=marie.meyer)"
```

# 📧 Tutoriel Complet — iRedMail + Active Directory

### Projet TSSR | Infrastructure billu.lan

**Version** : 1.0 | **OS** : Debian 11/12 | **Backend** : MariaDB

---

## 📑 Table des matières

```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 2 # Include headings from the specified level
maxLevel: 2 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

---

## 1. Prérequis et infrastructure

### 1.1 Schéma d'infrastructure

```
┌──────────────────────────────────────────────────────────┐
│                    Réseau billu.lan                       │
│                                                          │
│  ┌─────────────────┐         ┌─────────────────────┐    │
│  │  DOM-AD-01      │ LDAP    │  DOM-MAIL-01         │    │
│  │  172.16.12.1    │◄───────►│  172.16.13.6         │    │
│  │  Windows Srv    │  :389   │  Debian 11/12        │    │
│  │  2022 (AD/DNS)  │         │  iRedMail (MariaDB)  │    │
│  └─────────────────┘         └─────────────────────┘    │
│           ▲                           ▲                  │
│           │                           │                  │
│  ┌────────┴──────────────────────────┴────────┐         │
│  │           Postes clients Windows             │         │
│  │  Thunderbird / Navigateur (Roundcube)        │         │
│  └──────────────────────────────────────────────┘        │
└──────────────────────────────────────────────────────────┘
```

### 1.2 Tableau des serveurs

|Rôle|Nom|IP|OS|
|---|---|---|---|
|Active Directory|DOM-AD-01|172.16.12.1|Windows Server 2022|
|Serveur Mail|DOM-MAIL-01|172.16.13.6|Debian 11 ou 12|

### 1.3 Informations AD

|Paramètre|Valeur|
|---|---|
|Domaine AD|`billu.lan`|
|NetBIOS|`BILLU`|
|Base DN|`DC=billu,DC=lan`|
|OU principale|`OU=BilluUsers,DC=billu,DC=lan`|
|Compte de service|`svc-mail@billu.lan`|
|Mot de passe svc|`Azerty123!`|

### 1.4 Prérequis système pour iRedMail

- ✅ Debian 11 (Bullseye) ou 12 (Bookworm) — **installation minimale**
- ✅ RAM : minimum **2 Go** (4 Go recommandés)
- ✅ Disque : minimum **20 Go**
- ✅ Hostname FQDN configuré : `DOM-MAIL-01.billu.lan`
- ✅ Accès Internet (pour télécharger les paquets)
- ✅ Port 389 ouvert vers le serveur AD
- ✅ Ports mail ouverts : 25, 587, 465, 143, 993

---

## 2. Préparation du serveur Debian

### 2.1 Configuration du hostname

```bash
# Définir le hostname
hostnamectl set-hostname DOM-MAIL-01.billu.lan

# Vérifier
hostname
hostname -f   # Doit retourner : DOM-MAIL-01.billu.lan
```

### 2.2 Configurer /etc/hosts

```bash
nano /etc/hosts
```

Le fichier doit contenir :

```
127.0.0.1       localhost
172.16.13.6     DOM-MAIL-01.billu.lan    DOM-MAIL-01

# Serveur Active Directory
172.16.12.1     DOM-AD-01.billu.lan      DOM-AD-01
```

> ⚠️ **CRITIQUE** : La résolution du FQDN doit fonctionner avant l'installation. iRedMail utilise le hostname pour configurer tous les services.

### 2.3 Configurer le DNS

```bash
nano /etc/resolv.conf
```

```
domain billu.lan
search billu.lan
nameserver 172.16.12.1    # Le contrôleur AD fait aussi office de DNS
nameserver 8.8.8.8        # DNS secondaire pour la résolution externe
```

Pour rendre cette config persistante sous Debian 12 :

```bash
# Désactiver la modification automatique par NetworkManager
nano /etc/NetworkManager/NetworkManager.conf

# Ajouter dans la section [main] :
[main]
dns=none

# Redémarrer NetworkManager
systemctl restart NetworkManager
```

### 2.4 Vérifications réseau

```bash
# Test de résolution DNS
nslookup billu.lan 172.16.12.1
nslookup DOM-AD-01.billu.lan

# Test de connectivité vers l'AD
ping -c 3 172.16.12.1

# Test du port LDAP
nc -zv 172.16.12.1 389
# Attendu : Connection to 172.16.12.1 389 port [tcp/ldap] succeeded!

# Test LDAP (nécessite ldap-utils, installé à l'étape suivante)
apt install -y ldap-utils
ldapsearch -x -H ldap://172.16.12.1 -D "svc-mail@billu.lan" -w 'Azerty123!' \
  -b "OU=BilluUsers,DC=billu,DC=lan" "(objectClass=user)" sAMAccountName | head -20
```

### 2.5 Mise à jour du système

```bash
apt update && apt upgrade -y

# Paquets nécessaires
apt install -y curl wget gnupg2 ca-certificates lsb-release \
               ldap-utils net-tools dnsutils nano vim
```

---

## 3. Installation d'iRedMail

### 3.1 Télécharger iRedMail

```bash
cd /root

# Vérifier la dernière version sur https://www.iredmail.org/download.html
# À la date de ce tutoriel : 1.6.8

wget https://github.com/iredmail/iRedMail/archive/refs/tags/1.6.8.tar.gz
tar xvf 1.6.8.tar.gz
cd iRedMail-1.6.8
```

### 3.2 Lancer l'installateur

```bash
chmod +x iRedMail.sh
bash iRedMail.sh
```

### 3.3 Assistant d'installation — Réponses à fournir

L'assistant graphique (en mode texte) va vous poser plusieurs questions :

**Étape 1 — Répertoire de stockage des mails**

```
/var/vmail     ← Laisser par défaut, valider avec ENTRÉE
```

**Étape 2 — Serveur web**

```
[*] Nginx       ← Sélectionner Nginx (recommandé)
[ ] Apache
```

**Étape 3 — Backend de stockage**

```
[*] MariaDB     ← Sélectionner MariaDB
[ ] OpenLDAP
[ ] PostgreSQL
```

**Étape 4 — Mot de passe MariaDB root**

```
Entrer un mot de passe fort : Ex. MariaDB_Root_2024!
(Notez-le précieusement)
```

**Étape 5 — Domaine mail principal**

```
billu.lan
```

**Étape 6 — Mot de passe administrateur**

```
Compte : postmaster@billu.lan
Mot de passe : Ex. PostMaster_2024!
(Notez-le précieusement)
```

**Étape 7 — Composants optionnels**

```
[*] Roundcube Webmail    ← Cocher
[*] SOGo Groupware       ← Optionnel
[*] netdata              ← Optionnel
[*] iRedAdmin            ← Cocher (interface d'administration)
[*] Fail2Ban             ← Recommandé
[*] ClamAV               ← Optionnel (antivirus, consomme de la RAM)
[*] SpamAssassin         ← Recommandé
```

**Confirmer l'installation :**

```
Do you want to continue? [y|N]  →  y
```

### 3.4 Attendre la fin de l'installation

L'installation prend environ **10-20 minutes**. À la fin, le système affiche un récapitulatif :

```
================== Résumé ==================
- Domaine : billu.lan
- Postmaster : postmaster@billu.lan
- iRedAdmin : https://172.16.13.6/iredadmin/
- Roundcube  : https://172.16.13.6/mail/
- Base MariaDB : vmail / vmailadmin
============================================
```

### 3.5 Redémarrer le serveur

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
systemctl status nginx
systemctl status mariadb
systemctl status amavis    # Filtrage spam/virus
systemctl status clamav-daemon 2>/dev/null  # Si installé
```

### 4.2 Vérifier les ports en écoute

```bash
ss -tlnp | grep -E "25|587|465|143|993|80|443|389"
```

Résultat attendu :

```
LISTEN  0  *:25      ← SMTP
LISTEN  0  *:587     ← SMTP soumission (clients mail)
LISTEN  0  *:465     ← SMTPS
LISTEN  0  *:143     ← IMAP
LISTEN  0  *:993     ← IMAPS
LISTEN  0  *:80      ← HTTP (redirect vers HTTPS)
LISTEN  0  *:443     ← HTTPS (Roundcube / iRedAdmin)
```

### 4.3 Tester l'accès web

- **Roundcube** : https://172.16.13.6/mail/
    - Login : `postmaster@billu.lan` / votre mot de passe admin
- **iRedAdmin** : https://172.16.13.6/iredadmin/
    - Login : `postmaster@billu.lan` / votre mot de passe admin

> ⚠️ Le certificat SSL est auto-signé. Acceptez l'exception de sécurité dans votre navigateur.

### 4.4 Vérifier la base MariaDB

```bash
mysql -u root -p

# Dans MariaDB :
SHOW DATABASES;
# Doit afficher : vmail, iredadmin, roundcubemail

USE vmail;
SHOW TABLES;
# Tables importantes : domain, mailbox, alias, forwardings

SELECT domain FROM domain;
# Doit afficher : billu.lan

EXIT;
```

### 4.5 Tester l'authentification de base (avant AD)

```bash
# Tester avec le compte postmaster créé par iRedMail
doveadm auth test postmaster@billu.lan 'VotreMotDePasse'
# Attendu : passdb: postmaster@billu.lan auth succeeded
```

---

## 5. Préparation Active Directory

### 5.1 Créer le compte de service (sur le serveur AD)

> Si ce n'est pas déjà fait, voici les étapes sur Windows Server 2022 :

**Via PowerShell (sur le DC) :**

```powershell
# Créer l'OU si elle n'existe pas
New-ADOrganizationalUnit -Name "DSI" -Path "OU=BilluUsers,DC=billu,DC=lan"

# Créer le compte de service
New-ADUser `
  -Name "svc-mail" `
  -SamAccountName "svc-mail" `
  -UserPrincipalName "svc-mail@billu.lan" `
  -Path "OU=DSI,OU=BilluUsers,DC=billu,DC=lan" `
  -AccountPassword (ConvertTo-SecureString "Azerty123!" -AsPlainText -Force) `
  -PasswordNeverExpires $true `
  -CannotChangePassword $true `
  -Enabled $true `
  -Description "Compte de service iRedMail - Lecture LDAP uniquement"

# Vérifier
Get-ADUser -Identity "svc-mail" -Properties *
```

**Via l'interface graphique (Active Directory Users and Computers) :**

1. Ouvrir `dsa.msc`
2. Naviguer vers `billu.lan > OU=BilluUsers > OU=DSI`
3. Clic droit > Nouveau > Utilisateur
4. Prénom : `svc-mail`, Nom d'accès : `svc-mail`
5. Mot de passe : `Azerty123!`
6. Cocher : "Le mot de passe n'expire jamais"
7. Décocher : "L'utilisateur doit changer le mot de passe à la prochaine ouverture"

### 5.2 Vérifier les droits du compte de service

Le compte `svc-mail` doit avoir au minimum les droits de **lecture** sur l'OU `BilluUsers` :

```powershell
# Vérifier les droits AD (PowerShell sur le DC)
Get-ACL "AD:\OU=BilluUsers,DC=billu,DC=lan" | Format-List

# Si nécessaire, déléguer l'accès en lecture
# Via dsa.msc > clic droit sur BilluUsers > Déléguer le contrôle
# Choisir svc-mail > "Lire toutes les informations utilisateur"
```

### 5.3 Tester la connexion LDAP depuis le serveur mail

```bash
# Test de base (depuis DOM-MAIL-01)
ldapsearch -x -H ldap://172.16.12.1 \
  -D "svc-mail@billu.lan" \
  -w 'Azerty123!' \
  -b "OU=BilluUsers,DC=billu,DC=lan" \
  -s sub \
  "(objectClass=user)" \
  sAMAccountName userPrincipalName | grep -E "^(dn:|sAMAccountName:|userPrincipalName:)" | head -30

# Compter les utilisateurs
ldapsearch -x -H ldap://172.16.12.1 \
  -D "svc-mail@billu.lan" \
  -w 'Azerty123!' \
  -b "OU=BilluUsers,DC=billu,DC=lan" \
  -s sub \
  "(&(objectClass=user)(objectCategory=person)(userPrincipalName=*))" \
  dn 2>/dev/null | grep "^dn:" | wc -l
# Attendu : 225 (selon votre AD)

# Test sur un utilisateur spécifique
ldapsearch -x -H ldap://172.16.12.1 \
  -D "svc-mail@billu.lan" \
  -w 'Azerty123!' \
  -b "OU=BilluUsers,DC=billu,DC=lan" \
  "(userPrincipalName=marie.meyer@billu.lan)" \
  sAMAccountName userPrincipalName displayName
```

---

## 6. Configuration Dovecot (authentification LDAP/AD)

> C'est l'étape **la plus critique**. Dovecot gère toute l'authentification IMAP. Si cette étape fonctionne, Roundcube et Thunderbird fonctionneront aussi.

### 6.1 Sauvegarder la configuration actuelle

```bash
# Toujours sauvegarder avant de modifier
cp /etc/dovecot/conf.d/10-auth.conf     /etc/dovecot/conf.d/10-auth.conf.bak
cp /etc/dovecot/conf.d/10-mail.conf     /etc/dovecot/conf.d/10-mail.conf.bak
cp /etc/dovecot/conf.d/10-master.conf   /etc/dovecot/conf.d/10-master.conf.bak

# Si ces fichiers existent déjà, les sauvegarder aussi
[ -f /etc/dovecot/conf.d/auth-ldap.conf.ext ] && \
  cp /etc/dovecot/conf.d/auth-ldap.conf.ext /etc/dovecot/conf.d/auth-ldap.conf.ext.bak

[ -f /etc/dovecot/dovecot-ldap.conf.ext ] && \
  cp /etc/dovecot/dovecot-ldap.conf.ext /etc/dovecot/dovecot-ldap.conf.ext.bak
```

### 6.2 Examiner la configuration actuelle

```bash
# Voir ce qu'iRedMail a déjà configuré
cat /etc/dovecot/conf.d/10-auth.conf | grep -v "^#" | grep -v "^$"
ls /etc/dovecot/conf.d/
ls /etc/dovecot/*.conf.ext 2>/dev/null
```

### 6.3 Modifier 10-auth.conf

```bash
nano /etc/dovecot/conf.d/10-auth.conf
```

Localiser et modifier les sections suivantes :

```ini
##
## Authentication processes
##

# Mettre à "no" pour les tests (permet le plain text)
# Remettre à "yes" une fois tout validé (prod)
disable_plaintext_auth = no

# Mécanismes d'authentification
auth_mechanisms = plain login

##
## Password databases
##

# COMMENTER la ligne SQL (iRedMail l'active par défaut)
#!include auth-sql.conf.ext

# DÉCOMMENTER ou AJOUTER la ligne LDAP
!include auth-ldap.conf.ext

# Garder l'authentification système commentée
#!include auth-system.conf.ext

# Garder passdb-extra si présent
#!include auth-passwdfile.conf.ext
```

> 💡 **Important** : On remplace l'auth SQL par l'auth LDAP. Les mots de passe sont validés directement par l'AD, pas par la base MariaDB.

### 6.4 Créer/modifier auth-ldap.conf.ext

```bash
nano /etc/dovecot/conf.d/auth-ldap.conf.ext
```

```ini
# Authentification LDAP pour Active Directory
# Ce fichier définit comment Dovecot interroge l'AD

passdb {
  driver = ldap
  # Fichier de configuration LDAP détaillé
  args = /etc/dovecot/dovecot-ldap.conf.ext
}

# userdb static : les utilisateurs AD sont mappés sur l'utilisateur
# système "vmail" pour l'accès aux boîtes mail physiques
userdb {
  driver = static
  args = uid=vmail gid=vmail home=/var/vmail/vmail1/%d/%n
}
```

**Pourquoi `userdb static` et pas `userdb ldap` ?**

Dans iRedMail, les boîtes mail sont stockées localement dans `/var/vmail/vmail1/<domaine>/<utilisateur>/`. L'AD ne connaît pas ces chemins. On utilise donc `userdb static` pour que tous les utilisateurs AD soient mappés sur l'utilisateur système `vmail` qui possède ces répertoires.

### 6.5 Créer le fichier dovecot-ldap.conf.ext

```bash
nano /etc/dovecot/dovecot-ldap.conf.ext
```

```ini
# =============================================================
# Configuration LDAP/AD pour Dovecot — DOM-MAIL-01
# =============================================================

# --- Connexion au contrôleur de domaine ---
hosts = 172.16.12.1

# Désactiver TLS pour commencer (activer en prod)
tls = no

# Protocole LDAP version 3 (requis pour AD)
ldap_version = 3

# --- Compte de service pour les recherches ---
dn = svc-mail@billu.lan
dnpass = Azerty123!

# --- Base de recherche ---
# Toute la branche BilluUsers, sous-OU incluses
base = OU=BilluUsers,DC=billu,DC=lan

# Recherche récursive dans toutes les sous-OU (subtree)
scope = subtree

# --- Authentification par bind direct (méthode recommandée avec AD) ---
# Dovecot va faire un "bind" LDAP avec les credentials de l'utilisateur.
# C'est AD lui-même qui valide le mot de passe — le plus sécurisé.
auth_bind = yes

# Le bind se fait avec l'UPN complet : marie.meyer@billu.lan
# %u = identifiant fourni par l'utilisateur lors du login
auth_bind_userdn = %u

# --- Filtre de recherche des utilisateurs ---
# Cherche l'utilisateur par son UPN (format user@domain)
# Filtre les comptes désactivés (userAccountControl bit 2)
# Filtre les comptes machine (ne prend que objectCategory=person)
user_filter = (&(objectClass=user)(objectCategory=person)(userPrincipalName=%u)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))

# Même filtre pour l'auth (passdb)
pass_filter = (&(objectClass=user)(objectCategory=person)(userPrincipalName=%u)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))

# --- Attributs récupérés ---
# On récupère l'UPN comme identifiant utilisateur
pass_attrs = userPrincipalName=user

# Schéma de mot de passe (PLAIN car auth_bind gère tout)
default_pass_scheme = PLAIN

# --- Options de débogage (désactiver en prod) ---
# debug_level = 0
```

**Explication du filtre `userAccountControl:1.2.840.113556.1.4.803:=2` :**

- `1.2.840.113556.1.4.803` = opérateur bitwise AND spécifique à AD
- `:=2` = bit 2 = compte désactivé (ACCOUNTDISABLE)
- Le `!` (NOT) exclut les comptes désactivés

### 6.6 Sécuriser les permissions

```bash
chmod 640 /etc/dovecot/dovecot-ldap.conf.ext
chown root:dovecot /etc/dovecot/dovecot-ldap.conf.ext

chmod 640 /etc/dovecot/conf.d/auth-ldap.conf.ext
chown root:dovecot /etc/dovecot/conf.d/auth-ldap.conf.ext
```

### 6.7 Activer les logs verbeux pour le diagnostic

```bash
nano /etc/dovecot/conf.d/10-logging.conf
```

Ajouter/modifier :

```ini
# Fichier de log principal
log_path = /var/log/dovecot.log
info_log_path = /var/log/dovecot-info.log

# Activer pour le débogage (DÉSACTIVER en production)
auth_verbose = yes
auth_debug = yes
auth_debug_passwords = yes   # ⚠️ Jamais en prod !
```

### 6.8 Redémarrer et tester

```bash
# Vérifier la syntaxe avant de redémarrer
doveconf -n 2>&1 | head -50

# Redémarrer Dovecot
systemctl restart dovecot
systemctl status dovecot

# Ouvrir les logs en temps réel (terminal 1)
tail -f /var/log/dovecot.log

# Dans un autre terminal, tester l'authentification
doveadm auth test marie.meyer@billu.lan 'Azerty1*'
```

**Résultats possibles :**

```
✅ Succès :
passdb: marie.meyer@billu.lan auth succeeded
extra fields: user=marie.meyer@billu.lan

❌ Échec possible 1 — utilisateur non trouvé :
auth: ldap(marie.meyer@billu.lan): user not found from userdb
→ Vérifier le filtre user_filter et la base DN

❌ Échec possible 2 — erreur de bind :
auth: ldap(marie.meyer@billu.lan): bind failed: Invalid credentials
→ Vérifier le mot de passe de svc-mail (dn/dnpass)

❌ Échec possible 3 — pas de connexion :
auth: ldap: connect(172.16.12.1, 389) failed: Connection refused
→ Vérifier la connectivité réseau et le pare-feu
```

### 6.9 Tableau de dépannage Dovecot

|Message dans les logs|Cause probable|Solution|
|---|---|---|
|`Can't connect to LDAP server`|AD injoignable|`nc -zv 172.16.12.1 389`|
|`Invalid credentials`|Mauvais mdp svc-mail|Vérifier `dnpass` dans dovecot-ldap.conf.ext|
|`No such object`|Base DN incorrecte|Vérifier `base =`|
|`user not found`|Filtre trop restrictif|Tester avec `(userPrincipalName=%u)` seul|
|`Auth mechanism not supported`|Mécanisme PLAIN non activé|Vérifier `auth_mechanisms` dans 10-auth.conf|
|Aucun log lors du test|`doveadm` ne passe pas par Dovecot|Vérifier `!include auth-ldap.conf.ext`|

---

## 7. Configuration Postfix

Postfix gère la **réception et l'envoi** des emails. Il délègue l'authentification SMTP à Dovecot via SASL.

### 7.1 Vérifier la configuration SASL existante

```bash
# iRedMail configure normalement déjà ces paramètres
postconf smtpd_sasl_type
postconf smtpd_sasl_path
postconf smtpd_sasl_auth_enable
```

Les valeurs attendues :

```
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
```

Si ces valeurs sont correctes, **Postfix utilise déjà Dovecot pour l'auth**. Une fois Dovecot configuré pour l'AD, Postfix bénéficie automatiquement de l'authentification AD.

### 7.2 Vérifier que le domaine billu.lan est connu de Postfix

```bash
# Le domaine doit être dans la liste des domaines virtuels
mysql -u root -p vmail -e "SELECT domain, transport FROM domain;"
```

Si `billu.lan` n'apparaît pas :

```sql
mysql -u root -p vmail

INSERT INTO domain (
  domain, description, transport, backupmx,
  maxquota, quota, defaultuserquota, defaultlanguage,
  created, modified, expired, active
) VALUES (
  'billu.lan', 'Domaine principal', 'dovecot', 0,
  0, 0, 1024, 'fr_FR',
  NOW(), NOW(), '9999-12-31 00:00:00', 1
);
EXIT;
```

### 7.3 Vérifier la configuration du socket SASL dans Dovecot

```bash
grep -A 15 "Postfix\|postfix" /etc/dovecot/conf.d/10-master.conf
```

Ce bloc **doit** exister :

```ini
service auth {
  # Dovecot expose un socket Unix pour Postfix
  unix_listener /var/spool/postfix/private/auth {
    mode = 0660
    user = postfix
    group = postfix
  }
}
```

S'il est absent :

```bash
nano /etc/dovecot/conf.d/10-master.conf
# Ajouter le bloc ci-dessus dans la section service auth { }
systemctl restart dovecot postfix
```

### 7.4 Vérifier main.cf de Postfix

```bash
cat /etc/postfix/main.cf | grep -v "^#" | grep -v "^$"
```

Les paramètres importants pour notre configuration :

```ini
# Domaine de destination
myhostname = DOM-MAIL-01.billu.lan
myorigin = $myhostname
mydomain = billu.lan

# SASL (délégué à Dovecot)
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes

# Domaines virtuels (gérés par MariaDB)
virtual_mailbox_domains = proxy:mysql:/etc/postfix/mysql-virtual_mailbox_domains.cf
virtual_mailbox_maps = proxy:mysql:/etc/postfix/mysql-virtual_mailbox_maps.cf
virtual_alias_maps = proxy:mysql:/etc/postfix/mysql-virtual_alias_maps.cf
```

### 7.5 Vérifier que les requêtes MySQL fonctionnent

```bash
# Vérifier la config MySQL de Postfix
cat /etc/postfix/mysql-virtual_mailbox_domains.cf

# Tester la résolution du domaine
postmap -q billu.lan mysql:/etc/postfix/mysql-virtual_mailbox_domains.cf
# Attendu : billu.lan (ou 1)

# Tester la résolution d'une boîte mail (après création via script)
postmap -q marie.meyer@billu.lan mysql:/etc/postfix/mysql-virtual_mailbox_maps.cf
# Attendu : billu.lan/marie.meyer/  (chemin relatif de la boîte)
```

### 7.6 Redémarrer Postfix

```bash
postfix check   # Vérification de syntaxe
systemctl restart postfix
systemctl status postfix
```

---

## 8. Création automatique des boîtes mail (script)

Lorsqu'un utilisateur AD se connecte à Roundcube, sa boîte mail doit **déjà exister** dans la base MariaDB ET sur le disque. Ce script synchronise les utilisateurs AD vers iRedMail.

### 8.1 Architecture de la synchronisation

```
AD (LDAP)                iRedMail (MariaDB)         Disque
─────────                ──────────────────         ─────
sAMAccountName ──────► table: mailbox             /var/vmail/
userPrincipalName        table: forwardings        vmail1/billu.lan/
                                                  marie.meyer/
                                                  ├── cur/
                                                  ├── new/
                                                  └── tmp/
```

### 8.2 Récupérer le mot de passe MariaDB vmailadmin

```bash
grep "password" /etc/postfix/mysql-virtual_mailbox_maps.cf
# Ou
grep "password" /etc/dovecot/dovecot-sql.conf.ext
```

### 8.3 Le script de synchronisation complet

```bash
nano /usr/local/bin/sync-ad-mailboxes.sh
chmod +x /usr/local/bin/sync-ad-mailboxes.sh
```

```bash
#!/bin/bash
# =============================================================
# sync-ad-mailboxes.sh — Synchronisation AD → iRedMail
# Projet TSSR | billu.lan
# Usage : ./sync-ad-mailboxes.sh [--dry-run] [--user email]
# =============================================================

set -euo pipefail

# --- Configuration ---
LDAP_SERVER="172.16.12.1"
BIND_DN="svc-mail@billu.lan"
BIND_PW="Azerty123!"
BASE_DN="OU=BilluUsers,DC=billu,DC=lan"
MAIL_DOMAIN="billu.lan"

VMAIL_BASE="/var/vmail"
VMAIL_NODE="vmail1"
VMAIL_USER="vmail"
VMAIL_GROUP="vmail"

DB_HOST="127.0.0.1"
DB_PORT="3306"
DB_NAME="vmail"
DB_USER="vmailadmin"
# Récupère automatiquement le mot de passe depuis la config Postfix
DB_PASS="$(grep -oP "(?<=password = ).*" /etc/postfix/mysql-virtual_mailbox_maps.cf 2>/dev/null | head -1)"

LOG_FILE="/var/log/sync-ad-mailboxes.log"
DRY_RUN=false
SPECIFIC_USER=""

# --- Couleurs ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m'; BOLD='\033[1m'

# --- Fonctions de log ---
log()      { echo -e "$(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "$LOG_FILE"; }
log_info() { log "${GREEN}[INFO]${NC}  $*"; }
log_warn() { log "${YELLOW}[WARN]${NC}  $*"; }
log_error(){ log "${RED}[ERROR]${NC} $*"; }
log_skip() { log "${BLUE}[SKIP]${NC}  $*"; }

# --- Gestion des arguments ---
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run) DRY_RUN=true; log_warn "MODE DRY-RUN : aucune modification ne sera effectuée" ;;
    --user)    SPECIFIC_USER="$2"; shift ;;
    *) echo "Usage: $0 [--dry-run] [--user email@domain]"; exit 1 ;;
  esac
  shift
done

# --- Vérifications préalables ---
log_info "=== Démarrage de la synchronisation AD → iRedMail ==="
log_info "Serveur LDAP : $LDAP_SERVER | Domaine : $MAIL_DOMAIN"

# Vérifier les dépendances
for cmd in ldapsearch mysql; do
  command -v "$cmd" >/dev/null 2>&1 || { log_error "Commande manquante : $cmd"; exit 1; }
done

# Vérifier la connexion LDAP
if ! ldapsearch -x -H "ldap://${LDAP_SERVER}" -D "$BIND_DN" -w "$BIND_PW" \
     -b "$BASE_DN" -s base "(objectClass=*)" dn >/dev/null 2>&1; then
  log_error "Connexion LDAP échouée. Vérifier les paramètres."
  exit 1
fi
log_info "Connexion LDAP : OK"

# Vérifier la connexion MySQL
if ! mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" \
     -e "SELECT 1;" >/dev/null 2>&1; then
  log_error "Connexion MySQL échouée. Vérifier DB_USER/DB_PASS."
  exit 1
fi
log_info "Connexion MySQL : OK"

# --- Construction du filtre LDAP ---
if [ -n "$SPECIFIC_USER" ]; then
  LDAP_FILTER="(&(objectClass=user)(objectCategory=person)(userPrincipalName=${SPECIFIC_USER})(!(userAccountControl:1.2.840.113556.1.4.803:=2)))"
  log_info "Mode utilisateur unique : $SPECIFIC_USER"
else
  LDAP_FILTER="(&(objectClass=user)(objectCategory=person)(userPrincipalName=*@${MAIL_DOMAIN})(!(userAccountControl:1.2.840.113556.1.4.803:=2)))"
fi

# --- Récupérer les utilisateurs depuis AD ---
log_info "Interrogation de l'AD..."

USERS=$(ldapsearch -x -LLL \
  -H "ldap://${LDAP_SERVER}" \
  -D "${BIND_DN}" \
  -w "${BIND_PW}" \
  -b "${BASE_DN}" \
  -s sub \
  "$LDAP_FILTER" \
  userPrincipalName displayName department 2>/dev/null)

if [ -z "$USERS" ]; then
  log_error "Aucun utilisateur récupéré depuis l'AD."
  exit 1
fi

# Extraire les UPN
UPN_LIST=$(echo "$USERS" | grep "^userPrincipalName:" | awk '{print $2}')
USER_COUNT=$(echo "$UPN_LIST" | grep -c "@" || true)
log_info "$USER_COUNT utilisateurs trouvés dans l'AD."

# --- Traitement ---
CREATED=0; SKIPPED=0; ERRORS=0

while IFS= read -r UPN; do
  [ -z "$UPN" ] && continue

  USERNAME=$(echo "$UPN" | cut -d'@' -f1)
  DOMAIN=$(echo "$UPN" | cut -d'@' -f2)

  # Filtrer les domaines inattendus
  if [ "$DOMAIN" != "$MAIL_DOMAIN" ]; then
    log_warn "Domaine inattendu pour $UPN — ignoré."
    ((SKIPPED++)); continue
  fi

  # Vérifier si la boîte existe déjà
  EXISTS=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" \
    -sNe "SELECT COUNT(*) FROM mailbox WHERE username='${UPN}';" 2>/dev/null)

  if [ "${EXISTS:-0}" -gt 0 ]; then
    log_skip "Boîte existante : $UPN"
    ((SKIPPED++)); continue
  fi

  # Mode dry-run : afficher sans créer
  if $DRY_RUN; then
    log_info "[DRY-RUN] Créerait : $UPN"
    ((CREATED++)); continue
  fi

  # --- Créer le répertoire mail physique ---
  MAIL_DIR="${VMAIL_BASE}/${VMAIL_NODE}/${DOMAIN}/${USERNAME}"
  mkdir -p "${MAIL_DIR}"/{cur,new,tmp,Trash/{cur,new,tmp},Sent/{cur,new,tmp},Drafts/{cur,new,tmp}}
  chown -R "${VMAIL_USER}:${VMAIL_GROUP}" "${VMAIL_BASE}/${VMAIL_NODE}/${DOMAIN}"
  chmod -R 700 "$MAIL_DIR"

  # --- Insérer dans MariaDB ---
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

  if mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" <<SQL 2>/dev/null
INSERT INTO mailbox (
  username, password, name,
  storagebasedirectory, storagenode, maildir,
  quota, domain, isadmin, isglobaladmin,
  created, modified, expired, active
) VALUES (
  '${UPN}',
  '{PLAIN}AD_AUTH_ONLY_DO_NOT_USE',
  '${USERNAME}',
  '${VMAIL_BASE}',
  '${VMAIL_NODE}',
  '${DOMAIN}/${USERNAME}/',
  1024,
  '${DOMAIN}',
  0, 0,
  '${TIMESTAMP}', '${TIMESTAMP}',
  '9999-12-31 00:00:00',
  1
);

-- Alias requis pour la distribution du courrier
INSERT IGNORE INTO forwardings (
  address, forwarding, domain, dest_domain, is_list, active
) VALUES (
  '${UPN}', '${UPN}', '${DOMAIN}', '${DOMAIN}', 0, 1
);
SQL
  then
    log_info "✓ Créé : $UPN → $MAIL_DIR"
    ((CREATED++))
  else
    log_error "✗ Échec création : $UPN"
    ((ERRORS++))
  fi

done <<< "$UPN_LIST"

# --- Rapport final ---
echo ""
log_info "============================================"
log_info " Synchronisation terminée"
log_info "============================================"
log_info " ✓ Créées  : $CREATED boîtes"
log_info " ⊘ Ignorées: $SKIPPED boîtes (existantes)"
log_info " ✗ Erreurs : $ERRORS"
log_info "============================================"
log_info "Log complet : $LOG_FILE"
```

### 8.4 Utilisation du script

```bash
# Test sans modification (affiche ce qui serait créé)
/usr/local/bin/sync-ad-mailboxes.sh --dry-run

# Créer la boîte d'un seul utilisateur
/usr/local/bin/sync-ad-mailboxes.sh --user marie.meyer@billu.lan

# Synchroniser tous les utilisateurs
/usr/local/bin/sync-ad-mailboxes.sh

# Voir les logs
tail -f /var/log/sync-ad-mailboxes.log
```

### 8.5 Automatiser avec Cron

```bash
nano /etc/cron.d/sync-ad-mailboxes
```

```bash
# Synchronisation quotidienne à 2h00 du matin
# (Crée les boîtes des nouveaux utilisateurs AD automatiquement)
0 2 * * * root /usr/local/bin/sync-ad-mailboxes.sh >> /var/log/sync-ad-mailboxes.log 2>&1
```

### 8.6 Vérifier après synchronisation

```bash
# Vérifier en base
mysql -u root -p vmail -e "SELECT username, active, created FROM mailbox ORDER BY created DESC LIMIT 10;"

# Vérifier sur le disque
ls -la /var/vmail/vmail1/billu.lan/ | head -20

# Tester l'auth IMAP complète
doveadm auth test marie.meyer@billu.lan 'Azerty1*'
```

---

## 9. Configuration Roundcube

### 9.1 Vérifier la configuration Roundcube

```bash
cat /opt/www/roundcubemail/config/config.inc.php | grep -v "^#" | grep -v "^$"
# ou selon votre installation :
find / -name "config.inc.php" -path "*/roundcube*" 2>/dev/null
```

### 9.2 Paramètres IMAP de Roundcube

```bash
nano /opt/www/roundcubemail/config/config.inc.php
```

Vérifier/modifier ces paramètres :

```php
<?php

// Serveur IMAP — Roundcube se connecte à Dovecot local
$config['imap_host'] = 'ssl://localhost:993';

// Serveur SMTP — Roundcube envoie via Postfix local
$config['smtp_host'] = 'tls://localhost:587';
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';

// Domaine par défaut (suggéré à la connexion)
$config['username_domain'] = 'billu.lan';

// Format du login : utiliser l'adresse complète user@domain
$config['login_autocomplete'] = 2;

// Langue par défaut
$config['language'] = 'fr_FR';
```

### 9.3 Tester Roundcube

1. Ouvrir https://172.16.13.6/mail/ dans un navigateur
2. Accepter l'exception de certificat SSL
3. Se connecter avec :
    - **Login** : `marie.meyer@billu.lan`
    - **Mot de passe** : `Azerty1*` (mot de passe Windows AD)
4. Si l'authentification fonctionne, vous devez voir l'interface de messagerie

**En cas d'échec dans Roundcube :**

```bash
# Vérifier les logs Roundcube
tail -f /var/log/nginx/error.log
tail -f /opt/www/roundcubemail/logs/errors.log

# Vérifier que Dovecot IMAP écoute
ss -tlnp | grep 993
```

---

## 10. Configuration Thunderbird

### 10.1 Paramètres de configuration manuelle

Lors de la création du compte dans Thunderbird, sélectionner **"Configuration manuelle"** :

#### Réception — IMAP

|Champ|Valeur|
|---|---|
|Serveur|`172.16.13.6`|
|Port|`993`|
|Sécurité|`SSL/TLS`|
|Authentification|`Mot de passe normal`|
|Identifiant|`marie.meyer@billu.lan`|

#### Envoi — SMTP

|Champ|Valeur|
|---|---|
|Serveur|`172.16.13.6`|
|Port|`587`|
|Sécurité|`STARTTLS`|
|Authentification|`Mot de passe normal`|
|Identifiant|`marie.meyer@billu.lan`|

### 10.2 Gestion du certificat auto-signé

iRedMail génère un certificat SSL auto-signé. Thunderbird va afficher un avertissement. Pour l'accepter :

1. Lors de la connexion, une fenêtre s'affiche : **"Certificat de sécurité du serveur"**
2. Cliquer sur **"Confirmer l'exception de sécurité"**
3. Cocher **"Mémoriser en permanence cette exception"**
4. Cliquer sur **"Confirmer l'exception de sécurité"**

### 10.3 Déploiement en masse via autoconfig

Pour déployer la configuration automatiquement sur tous les postes du domaine, créer un fichier d'autoconfig :

```bash
# Sur DOM-MAIL-01, créer le fichier autoconfig
mkdir -p /var/www/html/mail
nano /var/www/html/mail/config-v1.1.xml
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<clientConfig version="1.1">
  <emailProvider id="billu.lan">
    <domain>billu.lan</domain>
    <displayName>Messagerie billu.lan</displayName>
    <displayShortName>billu</displayShortName>

    <incomingServer type="imap">
      <hostname>172.16.13.6</hostname>
      <port>993</port>
      <socketType>SSL</socketType>
      <authentication>password-cleartext</authentication>
      <username>%EMAILADDRESS%</username>
    </incomingServer>

    <outgoingServer type="smtp">
      <hostname>172.16.13.6</hostname>
      <port>587</port>
      <socketType>STARTTLS</socketType>
      <authentication>password-cleartext</authentication>
      <username>%EMAILADDRESS%</username>
    </outgoingServer>
  </emailProvider>
</clientConfig>
```

Thunderbird cherche automatiquement ce fichier à l'adresse `http://autoconfig.billu.lan/mail/config-v1.1.xml`.

### 10.4 Déploiement via GPO (optionnel)

Pour déployer Thunderbird et sa configuration sur tous les postes via GPO Windows :

1. Créer un partage réseau avec l'installeur MSI de Thunderbird
2. Créer un GPO "Installation Thunderbird" dans la GPO Computer Configuration
3. Pré-créer le fichier de profil Thunderbird avec les paramètres IMAP/SMTP

---

## 11. Tests et validation

### 11.1 Plan de tests complet

```
TEST 1 — Connectivité réseau
─────────────────────────────
□ ping 172.16.12.1 depuis DOM-MAIL-01
□ nc -zv 172.16.12.1 389 (port LDAP)

TEST 2 — Authentification LDAP directe
───────────────────────────────────────
□ ldapsearch avec svc-mail retourne des utilisateurs
□ ldapsearch filtre correctement les comptes désactivés
□ ldapsearch trouve marie.meyer@billu.lan

TEST 3 — Authentification Dovecot
──────────────────────────────────
□ doveadm auth test marie.meyer@billu.lan 'Azerty1*'
□ Résultat : auth succeeded
□ Logs Dovecot affichent la connexion

TEST 4 — Boîtes mail créées
─────────────────────────────
□ Script sync exécuté
□ Entrée présente en DB : SELECT * FROM mailbox WHERE username='marie.meyer@billu.lan';
□ Répertoire présent : ls /var/vmail/vmail1/billu.lan/marie.meyer/

TEST 5 — Roundcube
────────────────────
□ Connexion https://172.16.13.6/mail/
□ Login marie.meyer@billu.lan / Azerty1*
□ Interface webmail visible
□ Envoi d'un email de test

TEST 6 — Thunderbird
──────────────────────
□ Création du compte manuellement
□ Connexion IMAP réussie (dossiers visibles)
□ Connexion SMTP réussie (envoi possible)
□ Réception d'un email de test
```

### 11.2 Commandes de test rapides

```bash
# Test 1 — Réseau
ping -c 2 172.16.12.1 && echo "OK" || echo "FAIL"
nc -zv 172.16.12.1 389 && echo "LDAP OK" || echo "LDAP FAIL"

# Test 2 — LDAP
ldapsearch -x -H ldap://172.16.12.1 -D "svc-mail@billu.lan" -w 'Azerty123!' \
  -b "OU=BilluUsers,DC=billu,DC=lan" \
  "(userPrincipalName=marie.meyer@billu.lan)" userPrincipalName 2>&1 \
  | grep -E "result|userPrincipalName"

# Test 3 — Dovecot auth
doveadm auth test marie.meyer@billu.lan 'Azerty1*'

# Test 4 — DB mailbox
mysql -u root -p vmail -e \
  "SELECT username, active, quota FROM mailbox WHERE domain='billu.lan';"

# Test 5 — IMAP via telnet
openssl s_client -connect 172.16.13.6:993 -quiet 2>/dev/null
# Taper : a login marie.meyer@billu.lan Azerty1*
# Attendu : a OK Logged in

# Test 6 — SMTP
openssl s_client -connect 172.16.13.6:587 -starttls smtp -quiet 2>/dev/null
# Taper : EHLO test
# Taper : AUTH LOGIN
# (base64 encode l'identifiant et le mot de passe)
```

### 11.3 Test IMAP complet via imapsync (optionnel)

```bash
apt install -y imapsync

# Vérifier qu'une connexion IMAP fonctionne
imapsync \
  --host1 localhost --user1 marie.meyer@billu.lan --password1 'Azerty1*' \
  --host2 localhost --user2 marie.meyer@billu.lan --password2 'Azerty1*' \
  --justlogin
# Attendu : Login OK sur les deux connexions
```

---

## 12. Dépannage

### 12.1 Problème : doveadm auth test retourne "auth failed"

**Étape 1** — Activer les logs détaillés :

```bash
# Dans /etc/dovecot/conf.d/10-logging.conf
auth_verbose = yes
auth_debug = yes
auth_debug_passwords = yes
systemctl restart dovecot
tail -f /var/log/dovecot.log &
doveadm auth test marie.meyer@billu.lan 'Azerty1*'
```

**Étape 2** — Analyser les logs :

```bash
# Si vous voyez : "unknown user"
# → Le filtre user_filter ne trouve pas l'utilisateur
# → Tester avec un filtre simplifié :
# user_filter = (userPrincipalName=%u)

# Si vous voyez : "ldap: bind failed: Invalid credentials"
# → Le mot de passe dans dnpass est incorrect
# → Tester : ldapsearch -D "svc-mail@billu.lan" -w 'Azerty123!' ...

# Si vous voyez : "Can't contact LDAP server"
# → Problème réseau ou mauvaise IP dans "hosts ="
# → Tester : nc -zv 172.16.12.1 389
```

### 12.2 Problème : aucun log dans dovecot.log lors du test

```bash
# Vérifier que 10-auth.conf inclut bien auth-ldap
grep "include" /etc/dovecot/conf.d/10-auth.conf

# Vérifier qu'il n'y a pas d'erreur de syntaxe
doveconf -n 2>&1

# Vérifier que dovecot est bien démarré
systemctl status dovecot -l

# Vérifier les logs système
journalctl -u dovecot -n 50
```

### 12.3 Problème : Roundcube "Login Failed"

```bash
# 1. Vérifier que Dovecot répond sur IMAP
openssl s_client -connect localhost:993

# 2. Vérifier les logs Roundcube
tail -50 /var/log/roundcube/errors.log
# ou
tail -50 /opt/www/roundcubemail/logs/errors.log

# 3. Vérifier la config IMAP dans Roundcube
grep "imap_host" /opt/www/roundcubemail/config/config.inc.php

# 4. Tester l'auth Dovecot directement
doveadm auth test marie.meyer@billu.lan 'Azerty1*'
```

### 12.4 Problème : Le mail n'arrive pas dans la boîte

```bash
# 1. Tester la livraison locale
swaks --to marie.meyer@billu.lan --from test@billu.lan \
      --server 172.16.13.6 --port 587 \
      --auth-user marie.meyer@billu.lan --auth-password 'Azerty1*'
# Installer swaks : apt install swaks

# 2. Vérifier la file Postfix
mailq
postqueue -p

# 3. Vérifier les logs Postfix
tail -50 /var/log/mail.log | grep "marie.meyer"

# 4. Vérifier que la boîte existe en DB
mysql -u root -p vmail \
  -e "SELECT username, maildir, active FROM mailbox WHERE username='marie.meyer@billu.lan';"

# 5. Vérifier le répertoire physique
ls -la /var/vmail/vmail1/billu.lan/marie.meyer/
```

### 12.5 Problème : Erreur de certificat SSL

```bash
# Voir le certificat actuel
openssl s_client -connect 172.16.13.6:993 2>/dev/null | openssl x509 -noout -text | \
  grep -E "Subject:|Issuer:|Not After"

# Régénérer le certificat auto-signé iRedMail
# (si expiré ou invalide)
cd /etc/ssl/private/
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout iRedMail.key -out iRedMail.crt \
  -subj "/C=FR/ST=France/O=billu/CN=DOM-MAIL-01.billu.lan"

systemctl restart nginx dovecot postfix
```

### 12.6 Réinitialisation complète si nécessaire

```bash
# Restaurer les backups Dovecot
cp /etc/dovecot/conf.d/10-auth.conf.bak     /etc/dovecot/conf.d/10-auth.conf
cp /etc/dovecot/conf.d/auth-ldap.conf.ext.bak /etc/dovecot/conf.d/auth-ldap.conf.ext

systemctl restart dovecot
```

---

## 13. Sécurisation (optionnel)

### 13.1 Chiffrement LDAP (LDAPS)

```bash
# Sur le serveur AD — exporter le certificat du CA AD
# (via Gestionnaire de certificats ou PowerShell)

# Copier le certificat CA sur DOM-MAIL-01
scp admin@172.16.12.1:C:/Windows/System32/certsrv/CertEnroll/billu-CA.cer \
    /usr/local/share/ca-certificates/billu-CA.crt

update-ca-certificates

# Modifier dovecot-ldap.conf.ext pour LDAPS
nano /etc/dovecot/dovecot-ldap.conf.ext
```

```ini
# Remplacer :
hosts = 172.16.12.1
tls = no

# Par :
hosts = 172.16.12.1:636
tls = yes
ssl_ca = /usr/local/share/ca-certificates/billu-CA.crt
tls_require_cert = demand
```

```bash
systemctl restart dovecot
doveadm auth test marie.meyer@billu.lan 'Azerty1*'
```

### 13.2 Activer Fail2Ban pour la messagerie

```bash
# Vérifier que Fail2Ban est installé
systemctl status fail2ban

# Configurer une jail pour Dovecot
nano /etc/fail2ban/jail.local
```

```ini
[dovecot]
enabled  = true
port     = imap,imaps,submission,465,sieve
logpath  = /var/log/dovecot.log
maxretry = 5
bantime  = 3600

[postfix]
enabled  = true
port     = smtp,465,submission
logpath  = /var/log/mail.log
maxretry = 5
```

```bash
systemctl restart fail2ban
fail2ban-client status
```

### 13.3 Désactiver les logs de mots de passe en production

```bash
nano /etc/dovecot/conf.d/10-logging.conf
```

```ini
# En PRODUCTION : désactiver ces options
auth_verbose = no
auth_debug = no
auth_debug_passwords = no    # ⚠️ IMPÉRATIF en prod

# Garder uniquement les erreurs
log_path = /var/log/dovecot.log
```

```bash
systemctl restart dovecot
```

### 13.4 Certificat Let's Encrypt (si domaine public)

```bash
# Si DOM-MAIL-01 est accessible depuis Internet avec un nom de domaine public
apt install -y certbot python3-certbot-nginx

certbot --nginx -d mail.billu.lan
# (Nécessite un enregistrement DNS public pour mail.billu.lan)

# Configurer le renouvellement automatique
echo "0 0 * * * root certbot renew --quiet" > /etc/cron.d/certbot-renew
```

---

## 14. Récapitulatif de l'architecture

### 14.1 Flux d'authentification

```
Utilisateur (Roundcube / Thunderbird)
         │
         │ marie.meyer@billu.lan / Azerty1*
         ▼
    Dovecot IMAP (:993)
         │
         │ 1. Recherche LDAP avec svc-mail
         │    (filtre par userPrincipalName)
         ▼
    Active Directory (:389)
         │
         │ 2. Bind LDAP avec les credentials utilisateur
         │    (AD valide le mot de passe)
         ▼
    Active Directory (:389)
         │
         │ 3. Bind réussi → auth succeeded
         ▼
    Dovecot IMAP
         │
         │ 4. Ouvre la boîte mail
         │    /var/vmail/vmail1/billu.lan/marie.meyer/
         ▼
    Utilisateur connecté ✅
```

### 14.2 Flux d'envoi d'email

```
Thunderbird / Roundcube
         │ SMTP:587 + STARTTLS
         ▼
    Postfix (SMTP)
         │ SASL → Dovecot (validation credentials)
         │ Dovecot → AD (vérification mot de passe)
         ▼
    Amavis (filtrage spam/virus)
         │
         ▼
    Postfix (livraison)
         │ LMTP
         ▼
    Dovecot (dépôt en boîte)
         │
         ▼
    /var/vmail/vmail1/billu.lan/destinataire/new/ ✅
```

### 14.3 Fichiers de configuration modifiés

|Fichier|Rôle|Section|
|---|---|---|
|`/etc/dovecot/conf.d/10-auth.conf`|Active l'auth LDAP|§6.3|
|`/etc/dovecot/conf.d/auth-ldap.conf.ext`|passdb/userdb LDAP|§6.4|
|`/etc/dovecot/dovecot-ldap.conf.ext`|Paramètres LDAP AD|§6.5|
|`/etc/postfix/main.cf`|Config Postfix SASL|§7.1|
|`/usr/local/bin/sync-ad-mailboxes.sh`|Script de synchro|§8.3|
|`/opt/www/roundcubemail/config/config.inc.php`|Config Roundcube|§9.2|

### 14.4 Ports et protocoles

|Port|Protocole|Chiffrement|Usage|
|---|---|---|---|
|389|LDAP|Aucun (ou STARTTLS)|Requêtes vers AD|
|143|IMAP|STARTTLS|Clients mail (non recommandé)|
|993|IMAPS|SSL/TLS|Clients mail (recommandé)|
|587|SMTP|STARTTLS|Envoi authentifié|
|465|SMTPS|SSL/TLS|Envoi authentifié (legacy)|
|25|SMTP|Variable|Réception MX|
|443|HTTPS|SSL/TLS|Roundcube / iRedAdmin|

---

## 🔗 Ressources et documentation

- [Documentation officielle iRedMail + AD](https://docs.iredmail.org/active.directory.html)
- [iRedMail GitHub](https://github.com/iredmail/iRedMail)
- [Documentation Dovecot LDAP](https://doc.dovecot.org/configuration_manual/authentication/ldap/)
- [Postfix Documentation](http://www.postfix.org/documentation.html)
- [Roundcube Wiki](https://github.com/roundcube/roundcubemail/wiki)

---

_Tutoriel rédigé pour le projet TSSR — Infrastructure billu.lan_ _iRedMail 1.6.x | Dovecot 2.3.x | Postfix 3.x | Debian 11/12 | Windows Server 2022_
