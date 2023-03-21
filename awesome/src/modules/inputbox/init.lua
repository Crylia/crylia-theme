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

local function get_subtext_layout(layout, starti, endi)
  local text = layout:get_text()

  local subtext = text:sub(starti, endi)

  local ctx = layout:get_context()

  local sublayout = Pango.Layout.new(ctx)
  sublayout:set_font_description(layout:get_font_description())
  sublayout:set_text(subtext)

  local _, sub_extent = sublayout:get_extents()
  return sub_extent
end

function inputbox.draw_text(self)
  local text = self:get_text()
  local highlight = self:get_highlight()
  local fg_color = { 1, 1, 1, 1 }
  local cursor_color = { 1, 1, 1, 1 }

  if text == '' then
    fg_color = { 0.2, 0.2, 0.2, 1 }
    --self._private.layout:set_text(self._private.text_hint)
    --local cairo_text = self._private.text_hint
    -- Get the text extents from Pango so we don't need to use cairo to get a possibly wrong extent
    -- Then draw the text with cairo
  end

  local _, pango_extent = self._private.layout:get_extents()

  local surface = cairo.ImageSurface(cairo.Format.ARGB32, (pango_extent.width / Pango.SCALE) + pango_extent.x + 2, (pango_extent.height / Pango.SCALE) + pango_extent.y)
  local cr = cairo.Context(surface)

  -- Draw highlight
  if highlight.start_pos ~= highlight.end_pos then
    cr:set_source_rgb(0, 0, 1)
    local sub_extent = get_subtext_layout(self._private.layout, self:get_highlight().start_pos, self:get_highlight().end_pos)
    local _, x_offset = self._private.layout:index_to_line_x(self:get_highlight().start_pos, false)
    cr:rectangle(
      x_offset / Pango.SCALE,
      pango_extent.y / Pango.SCALE,
      sub_extent.width / Pango.SCALE,
      pango_extent.height / Pango.SCALE
    )
    cr:fill()
  end

  -- Draw text
  if not self.password_mode then
    PangoCairo.update_layout(cr, self._private.layout)
    cr:set_source_rgba(table.unpack(fg_color))
    cr:move_to(0, 0)
    PangoCairo.show_layout(cr, self._private.layout)
  else
    local count = self._private.layout:get_glyph_count()
    local passwd_string
    for i = 1, count, 1 do
      passwd_string = passwd_string .. '🞄'
    end
    self._private.layout:set_text(passwd_string)
    PangoCairo.update_layout(cr, self._private.layout)
    cr:set_source_rgba(table.unpack(fg_color))
    cr:move_to(0, 0)
    PangoCairo.show_layout(cr, self._private.layout)
  end
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
  self._private.akeygrabber = akeygrabber {
    autostart = true,
    stop_key = { 'Escape', 'Return' },
    start_callback = function()
    end,
    stop_callback = function()
    end,
    keybindings = {
      akey { -- Delete highlight or left to cursor
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
      akey { -- Delete highlight or right of cursor
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
      akey { -- Move cursor to left
        modifiers = {},
        key = 'Left',
        on_press = function()
          self:set_cursor_pos(self:get_cursor_index() - 1)
          self:set_highlight { start_pos = 0, end_pos = 0 }
        end,
      },
      akey { -- Move cursor to right
        modifiers = {},
        key = 'Right',
        on_press = function()
          self:set_cursor_pos(self:get_cursor_index() + 1)
          self:set_highlight { start_pos = 0, end_pos = 0 }
        end,
      },
      akey { -- Jump cursor to text beginning
        modifiers = {},
        key = 'Home',
        on_press = function()
          self:set_cursor_pos(0)
          self:set_highlight { start_pos = 0, end_pos = 0 }
        end,
      },
      akey { -- Jump cursor to text end
        modifiers = {},
        key = 'End',
        on_press = function()
          self:set_cursor_pos(#self:get_text())
          self:set_highlight { start_pos = 0, end_pos = 0 }
        end,
      },
      akey { -- Highlight to the left
        modifiers = { 'Shift' },
        key = 'Left',
        on_press = function()
          local cursor_pos = self:get_cursor_index()
          local hl = self:get_highlight()
          if cursor_pos == hl.start_pos then
            self:set_cursor_pos(cursor_pos - 1)
            self:set_highlight { start_pos = self:get_cursor_index(), end_pos = hl.end_pos }
          elseif cursor_pos == hl.end_pos then
            self:set_cursor_pos(cursor_pos - 1)
            self:set_highlight { start_pos = hl.start_pos, end_pos = self:get_cursor_index() }
          else
            if (hl.start_pos ~= cursor_pos) and (hl.end_pos ~= cursor_pos) then
              self:set_highlight { start_pos = cursor_pos, end_pos = cursor_pos }
              hl = self:get_highlight()
              self:set_cursor_pos(cursor_pos - 1)
              self:set_highlight { start_pos = self:get_cursor_index(), end_pos = hl.end_pos }
            end
          end
        end,
      },
      akey { -- Highlight to the right
        modifiers = { 'Shift' },
        key = 'Right',
        on_press = function()
          local cursor_pos = self:get_cursor_index()
          local hl = self:get_highlight()
          if cursor_pos == hl.end_pos then
            self:set_cursor_pos(cursor_pos + 1)
            self:set_highlight { start_pos = hl.start_pos, end_pos = self:get_cursor_index() }
          elseif cursor_pos == hl.start_pos then
            self:set_cursor_pos(cursor_pos + 1)
            self:set_highlight { start_pos = self:get_cursor_index(), end_pos = hl.end_pos }
          else
            if (hl.start_pos ~= cursor_pos) and (hl.end_pos ~= cursor_pos) then
              self:set_highlight { start_pos = cursor_pos, end_pos = cursor_pos }
              hl = self:get_highlight()
              self:set_cursor_pos(cursor_pos + 1)
              self:set_highlight { start_pos = hl.start_pos, end_pos = self:get_cursor_index() }
            end
          end
        end,
      },
      akey { -- Highlight all
        modifiers = { 'Control' },
        key = 'a',
        on_press = function()
          self:set_highlight { start_pos = 0, end_pos = #self:get_text() }
          self:set_cursor_pos(#self:get_text() - 1)
        end,
      },
      akey { -- Copy highlight
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
      akey { -- Paste text into cursor/highlight
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
      akey { -- Cut highlighted text
        modifiers = { 'Control' },
        key = 'x',
        on_press = function()
          --TODO
        end,
      },
      akey { -- Word jump right
        modifiers = { 'Control' },
        key = 'Right',
        on_press = function()

        end,
      },
      akey { -- Word jump left
        modifiers = { 'Control' },
        key = 'Left',
        on_press = function()

        end,
      },
      akey { -- Word jump highlight right
        modifiers = { 'Control', 'Shift' },
        key = 'Right',
        on_press = function()

        end,
      },
      akey { -- Word jump highlight left
        modifiers = { 'Control', 'Shift' },
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
      self:emit_signal('inputbox::keypressed', mod, key)
    end,
  }
end

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

    if not index then index = #self:get_text() end

    self:set_cursor_pos(index)
    -- Remove highlight, but also prepare its position (same pos = no highlight)
    self:set_highlight { start_pos = index, end_pos = index }

    local text = self:get_text()
    local hl = self:get_highlight()

    local mb_start = index
    local m_start_x = capi.mouse.coords().x

    mousegrabber.run(function(m)
      index, _ = self._private.layout:xy_to_index((m.x - m_start_x + x) * Pango.SCALE, y * Pango.SCALE)

      if not index then index = #text end

      if mb_start - index == 1 then
        if index <= hl.start_pos then
          if hl.end_pos < #text then
            self:set_highlight { start_pos = hl.start_pos, end_pos = hl.end_pos + 1 }
          end
        else
          self:set_highlight { start_pos = hl.start_pos + 1, end_pos = hl.end_pos }
        end
      elseif mb_start - index == -1 then
        if index >= hl.end_pos then
          if hl.start_pos > 1 then
            self:set_highlight { start_pos = hl.start_pos - 1, end_pos = hl.end_pos }
          end
        else
          self:set_highlight { start_pos = hl.start_pos, end_pos = hl.end_pos - 1 }
        end
      end

      if index ~= mb_start then
        self:set_cursor_pos(index)
        mb_start = index
      end
      print(self:get_highlight().start_pos, self:get_highlight().end_pos)
      hl = self:get_highlight()
      return m.buttons[1]
    end, 'xterm')
  end
end

function inputbox:set_cursor_pos_from_mouse(x, y)
  -- When setting the cursor position, trailing is not needed as its handled by the setter
  local index = self._private.layout:xy_to_index(x * Pango.SCALE, y * Pango.SCALE)
  if not index then index = #self:get_text() end

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
  if not cursor_pos or (cursor_pos < 0) or (cursor_pos > #self:get_text()) then return end
  --while (cursor_pos - self._private.cursor_pos.index) ~= 0 do
  --[[ self._private.cursor_pos.index, self._private.cursor_pos.trailing = self._private.layout:move_cursor_visually(
    true, self._private.cursor_pos.index,
    self._private.cursor_pos.trailing,
    cursor_pos - self._private.cursor_pos.index
  ) ]]
  self._private.cursor_pos.index = cursor_pos
  --end

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
  self:start_keygrabber()
end

function inputbox:unfocus(reset)
  if akeygrabber.is_running then
    self._private.akeygrabber:stop()
    if reset then
      self:set_cursor_pos(0)
      self:set_highlight { start_pos = 0, end_pos = 0 }
    end
  end
end

function inputbox.new(args)
  local ret = gobject { enable_properties = true }
  gtable.crush(ret, inputbox)

  ret._private = {}
  ret._private.context = PangoCairo.font_map_get_default():create_context()
  ret._private.layout = Pango.Layout.new(ret._private.context)
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

  if args.mouse_focus then
    ret.widget:connect_signal('button::press', function(_, x, y, button)
      if button == 1 then
        ret:set_cursor_pos_from_mouse(x, y)
        ret:start_mousegrabber(x, y)
        ret:start_keygrabber()
      end
    end)
  end

  ret:set_text(args.text or '')
  return ret
end

return setmetatable(inputbox, {
  __call = function(_, ...)
    return inputbox.new(...)
  end,
})