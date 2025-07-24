echo "=== Raspberry Pi Kiosk Setup ==="
echo "Installiere benötigte Pakete..."
sudo apt update
sudo apt upgrade -y
sudo apt install -y \
    chromium-browser \
    unclutter \
    sed

echo "Konfiguriere Autostart..."
mkdir -p ~/.config/autostart

# Die vorhandene autostart-Datei nach ~/.config/autostart/ kopieren
cp autostart ~/.config/autostart/kiosk.desktop

# Scripts ausführbar machen
chmod +x start.sh
chmod +x security.sh

# Erweiterte Sicherheitskonfiguration anwenden
./security.sh
echo "Deaktiviere Bildschirmschoner..."
sudo apt remove -y xscreensaver
echo "Konfiguriere Boot-Einstellungen..."
if [ ! -f /boot/config.txt.backup ]; then
    sudo cp /boot/config.txt /boot/config.txt.backup
fi
if ! grep -q "gpu_mem=128" /boot/config.txt; then
    echo "gpu_mem=128" | sudo tee -a /boot/config.txt
fi
echo "=== Installation abgeschlossen ==="
echo ""
echo "Nächste Schritte:"
echo "1. URL in start.sh anpassen (aktuell: https://example.com)"
echo "2. System neustarten: sudo reboot"
echo ""
echo "Der Kiosk-Modus startet automatisch nach dem Neustart!"