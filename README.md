# Raspberry Pi Kiosk Setup

Eine vollständige Lösung um einen Raspberry Pi in einen Kiosk-Modus zu versetzen.

## Dateien

- `start.sh` - Hauptscript zum Starten des Kiosk-Modus
- `install.sh` - Installationsscript für alle benötigten Pakete
- `autostart` - Desktop-Autostart Konfiguration
- `config.txt` - Boot-Konfiguration für den Raspberry Pi

## Installation

1. Alle Dateien auf den Raspberry Pi übertragen
2. Installationsscript ausführen:
   ```bash
   chmod +x install.sh
   sudo ./install.sh
   ```
3. System neustarten

## Konfiguration

- **URL ändern**: In `start.sh` die URL "https://example.com" durch Ihre gewünschte Webseite ersetzen
- **Bildschirmauflösung**: In `config.txt` anpassen
- **Autostart**: Wird automatisch durch das Installationsscript konfiguriert

## Funktionen

- Vollbild-Browser ohne Bedienelemente
- Automatischer Start beim Systemstart
- Bildschirmschoner deaktiviert
- Mauszeiger automatisch versteckt
- Energiesparfunktionen deaktiviert
- Fehlerdialoge unterdrückt

## Systemanforderungen

- Raspberry Pi mit Raspberry Pi OS (Desktop-Version)
- Internetverbindung
- Bildschirm angeschlossen
