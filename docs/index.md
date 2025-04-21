# DNS-basiertes Firewall-Update mit Logrotation

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Status: In Use](https://img.shields.io/badge/Status-In%20Use-green)
![Last Commit](https://img.shields.io/github/last-commit/EinsVier/firewall-dynupdate)
![Open Issues](https://img.shields.io/github/issues/EinsVier/firewall-dynupdate)
![Repo Size](https://img.shields.io/github/repo-size/EinsVier/firewall-dynupdate)
![ShellCheck](https://github.com/EinsVier/firewall-dynupdate/actions/workflows/bash-lint.yml/badge.svg)

Dieses Projekt automatisiert die Firewall-Freigabe eines bestimmten Ports (z. B. für Cockpit) auf Basis von dynamischen DNS-Hostnamen. Es ist gedacht für Heimserver, bei denen die erlaubten Quell-IP-Adressen über DynDNS-Adressen ermittelt werden müssen (z. B. FritzBoxen, NAS, etc.).

## Funktionen

- Auflösung beliebiger Hostnamen in IP-Adressen (auch lokale Namen wie `nas`)
- Automatische Aktualisierung von `firewalld`-Regeln bei IP-Änderungen
- Unterstützung mehrerer Ports gleichzeitig (z. B. Cockpit, Portainer, Web-Apps)
- Logging aller Abläufe in `/var/log/update-firewall.log`
- Systemd-Timer für regelmäßige Aktualisierung
- Logrotate-Konfiguration für saubere Logverwaltung
- Konfiguration über `.env`-Datei

## Ordnerstruktur

```
firewall-dynupdate/
├── scripts/
│   └── update_firewall.sh         # Hauptskript
├── systemd/
│   ├── update-firewall.service    # systemd Service
│   └── update-firewall.timer      # systemd Timer
├── logrotate/
│   └── update-firewall            # Logrotate-Konfiguration
├── .env                           # Konfiguration (HOSTS, PORTS, ZONE)
├── .env.example                   # Beispielkonfiguration
└── README.md                      # Diese Datei
```

## Voraussetzungen

- `firewalld` aktiv auf dem System
- `dig` (aus `dnsutils`) installiert
- Root-Rechte für Firewall-Updates
- systemd-basiertes Linux-System (z. B. Debian, Ubuntu, etc.)

## Einrichtung

### 1. Skript installieren

Speichere das Skript z. B. unter:
```
sudo cp scripts/update_firewall.sh /usr/local/bin/update_firewall.sh
sudo chmod +x /usr/local/bin/update_firewall.sh
```

### 2. .env-Datei konfigurieren

Inhalt z. B.:
```bash
HOSTS=(
  "mein-dyndns1.example.net"
  "mein-dyndns2.example.org"
  "lokaler-hostname"
)
PORTS=(9090 9443)
ZONE=home
```

### 3. systemd-Service aktivieren

```bash
sudo cp systemd/update-firewall.service /etc/systemd/system/
sudo cp systemd/update-firewall.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now update-firewall.timer
```

### 4. Logfile anlegen (optional, sonst wird es automatisch erstellt)
```bash
sudo touch /var/log/update-firewall.log
sudo chmod 600 /var/log/update-firewall.log
```

### 5. Logrotation konfigurieren
```bash
sudo cp logrotate/update-firewall /etc/logrotate.d/
```

## Logs anzeigen
```bash
sudo tail -f /var/log/update-firewall.log
journalctl -u update-firewall.service -n 20
```

## Lizenz
Dieses Projekt steht unter der MIT-Lizenz. Anpassbar und frei verwendbar 😄
