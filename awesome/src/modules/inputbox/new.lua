local Pango = require('lgi').Pango
local PangoCairo = require('lgi').PangoCairo
local abutton = require('awful.button')
local akey = require('awful.key')
local akeygrabber = require('awful.keygrabber')
local aplacement = require('awful.placement')
local apopup = require('awful.popup')
local base = require('wibox.widget.base')
local beautiful = require('beautiful')
local cairo = require('lgi').cairo
local gobject = require('gears.object')
local gstring = require('gears.string')
local gsurface = require('gears.surface')
local gtable = require('gears.table')
local gtimer = require('gears.timer')
local imagebox = require('wibox.widget.imagebox')
local setmetatable = setmetatable
local textbox = require('wibox.widget.textbox')
local wibox = require('wibox')
local dpi = beautiful.xresources.apply_dpi

local capi = {
  selection = selection,
  mousegrabber = mousegrabber,
  mouse = mouse,
}

local inputbox = {}

local function get_text_extent(text, font, font_size, args)
  local surface = cairo.ImageSurface(cairo.Format.ARGB32, 0, 0)
  local cr = cairo.Context(surface)
  cr:select_font_face(font, args)
  cr:set_font_size(font_size)
  return cr:text_extents(text)
end

function inputbox.draw_text(self)
  local text = self:get_text()
  local highlight = self:get_highlight()
  local fg_color = { 1, 1, 1 }
  local cursor_color = { 1, 1, 1, 1 }

  if text == '' then
    fg_color = { 0.2, 0.2, 0.2 }
    -- Silently change the text, it will be changed back after it is drawn
    self._private.layout:set_text(self._private.text_hint)
  end

  local _, pango_extent = self._private.layout:get_extents()

  local surface = cairo.ImageSurface(cairo.Format.ARGB32, (pango_extent.width / Pango.SCALE) + pango_extent.x, (pango_extent.height / Pango.SCALE) + pango_extent.y)
  local cr = cairo.Context(surface)

  -- Draw highlight
  if (highlight.start_pos ~= 0) or (highlight.end_pos ~= 0) then
    cr:set_source_rgb(0, 0, 1)
    local txt = text:sub(self:get_highlight().start_pos + 1, self:get_highlight().end_pos)
    cr:rectangle(
      cr:text_extents(text:sub(0, self:get_highlight().start_pos)).x_advance,
      pango_extent.y / Pango.SCALE,
      cr:text_extents(txt).width,
      pango_extent.height / Pango.SCALE
    )
    cr:fill()
  end

  -- Draw text
  PangoCairo.update_layout(cr, self._private.layout)
  cr:set_source_rgba(1, 1, 1, 1)
  cr:move_to(0, 0)
  PangoCairo.show_layout(cr, self._private.layout)

  -- Draw cursor
  cr:set_source_rgba(table.unpack(cursor_color))
  local cursor = self:get_cursor_pos()
  cr:rectangle(
    cursor.x / Pango.SCALE,
    cursor.y / Pango.SCALE,
    2,
    cursor.height / Pango.SCALE)
  cr:fill()

  self.widget:set_image(surface)
  return surface
end

function inputbox:start_keygrabber()
  self.akeygrabber = akeygrabber {
    autostart = true,
    stop_key = { 'Escape', 'Return' },
    start_callback = function()
    end,
    stop_callback = function()
    end,
    keybindings = {
      akey {
        modifiers = {},
        key = 'BackSpace',
        on_press = function()
          local hl = self:get_highlight()
          local text = self:get_text()
          local cursor_pos = self:get_cursor_index()
          if hl.end_pos ~= hl.start_pos then
            self:set_text(text:sub(0, hl.start_pos) .. text:sub(hl.end_pos + 1, #text))
            self:set_cursor_pos(hl.start_pos)
            self:set_highlight { start_pos = 0, end_pos = 0 }
          else
            self:set_text(text:sub(1, cursor_pos - 1) .. text:sub(cursor_pos + 1))
            self:set_cursor_pos(cursor_pos - 1)
          end
        end,
      },
      akey {
        modifiers = {},
        key = 'Delete',
        on_press = function()
          local hl = self:get_highlight()
          local text = self:get_text()
          local cursor_pos = self:get_cursor_index()
          if hl.end_pos ~= hl.start_pos then
            self:set_text(text:sub(0, hl.start_pos) .. text:sub(hl.end_pos + 1, #text))
            self:set_cursor_pos(hl.start_pos)
            self:set_highlight { start_pos = 0, end_pos = 0 }
          else
            self:set_text(text:sub(1, cursor_pos) .. text:sub(cursor_pos + 2, #text))
          end
        end,
      },
      akey {
        modifiers = {},
        key = 'Left',
        on_press = function()
          self:set_cursor_pos(self:get_cursor_index() - 1)
          self:set_highlight { start_pos = 0, end_pos = 0 }
        end,
      },
      akey {
        modifiers = {},
        key = 'Right',
        on_press = function()
          self:set_cursor_pos(self:get_cursor_index() + 1)
          self:set_highlight { start_pos = 0, end_pos = 0 }
        end,
      },
      akey {
        modifiers = {},
        key = 'Home',
        on_press = function()
          self:set_cursor_pos(0)
          self:set_highlight { start_pos = 0, end_pos = 0 }
        end,
      },
      akey {
        modifiers = {},
        key = 'End',
        on_press = function()
          self:set_cursor_pos(#self:get_text())
          self:set_highlight { start_pos = 0, end_pos = 0 }
        end,
      },
      akey {
        modifiers = { 'Shift' },
        key = 'Left',
        on_press = function()
          local cursor_pos = self:get_cursor_pos()
          local hl = self:get_highlight()
          if cursor_pos == hl.start_pos then
            self:set_cursor_pos(cursor_pos - 1)
            self:set_highlight { start_pos = self:get_cursor_pos(), end_pos = hl.end_pos }
          elseif cursor_pos == hl.end_pos then
            self:set_cursor_pos(cursor_pos - 1)
            self:set_highlight { start_pos = hl.start_pos, end_pos = self:get_cursor_pos() }
          else
            if (hl.start_pos ~= cursor_pos) and (hl.end_pos ~= cursor_pos) then
              self:set_highlight { start_pos = cursor_pos, end_pos = cursor_pos }
              hl = self:get_highlight()
              self:set_cursor_pos(cursor_pos - 1)
              self:set_highlight { start_pos = self:get_cursor_pos(), end_pos = hl.end_pos }
            end
          end
        end,
      },
      akey {
        modifiers = { 'Shift' },
        key = 'Right',
        on_press = function()
          local cursor_pos = self:get_cursor_pos()
          local hl = self:get_highlight()
          if cursor_pos == hl.end_pos then
            self:set_cursor_pos(cursor_pos + 1)
            self:set_highlight { start_pos = hl.start_pos, end_pos = self:get_cursor_pos() }
          elseif cursor_pos == hl.start_pos then
            self:set_cursor_pos(cursor_pos + 1)
            self:set_highlight { start_pos = self:get_cursor_pos(), end_pos = hl.end_pos }
          else
            if (hl.start_pos ~= cursor_pos) and (hl.end_pos ~= cursor_pos) then
              self:set_highlight { start_pos = cursor_pos, end_pos = cursor_pos }
              hl = self:get_highlight()
              self:set_cursor_pos(cursor_pos + 1)
              self:set_highlight { start_pos = hl.start_pos, end_pos = self:get_cursor_pos() }
            end
          end
        end,
      },
      akey {
        modifiers = { 'Control' },
        key = 'a',
        on_press = function()
          self:set_highlight { start_pos = 0, end_pos = #self:get_text() }
          self:set_cursor_pos(#self:get_text() - 1)
        end,
      },
      akey {
        modifiers = { 'Control' },
        key = 'c',
        on_press = function()
          local hl = self:get_highlight()
          if hl.start_pos ~= hl.end_pos then
            local text = self:get_text():sub(hl.start_pos, hl.end_pos)
            --TODO:self:copy_to_clipboard(text)
          end
        end,
      },
      akey {
        modifiers = { 'Control' },
        key = 'v',
        on_press = function()
          local hl = self:get_highlight()
          local selection = capi.selection()
          if hl.start_pos ~= hl.end_pos then
            self:set_text(self:get_text():sub(1, hl.start_pos) .. selection .. self:get_text():sub(hl.end_pos + 1, #self:get_text()))
            self:set_cursor_pos(hl.start_pos + #selection)
            self:set_highlight { start_pos = 0, end_pos = 0 }
          else
            self:set_text(self:get_text():sub(1, self:get_cursor_pos()) .. selection .. self:get_text():sub(self:get_cursor_pos() + 1, #self:get_text()))
            self:set_cursor_pos(self:get_cursor_pos() + #selection)
          end
        end,
      },
      akey {
        modifiers = { 'Control' },
        key = 'x',
        on_press = function()
          --TODO
        end,
      },
      akey {
        modifiers = { 'Control' },
        key = 'Right',
        on_press = function()

        end,
      },
      akey {
        modifiers = { 'Control' },
        key = 'Left',
        on_press = function()

        end,
      },
    },
    keypressed_callback = function(_, mod, key)
      local text = self:get_text()
      local cursor_pos = self:get_cursor_index()
      if (mod[1] == 'Mod2' or '') and (key:wlen() == 1) then
        self:set_text(text:sub(1, cursor_pos) .. key .. text:sub(cursor_pos + 1, #text))
        self:set_cursor_pos(cursor_pos + #key)
      elseif (mod[1] == 'Shift') and (key:wlen() == 1) then
        self:set_text(text:sub(1, cursor_pos) .. key:upper() .. text:sub(cursor_pos + 1, #text))
        self:set_cursor_pos(cursor_pos + #key)
      end
    end,
  }
end

--[[ function inputbox:advanced_by_character(mx, last_x)
  local delta = mx - last_x
  local character
  local text = self:get_text()
  local cursor_pos = self:get_cursor_pos()
  if delta < 0 then
    character = text:sub(cursor_pos + 1, cursor_pos + 1)
  else
    character = text:sub(cursor_pos - 1, cursor_pos - 1)
  end

  if character then
    local extents = get_text_extent(character, self.font, self.font_size, { cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL })
    if math.abs(delta) >= extents.x_advance then
      self:set_cursor_pos(cursor_pos + (((delta > 0) and 1) or -1))
      last_x = mx
      return (((delta > 0) and 1) or -1), last_x
    end
  end
  return 0, last_x
end ]]

function inputbox:start_mousegrabber(x, y)
  --[[ if not mousegrabber.isrunning() then
    local last_x, advanced, cursor_pos, mx = x, nil, self:get_cursor_pos(), nil
    local hl = self:get_highlight()
    self:set_highlight { start_pos = cursor_pos, end_pos = cursor_pos }
    local text = self:get_text()
    mousegrabber.run(function(m)
      mx = m.x
      if (math.abs(mx - x) > 5) then
        advanced, last_x = self:advanced_by_character(mx, last_x)
        if advanced == 1 then
          if cursor_pos <= hl.start_pos then
            if hl.end_pos < #text then
              self:set_highlight { start_pos = hl.start_pos, end_pos = hl.end_pos + 1 }
            end
          else
            self:set_highlight { start_pos = hl.start_pos + 1, end_pos = hl.end_pos }
          end
        elseif advanced == -1 then
          if cursor_pos >= hl.end_pos then
            if hl.start_pos > 1 then
              self:set_highlight { start_pos = hl.start_pos - 1, end_pos = hl.end_pos }
            end
          else
            self:set_highlight { start_pos = hl.start_pos, end_pos = hl.end_pos - 1 }
          end
        end
      end
      hl = self:get_highlight()
      return m.buttons[1]
    end, 'xterm')
  end ]]
  if not mousegrabber.isrunning() then
    local index, _ = self._private.layout:xy_to_index(x * Pango.SCALE, y * Pango.SCALE)

    if not index then return end

    self:set_cursor_pos(index)
    -- Remove highlight, but also prepare its position (same pos = no highlight)
    self:set_highlight { start_pos = index, end_pos = index }

    local text = self:get_text()
    local cursor_pos = self:get_cursor_pos()
    local hl = self:get_highlight()

    mousegrabber.run(function(m)
      index, _ = self._private.layout:xy_to_index(m.x * Pango.SCALE, m.y * Pango.SCALE)

      if not index then return end

      if math.abs(index - cursor_pos) == 1 then
        if cursor_pos <= hl.start_pos then
          if hl.end_pos < #text then
            self:set_highlight { start_pos = hl.start_pos, end_pos = hl.end_pos + 1 }
          end
        else
          self:set_highlight { start_pos = hl.start_pos + 1, end_pos = hl.end_pos }
        end
      elseif math.abs(index - cursor_pos) == -1 then
        if cursor_pos >= hl.end_pos then
          if hl.start_pos > 1 then
            self:set_highlight { start_pos = hl.start_pos - 1, end_pos = hl.end_pos }
          end
        else
          self:set_highlight { start_pos = hl.start_pos, end_pos = hl.end_pos - 1 }
        end
      end

      if index ~= cursor_pos then
        self:set_cursor_pos(index)
      end

      return m.buttons[1]
    end, 'xterm')
  end
end

function inputbox:set_cursor_pos_from_mouse(x, y)
  -- When setting the cursor position, trailing is not needed as its handled by the setter
  local index, _ = self._private.layout:xy_to_index(x * Pango.SCALE, y * Pango.SCALE)
  if not index then return end

  self:set_highlight { start_pos = 0, end_pos = 0 }
  self:set_cursor_pos(index)
end

function inputbox:get_text()
  return self._private.layout:get_text()
end

function inputbox:set_text(text)
  if self:get_text() == text then return end

  local attributes, parsed = Pango.parse_markup(text, -1, 0)

  if not attributes then return parsed.message or tostring(parsed) end

  self._private.layout:set_text(parsed, string.len(parsed))
  self._private.layout:set_attributes(attributes)

  self.draw_text(self)
end

function inputbox:get_cursor_pos()
  return self._private.layout:get_cursor_pos(self._private.cursor_pos.index)
end

function inputbox:get_cursor_index()
  return self._private.cursor_pos.index
end

function inputbox:set_cursor_pos(cursor_pos)
  -- moving only moved one character set, to move it multiple times we need to loop as long as the difference to the new cursor isn't 0
  if not cursor_pos or (cursor_pos < 0) or (cursor_pos >= #self:get_text()) then return end
  while (cursor_pos - self._private.cursor_pos.index) ~= 0 do
    self._private.cursor_pos.index, self._private.cursor_pos.trailing = self._private.layout:move_cursor_visually(
      true, self._private.cursor_pos.index,
      self._private.cursor_pos.trailing,
      cursor_pos - self._private.cursor_pos.index
    )
  end

  self.draw_text(self)
end

function inputbox:get_highlight()
  return self._private.highlight
end

function inputbox:set_highlight(highlight)
  self._private.highlight = highlight
  self.draw_text(self)
end

function inputbox:focus()

end

function inputbox:unfocus()

end

function inputbox.new(args)
  local ret = gobject { enable_properties = true }
  args.text = args.text .. '\n'
  gtable.crush(ret, inputbox)

  ret._private = {}
  ret._private.context = PangoCairo.font_map_get_default():create_context()
  ret._private.layout = Pango.Layout.new(ret._private.context)

  ret.font_size = 24
  ret.font = 'JetBrainsMono Nerd Font, ' .. 24
  ret._private.layout:set_font_description(Pango.FontDescription.from_string('JetBrainsMono Nerd Font 16'))

  ret._private.text_hint = args.text_hint or ''
  ret._private.cursor_pos = {
    index = args.cursor_pos or 0,
    trailing = 0,
  }
  ret._private.highlight = args.highlight or {
    start_pos = 0,
    end_pos = 0,
  }

  ret.widget = imagebox(nil, false)

  ret.widget:connect_signal('button::press', function(_, x, y, button)
    if button == 1 then
      ret:set_cursor_pos_from_mouse(x, y)
      --ret:start_mousegrabber(x, y)
      ret:start_keygrabber()
    end
  end)

  ret:set_text(args.text or '')
  --ret:set_cursor_pos(ret._private.cursor_pos)
  ret:set_highlight(ret._private.highlight)

  return ret
end

return setmetatable(inputbox, {
  __call = function(_, ...)
    return inputbox.new(...)
  end,
})
