# FAQ – Häufige Fragen

## Warum wird keine IP aufgelöst?

Prüfe zuerst, ob `dig` installiert ist:
```bash
dig example.org
```
Falls nicht:
```bash
sudo apt install dnsutils
```

Stelle sicher, dass die Hostnamen in der `.env`-Datei korrekt sind (kein Tippfehler, keine Anführungszeichen um das ganze Array).

---

## Was passiert, wenn eine IP sich nicht ändert?

Das Skript vergleicht alte und neue IPs. Nur wenn sich etwas ändert, wird die Firewall angepasst. Andernfalls bleibt alles wie es ist.

---

## Warum funktioniert die Weiterleitung im lokalen Netz nicht?

Stelle sicher, dass dein interner Hostname (z. B. `nas`) im LAN korrekt aufgelöst wird (z. B. via `getent hosts nas`).

Falls nicht, nutze besser eine feste IP in deiner `.env` oder setze sie statisch in deiner FritzBox.

---

## Warum wird Port 9090 trotz Regel blockiert?

- Stelle sicher, dass die Quelle-IP des Clients mit der aufgelösten IP übereinstimmt
- Prüfe mit `firewall-cmd --zone=home --list-rich-rules`, ob die Regel wirklich gesetzt wurde
- Firewall reload gemacht? (`sudo firewall-cmd --reload`)

---

## Kann ich weitere Dienste schützen?

Ja! Einfach in `.env` mehrere Ports definieren:
```bash
PORTS=(9090 9443 8123)
```
Jede aufgelöste IP wird dann für alle Ports einzeln freigegeben.

---

## Wo finde ich das Log?

```bash
cat /var/log/update-firewall.log
```
Es enthält Zeitstempel, IP-Zuordnungen und etwaige Warnungen.

---

## Wie setze ich das Ganze zurück?

```bash
sudo systemctl stop update-firewall.timer
sudo firewall-cmd --permanent --zone=home --remove-rich-rule='rule family="ipv4" ...'
sudo firewall-cmd --reload
```
Oder: TMP-Dateien löschen:
```bash
sudo rm /tmp/allowed_ips.txt /tmp/current_ips.txt
```

---

Noch Fragen? Gerne Issue auf GitHub öffnen 😄
