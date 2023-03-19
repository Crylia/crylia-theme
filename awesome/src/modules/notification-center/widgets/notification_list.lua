-------------------------------------
-- This is the notification-center --
-------------------------------------

-- Awesome Libs
local dpi = require('beautiful').xresources.apply_dpi
local wibox = require('wibox')
local naughty = require('naughty')
local gtimer = require('gears.timer')

local hover = require('src.tools.hover')

return setmetatable({}, {
  __call = function()
    local ret = wibox.widget {
      layout = require('src.lib.overflow_widget.overflow').vertical,
      scrollbar_width = 0,
      step = dpi(100),
      spacing = dpi(20),
    }

    --!No, :get_children_by_id() does not work here for some reason, yes I hate it too
    --[[ naughty.connect_signal('notification_surface', function(b)
      local start_time = os.time()
      local w = wibox.template.make_from_value(b)
      w = w:get_widget()
      assert(type(w) == 'table', 'w is not a wibox.widget.base')

      -- Change the clock to a timer how long ago the notification was created
      w.children[1].children[1].children[1].children[1].children[1].children[2].children[1].children[1] = wibox.widget {
        text = 'now',
        font = 'JetBrainsMono Nerd Font, Bold 12',
        halign = 'center',
        valign = 'center',
        widget = wibox.widget.textbox,
      }

      hover.bg_hover { widget = w.children[1].children[1].children[1].children[1].children[1].children[2].children[1].children[2].children[1].children[1] }
      w.children[1].children[1].children[1].children[1].children[1].children[2].children[1].children[2]:connect_signal('button::press', function()
        ret:remove_widgets(w)
        ret:emit_signal('new_children')
      end)

      gtimer {
        timeout = 1,
        autostart = true,
        call_now = true,
        callback = function()
          local time_ago = math.floor(os.time() - start_time)
          local timer_text = w.children[1].children[1].children[1].children[1].children[1].children[2].children[1].children[1]
          if time_ago < 5 then
            timer_text:set_text('now')
          elseif time_ago < 60 then
            timer_text:set_text(time_ago .. 's ago')
          elseif time_ago < 3600 then
            timer_text:set_text(math.floor(time_ago / 60) .. 'm ago')
          elseif time_ago < 86400 then
            timer_text:set_text(math.floor(time_ago / 3600) .. 'h ago')
          else
            timer_text:set_text(math.floor(time_ago / 86400) .. 'd ago')
          end
        end,
      }

      ret:add(w)
      ret:emit_signal('new_children')
    end) ]]

    return ret
  end,
})
