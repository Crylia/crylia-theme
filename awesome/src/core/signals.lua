---@diagnostic disable: undefined-field
-- Awesome Libs
local awful = require("awful")
local gears = require("gears")

local color = require("src.lib.color")
local rubato = require("src.lib.rubato")

local capi = {
  awesome = awesome,
  mouse = mouse,
  screen = screen,
  client = client,
  tag = tag
}

capi.screen.connect_signal("added", function()
  capi.awesome.restart()
end)

capi.screen.connect_signal("removed", function()
  capi.awesome.restart()
end)

capi.client.connect_signal("manage", function(c)
  if capi.awesome.startup and not c.size_hints.user_porition and not c.size_hints.program_position then
    awful.placement.no_offscreen(c)
  end
  if c.class == "Brave-browser" then
    c.floating = false
  end
  if c.transient_for then
    c.floating = true
  end
  if c.fullscreen then
    gears.timer.delayed_call(function()
      if c.valid then
        c:geometry(c.screen.geometry)
      end
    end)
  end
end)

capi.client.connect_signal('unmanage', function(c)
  if #awful.screen.focused().clients > 0 then
    awful.screen.focused().clients[1]:emit_signal(
      'request::activate',
      'mouse_enter', {
      raise = true
    })
  end
end)

capi.tag.connect_signal('property::selected', function(c)
  if #awful.screen.focused().clients > 0 then
    awful.screen.focused().clients[1]:emit_signal(
      'request::activate',
      'mouse_enter', {
      raise = true
    })
  end
end)

-- Sloppy focus
--[[ client.connect_signal("mouse::enter", function(c)
  c:emit_signal(
    "request::activate",
    "mouse_enter",{
      raise = true
    })
end) ]]

--- Takes a wibox.container.background and connects four signals to it
---@param widget wibox.container.background a background widget
---@param bg_override string | nil overrides the default bg hover color
---@param fg_override string | nil overrides the default fg hover color
---@param border_override string | nil overrides the default border hover color
---@param icon_override string | nil the old icon color
---@param icon_override_hover string | nil the hover effect color
function Hover_signal(widget, bg_override, fg_override, border_override, icon_override, icon_override_hover)
  local old_wibox, old_cursor, old_bg, old_fg, old_border
  widget.bg = widget.bg or "#000000"
  widget.fg = widget.fg or "#000000"
  widget.border_color = widget.border_color or "#000000"
  local icon = nil
  if icon_override and icon_override_hover then
    icon = widget:get_children_by_id("icon")[1].icon
    widget.icon = widget:get_children_by_id("icon")[1]
  end

  local _, rb, gb, bb = widget.bg:get_rgba()
  local _, rf, gf, bf = widget.fg:get_rgba()
  local rbo, gbo, bbo = color.utils.hex_to_rgba(widget.border_color)

  local r_timed_bg = rubato.timed { duration = 0.3, pos = math.floor(rb * 255), rate = 24 }
  local g_timed_bg = rubato.timed { duration = 0.3, pos = math.floor(gb * 255), rate = 24 }
  local b_timed_bg = rubato.timed { duration = 0.3, pos = math.floor(bb * 255), rate = 24 }

  local r_timed_fg = rubato.timed { duration = 0.3, pos = math.floor(rf * 255), rate = 24 }
  local g_timed_fg = rubato.timed { duration = 0.3, pos = math.floor(gf * 255), rate = 24 }
  local b_timed_fg = rubato.timed { duration = 0.3, pos = math.floor(bf * 255), rate = 24 }

  local r_timed_border = rubato.timed { duration = 0.3, pos = math.floor(rbo), rate = 24 }
  local g_timed_border = rubato.timed { duration = 0.3, pos = math.floor(gbo), rate = 24 }
  local b_timed_border = rubato.timed { duration = 0.3, pos = math.floor(bbo), rate = 24 }

  local function update_bg()
    widget:set_bg("#" ..
      color.utils.rgba_to_hex { math.min(r_timed_bg.pos, 255), math.min(g_timed_bg.pos, 255),
        math.min(b_timed_bg.pos, 255) })
  end

  local function update_fg()
    widget:set_fg("#" .. color.utils.rgba_to_hex { math.min(r_timed_fg.pos, 255), math.min(g_timed_fg.pos, 255),
      math.min(b_timed_fg.pos, 255) })
  end

  local function update_border()
    widget:set_border_color("#" ..
      color.utils.rgba_to_hex { math.min(r_timed_border.pos, 255), math.min(g_timed_border.pos, 255),
        math.min(b_timed_border.pos, 255) })
  end

  r_timed_bg:subscribe(update_bg)
  g_timed_bg:subscribe(update_bg)
  b_timed_bg:subscribe(update_bg)

  r_timed_fg:subscribe(update_fg)
  g_timed_fg:subscribe(update_fg)
  b_timed_fg:subscribe(update_fg)

  r_timed_border:subscribe(update_border)
  g_timed_border:subscribe(update_border)
  b_timed_border:subscribe(update_border)

  local function set_bg(newbg)
    r_timed_bg.target, g_timed_bg.target, b_timed_bg.target = newbg[1], newbg[2], newbg[3]
  end

  local function set_fg(newfg)
    r_timed_fg.target, g_timed_fg.target, b_timed_fg.target = newfg[1], newfg[2], newfg[3]
  end

  local function set_border(newborder)
    r_timed_border.target, g_timed_border.target, b_timed_border.target = newborder[1], newborder[2], newborder[3]
  end

  local _, rbg, gbg, bbg, abg = widget.bg:get_rgba()
  old_bg = RGB_to_hex(rbg, gbg, bbg)
  local _, rfg, gfg, bfg, afg = widget.fg:get_rgba()
  old_fg = RGB_to_hex(rfg, gfg, bfg)
  old_border = widget.border_color
  local rborder, gborder, bborder = color.utils.hex_to_rgba(old_border)

  local function match_hex(hex1, hex2)
    local r1, g1, b1 = color.utils.hex_to_rgba(hex1)
    local r2, g2, b2 = color.utils.hex_to_rgba(hex2)
    return math.abs(r1 - r2) <= 100 and math.abs(g1 - g2) <= 100 and math.abs(b1 - b2) <= 100
  end

  --[[ 
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
      local r, g, b = color.utils.hex_to_rgba(old_bg)
      set_bg({ r, g, b })
    end
    if old_fg then
      local r, g, b = color.utils.hex_to_rgba(old_fg)
      set_fg({ r, g, b })
    end
    if old_border then
      local r, g, b = color.utils.hex_to_rgba(old_border)
      set_border({ r, g, b })
    end
    if old_wibox then
      old_wibox.cursor = old_cursor
      old_wibox = nil
    end
    if widget.icon and icon_override and icon_override_hover then
      widget.icon.image = gears.color.recolor_image(icon, icon_override)
    end
  end

  local mouse_enter = function()
    _, rbg, gbg, bbg, abg = widget.bg:get_rgba()
    if not match_hex(RGB_to_hex(rbg, gbg, bbg), old_bg) then
      old_bg = RGB_to_hex(rbg, gbg, bbg)
      set_bg({ rbg * 0.9 * 255, gbg * 0.9 * 255, bbg * 0.9 * 255 })
    end
    if old_bg then
      if bg_override then
        rbg, gbg, bbg = color.utils.hex_to_rgba(bg_override)
        set_bg({ rbg, gbg, bbg })
      else
        set_bg({ rbg * 0.9 * 255, gbg * 0.9 * 255, bbg * 0.9 * 255 })
      end
    end

    _, rfg, gfg, bfg, afg = widget.fg:get_rgba()
    if not match_hex(RGB_to_hex(rfg, gfg, bfg), old_fg) then
      old_fg = RGB_to_hex(rfg, gfg, bfg)
      set_fg({ rfg * 0.9 * 255, gfg * 0.9 * 255, bfg * 0.9 * 255 })
    end
    if fg_override or old_fg then
      if fg_override then
        rfg, gfg, bfg = color.utils.hex_to_rgba(fg_override)
        set_fg({ rfg, gfg, bfg })
      else
        set_fg({ rfg * 0.9 * 255, gfg * 0.9 * 255, bfg * 0.9 * 255 })
      end
    end

    if not match_hex(old_border, widget.border_color) then
      old_border = widget.border_color
      rborder, gborder, bborder = color.utils.hex_to_rgba(old_border)
    end
    if border_override or old_border then
      if border_override then
        rborder, gborder, bborder = color.utils.hex_to_rgba(border_override)
        set_border({ rborder, gborder, bborder })
      else
        set_border({ rborder * 0.9, gborder * 0.9, bborder * 0.9 })
      end
    end
    if icon and widget.icon and icon_override and icon_override_hover then
      widget.icon.image = gears.color.recolor_image(icon, icon_override_hover)
    end
    local w = capi.mouse.current_wibox
    if w then
      old_cursor, old_wibox = w.cursor, w
      w.cursor = "hand1"
    end
    --widget:connect_signal("mouse::leave", mouse_leave)
  end

  widget:connect_signal("mouse::enter", mouse_enter)
  --widget:connect_signal("button::press", button_press)
  --widget:connect_signal("button::release", button_release)
  widget:connect_signal("mouse::leave", mouse_leave)
end
