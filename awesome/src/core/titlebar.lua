local math = math

-- Awesome libs
local abutton = require('awful.button')
local atitlebar = require('awful.titlebar')
local atooltip = require('awful.tooltip')
local beautiful = require('beautiful')
local cairo = require('lgi').cairo
local dpi = require('beautiful').xresources.apply_dpi
local gcolor = require('gears.color')
local gdk = require('lgi').require('Gdk', '3.0')
local gfilesystem = require('gears.filesystem')
local gsurface = require('gears.surface')
local gtimer = require('gears.timer')
local wibox = require('wibox')

local json = require('src.lib.json-lua.json-lua')

gdk.init {}

local capi = {
  mouse = mouse,
  client = client,
}

local instance = nil

local titlebar = {}

local titlebar_position = beautiful.user_config.titlebar_position

-- Converts the given hex color to hsv
local function hex2hsv(color)
  local r, g, b = gcolor.parse_color(color)
  local C_max = math.max(r, g, b)
  local C_min = math.min(r, g, b)
  local delta = C_max - C_min
  local H, S, V
  if delta == 0 then
    H = 0
  elseif C_max == r then
    H = 60 * (((g - b) / delta) % 6)
  elseif C_max == g then
    H = 60 * (((b - r) / delta) + 2)
  elseif C_max == b then
    H = 60 * (((r - g) / delta) + 4)
  end
  if C_max == 0 then
    S = 0
  else
    S = delta / C_max
  end
  V = C_max
  return H, S * 100, V * 100
end

-- Converts the given hsv color to hex
local function hsv2hex(H, S, V)
  S = S / 100
  V = V / 100
  if H > 360 then H = 360 end
  if H < 0 then H = 0 end
  local C = V * S
  local X = C * (1 - math.abs(((H / 60) % 2) - 1))
  local m = V - C
  local r_, g_, b_ = 0, 0, 0
  if H >= 0 and H < 60 then
    r_, g_, b_ = C, X, 0
  elseif H >= 60 and H < 120 then
    r_, g_, b_ = X, C, 0
  elseif H >= 120 and H < 180 then
    r_, g_, b_ = 0, C, X
  elseif H >= 180 and H < 240 then
    r_, g_, b_ = 0, X, C
  elseif H >= 240 and H < 300 then
    r_, g_, b_ = X, 0, C
  elseif H >= 300 and H < 360 then
    r_, g_, b_ = C, 0, X
  end
  local r, g, b = (r_ + m) * 255, (g_ + m) * 255, (b_ + m) * 255
  return ('#%02x%02x%02x'):format(math.floor(r), math.floor(g), math.floor(b))
end

-- Calculates the relative luminance of the given color
local function relative_luminance(color)
  local r, g, b = gcolor.parse_color(color)
  local function from_sRGB(u) return u <= 0.0031308 and 25 * u / 323 or ((200 * u + 11) / 211) ^ (12 / 5) end

  return 0.2126 * from_sRGB(r) + 0.7152 * from_sRGB(g) + 0.0722 * from_sRGB(b)
end

-- Rotates the hue of the given hex color by the specified angle (in degrees)
local function rotate_hue(color, angle)
  local H, S, V = hex2hsv(color)
  angle = math.max(math.min(angle or 0, 360), 0)
  H = (H + angle) % 360
  return hsv2hex(H, S, V)
end

-- Lightens a given hex color by the specified amount
local function lighten(color, amount)
  local r, g, b
  r, g, b = gcolor.parse_color(color)
  r = 255 * r
  g = 255 * g
  b = 255 * b
  r = r + math.floor(2.55 * amount)
  g = g + math.floor(2.55 * amount)
  b = b + math.floor(2.55 * amount)
  r = r > 255 and 255 or r
  g = g > 255 and 255 or g
  b = b > 255 and 255 or b
  return ('#%02x%02x%02x'):format(r, g, b)
end

-- Darkens a given hex color by the specified amount
local function darken(color, amount)
  local r, g, b
  r, g, b = gcolor.parse_color(color)
  r = 255 * r
  g = 255 * g
  b = 255 * b
  r = math.max(0, r - math.floor(r * (amount / 100)))
  g = math.max(0, g - math.floor(g * (amount / 100)))
  b = math.max(0, b - math.floor(b * (amount / 100)))
  return ('#%02x%02x%02x'):format(r, g, b)
end

-- Returns a vertical gradient pattern going from cololr_1 -> color_2
local function duotone_gradient_vertical(color_1, color_2, height, offset_1, offset_2)
  local fill_pattern = cairo.Pattern.create_linear(0, 0, 0, height)
  local r, g, b, a
  r, g, b, a = gcolor.parse_color(color_1)
  fill_pattern:add_color_stop_rgba(offset_1 or 0, r, g, b, a)
  r, g, b, a = gcolor.parse_color(color_2)
  fill_pattern:add_color_stop_rgba(offset_2 or 1, r, g, b, a)
  return fill_pattern
end

-- Returns a horizontal gradient pattern going from cololr_1 -> color_2
local function duotone_gradient_horizontal(color_1, color_2, width, offset_1, offset_2)
  local fill_pattern = cairo.Pattern.create_linear(0, 0, width, 0)
  local r, g, b, a
  r, g, b, a = gcolor.parse_color(color_1)
  fill_pattern:add_color_stop_rgba(offset_1 or 0, r, g, b, a)
  r, g, b, a = gcolor.parse_color(color_2)
  fill_pattern:add_color_stop_rgba(offset_2 or 1, r, g, b, a)
  return fill_pattern
end

local function save(tbl, filename)
  local handler = io.open(filename, 'w')
  if not handler then return nil end
  handler:write(json:encode(tbl))
  handler:close()
end

local function load(file)
  local handler = io.open(file, 'r')
  if not handler then return nil end
  local data = json:decode(handler:read('*a'))
  assert(data, 'Failed to load file: ' .. file)
  handler:close()
  return data
end

local function set_color_rule(c, color)
  if (not c) or (not c.instance) then return end
  titlebar.color_rules[c.instance .. titlebar_position] = color
  save(titlebar.color_rules, titlebar.color_rules_filepath)
end

local function get_color_rule(c)
  if (not c) or (not c.instance) then return end
  return titlebar.color_rules[c.instance .. titlebar_position]
end

---Gets the dominant color of a client for the purpose of setting the titlebar color
---@param client any
---@return string hex color
local function get_dominant_color(client)
  local tally = {}
  local content = gsurface(client.content)
  local cgeo = client:geometry()
  local x_offset, y_offset = 2, 2
  local color

  if titlebar_position == 'top' then
    for x_pos = 0, math.floor(cgeo.width / 2), 2 do
      for y_pos = 0, 8, 1 do
        color = '#' .. gdk.pixbuf_get_from_surface(content, x_offset + x_pos, y_offset + y_pos, 1, 1
        ):get_pixels():gsub('.', function(c)
          return ('%02x'):format(c:byte())
        end)
        if not tally[color] then
          tally[color] = 1
        else
          tally[color] = tally[color] + 1
        end
      end
    end
  elseif titlebar_position == 'left' then
    x_offset = 0
    for y_pos = 0, math.floor(cgeo.height / 2), 2 do
      for x_pos = 0, 8, 1 do
        color = '#' .. gdk.pixbuf_get_from_surface(content, x_offset + x_pos, y_offset + y_pos, 1, 1
        ):get_pixels():gsub('.', function(c)
          return ('%02x'):format(c:byte())
        end)
        if not tally[color] then
          tally[color] = 1
        else
          tally[color] = tally[color] + 1
        end
      end
    end
  end

  local mode_c = 0
  for kolor, kount in pairs(tally) do
    if kount > mode_c then
      mode_c = kount
      color = kolor
    end
  end
  set_color_rule(client, color)
  return color
end

local function create_button_image(name, is_focused, event, is_on)
  titlebar.key = titlebar.key or {}

  titlebar.key.close_color = beautiful.colorscheme.bg_red
  titlebar.key.minimize_color = beautiful.colorscheme.bg_yellow
  titlebar.key.maximize_color = beautiful.colorscheme.bg_green
  titlebar.key.floating_color = beautiful.colorscheme.bg_purple
  titlebar.key.ontop_color = beautiful.colorscheme.bg_purple
  titlebar.key.sticky_color = beautiful.colorscheme.bg_purple

  local focus_state = is_focused and 'focused' or 'unfocused'
  local key_img
  if is_on ~= nil then
    local toggle_state = is_on and 'on' or 'off'
    key_img = ('%s_%s_%s_%s'):format(name, toggle_state, focus_state, event)
  else
    key_img = ('%s_%s_%s'):format(name, focus_state, event)
  end
  if titlebar.key[key_img] then return titlebar.key[key_img] end
  local key_color = key_img .. '_color'
  if not titlebar.key[key_color] then
    local key_base_color = name .. '_color'
    local base_color = titlebar.key[key_base_color] or rotate_hue(hsv2hex(math.random(0, 360), 70, 90), 33)
    titlebar.key[key_base_color] = base_color
    local button_color = base_color
    local H = hex2hsv(base_color)
    if not is_focused and event ~= 'hover' then
      button_color = hsv2hex(H, 0, 50)
    end
    button_color = (event == 'hover') and lighten(button_color, 25) or
        (event == 'press') and darken(button_color, 25) or button_color
    titlebar.key[key_color] = button_color
  end
  local button_size = dpi(18)
  local surface = cairo.ImageSurface.create('ARGB32', button_size, button_size)
  local cr = cairo.Context.create(surface)
  cr:arc(button_size / 2, button_size / 2, button_size / 2, math.rad(0), math.rad(360))
  cr:set_source_rgba(gcolor.parse_color(titlebar.key[key_color] or beautiful.colorscheme.fg))
  cr.antialias = cairo.Antialias.BEST
  cr:fill()
  titlebar.key[key_img] = surface
  return titlebar.key[key_img]
end

---Returns a button widget for the titlebar
---@param c client
---@param name string Name for the tooltip and the correct button image
---@param button_callback function callback function called when the button is pressed
---@param property string|nil client state, e.g. active or inactive
---@return wibox.widget button widget
local function create_titlebar_button(c, name, button_callback, property)
  local button_img = wibox.widget.imagebox(nil, false)
  local tooltip = atooltip {
    text = name,
    delay_show = 0.5,
    margins_leftright = 12,
    margins_topbottom = 6,
    timeout = 0.25,
    align = 'bottom_right',
  }
  tooltip:add_to_object(button_img)
  local is_on, is_focused
  local event = 'normal'
  local function update()
    is_focused = c.active
    -- If the button is for a property that can be toggled
    if property then
      is_on = c[property]
      button_img.image = create_button_image(name, is_focused, event, is_on)
    else
      button_img.image = create_button_image(name, is_focused, event)
    end
  end

  c:connect_signal('unfocus', update)
  c:connect_signal('focus', update)
  if property then c:connect_signal('property::' .. property, update) end
  button_img:connect_signal('mouse::enter', function()
    event = 'hover'
    update()
  end)
  button_img:connect_signal('mouse::leave', function()
    event = 'normal'
    update()
  end)

  button_img.buttons = abutton({}, 1, function()
    event = 'press'
    update()
  end, function()
    if button_callback then
      event = 'normal'
      button_callback()
    else
      event = 'hover'
    end
    update()
  end)

  button_img.id = 'button_image'
  update()
  return wibox.widget {
    {
      {
        button_img,
        widget = wibox.container.constraint,
        height = dpi(18),
        width = dpi(18),
        strategy = 'exact',
      },
      widget = wibox.container.margin,
      margins = dpi(5),
    },
    widget = wibox.container.place,
  }
end

---Get the mouse bindings for the titlebar
---@param c client
---@return table all mouse bindings for the titlebar
local function get_titlebar_mouse_bindings(c)
  local clicks = 0
  local tolerance = 4
  local buttons = { abutton({}, 1, function()
    local cx, cy = capi.mouse.coords().x, capi.mouse.coords().y
    local delta = 250 / 1000
    clicks = clicks + 1
    if clicks == 2 then
      local nx, ny = capi.mouse.coords().x, capi.mouse.coords().y
      if math.abs(cx - nx) <= tolerance and math.abs(cy - ny) <= tolerance then
        c.maximized = not c.maximized
      end
    else
      c:activate { context = 'titlebar', action = 'mouse_move' }
    end
    -- Start a timer to clear the click count
    gtimer.weak_start_new(delta, function() clicks = 0 end)
  end), abutton({}, 2, function()
    c.color = get_dominant_color(c)
    set_color_rule(c, c.color)
    add_titlebar(c)
  end), abutton({}, 3, function()
    c:activate { context = 'mouse_click', action = 'mouse_resize' }
  end), }
  return buttons
end

---Creates a title widget for the titlebar
---@param c client
---@return wibox.widget The title widget
local function create_titlebar_title(c)
  local title_widget = wibox.widget {
    halign = 'center',
    ellipsize = 'middle',
    opacity = c.active and 1 or 0.7,
    valign = 'center',
    widget = wibox.widget.textbox,
  }

  local function update()
    title_widget.markup = ("<span foreground='%s'>%s</span>"):format(
      (((relative_luminance(beautiful.colorscheme.fg) + 0.05) / (relative_luminance(c.color) + 0.05)) >= 7 and true)
      and beautiful.colorscheme.fg or beautiful.colorscheme.bg, c.name)
  end

  c:connect_signal('property::name', update)
  c:connect_signal('unfocus', function()
    title_widget.opacity = 0.7
  end)
  c:connect_signal('focus', function() title_widget.opacity = 1 end)
  update()
  return {
    title_widget,
    widget = wibox.container.margin,
    margins = dpi(5),
  }
end

---Creates the widget for a titlebar item
---@param c client
---@param name string The name of the item
---@return wibox.widget|nil widget The titlebar item widget
local function get_titlebar_item(c, name)
  if titlebar_position == 'top' then
    if name == 'close' then return create_titlebar_button(c, name, function() c:kill() end)
    elseif name == 'maximize' then
      return create_titlebar_button(c, name, function() c.maximized = not c.maximized end, 'maximized')
    elseif name == 'minimize' then
      return create_titlebar_button(c, name, function() c.minimized = true end)
    elseif name == 'ontop' then
      return create_titlebar_button(c, name, function() c.ontop = not c.ontop end, 'ontop')
    elseif name == 'floating' then
      return create_titlebar_button(c, name, function()
        c.floating = not c.floating
        if c.floating then
          c.maximized = false
        end
      end, 'floating')
    elseif name == 'sticky' then
      return create_titlebar_button(c, name, function()
        c.sticky = not c.sticky
        return c.sticky
      end, 'sticky')
    elseif name == 'title' then
      return create_titlebar_title(c)
    elseif name == 'icon' then
      return wibox.widget {
        atitlebar.widget.iconwidget(c),
        widget = wibox.container.margin,
        margins = dpi(5),
      }
    end
  elseif titlebar_position == 'left' then
    if name == 'close' then
      return create_titlebar_button(c, name, function() c:kill() end)
    elseif name == 'maximize' then
      return create_titlebar_button(c, name, function() c.maximized = not c.maximized end, 'maximized')
    elseif name == 'minimize' then
      return create_titlebar_button(c, name, function() c.minimized = true end)
    elseif name == 'ontop' then
      return create_titlebar_button(c, name, function() c.ontop = not c.ontop end, 'ontop')
    elseif name == 'floating' then
      return create_titlebar_button(c, name, function()
        c.floating = not c.floating
        if c.floating then
          c.maximized = false
        end
      end, 'floating')
    elseif name == 'sticky' then
      return create_titlebar_button(c, name, function()
        c.sticky = not c.sticky
        return c.sticky
      end, 'sticky')
    elseif name == 'icon' then
      return wibox.widget {
        atitlebar.widget.iconwidget(c),
        widget = wibox.container.margin,
        margins = dpi(5),
      }
    end
  end
end

---Groups together the titlebar items for left, center, right placement
---@param c client
---@param group table|string The name of the group or a table of item names
---@return wibox.widget|nil widget The titlebar item widget
local function create_titlebar_items(c, group)
  if not group then return nil end
  if type(group) == 'string' then return create_titlebar_title(c) end
  local layout

  if titlebar_position == 'left' then
    layout = wibox.widget {
      layout = wibox.layout.fixed.vertical,
    }
  elseif titlebar_position == 'top' then
    layout = wibox.widget {
      layout = wibox.layout.fixed.horizontal,
    }
  end

  local item
  for _, name in ipairs(group) do
    item = get_titlebar_item(c, name)
    if item then layout:add(item) end
  end
  return layout
end

function add_titlebar(c)
  if titlebar_position == 'top' then
    atitlebar(c, {
      size = dpi(38),
      bg = gcolor.transparent,
      position = 'top',
    }):setup {
      {
        {
          create_titlebar_items(c, beautiful.user_config.titlebar_items.left_and_bottom),
          widget = wibox.container.margin,
          left = dpi(5),
        },
        {
          create_titlebar_items(c, beautiful.user_config.titlebar_items.middle),
          buttons = get_titlebar_mouse_bindings(c),
          layout = wibox.layout.flex.horizontal,
        },
        {
          create_titlebar_items(c, beautiful.user_config.titlebar_items.right_and_top),
          widget = wibox.container.margin,
          right = dpi(5),
        },
        layout = wibox.layout.align.horizontal,
      },
      widget = wibox.container.background,
      bg = duotone_gradient_vertical(
        lighten(c.color, 1),
        c.color,
        dpi(38),
        0,
        0.5
      ),
    }
  elseif titlebar_position == 'left' then
    atitlebar(c, {
      size = dpi(38),
      bg = gcolor.transparent,
      position = 'left',
    }):setup {
      {
        {
          create_titlebar_items(c, beautiful.user_config.titlebar_items.right_and_top),
          widget = wibox.container.margin,
          top = dpi(5),
        },
        {
          create_titlebar_items(c, beautiful.user_config.titlebar_items.middle),
          buttons = get_titlebar_mouse_bindings(c),
          layout = wibox.layout.flex.vertical,
        },
        {
          create_titlebar_items(c, beautiful.user_config.titlebar_items.left_and_bottom),
          widget = wibox.container.margin,
          left = dpi(5),
        },
        layout = wibox.layout.align.vertical,
      },
      widget = wibox.container.background,
      bg = duotone_gradient_horizontal(
        lighten(c.color, 1),
        c.color,
        dpi(38),
        0,
        0.5
      ),
    }
  end

  if not c.floating then
    atitlebar.hide(c, titlebar_position)
  end
  c:connect_signal('property::maximized', function()
    if not c.floating then
      --if not client or not client.focus then return end
      atitlebar.hide(c, titlebar_position)
    elseif c.floating and (not (c.maximized or c.fullscreen)) then
      atitlebar.show(c, titlebar_position)
    end
  end)
  c:connect_signal('property::floating', function()
    if not c.floating then
      --if not client or not client.focus then return end
      atitlebar.hide(c, titlebar_position)
    elseif c.floating and (not (c.maximized or c.fullscreen)) then
      atitlebar.show(c, titlebar_position)
    end
  end)
end

if not instance then
  instance = setmetatable(titlebar, { __call = function()

    titlebar.color_rules_filepath = gfilesystem.get_configuration_dir() .. '/src/config/' .. 'color_rules.json'
    titlebar.color_rules = load(titlebar.color_rules_filepath) or {}

    capi.client.connect_signal('request::titlebars', function(c)
      c._cb_add_window_decorations = function()
        gtimer.weak_start_new(0.5, function()
          c.color = get_dominant_color(c)
          add_titlebar(c)
          c:disconnect_signal('request::activate', c._cb_add_window_decorations)
        end)
      end

      local color = get_color_rule(c)
      if color then
        c.color = color
        add_titlebar(c)
      else
        c.color = beautiful.colorscheme.bg
        add_titlebar(c)
        c:connect_signal('request::activate', c._cb_add_window_decorations)
      end
    end)

    capi.client.connect_signal('request::manage', function(c)
      if not c.floating then
        --if not client or not client.focus then return end
        atitlebar.hide(c, titlebar_position)
      elseif c.floating and (not (c.maximized or c.fullscreen)) then
        atitlebar.show(c, titlebar_position)
      end
    end)
  end, })
end
return instance
