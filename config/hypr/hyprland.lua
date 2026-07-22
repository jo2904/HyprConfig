require("monitors")
require("workspaces")
require("animation")
require("autostart")
require("bindings")
require("gestures")
require("windowrules")

-- Variables d'environnement
hl.env("XCURSOR_SIZE",                "24")
hl.env("HYPRCURSOR_SIZE",             "24")
hl.env("GDK_BACKEND",                 "wayland,x11,*")
hl.env("QT_QPA_PLATFORM",             "wayland;xcb")
hl.env("QT_STYLE_OVERRIDE",           "kvantum")
hl.env("SDL_VIDEODRIVER",             "wayland")
hl.env("MOZ_ENABLE_WAYLAND",          "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT","wayland")
hl.env("OZONE_PLATFORM",              "wayland")

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
    binds = {
        allow_workspace_cycles = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },
    input = {
        kb_layout          = "fr",
        kb_variant         = "",
        kb_model           = "",
        kb_options         = "",
        kb_rules           = "",
        numlock_by_default = true,
        follow_mouse       = 1,
        sensitivity        = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})
