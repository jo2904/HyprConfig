-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- hypridle")
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
