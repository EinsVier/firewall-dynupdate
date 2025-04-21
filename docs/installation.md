# Installation

Hier erfährst du, wie du das Projekt **firewall-dynupdate** auf einem Linux-Server installierst.

## Voraussetzungen

- Ein systemd-basiertes Linux-System (z. B. Debian, Ubuntu, Fedora)
- Aktives `firewalld`
- Installiertes Paket `dnsutils` (für `dig`)
- Root-Rechte (für das Einrichten von Firewall- und Systemdiensten)

## Schritte

### 1. Repository klonen

```bash
git clone https://github.com/EinsVier/firewall-dynupdate.git
cd firewall-dynupdate
```

### 2. Skript installieren

```bash
sudo cp scripts/update_firewall.sh /usr/local/bin/update_firewall.sh
sudo chmod +x /usr/local/bin/update_firewall.sh
```

### 3. .env konfigurieren

```bash
cp .env.example .env
nano .env
```

Passe `HOSTS`, `PORTS` und `ZONE` an dein Netzwerk an.

### 4. systemd aktivieren

```bash
sudo cp systemd/update-firewall.service /etc/systemd/system/
sudo cp systemd/update-firewall.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now update-firewall.timer
```

### 5. Logfile anlegen (optional)

```bash
sudo touch /var/log/update-firewall.log
sudo chmod 600 /var/log/update-firewall.log
```

### 6. Logrotate einrichten

```bash
sudo cp logrotate/update-firewall /etc/logrotate.d/
```

## Testlauf

```bash
sudo /usr/local/bin/update_firewall.sh
```

## Statusprüfung

```bash
systemctl status update-firewall.timer
journalctl -u update-firewall.service
```

Weiter zur [Verwendung](./usage.md) →
