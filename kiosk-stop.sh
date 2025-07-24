#!/bin/bash

# =============================================================================
# Raspberry Pi Kiosk Stop Script  
# Beendet den Kiosk-Modus sicher
# =============================================================================

LOG_FILE="/home/pi/kiosk/kiosk.log"

# Logging-Funktion
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] STOP: $1" | tee -a "$LOG_FILE"
}

log "=== Kiosk-Modus wird beendet ==="

# Chromium-Prozesse beenden
log "Beende Chromium-Prozesse..."
pkill -f "chromium-browser.*kiosk" 2>/dev/null && log "Chromium beendet" || log "Kein Chromium-Prozess gefunden"

# Unclutter beenden
log "Beende Unclutter..."
pkill unclutter 2>/dev/null && log "Unclutter beendet" || log "Kein Unclutter-Prozess gefunden"

# Bildschirmschoner wieder aktivieren
log "Aktiviere Bildschirmschoner..."
export DISPLAY=:0
xset s on 2>/dev/null || log "Warnung: xset s on fehlgeschlagen"
xset +dpms 2>/dev/null || log "Warnung: xset +dpms fehlgeschlagen"

# Desktop anzeigen
log "Zeige Desktop..."
DISPLAY=:0 lxpanelctl restart 2>/dev/null || log "Warnung: lxpanelctl restart fehlgeschlagen"

log "=== Kiosk-Modus erfolgreich beendet ==="

# Desktop-Umgebung neu starten (optional)
# DISPLAY=:0 lxsession-logout --prompt="Kiosk beendet. Desktop neu starten?" 2>/dev/null &
