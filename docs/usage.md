# Verwendung

Hier erfährst du, wie du das Skript im Alltag nutzt, prüfst und erweiterst.

## Manuelles Ausführen

Zum Testen oder sofortigen Aktualisieren:
```bash
sudo /usr/local/bin/update_firewall.sh
```

## Timer überprüfen

Status des systemd-Timers:
```bash
systemctl status update-firewall.timer
```

Letzte Durchläufe ansehen:
```bash
journalctl -u update-firewall.service -n 20
```

## Logs anzeigen

```bash
sudo tail -f /var/log/update-firewall.log
```

## Konfiguration anpassen

Ändere die `.env`-Datei:
```bash
nano .env
```
Dann Timer neu starten:
```bash
sudo systemctl restart update-firewall.timer
```

## Beispiel `.env`

```bash
HOSTS=(
  "mein-dyndns1.example.net"
  "mein-dyndns2.example.org"
  "nas"
)
PORTS=(9090 9443)
ZONE=home
```

## Erweiterung: mehrere Ports

Das Skript erlaubt mehrere Ports gleichzeitig – z. B. für Cockpit, Portainer oder Home Assistant.

```bash
PORTS=(9090 9443 8123)
```

Weiter zu [Fehlerbehebung](./faq.md) →
