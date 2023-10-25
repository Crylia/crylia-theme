local gcolor = require('gears.color')

local rubato = require('src.lib.rubato')

local capi = {
  mouse = mouse,
}

local function hex_to_rgba(hex)
  return tonumber(hex:sub(2, 3), 16) / 255,
      tonumber(hex:sub(4, 5), 16) / 255,
      tonumber(hex:sub(6, 7), 16) / 255,
      ((tonumber(hex:sub(8, 9), 16) or 255) / 255)
end

local function rgba_to_hex(r, g, b, a)
  return string.format('%02x%02x%02x%02x', r * 255, g * 255, b * 255, a * 255)
end

local function overlay_color(col, overlay, opacity)
  if tonumber(col:sub(1, 2), 16) < 128 and tonumber(col:sub(3, 4), 16) < 128 and tonumber(col:sub(5, 6), 16) < 128 then
    overlay = 'ffffff'
  else
    overlay = '000000'
  end
  return math.floor((tonumber(overlay:sub(1, 2), 16) * opacity / 100) + tonumber(col:sub(1, 2), 16) * (1 - opacity / 100)),
      math.floor((tonumber(overlay:sub(3, 4), 16) * opacity / 100) + tonumber(col:sub(3, 4), 16) * (1 - opacity / 100)),
      math.floor((tonumber(overlay:sub(5, 6), 16) * opacity / 100) + tonumber(col:sub(5, 6), 16) * (1 - opacity / 100)),
      math.floor((tonumber(overlay:sub(7, 8), 16) or 255 * opacity / 100) + tonumber(col:sub(7, 8), 16) * (1 - opacity / 100))
end

local function bg_hover(args)
--[[   args = args or {}
  local old_cursor, old_wibox

  local _, r, g, b, a = args.widget.bg:get_rgba()

  local animation = {
    r = rubato.timed {
      duration = 0.3 or args.duration,
      easing = rubato.easing.linear,
      pos = r * 255,
      rate = 24,
      clamp_position = true,
    },
    g = rubato.timed {
      duration = 0.3 or args.duration,
      easing = rubato.easing.linear,
      pos = g * 255,
      rate = 24,
      clamp_position = true,
    },
    b = rubato.timed {
      duration = 0.3 or args.duration,
      easing = rubato.easing.linear,
      pos = b * 255,
      rate = 24,
      clamp_position = true,
    },
    a = rubato.timed {
      duration = 0.3 or args.duration,
      easing = rubato.easing.linear,
      pos = a * 255,
      rate = 24,
      clamp_position = true,
    },
  }

  local function set_bg()
    args.widget._private.background = gcolor(string.format('#%02x%02x%02x%02x', math.floor(animation.r.pos + 0.5), math.floor(animation.g.pos + 0.5), math.floor(animation.b.pos + 0.5), math.floor(animation.a.pos + 0.5)))
    args.widget:emit_signal('widget::redraw_needed')
  end

  animation.r:subscribe(set_bg)
  animation.g:subscribe(set_bg)
  animation.b:subscribe(set_bg)
  animation.a:subscribe(set_bg)

  args.widget:connect_signal('mouse::enter', function()
    if animation.r.running or animation.g.running or animation.b.running or animation.a.running then
      args.widget._private.background = gcolor(string.format('#%02x%02x%02x%02x', math.floor(animation.r.target + 0.5), math.floor(animation.g.target + 0.5), math.floor(animation.b.target + 0.5),
        math.floor(animation.a.target + 0.5)))
      args.widget:emit_signal('widget::redraw_needed')
    end
    _, r, g, b, a = args.widget.bg:get_rgba()
    animation.r.pos = r * 255
    animation.g.pos = g * 255
    animation.b.pos = b * 255
    animation.a.pos = a * 255

    local w = capi.mouse.current_wibox

    if w then
      old_cursor, old_wibox = w.cursor, w
      w.cursor = 'hand1' or args.cursor
    end

    animation.r.target, animation.g.target, animation.b.target, animation.a.target = overlay_color(rgba_to_hex(r, g, b, a), args.overlay_color or 'ffffff', args.overlay or 4)
  end)

  args.widget:connect_signal('mouse::leave', function()
    if old_wibox then
      old_wibox.cursor = old_cursor
      old_wibox = nil
    end

    animation.r.target, animation.g.target, animation.b.target, animation.a.target = r * 255, g * 255, b * 255, a * 255
  end)

  args.widget:connect_signal('button::press', function()
    animation.r.target, animation.g.target, animation.b.target, animation.a.target = overlay_color(rgba_to_hex(r, g, b, a), args.overlay_color or 'ffffff', args.press_overlay or 12)
  end)

  args.widget:connect_signal('button::release', function()
    animation.r.target, animation.g.target, animation.b.target, animation.a.target = overlay_color(rgba_to_hex(r, g, b, a), args.overlay_color or 'ffffff', args.overlay or 4)
  end)

  args.widget:connect_signal('property::bg', function(_, newbg)
    r, g, b, a = hex_to_rgba(newbg)
  end) ]]
end

--[[ local function fg_hover(args)
  args = args or {}
  local old_cursor, old_wibox

  local _, r, g, b, a = args.widget.fg:get_rgba()

  local animation = {
    r = rubato.timed {
      duration = 0.2 or args.duration,
      easing = rubato.easing.linear,
      pos = r * 255,
      rate = 24,
      clamp_position = true,
    },
    g = rubato.timed {
      duration = 0.2 or args.duration,
      easing = rubato.easing.linear,
      pos = g * 255,
      rate = 24,
      clamp_position = true,
    },
    b = rubato.timed {
      duration = 0.2 or args.duration,
      easing = rubato.easing.linear,
      pos = b * 255,
      rate = 24,
      clamp_position = true,
    },
    a = rubato.timed {
      duration = 0.2 or args.duration,
      easing = rubato.easing.linear,
      pos = a * 255,
      rate = 24,
      clamp_position = true,
    },
  }

  local function set_fg()
    args.widget:set_fg(string.format('#%02x%02x%02x%02x', math.floor(animation.r.pos + 0.5), math.floor(animation.g.pos + 0.5), math.floor(animation.b.pos + 0.5), math.floor(animation.a.pos + 0.5)))
  end

  animation.r:subscribe(set_fg)
  animation.g:subscribe(set_fg)
  animation.b:subscribe(set_fg)
  animation.a:subscribe(set_fg)

  args.widget:connect_signal('mouse::enter', function()
    if animation.r.running or animation.g.running or animation.b.running or animation.a.running then
      args.widget:set_fg(string.format('#%02x%02x%02x%02x', math.floor(animation.r.target + 0.5), math.floor(animation.g.target + 0.5), math.floor(animation.b.target + 0.5), math.floor(animation.a.target + 0.5)))
    end
    _, r, g, b, a = args.widget.fg:get_rgba()
    animation.r.pos = r * 255
    animation.g.pos = g * 255
    animation.b.pos = b * 255
    animation.a.pos = a * 255

    local w = capi.mouse.current_wibox

    if w then
      old_cursor, old_wibox = w.cursor, w
      w.cursor = 'hand1' or args.cursor
    end

    animation.r.target, animation.g.target, animation.b.target, animation.a.target = overlay_color(rgba_to_hex(r, g, b, a), args.overlay_color or 'ffffff', args.overlay or 4)
  end)
  args.widget:connect_signal('mouse::leave', function()
    if old_wibox then
      old_wibox.cursor = old_cursor
      old_wibox = nil
    end

    animation.r.target = r * 255
    animation.g.target = g * 255
    animation.b.target = b * 255
    animation.a.target = a * 255
  end)
  args.widget:connect_signal('button::press', function()
    _, r, g, b, a = args.widget.fg:get_rgba()

    args.widget:set_fg(string.format('#%02x%02x%02x%02x', math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5), math.floor(a + 0.5)))

    animation.r.pos = r * 255
    animation.g.pos = g * 255
    animation.b.pos = b * 255
    animation.a.pos = a * 255

    animation.r.target, animation.g.target, animation.b.target, animation.a.target = overlay_color(rgba_to_hex(r, g, b, a), args.overlay_color or 'ffffff', args.overlay or 12)
  end)
  args.widget:connect_signal('button::release', function()
    animation.r.target = r * 255
    animation.g.target = g * 255
    animation.b.target = b * 255
    animation.a.target = a * 255
  end)
end ]]

--[[ local function border_hover(args)
  args = args or {}
  local old_cursor, old_wibox

  local r, g, b, a = hex_to_rgba(args.widget.border_color)

  local animation = {
    r = rubato.timed {
      duration = 0.2 or args.duration,
      easing = rubato.easing.linear,
      pos = r * 255,
      rate = 24,
      clamp_position = true,
    },
    g = rubato.timed {
      duration = 0.2 or args.duration,
      easing = rubato.easing.linear,
      pos = g * 255,
      rate = 24,
      clamp_position = true,
    },
    b = rubato.timed {
      duration = 0.2 or args.duration,
      easing = rubato.easing.linear,
      pos = b * 255,
      rate = 24,
      clamp_position = true,
    },
    a = rubato.timed {
      duration = 0.2 or args.duration,
      easing = rubato.easing.linear,
      pos = a * 255,
      rate = 24,
      clamp_position = true,
    },
  }

  local function set_border()
    args.widget.border_color = string.format('#%02x%02x%02x%02x', math.floor(animation.r.pos + 0.5), math.floor(animation.g.pos + 0.5), math.floor(animation.b.pos + 0.5), math.floor(animation.a.pos + 0.5))
  end

  animation.r:subscribe(set_border)
  animation.g:subscribe(set_border)
  animation.b:subscribe(set_border)
  animation.a:subscribe(set_border)

  args.widget:connect_signal('mouse::enter', function()
    if animation.r.running or animation.g.running or animation.b.running or animation.a.running then
      args.widget.border_color = string.format('#%02x%02x%02x%02x', math.floor(animation.r.target + 0.5), math.floor(animation.g.target + 0.5), math.floor(animation.b.target + 0.5), math.floor(animation.a.target + 0.5))
    end
    r, g, b, a = hex_to_rgba(args.widget.border_color)
    animation.r.pos = r * 255
    animation.g.pos = g * 255
    animation.b.pos = b * 255
    animation.a.pos = a * 255

    local w = capi.mouse.current_wibox

    if w then
      old_cursor, old_wibox = w.cursor, w
      w.cursor = 'hand1' or args.cursor
    end

    animation.r.target, animation.g.target, animation.b.target, animation.a.target = overlay_color(rgba_to_hex(r, g, b, a), args.overlay_color or 'ffffff', args.overlay or 4)
  end)
  args.widget:connect_signal('mouse::leave', function()
    if old_wibox then
      old_wibox.cursor = old_cursor
      old_wibox = nil
    end

    animation.r.target = r * 255
    animation.g.target = g * 255
    animation.b.target = b * 255
    animation.a.target = a * 255
  end)
  args.widget:connect_signal('button::press', function()
    r, g, b, a = hex_to_rgba(args.widget.border_color)

    args.widget.border_color = string.format('#%02x%02x%02x%02x', math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5), math.floor(a + 0.5))

    animation.r.pos = r * 255
    animation.g.pos = g * 255
    animation.b.pos = b * 255
    animation.a.pos = a * 255

    animation.r.target, animation.g.target, animation.b.target, animation.a.target = overlay_color(rgba_to_hex(r, g, b, a), args.overlay_color or 'ffffff', args.overlay or 12)
  end)
  args.widget:connect_signal('button::release', function()
    animation.r.target = r * 255
    animation.g.target = g * 255
    animation.b.target = b * 255
    animation.a.target = a * 255
  end)
end ]]

return {
  bg_hover = bg_hover,
  --fg_hover = fg_hover,
  --border_hover = border_hover,
}
