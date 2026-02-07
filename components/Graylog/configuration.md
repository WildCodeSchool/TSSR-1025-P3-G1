# Sommaire - Guide de configuration Graylog

1. [Création d'un compte Administrateur](#1-création-dun-compte-administrateur)
2. [Configuration de Windows](#2-configuration-de-windows)
   - 2.1 [Téléchargement et installation de NXLog](#21-téléchargement-et-installation-de-nxlog-sur-windows)
   - 2.2 [Modification du fichier nxlog.conf](#22-modification-du-fichier-nxlogconf)
   - 2.3 [Redémarrage du service](#23-redémarrage-du-service)
3. [Configuration de Linux](#3-configuration-de-linux)
   - 3.1 [Installation et vérification de rsyslog](#31-installation-et-vérification-de-rsyslog)
   - 3.2 [Configuration du fichier rsyslog](#32-configuration-du-fichier-rsyslog)
   - 3.3 [Redémarrage du service](#33-redémarrage-du-service)
4. [Configuration de Graylog](#4-configuration-de-graylog)
   - 4.1 [Création d'un input NXLog pour Windows](#41-création-dun-input-nxlog-pour-windows)
   - 4.2 [Création d'un input Syslog pour Linux](#42-création-dun-input-syslog-pour-linux)
   - 4.3 [Création des Streams pour chaque serveur](#43-création-des-streams-pour-chaque-serveur)

---  

### 1. Création d'un compte Administrateur

1) Naviguer dans l'onglet **System**
2) Cliquer sur **Users and Teams**
3) Cliquer sur **Create user**

![img](Ressources/graylog_img/configuration/01_admin_account/01_graylog_configuration.png)

1) Entrer un prénom 
2) Entrer un nom 
3) Entrer un username 
4) Entrer une adresse Email
5) Choisir la Time Zone **Paris**
6) Assigner le rôle **Admin**
7) Il doit apparaître dans les **Selected Roles**
8) Saisir un mot de passe
9) Cliquer sur **Create user**

![img](Ressources/graylog_img/configuration/01_admin_account/02_graylog_configuration.png)

- Le compte doit apparaître dans les **Users**

![img](Ressources/graylog_img/configuration/01_admin_account/03_graylog_configuration.png)

---  

### 2. Configuration de Windows 

#### 2.1 Téléchargement et installation de NXLog sur Windows

1) Télécharger NXLog pour Windows : https://nxlog.co/downloads

2) Installer NXLog, pour chaque étape cliquer sur `Next`

#### 2.2 Modification du fichier nxlog.conf

1) Ouvrir le fichier `C:\Program Files\nxlog\conf\nxlog.conf` avec un éditeur de texte

2) Remplacer `<Output out>` par : 

> **Note :** L'adresse IP `172.16.13.2` correspond au serveur Graylog

- (`CTRL + F pour rechercher`)
```
<Output out>
    Module      om_tcp
    Host        172.16.13.2
    Port        12201
    OutputType  GELF_TCP
    Exec $Hostname = hostname();
</Output>
```

#### 2.3 Redémarrage du service

1) Redémarrer le service NXLog avec la commande Powershell : 
```bash
Restart-Service nxlog
```

2) Vérifier que le service est bien démarré avec la commande Powershell : 
```bash
Get-Service nxlog
```

---  

### 3. Configuration de Linux

#### 3.1 Installation et vérification de rsyslog

**Se connecter en root ou utiliser sudo pour les commandes nécessaires**

1) Vérifier si **rsyslog** est bien installé
```bash
systemctl status rsyslog
```

2) Installer syslog si celui-ci n'est pas installé avec la commande 
```bash
apt install rsyslog -y
```

#### 3.2 Configuration du fichier rsyslog

1) Ouvrir ou créer le fichier `nano /etc/rsyslog.d/90-graylog.conf` et ajouter :

> **Note :** L'adresse IP `172.16.13.2` correspond au serveur Graylog
```bash
# Configuration Graylog
*.* @172.16.13.2:514
```

2) Vérifier la configuration avec la commande `rsyslogd -N1`
```bash
rsyslogd -N1
```

#### 3.3 Redémarrage du service

1) Redémarrer le service avec la commande :
```bash
systemctl restart rsyslog
```

2) Vérifier le status du service :
```bash
systemctl status rsyslog
```

---  

### 4. Configuration de Graylog

#### 4.1 Création d'un input NXLog pour Windows

- Naviguer dans l'onglet **System** et cliquer sur **Inputs**

![img](Ressources/graylog_img/configuration/03_create_input/01_graylog_input.png)

1) Sélectionner **GELF TCP** dans la liste
2) Cliquer sur **Launch new input**

![img](Ressources/graylog_img/configuration/03_create_input/02_graylog_input.png)

1) Mettre en titre `NXLog_TCP_Windows`
2) Descendre et cliquer sur **Launch Input**

![img](Ressources/graylog_img/configuration/03_create_input/03_graylog_input.png)
![img](Ressources/graylog_img/configuration/03_create_input/04_graylog_input.png)

- L'input **NXLog_TCP_Windows** doit apparaître dans **Global inputs**

![img](Ressources/graylog_img/configuration/03_create_input/05_graylog_input.png)


1) Cliquer sur **Set-up Input**
2) Cliquer sur **Next**

![img](Ressources/graylog_img/configuration/03_create_input/06_graylog_input.png)

- Cliquer sur **Start Input**

![img](Ressources/graylog_img/configuration/03_create_input/07_graylog_input.png)

- Cliquer sur **Launch Input Diagnosis**

![img](Ressources/graylog_img/configuration/03_create_input/08_graylog_input.png)

- Vérifier que l'input est bien actif 

![img](Ressources/graylog_img/configuration/03_create_input/09_graylog_input.png)

#### 4.2 Création d'un input Syslog pour Linux

- Sélectionner **Syslog UDP** dans la liste et cliquer sur **Launch new input**

1) Mettre en titre `SYSLOG_UDP_Linux`
2) Descendre et sélectionner `Europe/Paris` dans la **Time Zone**
3) Cliquer sur **Launch Input**

![img](Ressources/graylog_img/configuration/03_create_input/10_graylog_input.png)
![img](Ressources/graylog_img/configuration/03_create_input/11_graylog_input.png)

- L'input **SYSLOG_UDP_Linux** doit apparaître dans **Global inputs**

![img](Ressources/graylog_img/configuration/03_create_input/12_graylog_input.png)

1) Cliquer sur **Set-up Input**
2) Cliquer sur **Create Stream**
3) Cliquer sur **Next**

![img](Ressources/graylog_img/configuration/03_create_input/13_graylog_input.png)

- Cliquer sur **Start Input**

![img](Ressources/graylog_img/configuration/03_create_input/14_graylog_input.png)

- Cliquer sur **Launch Input Diagnosis**

![img](Ressources/graylog_img/configuration/03_create_input/15_graylog_input.png)

- Vérifier que l'input est bien actif 

![img](Ressources/graylog_img/configuration/03_create_input/16_graylog_input.png)

#### 4.3 Création des Streams pour chaque serveur

##### 4.3.1 Création d'un stream

**Pour cette partie, la première partie sert d'exemple. Entrer les paramètres pour chaque stream dans la partie 4.3.2**

1) Cliquer sur l'onglet **Streams**
2) Cliquer sur **Create Stream**

![img](Ressources/graylog_img/configuration/04_create_streams/01_graylog_streams.png)

1) Title : DOM-AD-01
2) Description : Serveur Active Directory
3) Add Collaborator : 
    - **Un Administrateur** `DOM Admin`
    - Sélectionner `Manager` 
    - Cliquer sur **Add Collaborator**
4) Cliquer sur **Create stream**

![img](Ressources/graylog_img/configuration/04_create_streams/02_graylog_streams.png)

- Cliquer sur **Data Routing**

![img](Ressources/graylog_img/configuration/04_create_streams/03_graylog_streams.png)

- Cliquer sur **Create Rule**

![img](Ressources/graylog_img/configuration/04_create_streams/04_graylog_streams.png)

1) Field : Sélectionner `source`
2) Type : Sélectionner `Contain`
3) Value : Entrer le nom du serveur `DOM-AD-01`
4) Description : Serveur Active Directory
5) Cliquer sur **Create Rule**

![img](Ressources/graylog_img/configuration/04_create_streams/05_graylog_streams.png)

- La règle doit apparaître dans **Rule**

![img](Ressources/graylog_img/configuration/04_create_streams/06_graylog_streams.png)

- Cliquer sur le bouton `Lecture` pour activer le stream

![img](Ressources/graylog_img/configuration/04_create_streams/07_graylog_streams.png)

---  

##### 4.3.2 Création des streams de l'infrastructure

**Instructions :** Pour chaque serveur ci-dessous, suivre la procédure détaillée en 4.3.1 en utilisant les paramètres indiqués.

> **Note :** Le Stream 1 (DOM-AD-01) a déjà été créé comme exemple en section 4.3.1. Voici les paramètres pour les streams restants.

---  

###### Stream 2 : Serveur DHCP
**Paramètres du Stream :**
- **Title :** DOM-DHCP-01
- **Description :** Serveur DHCP
- **Add Collaborator :** 
    - **Un Administrateur** `DOM Admin`
    - Sélectionner `Manager` 
    - Cliquer sur **Add Collaborator**

**Paramètres de la règle de routage :**
- **Field :** source
- **Type :** Contain
- **Value :** DOM-DHCP-01
- **Description :** Serveur DHCP

---

###### Stream 3 : Serveur GLPI
**Paramètres du Stream :**
- **Title :** DOM-GLPI-01
- **Description :** Serveur GLPI
- **Add Collaborator :** 
    - **Un Administrateur** `DOM Admin`
    - Sélectionner `Manager` 
    - Cliquer sur **Add Collaborator**

**Paramètres de la règle de routage :**
- **Field :** source
- **Type :** Contain
- **Value :** DOM-GLPI-01
- **Description :** Serveur GLPI

---

###### Stream 4 : Serveur Zabbix
**Paramètres du Stream :**
- **Title :** DOM-ZABBIX-01
- **Description :** Serveur Zabbix
- **Add Collaborator :** 
    - **Un Administrateur** `DOM Admin`
    - Sélectionner `Manager` 
    - Cliquer sur **Add Collaborator**

**Paramètres de la règle de routage :**
- **Field :** source
- **Type :** Contain
- **Value :** DOM-ZABBIX-01
- **Description :** Serveur Zabbix

---

**Note :** Après la création de chaque stream, ne pas oublier de cliquer sur le bouton Lecture pour l'activer.
