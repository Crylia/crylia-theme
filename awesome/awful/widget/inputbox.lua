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

local capi = {
    selection = selection,
    mousegrabber = mousegrabber,
    mouse = mouse,
}

local inputbox = { mt = {} }

--- Formats the text with a cursor and highlights if set.
local function text_with_cursor(text, cursor_pos, self)
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

    if self._private.highlight and self._private.highlight.cur_pos_start and self._private.highlight.cur_pos_end then
        -- split the text into 3 parts based on the highlight and cursor position
        local text_start_highlight = gstring.xml_escape(text:sub(1, self._private.highlight.cur_pos_start - 1))
        local text_highlighted = gstring.xml_escape(text:sub(self._private.highlight.cur_pos_start,
            self._private.highlight.cur_pos_end))
        local text_end_highlight = gstring.xml_escape(text:sub(self._private.highlight.cur_pos_end + 1))

        return text_start_highlight ..
            "<span foreground='" .. highlight_fg .. "'  background='" .. highlight_bg .. "'>" ..
            text_highlighted .. '</span>' .. text_end_highlight
    else
        return text_start .. "<span background='" .. cursor_bg .. "' foreground='" .. cursor_fg .. "'>" ..
            char .. '</span>' .. text_end .. spacer
    end
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
    self.markup = text_with_cursor(self:get_text(), #self:get_text(), self)
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
    local cursor_pos = #self:get_text() + 1

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
                        if not self._private.highlight.cur_pos_start then
                            self._private.highlight.cur_pos_start = cursor_pos - 1
                        end
                        if not self._private.highlight.cur_pos_end then
                            self._private.highlight.cur_pos_end = cursor_pos
                        end

                        if self._private.highlight.cur_pos_start < cursor_pos then
                            self._private.highlight.cur_pos_end = self._private.highlight.cur_pos_end - 1
                        else
                            self._private.highlight.cur_pos_start = self._private.highlight.cur_pos_start
                        end

                        cursor_pos = cursor_pos - 1
                    end
                    if cursor_pos < 1 then
                        cursor_pos = 1
                    elseif cursor_pos > #self._private.text + 1 then
                        cursor_pos = #self._private.text + 1
                    end
                    self.markup = text_with_cursor(self:get_text(), cursor_pos, self)
                    self:emit_signal('inputbox::key_pressed', 'Shift', 'Left')
                end,
            },
            akey {
                modifiers = { 'Shift' },
                key = 'Right', -- right
                on_press = function()
                    if #self._private.text >= cursor_pos then
                        if not self._private.highlight.cur_pos_end then
                            self._private.highlight.cur_pos_end = cursor_pos - 1
                        end
                        if not self._private.highlight.cur_pos_start then
                            self._private.highlight.cur_pos_start = cursor_pos
                        end

                        if self._private.highlight.cur_pos_end <= cursor_pos then
                            self._private.highlight.cur_pos_end = self._private.highlight.cur_pos_end + 1
                        else
                            self._private.highlight.cur_pos_start = self._private.highlight.cur_pos_start + 1
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
                    self.markup = text_with_cursor(self:get_text(), cursor_pos, self)
                    self:emit_signal('inputbox::key_pressed', 'Shift', 'Right')
                end,
            },
            akey {
                modifiers = { 'Control' },
                key = 'a', -- a
                on_press = function()
                    -- Mark the entire text
                    self._private.highlight = {
                        cur_pos_start = 1,
                        cur_pos_end = #self._private.text,
                    }
                    self.markup = text_with_cursor(self:get_text(), cursor_pos, self)
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
                        if self._private.highlight and self._private.highlight.cur_pos_start and
                            self._private.highlight.cur_pos_end then
                            -- insert the text into the selected part
                            local text_start = self._private.text:sub(1, self._private.highlight.cur_pos_start - 1)
                            local text_end = self._private.text:sub(self._private.highlight.cur_pos_end + 1)
                            self:set_text(text_start .. sel .. text_end)
                            self._private.highlight = {}
                            cursor_pos = #text_start + #sel + 1
                        else
                            self:set_text(self._private.text:sub(1, cursor_pos - 1) ..
                                sel .. self._private.text:sub(cursor_pos))
                            cursor_pos = cursor_pos + #sel
                        end
                    end

                    self.markup = text_with_cursor(self:get_text(), cursor_pos, self)
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
                    self.markup = text_with_cursor(self:get_text(), cursor_pos, self)
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
                    self.markup = text_with_cursor(self:get_text(), cursor_pos, self)
                    self:emit_signal('inputbox::key_pressed', 'Control', 'Right')
                end,
            },
            akey {
                modifiers = {},
                key = 'BackSpace', --BackSpace
                on_press = function()
                    -- If text is highlighted delete that, else just delete the character to the left
                    if self._private.highlight and self._private.highlight.cur_pos_start and
                        self._private.highlight.cur_pos_end then
                        local text_start = self._private.text:sub(1, self._private.highlight.cur_pos_start - 1)
                        local text_end = self._private.text:sub(self._private.highlight.cur_pos_end + 1)
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
                    self.markup = text_with_cursor(self:get_text(), cursor_pos, self)
                    self:emit_signal('inputbox::key_pressed', nil, 'BackSpace')
                end,
            },
            akey {
                modifiers = {},
                key = 'Delete', --delete
                on_press = function()
                    -- If text is highlighted delete that, else just delete the character to the right
                    if self._private.highlight and self._private.highlight.cur_pos_start and
                        self._private.highlight.cur_pos_end then
                        local text_start = self._private.text:sub(1, self._private.highlight.cur_pos_start - 1)
                        local text_end = self._private.text:sub(self._private.highlight.cur_pos_end + 1)
                        self:set_text(text_start .. text_end)
                        self._private.highlight = {}
                        cursor_pos = #text_start + 1
                    else
                        if cursor_pos <= #self._private.text then
                            self:set_text(self._private.text:sub(1, cursor_pos - 1) ..
                                self._private.text:sub(cursor_pos + 1))
                        end
                    end
                    self.markup = text_with_cursor(self:get_text(), cursor_pos, self)
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
            self.markup = text_with_cursor(self:get_text(), cursor_pos, self)
            self:emit_signal('inputbox::key_pressed', modifiers, key)
        end,
    }
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
    local w = textbox()

    --gtable.crush(w, args)
    gtable.crush(w, inputbox, true)

    w.font = args.font or beautiful.font

    w.keybindings = args.keybindings or {}
    w.hint_text = args.hint_text

    w.markup = args.text or text_with_cursor('', 1, w)
    return w
end

function inputbox.mt:__call(...)
    return inputbox.new(...)
end

return setmetatable(inputbox, inputbox.mt)
