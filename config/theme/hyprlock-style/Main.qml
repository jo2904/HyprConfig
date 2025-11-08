import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: parent ? parent.width : 1920
    height: parent ? parent.height : 1080
    color: "#2e3440" // même couleur que ton Hyprlock

    // --- HEURE ---
    Text {
        id: timeLabel
        text: Qt.formatDateTime(new Date(), "HH:mm")
        color: "#d8dee9"
        font.family: "JetBrains Mono Extrabold"
        font.pixelSize: 150    // plus gros
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenterOffset: -300   // plus haut
        anchors.verticalCenter: parent.verticalCenter

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: timeLabel.text = Qt.formatDateTime(new Date(), "HH:mm")
        }
    }

    // --- DATE ---
    Text {
        id: dateLabel
        text: Qt.formatDateTime(new Date(), "dddd dd MMMM")
        color: "#d8dee9"
        font.family: "JetBrains Mono"
        font.pixelSize: 40      // plus gros
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: timeLabel.bottom
        anchors.topMargin: 20
    }

// --- CHAMP DE MOT DE PASSE ---
TextField {
    id: passwordField
    placeholderText: "  Enter Password 󰈷 "
    color: "#d8dee9"
    font.family: "CaskaydiaMono Nerd Font"
    font.pixelSize: 35
    echoMode: TextInput.Password
    width: 600
    height: 100
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenterOffset: 300
    anchors.verticalCenter: parent.verticalCenter
    focus: true   

    // Ajoute un peu d'espace intérieur
    leftPadding: 25
    rightPadding: 25
    topPadding: 10
    bottomPadding: 10

    background: Rectangle {
        radius: 10
        color: "#2e3440"
        border.color: "#d8dee9"
        border.width: 4
    }
}

Keys.onReturnPressed: {
    sddm.login("jo", passwordField.text, "hyprland")
}



}
