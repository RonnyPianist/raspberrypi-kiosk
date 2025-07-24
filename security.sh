#!/bin/bash

# Erweiterte Kiosk-Sicherheitskonfiguration
# Dieses Script deaktiviert Tastenkombinationen und sichert den Kiosk-Modus ab

echo "Konfiguriere erweiterte Kiosk-Sicherheit..."

# 1. Desktop-Umgebung Shortcuts deaktivieren (GNOME/LXDE)
if command -v gsettings &> /dev/null; then
    echo "Deaktiviere GNOME Shortcuts..."
    gsettings set org.gnome.desktop.wm.keybindings close "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
    gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "[]"
    gsettings set org.gnome.desktop.wm.keybindings show-desktop "[]"
    gsettings set org.gnome.desktop.wm.keybindings panel-main-menu "[]"
fi

# 2. XFCE Shortcuts deaktivieren
if command -v xfconf-query &> /dev/null; then
    echo "Deaktiviere XFCE Shortcuts..."
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Alt>F4" -r 2>/dev/null
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Primary><Alt>t" -r 2>/dev/null
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>F4" -r 2>/dev/null
fi

# 3. Erstelle .xsessionrc für automatische Anwendung
cat > ~/.xsessionrc << 'EOF'
# Kiosk-Modus Tastenkombinationen deaktivieren
xset s off
xset -dpms
xset s noblank

# Desktop-Shortcuts deaktivieren falls möglich
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.wm.keybindings close "[]"
    gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "[]"
fi
EOF

# 4. Openbox Konfiguration (falls verwendet)
mkdir -p ~/.config/openbox
cat > ~/.config/openbox/rc.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/">
  <keyboard>
    <!-- Alle Tastenkombinationen deaktiviert -->
  </keyboard>
  <mouse>
    <dragThreshold>1</dragThreshold>
    <doubleClickTime>500</doubleClickTime>
    <screenEdgeWarpTime>0</screenEdgeWarpTime>
    <screenEdgeWarpMouse>false</screenEdgeWarpMouse>
  </mouse>
  <focus>
    <focusNew>yes</focusNew>
    <followMouse>no</followMouse>
    <focusLast>yes</focusLast>
    <underMouse>no</underMouse>
    <focusDelay>0</focusDelay>
    <raiseOnFocus>no</raiseOnFocus>
  </focus>
  <placement>
    <policy>Smart</policy>
  </placement>
</openbox_config>
EOF

# 5. Panel und Taskleiste deaktivieren
if pgrep -x "lxpanel" > /dev/null; then
    pkill lxpanel
fi

if pgrep -x "pcmanfm" > /dev/null; then
    pkill pcmanfm
fi

echo "Erweiterte Kiosk-Sicherheit konfiguriert!"
echo "System neustarten für vollständige Anwendung: sudo reboot"
