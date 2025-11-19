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

#!/bin/bash

echo "➡️ Configuration des limites d'échecs de connexion (faillock)..."

# 1. Configurer /etc/security/faillock.conf
echo "➡️ Mise à jour de /etc/security/faillock.conf"

sudo bash -c 'cat > /etc/security/faillock.conf <<EOF
# Nombre d'échecs autorisés
deny = 5

# Intervalle de temps (5 minutes)
fail_interval = 300

# Durée du blocage (5 minutes)
unlock_time = 300
EOF'

echo "✔️ faillock.conf configuré."

# 2. Vérifier que faillock est bien activé dans /etc/pam.d/sddm
echo "➡️ Vérification de la configuration PAM pour SDDM..."

PAM_FILE="/etc/pam.d/sddm"

# Sauvegarde avant modification
sudo cp "$PAM_FILE" "$PAM_FILE.bak"

sudo bash -c "grep -q 'pam_faillock.so preauth' $PAM_FILE || \
sed -i '/auth.*pam_unix.so/i auth       required   pam_faillock.so preauth' $PAM_FILE"

sudo bash -c "grep -q 'pam_faillock.so authfail' $PAM_FILE || \
sed -i '/auth.*pam_unix.so/a auth       [default=die] pam_faillock.so authfail' $PAM_FILE"

sudo bash -c "grep -q 'pam_faillock.so$' $PAM_FILE || \
sed -i '/account.*pam_unix.so/a account    required   pam_faillock.so' $PAM_FILE"

echo "✔️ PAM pour SDDM vérifié et corrigé."

# 3. Réinitialiser d'anciens blocages
echo "➡️ Réinitialisation des blocages existants..."
sudo faillock --reset

echo "🎉 Configuration terminée :"
echo "   - 5 erreurs max"
echo "   - Fenêtre : 5 min"
echo "   - Blocage : 5 min"
echo "   - SDDM utilise maintenant ces règles"
