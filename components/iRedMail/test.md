nano /etc/dovecot/dovecot-ldap.conf.ext
```

Et colle directement tout le contenu que j'ai mis dans le tuto :
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
