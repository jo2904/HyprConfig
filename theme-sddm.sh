THEME_NAME="hyprlock-style"
INSTALL_DIR="/usr/share/sddm/themes"
CONF_DIR="/etc/sddm.conf.d"
LOCAL_PATH="$(pwd)/config/theme/$THEME_NAME"
echo "📦 Installation du thème SDDM : $THEME_NAME"

# 1️⃣ Copie du thème
if [ ! -d "$LOCAL_PATH" ]; then
    echo "❌ Dossier $LOCAL_PATH introuvable."
    exit 1
fi

echo "➡️  Copie du thème dans $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp -r "$LOCAL_PATH" "$INSTALL_DIR/"

# 2️⃣ Configuration du thème dans SDDM
echo "➡️  Configuration du thème dans $CONF_DIR/theme.conf..."
mkdir -p "$CONF_DIR"
cat > "$CONF_DIR/theme.conf" <<EOF
[Theme]
Current=$THEME_NAME
EOF

# 3️⃣ Configuration du clavier français
echo "➡️  Configuration du clavier français dans $CONF_DIR/keyboard.conf..."
cat > "$CONF_DIR/keyboard.conf" <<EOF
[General]
InputMethod=

[X11]
DisplayCommand=/usr/share/sddm/scripts/Xsetup
Numlock=on

[Keyboard]
Layout=fr
Variant=
Model=pc105
Options=
EOF

# 4️⃣ Vérifie la présence du thème
if [ ! -f "$INSTALL_DIR/$THEME_NAME/Main.qml" ]; then
    echo "❌ Erreur : Main.qml introuvable dans $INSTALL_DIR/$THEME_NAME"
    exit 1
fi

echo "✅ Installation terminée avec succès !"
echo "🎨 Thème : $THEME_NAME"
echo "🇫🇷 Clavier : fr (azerty)"