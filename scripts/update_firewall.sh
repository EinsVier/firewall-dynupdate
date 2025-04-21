#!/bin/bash

# ===========================
# Dynamisches Firewall-Update via DNS-Auflösung
# ===========================
# Dieses Skript aktualisiert die Firewall-Regeln basierend auf den IP-Adressen
# von Hosts, die in einer .env-Datei definiert sind. Es wird nur aktualisiert,
# .env-Datei einlesen (im selben Verzeichnis wie das Skript)
ENV_FILE="$(dirname "$0")/../.env"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "Fehler: .env-Datei nicht gefunden unter $ENV_FILE"
    exit 1
fi

# Dateien für aktuellen und vorherigen Zustand
TMPFILE="/tmp/allowed_ips.txt"
CURRFILE="/tmp/current_ips.txt"

# Logfile
LOGFILE="/var/log/update-firewall.log"
echo "[$(date)] Start: Firewall-Regeln aktualisieren" >> "$LOGFILE"

# Neues IP-File vorbereiten
> "$CURRFILE"

# IPs der Hosts ermitteln
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
        sudo firewall-cmd --permanent --zone=$ZONE \
          --remove-rich-rule="rule family='ipv4' source address='$IP' port port=$PORT protocol=tcp accept" >> "$LOGFILE" 2>&1
    done

    # Neue Regeln setzen
    NEW_IPS=$(cat "$CURRFILE")
    for IP in $NEW_IPS; do
        sudo firewall-cmd --permanent --zone=$ZONE \
          --add-rich-rule="rule family='ipv4' source address='$IP' port port=$PORT protocol=tcp accept" >> "$LOGFILE" 2>&1
    done

    # Firewall neuladen
    sudo firewall-cmd --reload >> "$LOGFILE" 2>&1

    # Neue IPs als Referenz speichern
    cp "$CURRFILE" "$TMPFILE"
else
    echo "Keine Änderung – Firewall bleibt gleich." | tee -a "$LOGFILE"
fi
