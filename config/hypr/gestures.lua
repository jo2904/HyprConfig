hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

hl.gesture({
    fingers   = 3,
    direction = "up",
    action    = "fullscreen",
})

hl.gesture({
    fingers   = 3,
    direction = "down",
    action    = function() hl.dispatch(hl.dsp.workspace.toggle_special()) end,
})
