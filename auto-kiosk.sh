#!/bin/bash

# =============================================================================
# Raspberry Pi Kiosk Autostart Script
# Startet Mentimeter-Webseite automatisch im Kiosk-Modus
# =============================================================================

# Konfiguration
KIOSK_DIR="/home/pi/kiosk"
LOG_FILE="$KIOSK_DIR/kiosk.log"
KIOSK_URL="https://www.menti.com/alkyrfv9ia3x"

# Logging-Funktion
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== Kiosk Autostart gestartet ==="

# Warten bis das System vollständig gestartet ist
log "Warte auf Systemstart..."
sleep 15

# Kiosk-Verzeichnis erstellen falls nicht vorhanden
mkdir -p "$KIOSK_DIR"

# Internetverbindung prüfen
log "Prüfe Internetverbindung..."
if ! ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    log "WARNUNG: Keine Internetverbindung erkannt!"
    log "Versuche trotzdem zu starten..."
fi

log "Lade Mentimeter-Webseite: $KIOSK_URL"

# Bildschirmschoner und Energieverwaltung deaktivieren
log "Deaktiviere Bildschirmschoner und Energieverwaltung..."
export DISPLAY=:0
xset s off 2>/dev/null || log "Warnung: xset s off fehlgeschlagen"
xset -dpms 2>/dev/null || log "Warnung: xset -dpms fehlgeschlagen"
xset s noblank 2>/dev/null || log "Warnung: xset s noblank fehlgeschlagen"

# Tastenkombinationen deaktivieren
log "Deaktiviere Tastenkombinationen..."
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.wm.keybindings close "[]" 2>/dev/null
    gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]" 2>/dev/null
    gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "[]" 2>/dev/null
fi

# Notfall-Exit-Handler im Hintergrund starten
log "Starte Notfall-Exit-Handler..."
(
    while true; do
        # Prüfe auf Ctrl+Shift+Alt+X Kombination
        if pgrep -f "chromium-browser.*kiosk" > /dev/null; then
            sleep 1
        else
            log "Chromium beendet, starte Cleanup..."
            break
        fi
    done
) &

# Mauszeiger verstecken
log "Verstecke Mauszeiger..."
if command -v unclutter &> /dev/null; then
    unclutter -idle 1 -root &
else
    log "Warnung: unclutter nicht installiert"
fi

# Warten vor Chromium-Start
sleep 5

# Chromium im Kiosk-Modus starten
log "Starte Chromium im Kiosk-Modus..."
log "URL: $KIOSK_URL"

chromium-browser \
    --noerrdialogs \
    --disable-infobars \
    --disable-features=TranslateUI \
    --disable-extensions \
    --disable-plugins \
    --disable-web-security \
    --disable-features=VizDisplayCompositor \
    --disable-restore-session-state \
    --disable-sync \
    --no-first-run \
    --fast \
    --fast-start \
    --disable-default-apps \
    --disable-translate \
    --disable-suggestions-service \
    --disable-save-password-bubble \
    --disable-session-crashed-bubble \
    --start-maximized \
    --kiosk \
    --incognito \
    --disable-background-mode \
    --disable-background-networking \
    --disable-background-timer-throttling \
    --disable-renderer-backgrounding \
    --disable-backgrounding-occluded-windows \
    --disable-ipc-flooding-protection \
    --no-sandbox \
    --disable-hang-monitor \
    --disable-prompt-on-repost \
    --disable-dev-shm-usage \
    --disable-gpu-sandbox \
    --ignore-certificate-errors \
    --ignore-ssl-errors \
    --ignore-certificate-errors-spki-list \
    --disable-features=VizDisplayCompositor \
    --allow-running-insecure-content \
    --disable-web-security \
    --user-data-dir=/tmp/chromium-kiosk \
    --app="$KIOSK_URL" \
    >> "$LOG_FILE" 2>&1 &

CHROMIUM_PID=$!
log "Chromium gestartet mit PID: $CHROMIUM_PID"

# Warten auf Chromium-Beendigung
wait $CHROMIUM_PID
log "Chromium beendet"

log "=== Kiosk Autostart beendet ==="
