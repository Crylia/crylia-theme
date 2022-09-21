---------------------------------------
-- This is the brightness_osd module --
---------------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local capi = {
  awesome = awesome,
  mouse = mouse,
}

return function(args)
  if not args then
    return
  end

  local function get_entries()

    local menu_entries = { layout = wibox.layout.fixed.vertical, spacing = dpi(10) }

    if args.entries then
      for _, entry in ipairs(args.entries) do
        local menu_entry = wibox.widget {
          {
            {
              {
                { -- Icon
                  widget = wibox.widget.imagebox,
                  image = gears.color.recolor_image(entry.icon, Theme_config.context_menu.entry.icon_color),
                  valign = "center",
                  halign = "center",
                  resize = true,
                  icon = entry.icon,
                  id = "icon"
                },
                widget = wibox.container.constraint,
                stragety = "exact",
                width = dpi(24),
                height = dpi(24),
                id = "const"
              },
              { -- Text
                widget = wibox.widget.textbox,
                text = entry.name,
                id = "name"
              },
              id = "lay",
              spacing = dpi(5),
              layout = wibox.layout.fixed.horizontal
            },
            margins = dpi(10),
            widget = wibox.container.margin,
            id = "mar"
          },
          bg = Theme_config.context_menu.entry.bg,
          fg = Theme_config.context_menu.entry.fg,
          shape = Theme_config.context_menu.entry.shape,
          border_width = Theme_config.context_menu.entry.border_width,
          border_color = Theme_config.context_menu.entry.border_color,
          widget = wibox.container.background,
          id = "menu_entry"
        }

        menu_entry:buttons(gears.table.join(
          awful.button({
            modifiers = {},
            button = 1,
            on_release = function()
              capi.awesome.emit_signal("context_menu::hide")
              entry.callback()
            end
          })
        ))

        Hover_signal(menu_entry, nil, Theme_config.context_menu.entry.hover_fg,
          Theme_config.context_menu.entry.hover_border, Theme_config.context_menu.entry.icon_color,
          Theme_config.context_menu.entry.icon_color_hover)
        table.insert(menu_entries, menu_entry)
      end
    end
    return menu_entries
  end

  local menu = awful.popup {
    widget = {
      get_entries(),
      margins = dpi(10),
      widget = wibox.container.margin
    },
    bg = Theme_config.context_menu.bg,
    fg = Theme_config.context_menu.fg,
    border_width = Theme_config.context_menu.border_width,
    border_color = Theme_config.context_menu.border_color,
    shape = Theme_config.context_menu.shape,
    x = capi.mouse.coords().x,
    y = capi.mouse.coords().y,
    visible = false,
    ontop = true,
    placement = awful.placement.no_offscreen,
  }

  menu:connect_signal("mouse::leave", function()
    capi.awesome.emit_signal("context_menu::hide")
  end)

  capi.awesome.connect_signal(
    "context_menu::hide",
    function()
      menu.visible = false
    end
  )
  return menu
end
