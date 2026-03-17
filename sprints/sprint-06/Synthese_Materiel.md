# Synthèse du matériel  
  
## 1. Contexte  
  
Ce document présente la synthèse des éléments matériels et virtuels composant l’infrastructure mise en place dans le cadre du projet 3.  
  
Seuls les éléments **complètement fonctionnels** (statut "Terminé") sont listés.  
  
---  
  
## 2. Tableau de synthèse  
  
| ID  | Nom Proxmox      | Nom Machine            | Type | OS                       | Fonction principale    | Réseau (vmbr)                       | Adresse IP / CIDR                                                | Disques (total / libre / %)                      | RAM (total / utilisation %) |     |
| --- | ---------------- | ---------------------- | ---- | ------------------------ | ---------------------- | ----------------------------------- | ---------------------------------------------------------------- | ------------------------------------------------ | --------------------------- | --- |
| 151 | G1-DOM-AD-01     | DOM-AD-01              | VM   | Windows Server           | Active Directory / DNS | vmbr412                             | 172.16.10.1/28                                                   | 2 / 40Go / 16Go/ 55%<br><br>40Go / 26Go / 45%    | 4 Go / 78 %                 |     |
| 126 | DOM-WEBEXT-01    | DOM-WEBEXT-01          | CT   | Debian 12                | Web externe            | vmbr411                             | 10.10.11.2/29                                                    | 1 / 20Go / 0.6Go / 4%                            | 1 Go / 4 %                  |     |
| 127 | DOM-WEBINT-01    | DOM-WEBINT-01          | CT   | Debian 12                | Web interne            | vmbr412                             | 172.16.13.6/28                                                   | 1 / 8Go / 6.4Go / 14%                            | 0.5 Go / 26%                |     |
| 128 | DOM-MAIL-01      | DOM-MAIL-01            | CT   | Debian 12                | Messagerie             | vmbr412                             | 172.16.13.5/28                                                   | 1 / 20Go / 16Go / 16%                            | 2Go / 64%                   |     |
| 129 | DOM-GLPI-01      | DOM-GLPI-01            | CT   | Debian 12                | GLPI                   | vmbr412                             | 172.16.13.1/28                                                   | 1 / 20Go / 17 Go / 12%                           | 1Go / 25%                   |     |
| 130 | DOM-LOGS-01      | DOM-LOGS-01            | CT   | Debian 12                | LOGS                   | vmbr412                             | 172.16.13.2/28                                                   | 1 / 40Go / 33Go / 13%                            | 8Go / 64%                   |     |
| 150 | G1-pfsense       | Firewall.billu.pfsense | VM   |                          | Firewall               | vmbr1 / vmbr410 / vmbr411 / vmbr450 | 10.0.0.2/29<br>10.10.10.1/29<br>10.10.11.1/29<br>192.168.10.1/30 | 1 / 10Go /                                       | 2Go / 70%                   |     |
| 152 | DOM-DHCP-01      | DOM-DHCP-01            | VM   | Windows server 2012 Core | DHCP                   | vmbr412                             | 172.16.12.2/28                                                   | 1 40Go / 32Go /<br>13%                           | 4Go / 72%                   |     |
| 153 | G1-DOM-ZABBIX-01 | DOM-ZABBIX-01          | VM   | Ubuntu 24.04             | ZABBIX                 | vmbr412                             | 172.16.13.3/28                                                   | 1 20Go / 9Go / 50%                               | 1Go / 86%                   |     |
| 154 | G1-DOM-FS-01     | DOM-FS-01              | VM   | Windows server 2012 Core | Serveur de Fichier     | vmbr412                             | 172.16.12.4/28                                                   | 2 60Go / 47.5Go / 58%<br><br>40Go / 39,8Go / 95% | 4Go /68%                    |     |
| 155 | G1-DOM-WSUS-01   | DOM-WSUS-01            | VM   | Windows server 2012 Core | Mise a jour            | vmbr412                             | 172.16.12.5/28                                                   | 1 40Go / 22Go % / 52%                            | 4Go / 78%                   |     |
| 156 | G1-DOM-WDS-01    | DOM-WDS-01             | VM   | Windows server 2012      | Déploiement machine    | vmbr412                             | 172.16.12.3/28                                                   | 2 60Go / 34Go / 57%<br><br>100Go / 94.85Go / 95% | 4Go / 79%                   |     |
| 157 | G1-DOM-VOIP-01   | DOM-VOIP-01            | VM   | Sangoma Linux 7          | VoIP                   | vmbr412                             | 172.16.13.7/28                                                   | 1 27Go / 21Go / 25%                              | 4Go / 46%                   |     |
| 158 | G1-DOM-AD-PDC-01 | DOM-AD-PDC-01          | VM   | Windows server 2012 Core | Role FSMO PDC          | vmbr412                             | 172.16.12.6/28                                                   | 1 40Go / 31Go / 25%                              | 4Go / 74%                   |     |
| 159 | G1-DOM-AD-RID-01 | DOM-AD-RID-01          | VM   | Windows server 2012 Core | Role FSMO RID master   | vmbr412                             | 172.16.12.7/28                                                   | 1 40Go/ 31Go / 25%                               | 4Go / 74%                   |     |
| 163 | G1-PC-ADMIN-01   | PC-ADMIN-01            | VM   | Windows 10               | Pc administrateur      | vmbr412                             | 172.16.12.14/28 DHCP                                             | 1 60Go / 11.5Go / 15%                            | 4Go / 78%                   |     |
| 164 | G1-PC-DSI-01     | PC-DSI-01              | VM   | Windows 10               | Pc client              | vmbr412                             | 172.16.6.10/29 DHCP                                              | 1 40Go / 4Go / 94%                               | 4Go / 75%                   |     |
| 165 | G1-PC-DEV-01     | PC-DEV-01              | VM   | Windows 10               | Pc client              | vmbr412                             | DHCP                                                             | 1 40Go / 6Go / 80%                               | 4Go /70%                    |     |
| 166 | G1-DOM-KALI-01   | DOM-KALI-01            | VM   | Kali linux               | Linux Pentest          | vmbr410                             |                                                                  | 1 30Go / 12Go / 60%                              | 8Go / 21%                   |     |
| 167 | G1-DOM-SNORT-01  | DOM-SNORT-01           | VM   | Debian 12                | Linux Defense          | vmbr412                             | 10.10.10.3/29                                                    | 1 40Go / 28Go / 27%                              | 4Go / 63%                   |     |
| 169 | G1-R1            | G1-R1                  | VM   | Vyos                     | Routage                | vmbr412<br>vmbr410                  | 172.16.0.254/24<br>10.10.10.2/29                                 | 1 2Go / 0.9Go / 60%                              | 512Mb / 88%                 |     |
|     |                  |                        |      |                          |                        |                                     |                                                                  |                                                  |                             |     |

  
---