-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

hl.on("hyprland.start", function()
    -- Les deux écrans ont un workspace "default" (1 et 7) : au login, le
    -- focus atterrit sur l'un ou l'autre selon l'ordre de détection des
    -- moniteurs. On force explicitement le focus sur le workspace 1.
    hl.dispatch(hl.dsp.focus({ workspace = 1 }))

    hl.exec_cmd("uwsm app -- ~/.config/scripts/start-hypridle.sh")
    hl.exec_cmd("uwsm app -- hyprsunset")
    hl.exec_cmd("uwsm app -- hyprpaper")
    -- mako reste configuré (config/mako/) mais n'est plus autostarté :
    -- quickshell (NotificationService) gère les notifications. Pour revenir
    -- en arrière, décommenter la ligne suivante et retirer le NotificationService.
    -- hl.exec_cmd("uwsm app -- mako")
    hl.exec_cmd("uwsm app -- quickshell")
    hl.exec_cmd("bluetoothctl power off")
    hl.exec_cmd("qs -p ~/.config/quickshell/overview")
    -- hl.exec_cmd("hyprpm reload -n")
    hl.exec_cmd("systemctl --user enable --now hyprpolkitagent.service")
end)
