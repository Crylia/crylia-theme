---------------------------------
-- This is the window_switcher --
---------------------------------

-- Awesome Libs
local aplacement = require('awful.placement')
local apopup = require('awful.popup')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gcolor = require('gears.color')
local gshape = require('gears.shape')
local gsurface = require('gears.surface')
local gtable = require('gears.table')
local wibox = require('wibox')
local gobject = require('gears.object')
local base = require('wibox.widget.base')
local gtimer = require('gears.timer')
local cairo = require('lgi').cairo
local awidget = require('awful.widget')

local capi = {
  awesome = awesome,
  client = client,
  mouse = mouse,
}

--local window_elements = require("src.modules.window_switcher.window_elements")()

--[[ return function(s)

  local window_switcher_list = wibox.widget {
    window_elements,
    margins = dpi(20),
    widget = wibox.container.margin
  }

  local window_switcher_container = awful.popup {
    widget = wibox.container.background,
    ontop = true,
    visible = false,
    stretch = false,
    screen = s,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(12))
    end,
    placement = awful.placement.centered,
    bg = beautiful.colorscheme.bg,
    border_color = beautiful.colorscheme.border_color,
    border_width = dpi(2)
  }

  window_switcher_container:setup {
    window_switcher_list,
    layout = wibox.layout.fixed.vertical
  }

  capi.awesome.connect_signal(
    "toggle_window_switcher",
    function()
      if capi.mouse.screen == s then
        window_switcher_container.visible = not window_switcher_container.visible
      end
    end
  )
end ]]

local client_preview = {}


function client_preview:toggle()
  self.visible = not self.visible
end

return setmetatable(client_preview, {
  __call = function(...)
    local args = ...

    local w = gobject {}

    gtable.crush(w, client_preview, true)

    --[[ local tl = awidget.tasklist {
      screen = 1,
      layout = wibox.layout.fixed.horizontal,
      filter = awidget.tasklist.filter.alltags,
      update_function = function(widget, _, _, _, clients)
        widget:reset()

        for _, c in ipairs(clients) do
          local tw = wibox.widget {
            {
              {
                {
                  {
                    widget = wibox.widget.imagebox,
                    resize = true,
                    id = c.instance,
                  },
                  widget = wibox.container.constraint,
                  height = dpi(256),
                  strategy = 'exact',
                },
                widget = wibox.container.place,
              },
              widget = wibox.container.margin,
              margins = dpi(20),
            },
            widget = wibox.container.background,
            bg = '#414141',
            id = c.pid,
            shape = gshape.rounded_rect,
          }

          gtimer {
            timeout = 1 / 24,
            autostart = true,
            callback = function()
              local content = gsurface(c.content)
              local cr = cairo.Context(content)
              local x, y, w, h = cr:clip_extents()
              local img = cairo.ImageSurface.create(cairo.Format.ARGB32, w - x, h - y)
              cr = cairo.Context(img)
              cr:set_source_surface(content, 0, 0)
              cr.operator = cairo.Operator.SOURCE
              cr:paint()
              local cont = tw:get_children_by_id('icon_role')[1]
              if cont then
                cont.image = gsurface.load(img)
                return
              end
            end,
          }

          widget:add(tw)
        end

        return widget
      end,
    } ]]

    w.popup = apopup {
      widget = {},
      ontop = true,
      visible = true,
      screen = args.screen,
      placement = aplacement.centered,
      bg = beautiful.colorscheme.bg,
      border_color = beautiful.colorscheme.border_color,
      border_width = dpi(2),
    }


    return w
  end,
})
