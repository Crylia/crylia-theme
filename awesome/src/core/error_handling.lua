----------------------------------------------------------------
-- This class is to output an error if you fuck up the config --
----------------------------------------------------------------
-- Awesome Libs
local naughty = require("naughty")

if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "! Not so Awesome ERROR !",
        text = awesome.startup_errors
    })
end

do
    local in_error = false
    awesome.connect_signal(
        "debug::error",
        function(err)
            if in_error then
                return
            end
            in_error = true

            naughty.notify({
                preset = naughty.config.presets.critical,
                title = "ERROR",
                text = tostring(err)
            })
            in_error = false
        end
    )
end
