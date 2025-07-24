#!/bin/bash

# Raspberry Pi Kiosk Mode Start Script
# Dieses Script startet den Raspberry Pi im Kiosk-Modus mit Chromium

# Warten bis das System vollständig gestartet ist
sleep 10

# Bildschirmschoner und Energieverwaltung deaktivieren
xset s off
xset -dpms
xset s noblank

# Tastenkombinationen deaktivieren (Alt+F4, Ctrl+Alt+T, etc.)
# Desktop-Umgebung Shortcuts deaktivieren
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.wm.keybindings close "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
    gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "[]"
fi

# Window Manager Tastenkombinationen blockieren
if command -v xfconf-query &> /dev/null; then
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/&lt;Alt&gt;F4" -s ""
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/&lt;Primary&gt;&lt;Alt&gt;t" -s ""
fi

# NOTFALL-TASTENKOMBINATION: Ctrl+Shift+Alt+X zum Beenden
# Hintergrund-Script starten, das auf die Tastenkombination hört
(
    while true; do
        if xinput test-xi2 --root | grep -q "KeyPress.*key 53.*Control.*Shift.*Alt"; then
            pkill -f chromium-browser
            break
        fi
        sleep 0.1
    done
) &

# Mauszeiger verstecken (unclutter muss installiert sein)
unclutter -idle 0.5 -root &

# Chromium im Kiosk-Modus starten mit erweiterten Sicherheitsoptionen
# Ersetzen Sie "https://example.com" mit Ihrer gewünschten URL
chromium-browser \
    --noerrdialogs \
    --disable-infobars \
    --disable-features=TranslateUI \
    --disable-extensions \
    --disable-plugins \
    --disable-web-security \
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
    --disable-infobars \
    --disable-features=VizDisplayCompositor \
    --start-maximized \
    --kiosk \
    --incognito \
    --disable-background-mode \
    --disable-background-networking \
    --disable-background-timer-throttling \
    --disable-renderer-backgrounding \
    --disable-backgrounding-occluded-windows \
    --disable-features=TranslateUI \
    --disable-ipc-flooding-protection \
    --no-sandbox \
    --disable-hang-monitor \
    --disable-prompt-on-repost \
    --disable-features=VizDisplayCompositor \
    --app="https://example.com"