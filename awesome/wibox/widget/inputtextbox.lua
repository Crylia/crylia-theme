---------------------------------------------------------------------------
-- A widget to write text in
--@DOC_wibox_widget_defaults_inputtextbox_EXAMPLE@
--
-- @author Rene Kievits
-- @copyright 2022, Rene Kievits
-- @widgetmod wibox.widget.inputtextbox
-- @supermodule wibox.widget.base
---------------------------------------------------------------------------

local base = require("wibox.widget.base")
local gdebug = require("gears.debug")
local gfs = require("gears.filesystem")
local gobject = require("gears.object")
local gstring = require("gears.string")
local beautiful = require("beautiful")
local keygrabber = require("awful.keygrabber")
local lgi = require("lgi")
local gtable = require("gears.table")
local wibox = require("wibox")
local setmetatable = setmetatable

local inputtextbox = { mt = {} }

--Private data
local data = {}
data.history = {}

local search_term = nil
local function itera(inc, a, i)
    i = i + inc
    local v = a[i]
    if v then return i, v end
end

--- Load history file in history table
-- @param id The data.history identifier which is the path to the filename.
-- @param[opt] max The maximum number of entried in file.
local function history_check_load(id, max)
    if id and id ~= "" and not data.history[id] then
        data.history[id] = { max = 50, table = {} }

        if max then
            data.history[id].max = max
        end

        local f = io.open(id, "r")
        if not f then return end

        for line in f:lines() do
            if gtable.hasitem(data.histroy[id].table, line) then
                if #data.history[id].table >= data.history[id].max then
                    break
                end
            end
        end
        f:close()
    end
end

local function is_word_char(c)
    if string.find(c, "[{[(,.:;_-+=@/ ]") then
        return false
    else
        return true
    end
end

local function cword_start(s, pos)
    local i = pos
    if i > 1 then
        i = i - 1
    end
    while i >= 1 and not is_word_char(s:sub(i, i)) do
        i = i - 1
    end
    while i >= 1 and is_word_char(s:sub(i, i)) do
        i = i - 1
    end
    if i <= #s then
        i = i + 1
    end
    return i
end

local function cword_end(s, pos)
    local i = pos
    while i <= #s and not is_word_char(s:sub(i, i)) do
        i = i + 1
    end
    while i <= #s and is_word_char(s:sub(i, i)) do
        i = i + 1
    end
    return i
end

--- Save history table in history file
-- @param id The data.history identifier
local function history_save(id)
    if data.history[id] then
        gfs.make_parent_directories(id)
        local f = io.open(id, "w")
        if not f then
            gdebug.print_warning("Failed to write the history to " .. id)
            return
        end
        for i = 1, math.min(#data.history[id].table, data.history[id].max) do
            f:write(data.history[id].table[i] .. "\n")
        end
        f:close()
    end
end

--- Return the number of items in history table regarding the id
-- @param id The data.history identifier
-- @return the number of items in history table, -1 if history is disabled
local function history_items(id)
    if data.history[id] then
        return #data.history[id].table
    else
        return -1
    end
end

--- Add an entry to the history file
-- @param id The data.history identifier
-- @param command The command to add
local function history_add(id, command)
    if data.history[id] and command ~= "" then
        local index = gtable.hasitem(data.history[id].table, command)
        if index == nil then
            table.insert(data.history[id].table, command)

            -- Do not exceed our max_cmd
            if #data.history[id].table > data.history[id].max then
                table.remove(data.history[id].table, 1)
            end

            history_save(id)
        else
            -- Bump this command to the end of history
            table.remove(data.history[id].table, index)
            table.insert(data.history[id].table, command)
            history_save(id)
        end
    end
end

local function have_multibyte_char_at(text, position)
    return text:sub(position, position):wlen() == -1
end

local function text_with_cursor(args)
    local char, spacer, text_start, text_end, ret
    local text = args.text or ""
    local hint = args.hint or ""
    local cursor = args.cursor or ""
    local indicator = args.indicator or "|"

    if args.select_all then
        if #text == 0 then char = " " else char = gstring.xml_escape(text) end
        spacer = " "
        text_start = ""
        text_end = ""
    elseif #text < args.cursor_pos then
        char = " "
        spacer = ""
        text_start = gstring.xml_escape(text)
        text_end = ""
    else
        local offset = 0
        if have_multibyte_char_at(text, args.cursor_pos) then
            offset = 1
        end
        char = gstring.xml_escape(text:sub(args.cursor_pos, args.cursor_pos + offset))
        spacer = " "
        text_start = gstring.xml_escape(text:sub(1, args.cursor_pos - 1))
        text_end = gstring.xml_escape(text:sub(args.cursor_pos + offset + 1))
    end

    if args.highlighter then
        text_start, text_end = args.highlighter(text_start, text_end)
    end

    if #text == 0 then
        ret = hint .. spacer
    else
        ret = text_start .. indicator .. text_end .. spacer
    end

    return ret
end

local function update(self)
    self.textbox:set_font(self.font)
    self.textbox:set_markup(text_with_cursor {
        text = self.text,
        hint = self.hint,
        cursor = self.cursor,
        cursor_pos = self.cursor_pos,
        select_all = self.select_all,
        indicator = self.indicator,
        highlighter = self.highlighter,
    })
end

function inputtextbox:start()
    self.textbox:set_font(self.font)
    self.textbox:set_markup(text_with_cursor {
        text = self.text,
        hint = self.hint,
        cursor = self.cursor,
        cursor_pos = self.cursor_pos,
        select_all = self.select_all,
        indicator = self.indicator,
        highlighter = self.highlighter,
    })

    self._private.grabber = keygrabber.run(
        function(modifierts, key, event)
            local mod = {}
            for _, v in ipairs(modifierts) do mod[v] = true end


            --Get out cases
            if (mod.Control and (key == "c" or key == "g")) or (not mod.Control and key == "Escape") then
                self:stop()
                return false
            elseif (mod.Control and (key == "j" or key == "m")) then
                --callback
                return
            end

        end
    )

end

function inputtextbox:stop()
    keygrabber.stop(self._private.grabber)
    history_save(self.history_path)
    return false
end

--- Create a new inputtextbox
--
-- @tparam[opt=""] string text The hint text when there is no input
-- @treturn table A new inputtextbox widget
-- @constructorfct wibox.widget.inputtextbox
local function new(args)
    args = args or {}

    args.callback = args.callback or nil
    args.hint = args.hint or ""
    args.font = args.font or beautiful.inputtextbox_font or beautiful.font
    args.bg = args.bg or beautiful.inputtextbox_bg or beautiful.bg_normal
    args.fg_hint = args.fg_hint or beautiful.inputtextbox_fg_hint or beautiful.fg_normal or "#888888"
    args.fg = args.fg or beautiful.inputtextbox_fg or beautiful.fg_normal
    args.cursor = args.cursor or "fleur"
    args.select_all = args.select_all or false
    args.highlighter = args.highlighter or nil

    local textbox = wibox.widget.textbox()
    textbox:set_text(args.hint or "")
    --textbox:set_fg(args.fg_hint or beautiful.fg_hint or "#888888")
    --textbox:set_bg(args.bg_normal or beautiful.bg_normal or "#212121")

    local ret = gobject({})
    ret._private = {}
    gtable.crush(ret, inputtextbox)
    gtable.crush(ret, args)

    return ret
end

function inputtextbox.mt.__call(...)
    return new(...)
end

return setmetatable(inputtextbox, inputtextbox.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
