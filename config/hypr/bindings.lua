local vars   = require("var")
local mainMod = "SUPER"

-- Lancement d'applications
hl.bind(mainMod .. " + Q",         hl.dsp.exec_cmd(vars.terminal))
hl.bind(mainMod .. " + C",         hl.dsp.window.close())
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(vars.fileManager))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(vars.fileManagerAlternative))
hl.bind(mainMod .. " + R",         hl.dsp.exec_cmd(vars.menu))
hl.bind(mainMod .. " + F",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("hyprlock"))

-- Focus des fenêtres
hl.bind(mainMod .. " + left",          hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + right",         hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",            hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + down",          hl.dsp.focus({ direction = "down"  }))

-- Déplacement des fenêtres
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))

-- Espaces de travail (clavier AZERTY)
local workspaceKeys = {
    "ampersand", "eacute", "quotedbl", "apostrophe", "parenleft",
    "minus", "egrave", "underscore", "ccedilla", "agrave"
}
for i, key in ipairs(workspaceKeys) do
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Special workspace
hl.bind(mainMod .. " + twosuperior",         hl.dsp.workspace.toggle_special())
hl.bind(mainMod .. " + SHIFT + twosuperior", hl.dsp.window.move({ workspace = "special" }))

-- Molette souris pour changer de bureau
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e+1" }))

-- Script écrans
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("~/.config/scripts/changeMainScreen.sh"))

-- Souris : déplacer / redimensionner
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Son et luminosité
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),       { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),      { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                   { locked = true, repeating = true })

-- Contrôle multimédia
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),         { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),   { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),   { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),     { locked = true })
hl.bind("XF86PowerOff",   hl.dsp.exec_cmd("qs ipc call power toggle"), { locked = true })

-- Capture d'écran
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("~/.config/scripts/toggle-screenshot.sh region"))
hl.bind("PRINT",                   hl.dsp.exec_cmd("~/.config/scripts/toggle-screenshot.sh output"))

-- Toggles
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.exec_cmd("~/.config/scripts/toggle-hypridle.sh"),    { description = "Toggle locking on idle"  })
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("~/.config/scripts/toggle-nightlight.sh"),  { description = "Toggle nightlight"        })
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("~/.config/scripts/toggle-theme.sh"),       { description = "Toggle theme"             })
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("~/.config/scripts/toggle-dnd.sh"),         { description = "Toggle do not disturb"   })
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("~/.config/scripts/toggle-powersave.sh"),   { description = "Toggle power save mode"  })
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("nwg-displays"),                            { description = "Info screen"              })

-- Navigation entre bureaux
hl.bind("ALT + Tab",   hl.dsp.focus({ workspace = "previous" }))
hl.bind("SUPER + TAB", hl.dsp.exec_cmd("qs -p ~/.config/quickshell/overview ipc call overview toggle"))
hl.bind("mouse:277",   hl.dsp.exec_cmd("qs -p ~/.config/quickshell/overview ipc call overview toggle"), { release = true })
