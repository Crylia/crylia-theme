local ipairs = ipairs
local setmetatable = setmetatable

-- Awesome Libs
local abutton = require('awful.button')
local ascreen = require('awful.screen')
local atag = require('awful.tag')
local awidget = require('awful.widget')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gtable = require('gears.table')
local wibox = require('wibox')

-- Local Libs
local hover = require('src.tools.hover')

local capi = { client = client }

local modkey = beautiful.user_config.modkey

local tag_text = {
  [1] = '一',
  [2] = '二',
  [3] = '三',
  [4] = '四',
  [5] = '五',
  [6] = '六',
  [7] = '七',
  [8] = '八',
  [9] = '九',
  [10] = '十',
}

return setmetatable({}, { __call = function(_, screen)
  return awidget.taglist {
    filter = awidget.taglist.filter.noempty,
    layout = wibox.layout.fixed.horizontal,
    screen = screen,
    update_function = function(widget, _, _, _, tags)
      widget:reset()
      -- Create a tag widget for each tag
      for _, tag in ipairs(tags) do
        local tag_widget = wibox.widget {
          {
            {
              {
                text = tag_text[tag.index],
                halign = 'center',
                valign = 'center',
                id = 'text_role',
                widget = wibox.widget.textbox,
              },
              id = 'tag_layout',
              spacing = dpi(10),
              layout = wibox.layout.fixed.horizontal,
            },
            left = dpi(10),
            right = dpi(10),
            widget = wibox.container.margin,
          },
          fg = beautiful.colorscheme.fg,
          bg = beautiful.colorscheme.bg1,
          shape = beautiful.shape[6],
          widget = wibox.container.background,
        }

        -- Add the buttons for each tag
        tag_widget:buttons { gtable.join(
          abutton({}, 1, function()
            tag:view_only()
          end),

          abutton({ modkey }, 1, function()
            if capi.client.focus then
              capi.client.focus:move_to_tag(tag)
            end
          end),

          abutton({}, 3, function()
            if capi.client.focus then
              capi.client.focus:toggle_tag(tag)
            end
          end),

          abutton({ modkey }, 3, function()
            if capi.client.focus then
              capi.client.focus:toggle_tag(tag)
            end
          end),

          abutton({}, 4, function()
            atag.viewnext(tag.screen)
          end),

          abutton({}, 5, function()
            atag.viewprev(tag.screen)
          end)
        ), }

        -- Change the taglist colors depending on the state of the tag
        if tag == ascreen.focused().selected_tag then
          tag_widget:set_bg(beautiful.colorscheme.fg)
          tag_widget:set_fg(beautiful.colorscheme.bg)
        elseif tag.urgent == true then
          tag_widget:set_bg(beautiful.colorscheme.bg_red)
          tag_widget:set_fg(beautiful.colorscheme.bg)
        else
          tag_widget:set_bg(beautiful.colorscheme.bg1)
          tag_widget:set_fg(beautiful.colorscheme.fg)
        end

        -- Add the client icons to the tag widget
        for _, client in ipairs(tag:clients()) do
          tag_widget:get_children_by_id('tag_layout')[1]:add(wibox.widget {
            {
              resize = true,
              valign = 'center',
              halign = 'center',
              image = client.icon or '',
              widget = wibox.widget.imagebox,
            },
            height = dpi(25),
            width = dpi(25),
            strategy = 'exact',
            widget = wibox.container.constraint,
          })
        end

        hover.bg_hover { widget = tag_widget }

        widget:add(tag_widget)
        widget:set_spacing(dpi(5))
      end
    end,
  }
end, })
