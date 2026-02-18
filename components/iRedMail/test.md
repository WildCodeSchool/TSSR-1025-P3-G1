# Synchronisation AD/LDAP avec iRedMail
## Projet TSSR - Domaine : billu.lan

---

## 📋 Informations du projet

| Élément | Valeur |
|---|---|
| **Serveur mail** | DOM-MAIL-01 / 172.16.13.6 |
| **Serveur AD/DNS** | 172.16.12.1 |
| **Domaine** | billu.lan |
| **NetBIOS** | BILLU |
| **Base LDAP** | OU=BillUsers,DC=billu,DC=lan |
| **Compte de service** | svc-mail@billu.lan |
| **Mot de passe svc-mail** | Azerty123! |

---

## 🎯 Objectif

Configurer iRedMail pour qu'il s'authentifie auprès de l'Active Directory. Les utilisateurs pourront se connecter au webmail Roundcube et à Thunderbird avec leurs **identifiants Windows AD** (sans recréer de comptes dans iRedMail).

---

## 📋 Prérequis

- iRedMail installé et fonctionnel sur DOM-MAIL-01
- Serveur AD Windows Server 2022 accessible sur 172.16.12.1
- Compte de service `svc-mail` créé dans **BillUsers > DSI** avec le mot de passe `Azerty123!`
- Test de connexion LDAP validé (225 entrées trouvées)

---

## 📦 Étape 1 : Installation des outils LDAP

### 1.1 Installer ldap-utils
```bash
apt install -y ldap-utils
```

### 1.2 Tester la connexion à l'AD
Avant toute configuration, vérifier que le serveur mail peut interroger l'AD :
```bash
ldapsearch -x -H ldap://172.16.12.1 -D "svc-mail@billu.lan" -w 'Azerty123!' -b "OU=BillUsers,DC=billu,DC=lan" "(objectClass=user)" sAMAccountName mail
```

✅ **Résultat attendu** : `result: 0 Success` avec 225 entrées (ou le nombre d'utilisateurs AD)

⚠️ **Important** : Écrire la commande en **une seule ligne** et utiliser des guillemets simples `' '` autour du mot de passe pour éviter que le `!` soit interprété par le shell.

---

## ⚙️ Étape 2 : Configuration de Dovecot (Authentification IMAP)

Dovecot gère l'authentification des utilisateurs pour la réception des mails (IMAP/POP3). On va le configurer pour qu'il vérifie les identifiants dans l'AD.

### 2.1 Sauvegarder la configuration existante
```bash
cp /etc/dovecot/dovecot-ldap.conf.ext /etc/dovecot/dovecot-ldap.conf.ext.bak
```

### 2.2 Éditer la configuration LDAP de Dovecot
```bash
nano /etc/dovecot/dovecot-ldap.conf.ext
```

Remplacer tout le contenu par :
```
# Adresse du serveur AD
hosts = 172.16.12.1

# Désactiver SSL/TLS (en labo, activer en production)
tls = no

# Compte de service pour la connexion à l'AD
dn = svc-mail@billu.lan
dnpass = Azerty123!

# Base de recherche (point de départ dans l'AD)
base = OU=BillUsers,DC=billu,DC=lan

# Protocole LDAP version 3
ldap_version = 3

# Scope de recherche (subtree = toutes les sous-OU)
scope = subtree

# Filtre pour trouver l'utilisateur
user_filter = (&(objectClass=user)(sAMAccountName=%n)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))

# Filtre d'authentification
pass_filter = (&(objectClass=user)(sAMAccountName=%n)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))

# Attributs récupérés depuis l'AD
pass_attrs = sAMAccountName=user, userPassword=password

# Schéma d'authentification
auth_bind = yes
auth_bind_userdn = %u@billu.lan

# Attributs utilisateur
user_attrs = sAMAccountName=user
```

> **Explication des filtres :**
> - `sAMAccountName=%n` → cherche par nom d'utilisateur Windows
> - `userAccountControl:...:=2` → exclut les comptes désactivés dans l'AD
> - `auth_bind = yes` → Dovecot se connecte directement à l'AD avec les identifiants de l'utilisateur pour vérifier le mot de passe

### 2.3 Vérifier la configuration Dovecot principale
```bash
nano /etc/dovecot/conf.d/10-auth.conf
```

Vérifier que ces lignes sont présentes et non commentées :
```
!include auth-ldap.conf.ext
```

Si la ligne est commentée (avec `#`), la décommenter.

### 2.4 Vérifier auth-ldap.conf.ext
```bash
cat /etc/dovecot/conf.d/auth-ldap.conf.ext
```

Le fichier doit contenir :
```
passdb {
  driver = ldap
  args = /etc/dovecot/dovecot-ldap.conf.ext
}

userdb {
  driver = ldap
  args = /etc/dovecot/dovecot-ldap.conf.ext
  default_fields = uid=vmail gid=vmail home=/var/vmail/%d/%n
}
```

Si ce n'est pas le cas, éditez-le pour qu'il corresponde.

### 2.5 Redémarrer Dovecot
```bash
systemctl restart dovecot
systemctl status dovecot
```

---

## ⚙️ Étape 3 : Configuration de Postfix (Envoi/Réception SMTP)

Postfix doit savoir que les utilisateurs AD sont valides pour accepter les mails destinés à leurs adresses `@billu.lan`.

### 3.1 Créer le dossier de configuration LDAP Postfix
```bash
mkdir -p /etc/postfix/ldap
```

### 3.2 Créer le fichier de correspondance des boites mail
```bash
nano /etc/postfix/ldap/virtual_mailbox_maps.cf
```

Contenu :
```
server_host = 172.16.12.1
bind = yes
bind_dn = svc-mail@billu.lan
bind_pw = Azerty123!
search_base = OU=BillUsers,DC=billu,DC=lan
scope = sub
query_filter = (&(objectClass=user)(sAMAccountName=%u)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))
result_attribute = sAMAccountName
result_format = %d/%u/Maildir/
version = 3
```

### 3.3 Créer le fichier des destinataires valides
```bash
nano /etc/postfix/ldap/virtual_mailbox_domains.cf
```

Contenu :
```
server_host = 172.16.12.1
bind = yes
bind_dn = svc-mail@billu.lan
bind_pw = Azerty123!
search_base = DC=billu,DC=lan
scope = sub
query_filter = (associatedDomain=%s)
result_attribute = associatedDomain
version = 3
```

### 3.4 Modifier la configuration principale de Postfix
```bash
nano /etc/postfix/main.cf
```

Trouver la ligne `virtual_mailbox_maps` et modifier/ajouter :
```
virtual_mailbox_maps = proxy:ldap:/etc/postfix/ldap/virtual_mailbox_maps.cf
```

### 3.5 Redémarrer Postfix
```bash
systemctl restart postfix
systemctl status postfix
```

---

## ⚙️ Étape 4 : Créer les boites mail automatiquement

Même si l'authentification est gérée par l'AD, iRedMail a besoin que les boites mail existent physiquement sur le serveur. On va créer un script pour les générer automatiquement.

### 4.1 Créer le script de création des boites mail
```bash
nano /usr/local/bin/create_mail_from_ad.sh
```

Contenu :
```bash
#!/bin/bash

# Configuration
AD_SERVER="172.16.12.1"
BIND_DN="svc-mail@billu.lan"
BIND_PW="Azerty123!"
BASE_DN="OU=BillUsers,DC=billu,DC=lan"
MAIL_DOMAIN="billu.lan"
VMAIL_DIR="/var/vmail"

# Récupérer tous les utilisateurs actifs de l'AD
USERS=$(ldapsearch -x -H ldap://$AD_SERVER \
  -D "$BIND_DN" \
  -w "$BIND_PW" \
  -b "$BASE_DN" \
  "(&(objectClass=user)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))" \
  sAMAccountName | grep "sAMAccountName:" | awk '{print $2}')

# Créer le répertoire mail pour chaque utilisateur
for USER in $USERS; do
  MAILDIR="$VMAIL_DIR/$MAIL_DOMAIN/$USER/Maildir"
  if [ ! -d "$MAILDIR" ]; then
    mkdir -p "$MAILDIR"/{cur,new,tmp}
    chown -R vmail:vmail "$VMAIL_DIR/$MAIL_DOMAIN/$USER"
    echo "Boite mail créée pour : $USER@$MAIL_DOMAIN"
  fi
done

echo "Terminé !"
```

### 4.2 Rendre le script exécutable
```bash
chmod +x /usr/local/bin/create_mail_from_ad.sh
```

### 4.3 Exécuter le script
```bash
bash /usr/local/bin/create_mail_from_ad.sh
```

Tu devrais voir la création des boites mail pour chaque utilisateur AD.

### 4.4 Vérifier les boites créées
```bash
ls /var/vmail/billu.lan/
```

---

## 🔄 Étape 5 : Automatiser la synchronisation

Pour que les nouveaux utilisateurs AD aient automatiquement une boite mail, on ajoute le script en tâche planifiée (cron).

```bash
crontab -e
```

Ajouter à la fin :
```
# Synchronisation AD toutes les nuits à 2h
0 2 * * * /usr/local/bin/create_mail_from_ad.sh >> /var/log/mail_sync.log 2>&1
```

---

## 🧪 Étape 6 : Tests

### 6.1 Test d'authentification LDAP
```bash
ldapsearch -x -H ldap://172.16.12.1 -D "svc-mail@billu.lan" -w 'Azerty123!' -b "OU=BillUsers,DC=billu,DC=lan" "(objectClass=user)" sAMAccountName mail
```

### 6.2 Test de connexion Dovecot
```bash
doveadm auth test utilisateur@billu.lan MotDePasseAD
```

Remplacer `utilisateur` par un vrai compte AD.

### 6.3 Vérification des logs
```bash
# Logs Dovecot
tail -f /var/log/dovecot.log

# Logs mail
tail -f /var/log/mail.log
```

---

## 🌐 Étape 7 : Configuration de Thunderbird

### 7.1 Installer Thunderbird sur le client
Sur les postes clients Windows :
- Télécharger Thunderbird : https://www.thunderbird.net/fr/

### 7.2 Ajouter un compte dans Thunderbird

1. Ouvrir Thunderbird
2. **Nouveau compte de messagerie**
3. Remplir :
   - **Nom** : Prénom Nom de l'utilisateur
   - **Email** : `utilisateur@billu.lan`
   - **Mot de passe** : mot de passe AD de l'utilisateur
4. Cliquer sur **Continuer**

### 7.3 Configuration manuelle si détection automatique échoue

Si Thunderbird ne détecte pas automatiquement les paramètres, les saisir manuellement :

**Serveur entrant (IMAP) :**
| Paramètre | Valeur |
|---|---|
| Protocole | IMAP |
| Serveur | 172.16.13.6 |
| Port | 993 |
| SSL | SSL/TLS |
| Authentification | Mot de passe normal |

**Serveur sortant (SMTP) :**
| Paramètre | Valeur |
|---|---|
| Serveur | 172.16.13.6 |
| Port | 587 |
| SSL | STARTTLS |
| Authentification | Mot de passe normal |

**Identifiant :** `utilisateur@billu.lan` (avec le domaine)

### 7.4 Accepter le certificat SSL auto-signé
Thunderbird affichera un avertissement pour le certificat auto-signé.
→ Cliquer sur **"Confirmer l'exception de sécurité"**

---

## 🌐 Étape 8 : Accès Webmail (Roundcube)

Les utilisateurs peuvent accéder au webmail via :
```
https://172.16.13.6/mail/
ou
https://DOM-MAIL-01.billu.lan/mail/
ou
https://mailbillu/mail/   (si CNAME configuré sur l'AD)
```

**Connexion avec les identifiants AD :**
- **Utilisateur** : `utilisateur@billu.lan`
- **Mot de passe** : mot de passe Windows de l'utilisateur

---

## 🛠️ Dépannage courant

### Erreur : "invalid credentials" lors du ldapsearch
- Vérifier le mot de passe du compte `svc-mail` sur l'AD
- Utiliser des guillemets simples `' '` autour du mot de passe
- Écrire la commande en une seule ligne
- Le `!` dans un mot de passe peut être interprété par bash → changer le mot de passe

### Erreur : Dovecot ne démarre pas après modification
```bash
dovecot -n  # Vérifie la configuration
journalctl -u dovecot -n 50  # Voir les logs d'erreur
```

### Erreur : Thunderbird ne se connecte pas
- Vérifier que les ports 993 et 587 sont ouverts dans nftables
- Vérifier que Dovecot tourne : `systemctl status dovecot`
- Vérifier les logs : `tail -f /var/log/dovecot.log`

### Les boites mail ne sont pas créées
```bash
ls -la /var/vmail/billu.lan/
# Vérifier les permissions
chown -R vmail:vmail /var/vmail/
```

---

## 🎯 Checklist finale

- [ ] ldap-utils installé
- [ ] Test ldapsearch validé (result: 0 Success)
- [ ] Configuration Dovecot LDAP modifiée
- [ ] Dovecot redémarré sans erreur
- [ ] Configuration Postfix LDAP modifiée
- [ ] Postfix redémarré sans erreur
- [ ] Script création boites mail exécuté
- [ ] Boites mail créées dans `/var/vmail/billu.lan/`
- [ ] Tâche cron configurée pour la synchronisation automatique
- [ ] Test d'authentification Dovecot validé
- [ ] Thunderbird configuré sur un poste client
- [ ] Envoi/réception d'email testé via Thunderbird
- [ ] Connexion webmail Roundcube validée avec un compte AD

---

nano /etc/dovecot/dovecot-ldap.conf.ext
```

Remplace **tout le contenu** par :
```
hosts           = 172.16.12.1:389
ldap_version    = 3
auth_bind       = yes
dn              = vmail
dnpass          = Azerty123!
base            = cn=users,dc=billu,dc=lan
scope           = subtree
deref           = never

# Pour les commandes doveadm
iterate_attrs   = userPrincipalName=user
iterate_filter  = (&(userPrincipalName=*)(objectClass=person)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))

# Filtres d'authentification
user_filter     = (&(userPrincipalName=%u)(objectClass=person)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))
pass_filter     = (&(userPrincipalName=%u)(objectClass=person)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))
pass_attrs      = userPassword=password
default_pass_scheme = CRYPT
user_attrs      = =home=/var/vmail/billu.lan/%Ln/,=mail=maildir:~/Maildir/
