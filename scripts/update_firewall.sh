#!/bin/bash
set -euo pipefail

# ===========================
# Dynamisches Firewall-Update via DNS-Auflösung (.env konfigurierbar)
# ===========================

# .env-Datei einlesen
ENV_FILE="$(dirname "$0")/../.env"
# shellcheck source=../.env
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "Fehler: .env-Datei nicht gefunden unter $ENV_FILE"
    exit 1
fi

# Root-Prüfung
if [[ $EUID -ne 0 ]]; then
    echo "Dieses Skript muss als root ausgeführt werden." >&2
    exit 1
fi

# Dateien für aktuellen und vorherigen Zustand
TMPFILE="/tmp/allowed_ips.txt"
CURRFILE="/tmp/current_ips.txt"

# Logfile
LOGFILE="/var/log/update-firewall.log"
echo "[$(date)] Start: Firewall-Regeln aktualisieren" >> "$LOGFILE"

# Neues IP-File vorbereiten
: > "$CURRFILE"

# shellcheck disable=SC2153
for HOST in "${HOSTS[@]}"; do
    IP=$(dig +short "$HOST" | tail -n1)
    if [[ $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Ermittelte IP für $HOST: $IP" | tee -a "$LOGFILE"
        echo "$IP" >> "$CURRFILE"
    else
        echo "WARNUNG: $HOST konnte nicht aufgelöst werden." | tee -a "$LOGFILE"
    fi
done

# Nur bei Änderung der IPs weitermachen
if ! cmp -s "$CURRFILE" "$TMPFILE"; then
    echo "IP-Änderung erkannt – aktualisiere Firewall..." | tee -a "$LOGFILE"

    # Alte Regeln entfernen
    OLD_IPS=$(cat "$TMPFILE" 2>/dev/null)
    for IP in $OLD_IPS; do
        # shellcheck disable=SC2153
        for PORT in "${PORTS[@]}"; do
            sudo firewall-cmd --permanent --zone="$ZONE" \
              --remove-rich-rule="rule family='ipv4' source address='$IP' port port=$PORT protocol=tcp accept" | tee -a "$LOGFILE"
        done
    done

    # Neue Regeln setzen
    NEW_IPS=$(cat "$CURRFILE")
    for IP in $NEW_IPS; do
        # shellcheck disable=SC2153
        for PORT in "${PORTS[@]}"; do
            sudo firewall-cmd --permanent --zone="$ZONE" \
              --add-rich-rule="rule family='ipv4' source address='$IP' port port=$PORT protocol=tcp accept" | tee -a "$LOGFILE"
        done
    done

    # Firewall neuladen
    sudo firewall-cmd --reload | tee -a "$LOGFILE"

    # Neue IPs als Referenz speichern
    cp "$CURRFILE" "$TMPFILE"
else
    echo "Keine Änderung – Firewall bleibt gleich." | tee -a "$LOGFILE"
fi
