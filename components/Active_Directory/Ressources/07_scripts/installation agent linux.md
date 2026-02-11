
## Pour **Debian/Ubuntu** :

```bash
# Télécharger le dépôt GLPI
wget -O - https://raw.githubusercontent.com/glpi-project/glpi-agent/develop/contrib/unix/glpi-agent.gpg | sudo gpg --dearmor -o /usr/share/keyrings/glpi-agent-archive-keyring.gpg

# Ajouter le dépôt (adapte selon ta version)
# Pour Debian 11/Ubuntu 20.04+
echo "deb [signed-by=/usr/share/keyrings/glpi-agent-archive-keyring.gpg] https://glpi-project.github.io/glpi-agent/releases/latest/debian/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/glpi-agent.list

# Mettre à jour et installer
sudo apt update
sudo apt install -y glpi-agent
```

## **OU méthode plus simple** (téléchargement direct du .deb) :

```bash
# Télécharger le paquet
wget https://github.com/glpi-project/glpi-agent/releases/download/1.11/glpi-agent_1.11-1_all.deb

# Installer
sudo dpkg -i glpi-agent_1.11-1_all.deb

# Installer les dépendances si besoin
sudo apt install -f
```
