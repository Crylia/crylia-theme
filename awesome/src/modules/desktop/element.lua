local base = require('wibox.widget.base')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gcolor = require('gears.color')
local gshape = require('gears.shape')
local gtable = require('gears.table')
local lgi = require('lgi')
local cairo = lgi.cairo
local wibox = require('wibox')

local input = require('src.modules.inputbox')

local element = { mt = {} }

function element:layout(_, width, height)
  if self._private.widget then
    return { base.place_widget_at(self._private.widget, 0, 0, width, height) }
  end
end

function element:fit(context, width, height)
  local w, h = 0, 0
  if self._private.widget then
    w, h = base.fit_widget(self, context, self._private.widget, width, height)
  end
  return w, h
end

function element:get_widget()
  return self._private.widget
end

function element:on_hover()
  self:connect_signal('mouse::enter', function()
    self.bg = '#0ffff033'
    self.border_color = '#0ffff099'
  end)

  self:connect_signal('mouse::leave', function()
    self.bg = gcolor.transparent
    self.border_color = gcolor.transparent
  end)

  self:connect_signal('button::press', function()
    self.bg = '#0ffff088'
    self.border_color = '#0ffff0dd'
  end)

  self:connect_signal('button::release', function()
    self.bg = '#0ffff033'
    self.border_color = '#0ffff099'
  end)
end

---Get the cairo extents for any text with its give size and font
---@param font string A font
---@param font_size number Font size
---@param text string Text to get the extent for
---@param args table Additional arguments
---@return userdata cairo.Extent
local function cairo_text_extents(font, font_size, text, args)
  local surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, 0, 0)
  local cr = cairo.Context(surface)
  cr:select_font_face(font, cairo.FontSlant.NORMAL, cairo.FontWeight.BOLD)
  cr:set_font_size(font_size)
  cr:set_antialias(cairo.Antialias.BEST)
  return cr:text_extents(text)
end

local function split_string(str, max_width)
  local line1 = ''
  local line2 = ''
  local line1_width = 0
  local line2_width = 0
  local font = 'JetBrainsMono Nerd Font'
  local font_size = dpi(16)
  local font_args = { cairo.FontSlant.NORMAL, cairo.FontWeight.BOLD }

  for word in str:gmatch('%S+') do
    local word_width = cairo_text_extents(font, font_size, word, font_args).width
    if line1_width + word_width < max_width then
      line1 = line1 .. word .. ' '
      line1_width = line1_width + word_width
    else
      line2 = line2 .. word .. ' '
      line2_width = line2_width + word_width
    end
  end

  return line1, line2
end

---This function takes any text and uses cairo to draw an outline and a shadow
---It also wraps the text correctly if max_width would be violated. It only uses two lines for wraping
---the rest is cut off.
---@param text string Text to be changed
---@param max_width number max width the text won't go over
---@return cairo.Surface cairo_surface manupulated text as a cairo surface
---@return table `width`,`height` The surface dimensions
local function outlined_text(text, max_width)
  local font = 'JetBrainsMono Nerd Font'
  local font_size = dpi(16)
  local spacing = dpi(5)
  local margin = dpi(5)
  max_width = max_width - (margin * 2)
  local shadow_offset_x, shadow_offset_y = 1, 1
  local font_args = { cairo.FontSlant.NORMAL, cairo.FontWeight.BOLD }

  -- Get the dimensions from the text
  local extents = cairo_text_extents(font, font_size, text, font_args)

  -- if its bigger it needs special treatment
  if extents.width > max_width then

    local line1, line2 = split_string(text, max_width)

    -- Get the dimensions for both lines
    local extents1 = cairo_text_extents(font, font_size, line1, font_args)
    local extents2 = cairo_text_extents(font, font_size, line2, font_args)

    -- The surface width will be the biggest of the two lines
    local s_width = extents1.width
    if extents1.width < extents2.width then
      s_width = extents2.width
    end

    -- Create a new surface based on the widest line, and both line's height + the spacing between them and the shadow offset
    local surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, s_width + shadow_offset_x, extents1.height + extents2.height + spacing + (shadow_offset_y * 3))
    local cr = cairo.Context(surface)

    -- Create the font with best antialias
    cr:select_font_face(font, cairo.FontSlant.NORMAL, cairo.FontWeight.BOLD)
    cr:set_font_size(font_size)
    cr:set_antialias(cairo.Antialias.BEST)

    -- To center both lines get the surface center then substract half the line width
    local text_x = s_width / 2 - ((extents1.width) / 2)
    local text_x2 = s_width / 2 - ((extents2.width) / 2)

    -- This makes the first text to be blow the main text
    cr:set_operator(cairo.Operator.OVER)

    -- Draw the text shadow
    cr:move_to(text_x + shadow_offset_x, -extents1.y_bearing + shadow_offset_y)
    cr:set_source_rgba(0, 0, 0, 0.5)
    cr:show_text(line1)

    cr:set_operator(cairo.Operator.OVER)

    -- Draw the second shadow
    cr:move_to(text_x2 + shadow_offset_x, extents1.height + extents2.height + spacing + shadow_offset_y)
    cr:set_source_rgba(0, 0, 0, 0.5)
    cr:show_text(line2)

    -- Draw the first and second line
    cr:move_to(text_x, -extents1.y_bearing)
    cr:set_source_rgb(1, 1, 1)
    cr:text_path(line1)
    cr:move_to(text_x2, extents1.height + extents2.height + spacing)
    cr:text_path(line2)

    -- Color it and set the stroke
    cr:fill_preserve()
    cr:set_source_rgb(0, 0, 0)
    cr:set_line_width(0.1)
    cr:stroke()

    return surface, { width = extents.width, height = extents1.height + extents2.height + spacing }
  else
    -- The size is the dimension from above the if
    local surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, extents.width, extents.height + shadow_offset_y)
    local cr = cairo.Context(surface)

    -- Set the font, then draw the text and its stroke
    cr:select_font_face(font, cairo.FontSlant.NORMAL, cairo.FontWeight.BOLD)
    cr:set_font_size(font_size)

    -- This makes the first text to be blow the main text
    cr:set_operator(cairo.Operator.OVER)

    -- Draw the text shadow
    cr:move_to(-extents.x_bearing + shadow_offset_x, -extents.y_bearing + shadow_offset_y)
    cr:set_source_rgba(0, 0, 0, 0.5)
    cr:show_text(text)

    cr:move_to(-extents.x_bearing, -extents.y_bearing)
    cr:set_source_rgb(1, 1, 1)
    cr:text_path(text)
    cr:fill_preserve()
    cr:set_source_rgb(0, 0, 0)
    cr:set_line_width(0.1)
    cr:stroke()
    return surface, { width = extents.width, height = extents.height }
  end
end

function element.new(args)
  args = args or {}

  local text_img, size = outlined_text(args.label, args.width)

  local inputbox = input {
    font = 'JetBrainsMono Nerd Font 12 Regular',
    mouse_focus = false,
    text = args.label,
  }

  local w = base.make_widget_from_value(wibox.widget {
    {
      {
        {
          {
            image = args.icon,
            resize = true,
            clip_shape = gshape.rounded_rect,
            valign = 'top',
            halign = 'center',
            id = 'icon_role',
            forced_width = args.icon_size,
            forced_height = args.icon_size,
            widget = wibox.widget.imagebox,
          },
          widget = wibox.container.margin,
          top = dpi(5),
          left = dpi(20),
          right = dpi(20),
          bottom = dpi(5),
        },
        {
          image = text_img,
          resize = false,
          valign = 'bottom',
          halign = 'center',
          widget = wibox.widget.imagebox,
        },
        spacing = dpi(10),
        layout = wibox.layout.align.vertical,
      },
      valign = 'center',
      halign = 'center',
      widget = wibox.container.place,
    },
    fg = beautiful.colorscheme.fg,
    bg = gcolor.transparent,
    border_color = gcolor.transparent,
    border_width = dpi(2),
    shape = gshape.rounded_rect,
    forced_width = args.width,
    forced_height = args.height,
    width = args.width,
    height = args.height,
    exec = args.exec,
    icon_size = args.icon_size,
    icon = args.icon,
    label = args.label,
    widget = wibox.container.background,
  })

  assert(w, 'No widget returned')

  gtable.crush(w, element, true)

  w:on_hover()

  return w
end

function element.mt:__call(...)
  return element.new(...)
end

return setmetatable(element, element.mt)
