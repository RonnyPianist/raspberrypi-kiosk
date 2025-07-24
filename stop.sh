echo "Stoppe Kiosk-Modus..."
pkill -f chromium-browser
pkill -f unclutter
echo "Kiosk-Modus gestoppt. Desktop ist wieder verfügbar."
echo "Zum Neustarten des Kiosk-Modus führen Sie './start.sh' aus."