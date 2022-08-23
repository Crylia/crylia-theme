---@diagnostic disable: undefined-field
-- Awesome Libs
local awful = require("awful")
local gears = require("gears")

local color = require("src.lib.color")
local rubato = require("src.lib.rubato")

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
    if c.transient_for then
      c.floating = true
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
--[[ client.connect_signal(
  "mouse::enter",
  function(c)
    c:emit_signal(
      "request::activate",
      "mouse_enter",
      {
        raise = true
      }
    )
  end
) ]]

--- Takes a wibox.container.background and connects four signals to it
---@param widget wibox.container.background a background widget
---@param bg_override string | nil overrides the default bg hover color
---@param fg_override string | nil overrides the default fg hover color
---@param border_override string | nil overrides the default border hover color
---@param icon_override string | nil the old icon color
---@param icon_override_hover string | nil the hover effect color
function Hover_signal(widget, bg_override, fg_override, border_override, icon_override, icon_override_hover)
  local old_wibox, old_cursor, old_bg, old_fg, old_border

  local r, g, b

  widget.bg = widget.bg or "#000000"
  widget.fg = widget.fg or "#000000"
  widget.border_color = widget.border_color or "#000000"
  local icon = nil
  if icon_override and icon_override_hover then
    icon = widget:get_children_by_id("icon")[1].icon
    widget.icon = widget:get_children_by_id("icon")[1]
  end

  --[[ local r_timed_bg = rubato.timed { duration = 0.5 }
  local g_timed_bg = rubato.timed { duration = 0.5 }
  local b_timed_bg = rubato.timed { duration = 0.5 }

  local function update_bg()
    widget:set_bg("#" .. color.utils.rgba_to_hex { r_timed_bg.pos, g_timed_bg.pos, b_timed_bg.pos })
  end

  r_timed_bg:subscribe(update_bg)
  g_timed_bg:subscribe(update_bg)
  b_timed_bg:subscribe(update_bg)

  local function set_bg(newbg)
    r_timed_bg.target, g_timed_bg.target, b_timed_bg.target = color.utils.hex_to_rgba(newbg)
  end ]]

  local mouse_enter = function()
    _, r, g, b, _ = widget.bg:get_rgba()
    old_bg = RGB_to_hex(r, g, b)
    if bg_override or old_bg then
      widget:set_bg(bg_override or old_bg .. "dd")
    end
    _, r, g, b, _ = widget.fg:get_rgba()
    old_fg = RGB_to_hex(r, g, b)
    if fg_override or old_fg then
      widget:set_fg(fg_override or old_fg .. "dd")
    end
    old_border = widget.border_color
    if border_override or old_border then
      widget.border_color = border_override or old_border .. "dd"
    end
    if icon and widget.icon and icon_override and icon_override_hover then
      widget.icon.image = gears.color.recolor_image(icon, icon_override_hover)
    end
    local w = mouse.current_wibox
    if w then
      old_cursor, old_wibox = w.cursor, w
      w.cursor = "hand1"
    end
  end

  --[[ local button_press = function()
    if old_bg or bg_override then
      if bg_override then
        bg_override = bg_override .. "bb"
      end
      widget.bg = bg_override or old_bg .. "bb"
    end
    if fg_override or old_fg then
      if fg_override then
        fg_override = fg_override .. "bb"
      end
      widget.fg = fg_override or old_fg .. "bb"
    end
  end

  local button_release = function()
    if old_bg or bg_override then
      if bg_override then
        bg_override = bg_override .. "dd"
      end
      widget.bg = bg_override or old_bg .. "dd"
    end
    if fg_override or old_fg then
      if fg_override then
        fg_override = fg_override .. "dd"
      end
      widget.fg = fg_override or old_fg .. "dd"
    end
  end ]]

  local mouse_leave = function()
    if old_bg then
      widget:set_bg(old_bg)
    end
    if old_fg then
      widget:set_fg(old_fg)
    end
    if old_border then
      widget.border_color = old_border
    end
    if old_wibox then
      old_wibox.cursor = old_cursor
      old_wibox = nil
    end
    if widget.icon and icon_override and icon_override_hover then
      widget.icon.image = gears.color.recolor_image(icon, icon_override)
    end
  end

  widget:connect_signal("mouse::enter", mouse_enter)
  --widget:connect_signal("button::press", button_press)
  --widget:connect_signal("button::release", button_release)
  widget:connect_signal("mouse::leave", mouse_leave)
end
