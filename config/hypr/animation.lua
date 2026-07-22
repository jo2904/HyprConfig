-- Bezier curves
hl.curve("emphasizedDecel", { type = "bezier", points = { {0.05, 0.7},  {0.1,  1}    } })
hl.curve("emphasizedAccel", { type = "bezier", points = { {0.3,  0},    {0.8,  0.15} } })
hl.curve("menuDecel",       { type = "bezier", points = { {0.1,  1},    {0,    1}    } })
hl.curve("menuAccel",       { type = "bezier", points = { {0.52, 0.03}, {0.72, 0.08} } })

-- Animations
hl.config({ animations = { enabled = true } })

hl.animation({ leaf = "windowsIn",           enabled = true, speed = 3,   bezier = "emphasizedDecel", style = "popin 80%"  })
hl.animation({ leaf = "windowsOut",          enabled = true, speed = 2,   bezier = "emphasizedDecel", style = "popin 90%"  })
hl.animation({ leaf = "windowsMove",         enabled = true, speed = 3,   bezier = "emphasizedDecel", style = "slide"      })
hl.animation({ leaf = "border",              enabled = true, speed = 10,  bezier = "emphasizedDecel"                       })
hl.animation({ leaf = "layersIn",            enabled = true, speed = 2.7, bezier = "emphasizedDecel", style = "popin 93%"  })
hl.animation({ leaf = "layersOut",           enabled = true, speed = 2.4, bezier = "menuAccel",       style = "popin 94%"  })
hl.animation({ leaf = "fadeLayersIn",        enabled = true, speed = 0.5, bezier = "menuDecel"                             })
hl.animation({ leaf = "fadeLayersOut",       enabled = true, speed = 2.7, bezier = "menuAccel"                             })
hl.animation({ leaf = "workspaces",          enabled = true, speed = 4,   bezier = "menuDecel",       style = "slide"      })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 2.8, bezier = "emphasizedDecel", style = "slidevert"  })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 1.2, bezier = "emphasizedAccel", style = "slidevert"  })

-- General, layout, decoration
hl.config({
    general = {
        gaps_in           = 0,
        gaps_out          = 1,
        gaps_workspaces   = 30,
        border_size       = 1,
        col = {
            active_border   = "rgb(D8DEE9)",
            inactive_border = "rgba(31313600)",
        },
        resize_on_border  = true,
        no_focus_fallback = true,
        allow_tearing     = true,
        snap = {
            enabled      = true,
            window_gap   = 2,
            monitor_gap  = 3,
            respect_gaps = true,
        },
    },
    dwindle = {
        preserve_split = true,
        smart_split    = false,
        smart_resizing = false,
    },
    decoration = {
        rounding = 18,
        blur = {
            enabled                   = true,
            xray                      = true,
            special                   = false,
            new_optimizations         = true,
            size                      = 14,
            passes                    = 3,
            brightness                = 1,
            noise                     = 0.04,
            contrast                  = 1,
            popups                    = true,
            popups_ignorealpha        = 0.6,
            input_methods             = true,
            input_methods_ignorealpha = 0.8,
        },
        shadow = {
            enabled      = true,
            range        = 10,
            offset       = "0 2",
            render_power = 4,
            color        = "rgba(00000010)",
        },
        dim_inactive = true,
        dim_strength = 0.025,
        dim_special  = 0.07,
    },
})
