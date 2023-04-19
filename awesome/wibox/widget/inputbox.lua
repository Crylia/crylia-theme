---------------------------------------------------------------------------
-- A widget to write text in
--@DOC_wibox_widget_defaults_inputtextbox_EXAMPLE@
--
-- @author Rene Kievits
-- @copyright 2022 Rene Kievits
-- @widgetmod wibox.widget.inputbox
-- @supermodule wibox.widget.textbox
---------------------------------------------------------------------------

local base = require('wibox.widget.base')
local gdebug = require('gears.debug')
local gfs = require('gears.filesystem')
local gobject = require('gears.object')
local gstring = require('gears.string')
local beautiful = require('beautiful')
local keygrabber = require('awful.keygrabber')
local lgi = require('lgi')
local gtable = require('gears.table')
local wibox = require('wibox')
local abutton = require('awful.button')
local setmetatable = setmetatable

local capi =
{
    selection = selection,
    mousegrabber = mousegrabber,
    mouse = mouse,
}

local inputbox = { mt = {} }

local function text_with_cursor(text, cursor_pos, self)
    local char, spacer, text_start, text_end

    local cursor_fg = beautiful.inputbox_cursor_fg or beautiful.colorscheme.bg1
    local cursor_bg = beautiful.inputbox_cursor_bg or beautiful.colorscheme.bg_blue
    local text_color = beautiful.inputbox_fg or beautiful.colorscheme.fg
    local placeholder_text = beautiful.inputbox_placeholder_text or 'Type here...'
    local placeholder_fg = beautiful.inputbox_placeholder_fg or beautiful.colorscheme.bg2
    local highlight_bg = beautiful.inputbox_highlight_bg or beautiful.fg
    local highlight_fg = beautiful.inputbox_highlight_fg or beautiful.bg

    if text == '' then
        return "<span foreground='" .. placeholder_fg .. "'>" .. placeholder_text .. '</span>'
    end

    if #text < cursor_pos then
        char = ' '
        spacer = ''
        text_start = gstring.xml_escape(text)
        text_end = ''
    else
        local offset = 0
        if #text:sub(cursor_pos, cursor_pos) == -1 then
            offset = 1
        end
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

        return "<span foreground='" .. text_color .. "'>" .. text_start_highlight .. '</span>' ..
            "<span foreground='" .. highlight_fg .. "'  background='" .. highlight_bg .. "'>" ..
            text_highlighted ..
            '</span>' .. "<span foreground='" .. text_color .. "'>" .. text_end_highlight .. '</span>'
    else
        return "<span foreground='" .. text_color .. "'>" .. text_start .. '</span>' ..
            "<span background='" .. cursor_bg .. "' foreground='" .. cursor_fg .. "'>" ..
            char .. '</span>' .. "<span foreground='" .. text_color .. "'>" .. text_end .. spacer .. '</span>'
    end
end

--- Clears the current text
function inputbox:clear()
    self:set_text('')
end

function inputbox:get_text()
    return self._private.text or ''
end

function inputbox:set_text(text)
    self._private.text = text
    self:emit_signal('property::text', text)
end

--- Stop the keygrabber and mousegrabber
function inputbox:stop()
    self:emit_signal('stopped')
    keygrabber.stop()
    capi.mousegrabber.stop()
end

function inputbox:focus()
    keygrabber.stop()
    if not keygrabber.is_running then
        self:run()
    end

    -- Stops the mousegrabber when not clicked on the widget
    --[[ capi.mousegrabber.run(
        function(m)
            if m.buttons[1] then
                if capi.mouse.current_wibox ~= self:get_widget().widget then
                    self:emit_signal("keygrabber::stop", "")
                    return false
                end
            end
            return true
        end, "left_ptr"
    ) ]]

    self:connect_signal('button::press', function()
        if capi.mouse.current_widget ~= self then
            self:emit_signal('keygrabber::stop', '')
        end
    end)
end

function inputbox:run()

    if not self._private.text then self._private.text = '' end

    -- Init the cursor position, but causes on refocus the cursor to move to the left
    local cursor_pos = #self:get_text() + 1

    self:emit_signal('started')

    -- Init and reset(when refocused) the highlight
    self._private.highlight = {}

    -- Emitted when the keygrabber is stopped
    self:connect_signal('cancel', function()
        self:stop()
        self:emit_signal('stopped')
    end)

    -- Emitted when the keygrabber should submit the text
    self:connect_signal('submit', function(text)
        self:stop()
        self:emit_signal('stopped', text)
    end)

    self:emit_signal('key_pressed', 'B', 'A')


    keygrabber.run(function(mod, key, event)
        local mod_keys = {}
        for _, v in ipairs(mod) do
            mod_keys[v] = true
        end

        if not (event == 'press') then return end
        --Escape cases
        -- Just quit and leave the text as is
        if (not mod_keys.Control) and (key == 'Escape') then
            self:emit_signal('cancel')
        elseif (not mod_keys.Control and key == 'KP_Enter') or (not mod_keys.Control and key == 'Return') then
            self:emit_signal('submit', self:get_text())
            self:set_text('')
        end

        -- All shift, control or key cases
        if mod_keys.Shift then
            if key == 'Left' then
                if cursor_pos > 1 then
                    if not self._private.highlight.cur_pos_start then
                        self._private.highlight.cur_pos_start = cursor_pos - 1
                    end
                    if not self._private.highlight.cur_pos_end then
                        self._private.highlight.cur_pos_end = cursor_pos
                    end

                    if self._private.highlight.cur_pos_start < cursor_pos then
                        self._private.highlight.cur_pos_end = self._private.highlight.cur_pos_end - 1
                    else
                        self._private.highlight.cur_pos_start = self._private.highlight.cur_pos_start - 1
                    end

                    cursor_pos = cursor_pos - 1
                end
            elseif key == 'Right' then
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
            else
                if key:wlen() == 1 then
                    self:set_text(self._private.text:sub(1, cursor_pos - 1) ..
                        string.upper(key) .. self._private.text:sub(cursor_pos))
                    cursor_pos = cursor_pos + 1
                end
            end
        elseif mod_keys.Control then
            if key == 'a' then
                -- Mark the entire text
                self._private.highlight = {
                    cur_pos_start = 1,
                    cur_pos_end = #self._private.text,
                }
            elseif key == 'c' then
                -- TODO: Copy the highlighted text when the selection setter gets implemented
            elseif key == 'v' then
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
            elseif key == 'x' then
                --TODO: "cut". Copy selected then clear text, this requires to add the c function first.
                self._private.highlight = {}
            elseif key == 'Left' then
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
            elseif key == 'Right' then
                local next_space = self._private.text:sub(cursor_pos):find('%s')
                if next_space then
                    cursor_pos = cursor_pos + next_space
                else
                    cursor_pos = #self._private.text + 1
                end
            end
        else
            if key == 'BackSpace' then
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
                        self:set_text(self._private.text:sub(1, cursor_pos - 2) ..
                            self._private.text:sub(cursor_pos))
                        cursor_pos = cursor_pos - 1
                    end
                end
            elseif key == 'Delete' then
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
            elseif key == 'Left' then
                -- Move cursor ro the left
                if cursor_pos > 1 then
                    cursor_pos = cursor_pos - 1
                end
                self._private.highlight = {}
            elseif key == 'Right' then
                -- Move cursor to the right
                if cursor_pos <= #self._private.text then
                    cursor_pos = cursor_pos + 1
                end
                self._private.highlight = {}
            else
                -- Print every alphanumeric key
                -- It seems like gears.xmlescape doesn't support non alphanumeric characters
                if key:wlen() == 1 then
                    self:set_text(self._private.text:sub(1, cursor_pos - 1) ..
                        key .. self._private.text:sub(cursor_pos))
                    cursor_pos = cursor_pos + #key
                end
            end

            -- Make sure the cursor cannot go out of bounds
            if cursor_pos < 1 then
                cursor_pos = 1
            elseif cursor_pos > #self._private.text + 1 then
                cursor_pos = #self._private.text + 1
            end
        end
        -- Update cycle
        self.text = text_with_cursor(self:get_text(), cursor_pos, self)

        -- using self:emit_signal... results in nil tables beeing send
        awesome.emit_signal('inputbox::key_pressed', mod_keys, key)
    end)
end

function inputbox.new(args)
    args = args or {}

    local w = wibox.widget.textbox(args.text or '')

    gtable.crush(w, inputbox, true)

    w:buttons(
        gtable.join {
            abutton({}, 1, function()
                w:focus()
            end),
            abutton({}, 3, function()
                -- TODO: Figure out how to paste with highlighted support
                -- Maybe with a signal?
            end),
        }
    )

    -- Change the cursor to "xterm" on hover over
    local old_cursor, old_wibox
    w:connect_signal(
        'mouse::enter',
        function()
            local wid = capi.mouse.current_wibox
            if wid then
                old_cursor, old_wibox = wid.cursor, wid
                wid.cursor = 'xterm'
            end
        end
    )

    -- Change the cursor back once leaving the widget
    w:connect_signal(
        'mouse::leave',
        function()
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    )

    w.text = text_with_cursor('', 1, w)


    return w
end

function inputbox.mt:__call(...)
    return inputbox.new(...)
end

return setmetatable(inputbox, inputbox.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
