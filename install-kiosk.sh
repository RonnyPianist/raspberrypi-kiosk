#!/bin/bash

# =============================================================================
# Raspberry Pi Kiosk Installation Script
# Installiert alle benötigten Komponenten für den Kiosk-Modus
# =============================================================================

set -e  # Script bei Fehlern beenden

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging-Funktionen
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Prüfen ob als Root ausgeführt
if [[ $EUID -eq 0 ]]; then
   log_error "Dieses Script sollte NICHT als root ausgeführt werden!"
   echo "Verwenden Sie: ./install-kiosk.sh"
   exit 1
fi

log_info "=== Raspberry Pi Kiosk Installation gestartet ==="

# System aktualisieren
log_info "Aktualisiere Paketlisten..."
sudo apt update

log_info "Aktualisiere System..."
sudo apt upgrade -y

# Benötigte Pakete installieren
log_info "Installiere benötigte Pakete..."
sudo apt install -y \
    chromium-browser \
    unclutter \
    xdotool \
    xinput \
    x11-xserver-utils \
    matchbox-window-manager \
    xautomation

# Kiosk-Verzeichnis erstellen
KIOSK_DIR="/home/$USER/kiosk"
log_info "Erstelle Kiosk-Verzeichnis: $KIOSK_DIR"
mkdir -p "$KIOSK_DIR"
mkdir -p "$KIOSK_DIR/web"
mkdir -p "$KIOSK_DIR/logs"

# Scripts kopieren
log_info "Kopiere Kiosk-Scripts..."
cp auto-kiosk.sh "$KIOSK_DIR/"
cp kiosk-stop.sh "$KIOSK_DIR/" 2>/dev/null || log_warning "kiosk-stop.sh nicht gefunden"
cp start.sh "$KIOSK_DIR/" 2>/dev/null || log_warning "start.sh nicht gefunden"
cp stop.sh "$KIOSK_DIR/" 2>/dev/null || log_warning "stop.sh nicht gefunden"

# Ausführungsrechte setzen
chmod +x "$KIOSK_DIR"/*.sh

# Autostart-Verzeichnis erstellen
AUTOSTART_DIR="/home/$USER/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

# Autostart Desktop-Datei erstellen
log_info "Erstelle Autostart-Desktop-Datei..."
cat > "$AUTOSTART_DIR/kiosk.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Raspberry Pi Kiosk
Comment=Startet den Raspberry Pi im Kiosk-Modus mit Mentimeter
Exec=$KIOSK_DIR/auto-kiosk.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
StartupNotify=false
Terminal=false
Categories=System;
Icon=applications-internet
EOF

# Boot-Konfiguration anpassen
log_info "Konfiguriere Boot-Einstellungen..."

# GPU Memory Split erhöhen für bessere Performance
if ! grep -q "gpu_mem=128" /boot/config.txt; then
    echo "gpu_mem=128" | sudo tee -a /boot/config.txt
    log_info "GPU Memory auf 128MB gesetzt"
fi

# Disable Overscan für bessere Bildschirmnutzung
if ! grep -q "disable_overscan=1" /boot/config.txt; then
    echo "disable_overscan=1" | sudo tee -a /boot/config.txt
    log_info "Overscan deaktiviert"
fi

# HDMI-Ausgang erzwingen
if ! grep -q "hdmi_force_hotplug=1" /boot/config.txt; then
    echo "hdmi_force_hotplug=1" | sudo tee -a /boot/config.txt
    log_info "HDMI-Hotplug erzwungen"
fi

# Desktop-Umgebung optimieren
log_info "Optimiere Desktop-Umgebung für Kiosk-Modus..."

# Splash Screen deaktivieren
sudo sed -i 's/$/ quiet splash plymouth.ignore-serial-consoles/' /boot/cmdline.txt 2>/dev/null || true

# Taskleiste automatisch verstecken (falls LXDE)
LXPANEL_CONFIG="/home/$USER/.config/lxpanel/LXDE-pi/panels/panel"
if [ -f "$LXPANEL_CONFIG" ]; then
    sed -i 's/autohide=0/autohide=1/' "$LXPANEL_CONFIG" 2>/dev/null || true
    log_info "Taskleiste wird automatisch versteckt"
fi

# Bildschirmschoner permanent deaktivieren
cat >> "/home/$USER/.bashrc" << 'EOF'

# Kiosk-Modus: Bildschirmschoner deaktivieren
if [ -n "$DISPLAY" ]; then
    xset s off 2>/dev/null
    xset -dpms 2>/dev/null  
    xset s noblank 2>/dev/null
fi
EOF

# Service-Datei für systemd erstellen (optional)
log_info "Erstelle systemd Service..."
sudo tee /etc/systemd/system/kiosk.service > /dev/null << EOF
[Unit]
Description=Raspberry Pi Kiosk Service
After=graphical-session.target

[Service]
Type=forking
User=$USER
Environment=DISPLAY=:0
WorkingDirectory=$KIOSK_DIR
ExecStart=$KIOSK_DIR/auto-kiosk.sh
Restart=on-failure
RestartSec=10

[Install]
WantedBy=graphical-session.target
EOF

# Service aktivieren (standardmäßig deaktiviert)
# sudo systemctl enable kiosk.service

# Hilfe-Skript erstellen
log_info "Erstelle Hilfe-Skript..."
cat > "$KIOSK_DIR/help.sh" << 'EOF'
#!/bin/bash
echo "=== Raspberry Pi Kiosk Hilfe ==="
echo ""
echo "Verfügbare Kommandos:"
echo "  ./auto-kiosk.sh     - Kiosk-Modus starten"
echo "  ./start.sh          - Kiosk-Modus starten (alias)"
echo "  ./stop.sh           - Kiosk-Modus beenden"
echo "  ./help.sh           - Diese Hilfe anzeigen"
echo ""
echo "Notfall-Exit im Kiosk-Modus:"
echo "  Ctrl+Shift+Alt+X    - Kiosk-Modus beenden"
echo ""
echo "Systemd Service (optional):"
echo "  sudo systemctl start kiosk    - Service starten"
echo "  sudo systemctl stop kiosk     - Service stoppen"
echo "  sudo systemctl enable kiosk   - Autostart aktivieren"
echo "  sudo systemctl disable kiosk  - Autostart deaktivieren"
echo ""
echo "Log-Dateien:"
echo "  $PWD/kiosk.log     - Kiosk-Log"
echo "  $PWD/logs/         - Weitere Logs"
echo ""
echo "Konfiguration:"
echo "  $PWD/web/index.html - Webseite bearbeiten"
echo ""
EOF

chmod +x "$KIOSK_DIR/help.sh"

# README erstellen
log_info "Erstelle README..."
cat > "$KIOSK_DIR/README.md" << 'EOF'
# Raspberry Pi Kiosk System

Dieses System verwandelt Ihren Raspberry Pi in ein Kiosk-System, das automatisch eine Mentimeter-Webseite im Vollbildmodus anzeigt.

## Features

- ✅ Automatischer Start beim Boot
- ✅ Mentimeter-Webseite im Vollbildmodus
- ✅ Vollbildmodus ohne Browser-UI
- ✅ Bildschirmschoner deaktiviert
- ✅ Mauszeiger automatisch versteckt
- ✅ Notfall-Exit-Kombination
- ✅ Logging und Monitoring
- ✅ Internetverbindungsprüfung

## Verwendung

### Kiosk starten
```bash
./auto-kiosk.sh
```

### Kiosk beenden
- Notfall-Tastenkombination: `Ctrl+Shift+Alt+X`
- Oder Terminal: `./stop.sh`

### URL ändern
Bearbeiten Sie die Variable KIOSK_URL in `auto-kiosk.sh`

### Hilfe
```bash
./help.sh
```

## Struktur

```
kiosk/
├── auto-kiosk.sh      # Haupt-Script
├── start.sh           # Start-Script (alias)
├── stop.sh            # Stop-Script
├── help.sh            # Hilfe-Script
├── README.md          # Diese Datei
├── logs/              # Log-Verzeichnis
└── kiosk.log          # Haupt-Log-Datei
```

## Troubleshooting

### Kiosk startet nicht
1. Prüfen Sie die Log-Datei: `cat kiosk.log`
2. Testen Sie manuell: `./auto-kiosk.sh`
3. Prüfen Sie Berechtigungen: `ls -la *.sh`
4. Prüfen Sie Internetverbindung: `ping 8.8.8.8`

### Webseite wird nicht angezeigt
1. Prüfen Sie Internetverbindung
2. Testen Sie die URL im Browser: https://www.menti.com/alkyrfv9ia3x
3. Prüfen Sie die Chromium-Logs in kiosk.log

### Autostart funktioniert nicht
1. Prüfen Sie die Desktop-Datei: `cat ~/.config/autostart/kiosk.desktop`
2. Testen Sie den Autostart: `dex ~/.config/autostart/kiosk.desktop`

## Anpassungen

### Andere URL verwenden
Ändern Sie in `auto-kiosk.sh` die Zeile:
```bash
KIOSK_URL="https://www.menti.com/alkyrfv9ia3x"
```
zu:
```bash
KIOSK_URL="https://ihre-webseite.de"
```

### Automatischen Start deaktivieren
```bash
rm ~/.config/autostart/kiosk.desktop
```

### Systemd Service verwenden
```bash
sudo systemctl enable kiosk.service
sudo systemctl start kiosk.service
```
EOF

# Installation abschließen
log_success "=== Installation erfolgreich abgeschlossen! ==="
echo ""
log_info "Nächste Schritte:"
echo "1. Neustart: sudo reboot"
echo "2. Oder manuell starten: cd $KIOSK_DIR && ./auto-kiosk.sh"
echo "3. Hilfe anzeigen: cd $KIOSK_DIR && ./help.sh"
echo ""
log_info "Installierte Dateien:"
echo "- Kiosk-Verzeichnis: $KIOSK_DIR"
echo "- Autostart-Desktop: $AUTOSTART_DIR/kiosk.desktop"
echo "- Systemd Service: /etc/systemd/system/kiosk.service"
echo ""
log_warning "Notfall-Exit im Kiosk-Modus: Ctrl+Shift+Alt+X"
