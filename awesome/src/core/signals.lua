---@diagnostic disable: undefined-field
-- Awesome Libs
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

screen.connect_signal(
  "added",
  function()
    awesome.restart()
  end
)

screen.connect_signal(
  "removed",
  function()
    awesome.restart()
  end
)

client.connect_signal(
  "manage",
  function(c)
    if awesome.startup and not c.size_hints.user_porition and not c.size_hints.program_position then
      awful.placement.no_offscreen(c)
    end
    c.shape = function(cr, width, height)
      if c.fullscreen or c.maximized then
        gears.shape.rectangle(cr, width, height)
      else
        gears.shape.rounded_rect(cr, width, height, 10)
      end
    end
    if c.class == "Brave-browser" then
      c.floating = false
    end
  end
)

client.connect_signal(
  'unmanage',
  function(c)
    if #awful.screen.focused().clients > 0 then
      awful.screen.focused().clients[1]:emit_signal(
        'request::activate',
        'mouse_enter',
        {
          raise = true
        }
      )
    end
  end
)

tag.connect_signal(
  'property::selected',
  function(c)
    if #awful.screen.focused().clients > 0 then
      awful.screen.focused().clients[1]:emit_signal(
        'request::activate',
        'mouse_enter',
        {
          raise = true
        }
      )
    end
  end
)

-- Sloppy focus
client.connect_signal(
  "mouse::enter",
  function(c)
    c:emit_signal(
      "request::activate",
      "mouse_enter",
      {
        raise = false
      }
    )
  end
)

--- Takes a wibox.container.background and connects four signals to it
---@param widget wibox.container.background
function Hover_signal(widget, bg_override)
  local old_wibox, old_cursor, old_bg, old_fg, old_border

  local r, g, b

  widget.bg = widget.bg or ""
  widget.fg = widget.fg or ""
  widget.border_color = widget.border_color or ""

  local mouse_enter = function()
    _, r, g, b, _ = widget.bg:get_rgba()
    old_bg = RGB_to_hex(r, g, b)
    if bg_override or old_bg then
      widget.bg = bg_override or old_bg .. "dd"
    end
    _, r, g, b, _ = widget.fg:get_rgba()
    old_fg = RGB_to_hex(r, g, b)
    if old_fg then
      widget.fg = old_fg .. "dd"
    end
    old_border = widget.border_color
    if old_border then
      widget.border_color = old_border .. "dd"
    end
    local w = mouse.current_wibox
    if w then
      old_cursor, old_wibox = w.cursor, w
      w.cursor = "hand1"
    end
  end

  local button_press = function()
    if old_bg or bg_override then
      widget.bg = bg_override or old_bg .. "bb"
    end
    if old_fg then
      widget.fg = old_fg .. "bb"
    end
  end

  local button_release = function()
    if old_bg or bg_override then
      widget.bg = bg_override or old_bg .. "dd"
    end
    if old_fg then
      widget.fg = old_fg .. "dd"
    end
  end

  local mouse_leave = function()
    if old_bg then
      widget.bg = old_bg
    end
    if old_fg then
      widget.fg = old_fg
    end
    if old_border then
      widget.border_color = old_border
    end
    if old_wibox then
      old_wibox.cursor = old_cursor
      old_wibox = nil
    end
  end

  widget:connect_signal("mouse::enter", mouse_enter)
  widget:connect_signal("button::press", button_press)
  widget:connect_signal("button::release", button_release)
  widget:connect_signal("mouse::leave", mouse_leave)
end
