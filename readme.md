# Raspberry Pi Kiosk System

Ein komplettes Autostart-System für Raspberry Pi, das automatisch eine Mentimeter-Webseite im Kiosk-Modus anzeigt.

## Features

-  Automatischer Start beim Boot
-  Mentimeter-Webseite im Vollbildmodus
-  Vollbildmodus ohne Browser-Interface
-  Bildschirmschoner permanent deaktiviert
-  Mauszeiger automatisch versteckt
-  Notfall-Exit-Kombination (Ctrl+Shift+Alt+X)
-  Umfassendes Logging
-  Internetverbindungsprüfung
-  Einfache Installation

## Enthaltene Dateien

- `install-kiosk.sh` - Vollständige Installation aller Komponenten
- `auto-kiosk.sh` - Haupt-Kiosk-Script mit HTML-Generierung
- `kiosk-stop.sh` - Detailliertes Stop-Script
- `auto-kiosk.desktop` - Autostart-Desktop-Datei

## Installation auf dem Raspberry Pi

1. **Dateien auf den Raspberry Pi übertragen:**
   ```bash
   # Option 1: USB-Stick oder SFTP
   # Option 2: Git Clone (falls Repository verfügbar)
   # Option 3: Direkt auf Pi erstellen
   ```

2. **Installation ausführen (Im Terminal/Shell):**
   ```bash
   chmod +x install-kiosk.sh
   ./install-kiosk.sh
   ```

3. **System neustarten:**
   ```bash
   sudo reboot
   ```

## Verwendung

### Automatischer Start
- Nach dem Reboot startet der Kiosk-Modus automatisch
- Zeigt die Mentimeter-Webseite: URL

### Manueller Start
```bash
cd /home/pi/kiosk
./auto-kiosk.sh
```

### Kiosk beenden
- **Notfall-Tastenkombination:** `Ctrl+Shift+Alt+X`
- **Über Terminal:** `./stop.sh`

### URL ändern
```bash
nano /home/pi/kiosk/auto-kiosk.sh
# Ändern Sie die Zeile: KIOSK_URL="URL"
```

## Mentimeter Integration

Das System ist konfiguriert für die spezifische Mentimeter-Webseite:
- **URL:** URL
- **Vollbildmodus:** Optimiert für Präsentationen
- **Internetverbindungsprüfung:** Warnt bei fehlender Verbindung
- **Browser-Optimierung:** Spezielle Chromium-Flags für Web-Apps

## Konfiguration

### Eigene URL verwenden
In `auto-kiosk.sh` ändern:
```bash
# Aktuelle Zeile:
KIOSK_URL="URL"

# Ändern zu:
KIOSK_URL="https://ihre-webseite.de"
```

### Autostart deaktivieren
```bash
rm ~/.config/autostart/kiosk.desktop
```

### Systemd Service (Alternative)
```bash
sudo systemctl enable kiosk.service
sudo systemctl start kiosk.service
```

## Logs und Debugging

- **Haupt-Log:** `/home/pi/kiosk/kiosk.log`
- **Weitere Logs:** `/home/pi/kiosk/logs/`

### Log-Ausgabe in Echtzeit
```bash
tail -f /home/pi/kiosk/kiosk.log
```

## Troubleshooting

### Kiosk startet nicht
1. Log-Datei prüfen: `cat /home/pi/kiosk/kiosk.log`
2. Internetverbindung prüfen: `ping 8.8.8.8`
3. Berechtigungen prüfen: `ls -la /home/pi/kiosk/*.sh`
4. Manuell testen: `cd /home/pi/kiosk && ./auto-kiosk.sh`

### Mentimeter lädt nicht
1. Internetverbindung prüfen: `ping www.menti.com`
2. URL im Browser testen: URL
3. DNS-Einstellungen prüfen: `cat /etc/resolv.conf`

### Schwarzer Bildschirm
1. HDMI-Kabel prüfen
2. Boot-Konfiguration prüfen: `cat /boot/config.txt`
3. X11 läuft: `ps aux | grep X`

### Autostart funktioniert nicht
1. Desktop-Datei prüfen: `cat ~/.config/autostart/kiosk.desktop`
2. Autostart testen: `dex ~/.config/autostart/kiosk.desktop`

## Sicherheit

- Browser läuft im Incognito-Modus
- Keine Passwort-Speicherung
- Web-Security deaktiviert für lokale Dateien
- Sandbox deaktiviert für bessere Performance

## Anpassungen

### Design der Webseite ändern
Die CSS-Styles in `/home/pi/kiosk/web/index.html` können beliebig angepasst werden.

### Zusätzliche Funktionen
- Wetter-Widget hinzufügen
- RSS-Feed einbinden  
- Kamera-Stream anzeigen
- Interaktive Elemente

## Systemanforderungen

- Raspberry Pi 3 oder neuer
- Raspberry Pi OS (Bullseye oder neuer)
- Desktop-Umgebung (LXDE/PIXEL)
- Internetverbindung für Installation

## Notfall-Maßnahmen

Falls das System nicht mehr reagiert:
1. **SSH-Zugang:** `ssh pi@raspberry-ip`
2. **Kiosk beenden:** `pkill -f chromium-browser`
3. **Autostart deaktivieren:** `rm ~/.config/autostart/kiosk.desktop`
4. **Neustart:** `sudo reboot`

**Viel Erfolg mit Ihrem Raspberry Pi Kiosk-System! 🎉**
