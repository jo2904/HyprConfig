-- Toutes les fenêtres flottantes centrées par défaut
hl.window_rule({
    name   = "windowrule-default-float",
    center = true,
    float  = true,
    match  = { float = true },
})

-- Picture-in-Picture
hl.window_rule({
    name              = "windowrule-pip",
    float             = true,
    keep_aspect_ratio = true,
    move              = "monitor_w*0.73 monitor_h*0.72",
    size              = "monitor_w*0.25 monitor_h*0.25",
    pin               = true,
    match             = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
})

hl.window_rule({
    name              = "windowrule-video-overlay",
    float             = true,
    keep_aspect_ratio = true,
    move              = "monitor_w*0.73 monitor_h*0.72",
    size              = "monitor_w*0.25 monitor_h*0.25",
    pin               = true,
    match             = { title = "^(Incrustation vidéo).*" },
})

-- Outil capture d'écran (satty)
hl.window_rule({
    name  = "windowrule-satty",
    float = true,
    size  = "monitor_w*0.7 monitor_h*0.6",
    move  = "monitor_w*0.15 monitor_h*0.15",
    match = { title = "^(satty)$" },
})

-- Boîtes de dialogue communes (EN + FR)
hl.window_rule({
    name  = "windowrule-open-dialog-en",
    float = true,
    size  = "monitor_w*0.7 monitor_h*0.6",
    move  = "monitor_w*0.15 monitor_h*0.15",
    match = { title = "^(Open)$" },
})

hl.window_rule({
    name  = "windowrule-open-dialog-fr",
    float = true,
    size  = "monitor_w*0.7 monitor_h*0.6",
    move  = "monitor_w*0.15 monitor_h*0.15",
    match = { title = "^(Ouvrir)$" },
})

hl.window_rule({
    name  = "windowrule-saveas-dialog-en",
    float = true,
    size  = "monitor_w*0.7 monitor_h*0.6",
    move  = "monitor_w*0.15 monitor_h*0.15",
    match = { title = "^(Save As)$" },
})

hl.window_rule({
    name  = "windowrule-saveas-dialog-fr",
    float = true,
    size  = "monitor_w*0.7 monitor_h*0.6",
    move  = "monitor_w*0.15 monitor_h*0.15",
    match = { title = "^(Enregistrer)$" },
})

hl.window_rule({
    name  = "windowrule-file-upload-en",
    float = true,
    size  = "monitor_w*0.7 monitor_h*0.6",
    move  = "monitor_w*0.15 monitor_h*0.15",
    match = { title = "^(File Upload)$" },
})

hl.window_rule({
    name  = "windowrule-file-upload-fr",
    float = true,
    size  = "monitor_w*0.7 monitor_h*0.6",
    move  = "monitor_w*0.15 monitor_h*0.15",
    match = { title = "^(Envoi du fichier)$" },
})

-- Correctif drag XWayland
hl.window_rule({
    name     = "windowrule-empty-class-title",
    no_focus = true,
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
})

hl.window_rule({
    name  = "windowrule-floating-class",
    float = true,
    size  = "monitor_w*0.7 monitor_h*0.6",
    move  = "monitor_w*0.15 monitor_h*0.15",
    match = { class = "^(floating)$" },
})

-- nwg-displays
hl.window_rule({
    name   = "windowrule-nwg-displays",
    float  = true,
    center = true,
    size   = "monitor_w*0.8 monitor_h*0.8",
    match  = { class = "^(nwg-displays)$" },
})

-- Gazelle
hl.window_rule({
    name   = "windowrule-gazelle",
    float  = true,
    center = true,
    size   = "monitor_w*0.8 monitor_h*0.8",
    match  = { class = "^(Gazelle)$" },
})

-- HyprTile
hl.window_rule({
    name        = "windowrule-hyprtile",
    float       = true,
    move        = "0 0",
    border_size = 0,
    no_anim     = true,
    match       = { class = "HyprTile" },
})

-- Spotify -> special workspace
hl.window_rule({
    name      = "windowrule-spotify",
    workspace = "special",
    match     = { class = "^([Ss]potify)$" },
})

-- Layer rules (outils de capture)
hl.layer_rule({
    name    = "layerrule-hyprpicker",
    no_anim = true,
    match   = { namespace = "hyprpicker" },
})

hl.layer_rule({
    name    = "layerrule-selection",
    no_anim = true,
    match   = { namespace = "selection" },
})
