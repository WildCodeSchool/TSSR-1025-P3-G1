# Synthèse du matériel  
  
## 1. Contexte  
  
Ce document présente la synthèse des éléments matériels et virtuels composant l’infrastructure mise en place dans le cadre du projet 3.  
  
Seuls les éléments **complètement fonctionnels** (statut "Terminé") sont listés.  
  
---  
  
## 2. Tableau de synthèse  
  
## 2. Tableau de synthèse

| ID | Nom Proxmox | Nom Machine | Type | OS | Fonction principale | Réseau | Adresse IP / CIDR | Disques | RAM |
|----|-------------|------------|------|----|---------------------|--------|-------------------|--------|-----|
| 151 | G1-DOM-AD-01 | DOM-AD-01 | VM | Windows Server | Active Directory / DNS | VLAN 120 | 172.16.12.1/28 | 2 disques : Disque 1 = 40 Go / 16 Go libre / 40 % ; Disque 2 = 40 Go / 26 Go libre / 65 % | 4 Go / 60 % |
| 152 | DOM-DHCP-01 | DOM-DHCP-01 | VM | Windows Server | DHCP | VLAN 120 | 172.16.12.2/28 | 1 disque : Disque 1 = 40 Go / 32 Go libre / 80 % | 2 Go / 50 % |
| 156 | G1-DOM-WDS-01 | DOM-WDS-01 | VM | Windows Server | Déploiement postes (WDS) | VLAN 120 | 172.16.12.3/28 | 1 disque : Disque 1 = 40 Go / 18 Go libre / 45 % | 2 Go / 50 % |
| 154 | G1-DOM-FS-01 | DOM-FS-01 | VM | Windows Server | Serveur de fichiers | VLAN 120 | 172.16.12.4/28 | 2 disques : Disque 1 = 40 Go / 10 Go libre / 25 % ; Disque 2 = 100 Go / 70 Go libre / 70 % | 4 Go / 65 % |
| 155 | G1-DOM-WSUS-01 | DOM-WSUS-01 | VM | Windows Server | WSUS | VLAN 120 | 172.16.12.5/28 | 1 disque : Disque 1 = 40 Go / 22 Go libre / 55 % | 4 Go / 60 % |
| 158 | G1-DOM-AD-PDC-01 | DOM-AD-PDC-01 | VM | Windows Server | Contrôleur de domaine (PDC) | VLAN 120 | 172.16.12.6/28 | 1 disque : Disque 1 = 40 Go / 20 Go libre / 50 % | 4 Go / 60 % |
| 159 | G1-DOM-AD-RID-01 | DOM-AD-RID-01 | VM | Windows Server | Contrôleur de domaine (RID) | VLAN 120 | 172.16.12.7/28 | 1 disque : Disque 1 = 40 Go / 18 Go libre / 45 % | 4 Go / 60 % |
| 129 | DOM-GLPI-01 | DOM-GLPI-01 | CT | Debian | GLPI | VLAN 130 | 172.16.13.1/28 | 1 disque : Disque 1 = 20 Go / 8 Go libre / 40 % | 2 Go / 50 % |
| 130 | DOM-LOGS-01 | DOM-LOGS-01 | CT | Debian | Graylog | VLAN 130 | 172.16.13.2/28 | 1 disque : Disque 1 = 40 Go / 18 Go libre / 45 % | 4 Go / 60 % |
| 153 | G1-DOM-ZABBIX-01 | DOM-ZABBIX-01 | VM | Linux | Supervision (Zabbix) | VLAN 130 | 172.16.13.3/28 | 1 disque : Disque 1 = 40 Go / 20 Go libre / 50 % | 4 Go / 60 % |
| 128 | DOM-MAIL-01 | DOM-MAIL-01 | CT | Linux | Messagerie (iRedMail) | VLAN 130 | 172.16.13.5/28 | 1 disque : Disque 1 = 30 Go / 15 Go libre / 50 % | 4 Go / 60 % |
| 127 | DOM-WEBINT-01 | DOM-WEBINT-01 | CT | Linux | Web interne | VLAN 130 | 172.16.13.6/28 | 1 disque : Disque 1 = 20 Go / 10 Go libre / 50 % | 2 Go / 50 % |
| 157 | G1-DOM-VOIP-01 | DOM-VOIP-01 | VM | Linux | Téléphonie (FreePBX) | VLAN 130 | 172.16.13.7/28 | 1 disque : Disque 1 = 20 Go / 9 Go libre / 45 % | 2 Go / 50 % |
| 126 | DOM-WEBEXT-01 | DOM-WEBEXT-01 | CT | Linux | Web externe (DMZ) | VLAN 411 | 10.10.11.2/29 | 1 disque : Disque 1 = 20 Go / 12 Go libre / 60 % | 2 Go / 50 % |
| 150 | G1-pfsense | Firewall.billu.pfsense | VM | pfSense | Pare-feu / NAT | WAN / LAN / DMZ | 10.0.0.1 | 1 disque : Disque 1 = 10 Go / 6 Go libre / 60 % | 1 Go / 40 % |
| 169 | G1-R1 | G1-R1 | VM | VyOS | Routage inter-VLAN | LAN | 10.10.0.254 | 1 disque : Disque 1 = 10 Go / 6 Go libre / 60 % | 1 Go / 40 % |
| 163 | G1-PC-ADMIN-01 | PC-ADMIN-01 | VM | Windows 10 | Poste administration | VLAN 60 | 172.16.6.14 | 1 disque : Disque 1 = 50 Go / 30 Go libre / 60 % | 4 Go / 60 % |
| 164 | G1-PC-DSI-01 | PC-DSI-01 | VM | Windows 10 | Poste utilisateur | VLAN 60 | 172.16.6.X | 1 disque : Disque 1 = 50 Go / 28 Go libre / 55 % | 4 Go / 60 % |
| 165 | G1-PC-DEV-01 | PC-DEV-01 | VM | Windows 10 | Poste utilisateur | VLAN 10 | 172.16.1.X | 1 disque : Disque 1 = 50 Go / 25 Go libre / 50 % | 4 Go / 60 % |
| 166 | G1-DOM-KALI-01 | DOM-KALI-01 | VM | Kali Linux | Audit sécurité | VLAN ADMIN | IP dynamique | 1 disque : Disque 1 = 30 Go / 15 Go libre / 50 % | 2 Go / 50 % |
| 167 | G1-DOM-SNORT-01 | DOM-SNORT-01 | VM | Linux | IDS (Snort) | VLAN ADMIN | IP dynamique | 1 disque : Disque 1 = 20 Go / 8 Go libre / 40 % | 2 Go / 50 % |
  
---