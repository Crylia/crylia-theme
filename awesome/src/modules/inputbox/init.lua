---------------------------------------------------------------------------
-- This widget can be used to type text and get the text from it.
--@DOC_wibox_widget_defaults_inputbox_EXAMPLE@
--
-- @author Rene Kievits
-- @copyright 2022, Rene Kievits
-- @module awful.widget.inputbox
---------------------------------------------------------------------------

local setmetatable = setmetatable
local beautiful = require('beautiful')
local gtable = require('gears.table')
local base = require('wibox.widget.base')
local gstring = require('gears.string')
local akeygrabber = require('awful.keygrabber')
local akey = require('awful.key')
local textbox = require('wibox.widget.textbox')
local imagebox = require('wibox.widget.imagebox')
local cairo = require('lgi').cairo
local apopup = require('awful.popup')
local aplacement = require('awful.placement')
local gsurface = require('gears.surface')
local wibox = require('wibox')
local abutton = require('awful.button')

local capi = {
  selection = selection,
  mousegrabber = mousegrabber,
  mouse = mouse,
}

local inputbox = { mt = {} }

--- Formats the text with a cursor and highlights if set.
--[[ local function text_with_cursor(text, cursor_pos, self)
  local char, spacer, text_start, text_end

  local cursor_fg = beautiful.inputbox_cursor_fg or '#313131'
  local cursor_bg = beautiful.inputbox_cursor_bg or '#0dccfc'
  local placeholder_text = self.hint_text or ''
  local placeholder_fg = beautiful.inputbox_placeholder_fg or '#777777'
  local highlight_bg = beautiful.inputbox_highlight_bg or '#35ffe4'
  local highlight_fg = beautiful.inputbox_highlight_fg or '#000000'

  if text == '' then
    return "<span foreground='" .. placeholder_fg .. "'>" .. placeholder_text .. '</span>'
  end

  local offset = 0
  if text:sub(cursor_pos - 1, cursor_pos - 1) == -1 then
    offset = 1
  end

  if #text < cursor_pos then
    char = ' '
    spacer = ''
    text_start = gstring.xml_escape(text)
    text_end = ''
  else
    char = gstring.xml_escape(text:sub(cursor_pos, cursor_pos + offset))
    spacer = ' '
    text_start = gstring.xml_escape(text:sub(1, cursor_pos - 1))
    text_end = gstring.xml_escape(text:sub(cursor_pos + offset + 1))
  end

  if self._private.highlight and self._private.highlight.start_pos and self._private.highlight.end_pos then
    -- split the text into 3 parts based on the highlight and cursor position
    local text_start_highlight = gstring.xml_escape(text:sub(1, self._private.highlight.start_pos - 1))
    local text_highlighted = gstring.xml_escape(text:sub(self._private.highlight.start_pos,
      self._private.highlight.end_pos))
    local text_end_highlight = gstring.xml_escape(text:sub(self._private.highlight.end_pos + 1))

    return text_start_highlight ..
        "<span foreground='" .. highlight_fg .. "'  background='" .. highlight_bg .. "'>" ..
        text_highlighted .. '</span>' .. text_end_highlight
  else
    return text_start .. "<span background='" .. cursor_bg .. "' foreground='" .. cursor_fg .. "'>" ..
        char .. '</span>' .. text_end .. spacer
  end
end ]]

local function text_extents(text, font, font_size, args)
  local surface = cairo.ImageSurface(cairo.Format.ARGB32, 0, 0)
  local cr = cairo.Context(surface)
  cr:select_font_face(font, args)
  cr:set_font_size(font_size)
  return cr:text_extents(text)
end

--[[
  calculate width/height of the text
  create new surface with the calculated width/height
  draw a vertical line on the surface as the cursor
  the position of the vertical line will be the cursor_pos - text length and the text extend
  draw the "text" .. "cursor" .. "rest of the text"
  return the surface

  mouse_coord holds the coordinates where the user clicked
  if its not empty then draw the cursor where the user clicked,
    if its on a character then set the cursor to the closest space

  if some text is highlighted then draw the text with the highlights
]]
--inputbox.text
--inputbox.cursor_pos <<-- 1 = before the text, 2 = after the first character, 3 = after the second character, etc
--inputbox.highlight <<-- { start_pos, end_pos }
--inputbox.mouse_coord <<-- { x, y } (Will be saved after the user clicked, it will only be overwritten when the user clicks again)
function inputbox:draw_text_surface(x, override_cursor)
  -- x can be 0 for the first time its drawn with a default cursor position
  x = x or 0

  --Colors need to be in rgba 0-1 format, table.unpack is used to unpack the table into function arguments
  local fg, fg_highlight, bg_highlight, fg_cursor = { 1, 1, 1 }, { 1, 1, 1 }, { 0.1, 1, 1, 0.5 }, { 1, 1, 1 }

  -- Main text_entent mainly to align everything to this one (it knows the highest and lowest point of the text)
  local text_extent = text_extents(self:get_text(), self.font, self.font_size, { cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL })

  --The offset if so the user has some space to click on the left and right side of the text
  local start_offset = 4
  local end_offset = 4
  local surface = cairo.ImageSurface(cairo.Format.ARGB32, text_extent.width + start_offset + end_offset, text_extent.height)
  local cr = cairo.Context(surface)

  --Split the text initially into 2 or 3 parts (most likely split again later)
  local text = self:get_text()
  local text_start, text_end, text_highlight
  if self._private.highlight.start_pos ~= self._private.highlight.end_pos then
    text_start = text:sub(1, self._private.highlight.start_pos - 1)
    text_highlight = text:sub(self._private.highlight.start_pos, self._private.highlight.end_pos)
    text_end = text:sub(self._private.highlight.end_pos + 1)
  else
    text_start = text:sub(1, self._private.cursor_pos - 1)
    text_end = text:sub(self._private.cursor_pos)
  end

  --Figure out the cursor position based on the mouse coordinates
  if override_cursor then
    local cursor_pos = 1
    for i = 1, #text, 1 do
      -- Not sure if I need new context's to check the character width but I got inconsistent results without it
      local ccr = cairo.Context(surface)
      ccr:select_font_face(self.font, { cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL })
      ccr:set_font_size(self.font_size)
      local ext_c = ccr:text_extents(text:sub(1, i))
      if ext_c.width >= x then
        local cccr = cairo.Context(surface)
        cccr:select_font_face(self.font, { cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL })
        cccr:set_font_size(self.font_size)
        if math.abs(cccr:text_extents(text:sub(1, i - 1)).width - x) <= math.abs(ext_c.width - x) then
          cursor_pos = i
        else
          cursor_pos = i + 1
        end
        break
      else
        cursor_pos = #text + 1
      end
    end
    self._private.cursor_pos = cursor_pos
  end
  -- Text extents for the start and highlight without any splitting (less calculating, text_end is not needed)
  local text_start_extents = text_extents(text_start, self.font, self.font_size, { cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL })
  local text_highlight_extents = text_extents(text_highlight, self.font, self.font_size, { cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL })

  cr:select_font_face(self.font, cairo.FontSlant.NORMAL, cairo.FontWeight.REGULAR)
  cr:set_font_size(self.font_size)
  --[[
    The following code is a bit of a mess because I have to check if the cursor is inside the highlighted text,
    the text_start or text_end and then split either of them again to draw the cursor between.
  ]]
  if (self._private.cursor_pos > 1) and text_highlight then
    -- If the cursor is inside the highlighted text
    if (self._private.highlight.start_pos <= self._private.cursor_pos) and (self._private.highlight.end_pos >= self._private.cursor_pos) then
      -- Draw the text_start
      cr:set_source_rgb(table.unpack(fg))
      cr:move_to(start_offset, -text_extent.y_bearing)
      cr:show_text(text_start)

      -- split the text_highlight at the cursor_pos
      local text_highlight_start = text_highlight:sub(1, self._private.cursor_pos - self._private.highlight.start_pos)
      local text_highlight_end = text_highlight:sub(self._private.cursor_pos - self._private.highlight.start_pos + 1)
      -- The text_highlight_start extents are needed for the cursor position and the text_highlight_end position
      local text_highlight_start_extents = text_extents(text_highlight_start, self.font, self.font_size, { cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL })

      -- Draw the first highlighted part(text_highlight_start)
      cr:set_source_rgb(table.unpack(fg_highlight))
      cr:move_to(start_offset + text_start_extents.x_advance, -text_extent.y_bearing)
      cr:show_text(text_highlight_start)

      -- Draw the cursor
      cr:set_source_rgb(table.unpack(fg_cursor))
      cr:move_to(start_offset + text_start_extents.x_advance + text_highlight_start_extents.x_advance, text_extent.y_bearing)
      cr:line_to(start_offset + text_start_extents.x_advance + text_highlight_start_extents.x_advance, text_extent.height)
      cr:stroke()

      -- Draw the second highlighted part(text_highlight_end)
      cr:set_source_rgb(table.unpack(fg_highlight))
      cr:move_to(start_offset + text_start_extents.x_advance + text_highlight_start_extents.x_advance, -text_extent.y_bearing)
      cr:show_text(text_highlight_end)

      -- Draw the text_end
      cr:set_source_rgb(table.unpack(fg))
      cr:move_to(start_offset + text_start_extents.x_advance + text_highlight_extents.x_advance, -text_extent.y_bearing)
      cr:show_text(text_end)

      -- Draw the background highlight
      cr:set_source_rgba(table.unpack(bg_highlight))
      cr:rectangle(start_offset + text_start_extents.x_advance, text_extent.y_advance, text_highlight_extents.width, text_extent.height)
      cr:fill()
    elseif self._private.cursor_pos < self._private.highlight.start_pos then -- If its inside the text_start
      -- Split the text_start at the cursor_pos
      local text_start_start = text_start:sub(1, self._private.cursor_pos - 1)
      local text_start_end = text_start:sub(self._private.cursor_pos)
      -- The text_start_start extents is needed for the cursor position and the text_start_end position
      local text_start_start_extents = text_extents(text_start_start, self.font, self.font_size, { cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL })

      -- Draw the first part of the text_start(text_start_start)
      cr:set_source_rgb(table.unpack(fg))
      cr:move_to(start_offset, -text_extent.y_bearing)
      cr:show_text(text_start_start)

      -- Draw the cursor
      cr:set_source_rgb(table.unpack(fg_cursor))
      cr:move_to(start_offset + text_start_start_extents.x_advance, text_extent.y_bearing)
      cr:line_to(start_offset + text_start_start_extents.x_advance, text_extent.height)
      cr:stroke()

      -- Draw the second part of the text_start(text_start_end)
      cr:set_source_rgb(table.unpack(fg))
      cr:move_to(start_offset + text_start_start_extents.x_advance, -text_extent.y_bearing)
      cr:show_text(text_start_end)

      -- Draw the text_highlight
      cr:set_source_rgb(table.unpack(fg_highlight))
      cr:move_to(start_offset + text_start_extents.x_advance, -text_extent.y_bearing)
      cr:show_text(text_highlight)

      -- Draw the text_end
      cr:set_source_rgb(table.unpack(fg))
      cr:move_to(start_offset + text_start_extents.x_advance + text_highlight_extents.x_advance, -text_extent.y_bearing)
      cr:show_text(text_end)

      -- Draw the highlight background
      cr:set_source_rgba(table.unpack(bg_highlight))
      cr:rectangle(start_offset + text_start_extents.x_advance, text_extent.y_advance, text_highlight_extents.width, text_extent.height)
      cr:fill()
    elseif self._private.cursor_pos > self._private.highlight.end_pos then -- If its inside the text_end
      -- Draw the text start
      cr:set_source_rgb(table.unpack(fg))
      cr:move_to(start_offset, -text_extent.y_bearing)
      cr:show_text(text_start)

      -- Draw the text highlight
      cr:set_source_rgb(table.unpack(fg_highlight))
      cr:move_to(start_offset + text_start_extents.x_advance, -text_extent.y_bearing)
      cr:show_text(text_highlight)

      --split the text_end at the cursor_pos
      local text_end_start = text_end:sub(1, self._private.cursor_pos - self._private.highlight.end_pos - 1)
      local text_end_end = text_end:sub(self._private.cursor_pos - self._private.highlight.end_pos)
      -- Text end_start extents needed for the cursor position and the text_end_end
      local text_end_start_extents = text_extents(text_end_start, self.font, self.font_size, { cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL })

      -- Draw the first part of the text_end (text_end_start)
      cr:set_source_rgb(table.unpack(fg))
      cr:move_to(start_offset + text_start_extents.x_advance + text_highlight_extents.x_advance, -text_extent.y_bearing)
      cr:show_text(text_end_start)

      -- Draw the cursor
      cr:set_source_rgb(table.unpack(fg_cursor))
      cr:move_to(start_offset + text_start_extents.x_advance + text_highlight_extents.x_advance + text_end_start_extents.x_advance, text_extent.y_bearing)
      cr:line_to(start_offset + text_start_extents.x_advance + text_highlight_extents.x_advance + text_end_start_extents.x_advance, text_extent.height)
      cr:stroke()

      -- Draw the second part of the text_end (text_end_end)
      cr:set_source_rgb(table.unpack(fg))
      cr:move_to(start_offset + text_start_extents.x_advance + text_highlight_extents.x_advance + text_end_start_extents.x_advance, -text_extent.y_bearing)
      cr:show_text(text_end_end)

      -- Draw the highlight background
      cr:set_source_rgba(table.unpack(bg_highlight))
      cr:rectangle(start_offset + text_start_extents.x_advance, text_extent.y_advance, text_highlight_extents.width, text_extent.height)
      cr:fill()
    end
  else -- If the cursor is all the way to the left no split is needed
    -- text_start
    cr:set_source_rgb(table.unpack(fg))
    cr:move_to(start_offset, -text_extent.y_bearing)
    cr:show_text(text_start)

    -- Cursor
    cr:set_source_rgb(table.unpack(fg_cursor))
    cr:move_to(start_offset + text_start_extents.x_advance, text_extent.y_bearing)
    cr:line_to(start_offset + text_start_extents.x_advance, text_extent.height)
    cr:stroke()

    -- text_highlight
    if text_highlight then
      cr:set_source_rgb(table.unpack(fg_highlight))
      cr:move_to(start_offset + text_start_extents.x_advance, -text_extent.y_bearing)
      cr:show_text(text_highlight)
      cr:set_source_rgba(table.unpack(bg_highlight))
      cr:rectangle(start_offset + text_start_extents.x_advance, text_extent.y_advance, text_highlight_extents.width, text_extent.height)
      cr:fill()
    end

    -- text_end
    cr:set_source_rgb(table.unpack(fg))
    cr:move_to(start_offset + text_highlight_extents.x_advance + text_start_extents.x_advance, -text_extent.y_bearing)
    cr:show_text(text_end)
  end
  return surface
end

function inputbox:layout(_, width, height)
  if self._private.widget then
    return { base.place_widget_at(self._private.widget, 0, 0, width, height) }
  end
end

function inputbox:fit(context, width, height)
  local w, h = 0, 0
  if self._private.widget then
    w, h = base.fit_widget(self, context, self._private.widget, width, height)
  end
  return w, h
end

inputbox.set_widget = base.set_widget_common

--- Clears the current text
function inputbox:clear()
  self:set_text('')
end

function inputbox:get_text()
  return self._private.text or ''
end

function inputbox:set_text(text)
  self._private.text = text
  --self.markup = text_with_cursor(self:get_text(), #self:get_text(), self)
  self:emit_signal('property::text', text)
end

--- Stop the keygrabber and mousegrabber
function inputbox:stop()
  if (not self.akeygrabber) or (not self.akeygrabber.is_running) then return end
  self:emit_signal('stopped')
  self.akeygrabber.stop()
end

function inputbox:focus()
  if (not self.akeygrabber) or (not self.akeygrabber.is_running) then
    akeygrabber.stop()
    self:run()
  end

  self:connect_signal('button::press', function()
    if capi.mouse.current_widget ~= self then
      self:emit_signal('keygrabber::stop', '')
    end
  end)
end

--- Init the inputbox and start the keygrabber
function inputbox:run()
  if not self._private.text then self._private.text = '' end

  -- Init the cursor position, but causes on refocus the cursor to move to the left
  local cursor_pos = self._private.cursor_pos or #self:get_text() + 1

  -- Init and reset(when refocused) the highlight
  self._private.highlight = {}

  self.akeygrabber = akeygrabber {
    autostart = true,
    start_callback = function()
      self:emit_signal('started')
    end,
    stop_callback = function(_, stop_key)
      if stop_key == 'Return' then
        self:emit_signal('submit', self:get_text(), stop_key)
      else
        self:emit_signal('stopped', stop_key)
      end
    end,
    stop_key = { 'Escape', 'Return' },
    keybindings = {
      --lShift, rShift = #50, #62
      --lControl, rControl = #37, #105
      akey {
        modifiers = { 'Shift' },
        key = 'Left', -- left
        on_press = function()
          if cursor_pos > 1 then
            local offset = (self._private.text:sub(cursor_pos - 1, cursor_pos - 1):wlen() == -1) and 1 or 0
            if not self._private.highlight.start_pos then
              self._private.highlight.start_pos = cursor_pos - 1
            end
            if not self._private.highlight.end_pos then
              self._private.highlight.end_pos = cursor_pos
            end

            if self._private.highlight.start_pos < cursor_pos then
              self._private.highlight.end_pos = self._private.highlight.end_pos - 1
            else
              self._private.highlight.start_pos = self._private.highlight.start_pos
            end

            cursor_pos = cursor_pos - 1
          end
          if cursor_pos < 1 then
            cursor_pos = 1
          elseif cursor_pos > #self._private.text + 1 then
            cursor_pos = #self._private.text + 1
          end
          self._private.cursor_pos = cursor_pos
          self.p.widget:get_children_by_id('text_image')[1].image = self:draw_text_surface()
          self:emit_signal('inputbox::key_pressed', 'Shift', 'Left')
        end,
      },
      akey {
        modifiers = { 'Shift' },
        key = 'Right', -- right
        on_press = function()
          if #self._private.text >= cursor_pos then
            if not self._private.highlight.end_pos then
              self._private.highlight.end_pos = cursor_pos - 1
            end
            if not self._private.highlight.start_pos then
              self._private.highlight.start_pos = cursor_pos
            end

            if self._private.highlight.end_pos <= cursor_pos then
              self._private.highlight.end_pos = self._private.highlight.end_pos + 1
            else
              self._private.highlight.start_pos = self._private.highlight.start_pos + 1
            end
            cursor_pos = cursor_pos + 1
            if cursor_pos > #self._private.text + 1 then
              self._private.highlight = {}
            end
          end
          if cursor_pos < 1 then
            cursor_pos = 1
          elseif cursor_pos > #self._private.text + 1 then
            cursor_pos = #self._private.text + 1
          end
          self._private.cursor_pos = cursor_pos
          self.p.widget:get_children_by_id('text_image')[1].image = self:draw_text_surface()
          self:emit_signal('inputbox::key_pressed', 'Shift', 'Right')
        end,
      },
      akey {
        modifiers = { 'Control' },
        key = 'a', -- a
        on_press = function()
          -- Mark the entire text
          self._private.highlight = {
            start_pos = 1,
            end_pos = #self._private.text,
          }
          self.p.widget:get_children_by_id('text_image')[1].image = self:draw_text_surface()
          self:emit_signal('inputbox::key_pressed', 'Control', 'a')
        end,
      },
      akey {
        modifiers = { 'Control' },
        key = 'v', -- v
        on_press = function()
          local sel = capi.selection()
          if sel then
            sel = sel:gsub('\n', '')
            if self._private.highlight and self._private.highlight.start_pos and
                self._private.highlight.end_pos then
              -- insert the text into the selected part
              local text_start = self._private.text:sub(1, self._private.highlight.start_pos - 1)
              local text_end = self._private.text:sub(self._private.highlight.end_pos + 1)
              self:set_text(text_start .. sel .. text_end)
              self._private.highlight = {}
              cursor_pos = #text_start + #sel + 1
            else
              self:set_text(self._private.text:sub(1, cursor_pos - 1) ..
                sel .. self._private.text:sub(cursor_pos))
              cursor_pos = cursor_pos + #sel
            end
          end

          self.p.widget:get_children_by_id('text_image')[1].image = self:draw_text_surface()
          self:emit_signal('inputbox::key_pressed', 'Control', 'v')
        end,
      },
      akey {
        modifiers = { 'Control' },
        key = 'c', -- c
        on_press = function()
          --TODO
        end,
      },
      akey {
        modifiers = { 'Control' },
        key = 'x', -- x
        on_press = function()
          --TODO
        end,
      },
      akey {
        modifiers = { 'Control' },
        key = 'Left', -- left
        on_press = function()
          -- Find all spaces
          local spaces = {}
          local t, i = self._private.text, 0

          while t:find('%s') do
            i = t:find('%s')
            table.insert(spaces, i)
            t = t:sub(1, i - 1) .. '-' .. t:sub(i + 1)
          end

          local cp = 1
          for _, v in ipairs(spaces) do
            if (v < cursor_pos) then
              cp = v
            end
          end
          cursor_pos = cp
          if cursor_pos < 1 then
            cursor_pos = 1
          elseif cursor_pos > #self._private.text + 1 then
            cursor_pos = #self._private.text + 1
          end
          self.p.widget:get_children_by_id('text_image')[1].image = self:draw_text_surface()
          self:emit_signal('inputbox::key_pressed', 'Control', 'Left')
        end,
      },
      akey {
        modifiers = { 'Control' },
        key = 'Right', -- right
        on_press = function()
          local next_space = self._private.text:sub(cursor_pos):find('%s')
          if next_space then
            cursor_pos = cursor_pos + next_space
          else
            cursor_pos = #self._private.text + 1
          end

          if cursor_pos < 1 then
            cursor_pos = 1
          elseif cursor_pos > #self._private.text + 1 then
            cursor_pos = #self._private.text + 1
          end
          self.p.widget:get_children_by_id('text_image')[1].image = self:draw_text_surface()
          self:emit_signal('inputbox::key_pressed', 'Control', 'Right')
        end,
      },
      akey {
        modifiers = {},
        key = 'BackSpace', --BackSpace
        on_press = function()
          -- If text is highlighted delete that, else just delete the character to the left
          if self._private.highlight and self._private.highlight.start_pos and
              self._private.highlight.end_pos then
            local text_start = self._private.text:sub(1, self._private.highlight.start_pos - 1)
            local text_end = self._private.text:sub(self._private.highlight.end_pos + 1)
            self:set_text(text_start .. text_end)
            self._private.highlight = {}
            cursor_pos = #text_start + 1
          else
            if cursor_pos > 1 then
              local offset = (self._private.text:sub(cursor_pos - 1, cursor_pos - 1):wlen() == -1) and 1 or
                  0
              self:set_text(self._private.text:sub(1, cursor_pos - 2 - offset) ..
                self._private.text:sub(cursor_pos))
              cursor_pos = cursor_pos - 1 - offset
            end
          end
          self.p.widget:get_children_by_id('text_image')[1].image = self:draw_text_surface()
          self:emit_signal('inputbox::key_pressed', nil, 'BackSpace')
        end,
      },
      akey {
        modifiers = {},
        key = 'Delete', --delete
        on_press = function()
          -- If text is highlighted delete that, else just delete the character to the right
          if self._private.highlight and self._private.highlight.start_pos and
              self._private.highlight.end_pos then
            local text_start = self._private.text:sub(1, self._private.highlight.start_pos - 1)
            local text_end = self._private.text:sub(self._private.highlight.end_pos + 1)
            self:set_text(text_start .. text_end)
            self._private.highlight = {}
            cursor_pos = #text_start + 1
          else
            if cursor_pos <= #self._private.text then
              self:set_text(self._private.text:sub(1, cursor_pos - 1) ..
                self._private.text:sub(cursor_pos + 1))
            end
          end
          self.p.widget:get_children_by_id('text_image')[1].image = self:draw_text_surface()
          self:emit_signal('inputbox::key_pressed', nil, 'Delete')
        end,
      },
      akey {
        modifiers = {},
        key = 'Left', --left
        on_press = function()
          -- Move cursor ro the left
          if cursor_pos > 1 then
            cursor_pos = cursor_pos - 1
          end
          self._private.highlight = {}
        end,
      },
      akey {
        modifiers = {},
        key = 'Right', --right
        on_press = function()
          -- Move cursor to the right
          if cursor_pos <= #self._private.text then
            cursor_pos = cursor_pos + 1
          end
          self._private.highlight = {}
        end,
      },
      --self.keybindings
    },
    keypressed_callback = function(_, modifiers, key)
      if modifiers[1] == 'Shift' then
        if key:wlen() == 1 then
          self:set_text(self._private.text:sub(1, cursor_pos - 1) ..
            string.upper(key) .. self._private.text:sub(cursor_pos))
          cursor_pos = cursor_pos + #key
        end
      elseif modifiers[1] == 'Mod2' or '' then
        if key:wlen() == 1 then
          self:set_text(self._private.text:sub(1, cursor_pos - 1) ..
            key .. self._private.text:sub(cursor_pos))
          cursor_pos = cursor_pos + #key
        end
      end

      if cursor_pos < 1 then
        cursor_pos = 1
      elseif cursor_pos > #self._private.text + 1 then
        cursor_pos = #self._private.text + 1
      end
      self.p.widget:get_children_by_id('text_image')[1].image = self:draw_text_surface()
      self:emit_signal('inputbox::key_pressed', modifiers, key)
    end,
  }
end

--[[
  take the text and cursor position and figure out which character is next
  if mx is greater than lx then the right character is the next character
  if mx is less than lx then the left character is the next character

  calculate the delta between mx and lx, if the delta is greater than the next
  character increase or decrease the cursor position by 1 (depends if the delta is positive or negative)
  and set the lx = mx

  return 1 if advanced to the right, -1 if advanced to the left, 0 if not advanced; and the new lx
]]
function inputbox:advanced_by_character(mx, lx)
  local delta = mx - lx
  local character
  if delta < 0 then
    character = self._private.text:sub(self._private.cursor_pos + 1, self._private.cursor_pos + 1)
  else
    character = self._private.text:sub(self._private.cursor_pos - 1, self._private.cursor_pos - 1)
  end

  --local character = (self._private.text:sub(self._private.cursor_pos + 1, self._private.cursor_pos + 1) and (delta < 0)) or self._private.text:sub(self._private.cursor_pos - 1, self._private.cursor_pos - 1)
  if character then
    local cr = cairo.Context(cairo.ImageSurface(cairo.Format.ARGB32, 1, 1))
    cr:select_font_face(self.font, cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL)
    cr:set_font_size(self.font_size)
    local extents = cr:text_extents(character)
    if math.abs(delta) >= extents.x_advance then
      self._private.cursor_pos = self._private.cursor_pos + (((delta > 0) and 1) or -1)
      lx = mx
      return (((delta > 0) and 1) or -1), lx
    end
  end
  return 0, lx
end

--- Creates a new inputbox widget
-- @tparam table args Arguments for the inputbox widget
-- @tparam string args.text The text to display in the inputbox
-- @tparam[opt=beautiful.fg_normal] string args.fg Text foreground color
-- @tparam[opt=beautiful.border_focus] string args.border_focus_color Border color when focused
-- @tparam[opt=""] string args.placeholder_text placeholder text to be shown when not focused and
-- @tparam[opt=beautiful.inputbox_placeholder_fg] string args.placeholder_fg placeholder text foreground color
-- @tparam[opt=beautiful.inputbox_cursor_bg] string args.cursor_bg Cursor background color
-- @tparam[opt=beautiful.inputbox_cursor_fg] string args.cursor_fg Cursor foreground color
-- @tparam[opt=beautiful.inputbox_highlight_bg] string args.highlight_bg Highlight background color
-- @tparam[opt=beautiful.inputbox_highlight_fg] string args.highlight_fg Highlight foreground color
-- @treturn awful.widget.inputbox The inputbox widget.
-- @constructorfct awful.widget.inputbox
function inputbox.new(args)
  args = args or {}

  -- directly pass a possible default text(this is not meant to be a hint)
  local w = imagebox()

  --gtable.crush(w, args)
  gtable.crush(w, inputbox, true)
  w._private = {}

  w._private.text = args.text or ''
  w.font_size = 24
  w.font = User_config.font.regular
  w._private.cursor_pos = args.cursor_pos
  w._private.highlight = args.highlight

  w.p = apopup {
    widget = {
      {
        image = w:draw_text_surface(),
        resize = false,
        valign = 'bottom',
        halign = 'center',
        widget = wibox.widget.imagebox,
        id = 'text_image',
      },
      widget = wibox.container.margin,
      margins = 20,
    },
    bg = '#212121',
    visible = true,
    screen = 1,
    placement = aplacement.centered,
  }

  w.p.widget:get_children_by_id('text_image')[1]:buttons(gtable.join {
    abutton({}, 1, function()
      -- Get the mouse coordinates realative to the widget
      local x, y = mouse.coords().x - p.x - 20, mouse.coords().y - p.y - 20 -- 20 is the margin on either side
      p.widget:get_children_by_id('text_image')[1].image = w:draw_text_surface(x, false)
      w.highlight = { start_pos = w.cursor_pos, end_pos = w.cursor_pos }
      p.widget:get_children_by_id('text_image')[1].image = w:draw_text_surface(x, false)
      if not mousegrabber.isrunning() then
        local last_x, advanced, cursor_pos, mx = x, nil, w.cursor_pos, nil
        mousegrabber.run(function(m)
          mx = m.x - p.x - 20
          if (math.abs(mx - x) > 5) then
            -- Returns 1 if the mouse has advanced to the right, -1 if it has advanced to the left
            advanced, last_x = w:advanced_by_character(mx, last_x)
            if advanced == 1 then
              print(cursor_pos, w.highlight.start_pos, w.highlight.end_pos)
              if cursor_pos <= w.highlight.start_pos then
                if w.highlight.end_pos < #w._private.text then
                  w.highlight.end_pos = w.highlight.end_pos + 1
                end
              else
                w.highlight.start_pos = w.highlight.start_pos + 1
              end
              p.widget:get_children_by_id('text_image')[1].image = w:draw_text_surface(x, true)
              print(w.highlight.start_pos, w.highlight.end_pos)
            elseif advanced == -1 then
              if cursor_pos >= w.highlight.end_pos then
                if w.highlight.start_pos > 1 then
                  w.highlight.start_pos = w.highlight.start_pos - 1
                end
              else
                w.highlight.end_pos = w.highlight.end_pos - 1
              end
              p.widget:get_children_by_id('text_image')[1].image = w:draw_text_surface(x, true)
              print(w.highlight.start_pos, w.highlight.end_pos)
            end
          end

          return m.buttons[1]
        end, 'xterm')
      end
      w:run()
    end),
  })

  --w.font = args.font or beautiful.font

  --w.keybindings = args.keybindings or {}
  --w.hint_text = args.hint_text

  --w.markup = args.text or text_with_cursor('', 1, w)
  return w
end

function inputbox.mt:__call(...)
  return inputbox.new(...)
end

return setmetatable(inputbox, inputbox.mt)
