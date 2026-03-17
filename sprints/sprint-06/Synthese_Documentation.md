# Synthèse de la documentation

## 1. Contexte

Ce document présente l’état de la documentation des différents éléments de l’infrastructure mise en place dans le cadre du projet 3.

L’objectif est de vérifier :
- La présence des documentations
- Leur qualité
- Leur exploitabilité

Seuls les éléments **complètement fonctionnels** (statut "Terminé") sont pris en compte.

---

## 2. Tableau de synthèse

| ID  | Nom Proxmox      | Nom Machine            | Type | Documentation d’installation                                                                      | Documentation d’utilisation                                                                  |
| --- | ---------------- | ---------------------- | ---- | ------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| 151 | G1-DOM-AD-01     | DOM-AD-01              | VM   | À jour > [Installation AD](../../components/Active_Directory/installation.md)                     | À jour > [Utilisation AD](../../components/Active_Directory/configuration.md)                     |
| 126 | DOM-WEBEXT-01    | DOM-WEBEXT-01          | CT   | À jour > [Installation Web Ext](../../components/Web_Ext/installation.md)                         | À jour > [Utilisation Web Ext](../../components/Web_Ext/configuration.md)                         |
| 128 | DOM-MAIL-01      | DOM-MAIL-01            | CT   | À jour > [Installation iRedMail](../../components/iRedMail/installation.md)                       | À jour > [Utilisation iRedMail](../../components/iRedMail/configuration.md)                       |
| 129 | DOM-GLPI-01      | DOM-GLPI-01            | CT   | À jour > [Installation GLPI](../../components/GLPI/installation.md)                               | À jour > [Utilisation GLPI](../../components/GLPI/configuration.md)                               |
| 130 | DOM-LOGS-01      | DOM-LOGS-01            | CT   | À jour > [Installation Graylog](../../components/Graylog/installation.md)                         | À jour > [Utilisation Graylog](../../components/Graylog/configuration.md)                         |
| 150 | G1-pfsense       | Firewall.billu.pfsense | VM   | À jour > [Installation pfSense](../../components/PFSense/installation.md)                         | À jour > [Utilisation pfSense](../../components/PFSense/configuration.md)                         |
| 152 | DOM-DHCP-01      | DOM-DHCP-01            | VM   | À jour > [Installation DHCP](../../components/DHCP/installation.md)                               | À jour > [Utilisation DHCP](../../components/DHCP/configuration.md)                               |
| 153 | G1-DOM-ZABBIX-01 | DOM-ZABBIX-01          | VM   | À jour > [Installation Zabbix](../../components/Zabbix/installation.md)                           | À jour > [Utilisation Zabbix](../../components/Zabbix/configuration.md)                           |
| 154 | G1-DOM-FS-01     | DOM-FS-01              | VM   | À jour > [Installation Serveur de fichiers](../../components/Serveur_de_fichiers/installation.md) | À jour > [Utilisation Serveur de fichiers](../../components/Serveur_de_fichiers/configuration.md) |
| 155 | G1-DOM-WSUS-01   | DOM-WSUS-01            | VM   | À jour > [Installation WSUS](../../components/WSUS/installation.md)                               | À jour > [Utilisation WSUS](../../components/WSUS/configuration.md)                               |
| 156 | G1-DOM-WDS-01    | DOM-WDS-01             | VM   | À jour > [Installation WDS](../../components/WDS/installation.md)                                 | À jour > [Utilisation WDS](../../components/WDS/configuration.md)                                 |
| 157 | G1-DOM-VOIP-01   | DOM-VOIP-01            | VM   | À jour > [Installation FreePBX](../../components/FreePBX/installation.md)                         | À jour > [Utilisation FreePBX](../../components/FreePBX/configuration.md)                         |
| 158 | G1-DOM-AD-PDC-01 | DOM-AD-PDC-01          | VM   | À jour > [Installation AD PDC](../../components/Active_Directory/installation.md)                 | À jour > [Utilisation AD](../../components/Active_Directory/configuration.md)                     |
| 159 | G1-DOM-AD-RID-01 | DOM-AD-RID-01          | VM   | À jour > [Installation AD RID](../../components/Active_Directory/installation.md)                 | À jour > [Utilisation AD](../../components/Active_Directory/configuration.md)                     |
| 163 | G1-PC-ADMIN-01   | PC-ADMIN-01            | VM   | À jour > [Utilisation AD](../../components/PC_Administration/configuration.md)                                                               | À jour > [Utilisation AD](../../components/PC_Administration/configuration.md)md)                                                                    |
| 164 | G1-PC-DSI-01     | PC-DSI-01              | VM   | Inexistante (poste client standard)                                                               | Inexistante (non nécessaire)                                                                 |
| 165 | G1-PC-DEV-01     | PC-DEV-01              | VM   | Inexistante (poste client standard)                                                               | Inexistante (non nécessaire)                                                                 |
| 166 | G1-DOM-KALI-01   | DOM-KALI-01            | VM   |  Inexistante                |  Inexistante            |
| 167 | G1-DOM-SNORT-01  | DOM-SNORT-01           | VM   |  Inexistante                          |  Inexistante                           |
| 169 | G1-R1            | G1-R1                  | VM   | À jour > [Installation VyOS](../../components/Vyos_Routeur/installation.md)                       | À jour > [Utilisation VyOS](../../components/Vyos_Routeur/configuration.md)                       |

---
