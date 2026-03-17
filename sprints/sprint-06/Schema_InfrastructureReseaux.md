# 

## 1. Contexte

Ce document présente le schéma final de l’infrastructure réseau mise en place dans le cadre du projet 3.

Seuls les éléments **complètement fonctionnels** (statut "Terminé") sont représentés.

---

## 2. Schéma actuel

![Schéma infrastructure](./Ressources/schema_infrastructure_final.jpg)

---

## 3. Schéma initial (Sprint 1)

![Schéma initial](./Ressources/schema_infrastructure_s1.jpg)

---

## 4. Description des éléments du schéma

| ID        | Nom       | Type | Adresse IP     | Fonction               | Réseau (vmbr/VLAN) |
| --------- | --------- | ---- | -------------- | ---------------------- | ------------------ |
| DOM-AD-01 | DOM-AD-01 | VM   | 172.16.12.1/28 | Active Directory / DNS | vmbr412            |
|           |           |      |                |                        |                    |


---

## 5. Plan d’adressage réseau

### 5.1 Les différents réseaux

#### Réseau PfSense > Vyos 
- Réseau : 
- Passerelle : 

### 5.2 VLAN / Réseaux spécifiques (si applicable)

| VLAN ID | Nom | Plage IP       | Description         |
| ------- | --- | -------------- | ------------------- |
| 10      | DEV | 172.16.10.0/24 | Réseau utilisateurs |
|         |     |                |                     |


---

## 6. Nomenclature utilisée

Les noms des équipements respectent la nomenclature définie dans le projet :

- Serveurs : `DOM-<ROLE>-<ID>`
- Clients : `PC-<SERV>-<ID>`
- Équipements réseau : `G1-R1`

---

## 7. Remarques

- Les éléments non fonctionnels ou en cours ne sont pas représentés.
- Le schéma est disponible en version modifiable dans le dossier `/Ressources`.
- Les adresses IP et noms peuvent évoluer selon les besoins du projet.

---