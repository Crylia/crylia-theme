----------------------------------
-- This is the time_date widget --
----------------------------------

-- Awesome Libs
local dpi = require("beautiful").xresources.apply_dpi
local wibox = require("wibox")

return function()

  local time_date = wibox.widget {
    {
      {
        {
          { -- Time
            {
              id = "label",
              align = "center",
              valign = "center",
              format = "<span foreground='#18FFFF' font='JetBrainsMono Nerd Font, Bold 46'><b>%H:%M</b></span>",
              widget = wibox.widget.textclock
            },
            widget = wibox.container.margin
          },
          { -- Date and Day
            { -- Date
              {
                id = "label",
                align = "left",
                valign = "bottom",
                format = "<span foreground='#69F0AE' font='JetBrainsMono Nerd Font, Regular 18'><b>%e</b></span><span foreground='#18FFFF' font='JetBrainsMono Nerd Font, Regular 18'><b> %b %Y</b></span>",
                widget = wibox.widget.textclock
              },
              widget = wibox.container.margin
            },
            { -- Day
              {
                id = "label",
                align = "left",
                valign = "top",
                format = "<span foreground='#69F0AE' font='JetBrainsMono Nerd Font, Bold 20'><b>%A</b></span>",
                widget = wibox.widget.textclock
              },
              widget = wibox.container.margin
            },
            layout = wibox.layout.flex.vertical
          },
          spacing = dpi(20),
          layout = wibox.layout.fixed.horizontal
        },
        valign = "center",
        halign = "center",
        widget = wibox.container.place
      },
      id = "background",
      widget = wibox.container.background
    },
    id = "margin",
    margins = dpi(20),
    widget = wibox.container.margin
  }

  return time_date

end
