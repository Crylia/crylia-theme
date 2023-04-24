local abutton = require('awful.button')
local akey = require('awful.key')
local akeygrabber = require('awful.keygrabber')
local aplacement = require('awful.placement')
local apopup = require('awful.popup')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gtable = require('gears.table')
local gtimer = require('gears.timer')
local wibox = require('wibox')
local gobject = require('gears.object')
local Gio = require('lgi').Gio
local gfilesystem = require('gears.filesystem')
local gcolor = require('gears.color')

local fzy = require('fzy')

local hover = require('src.tools.hover')
local inputbox = require('src.modules.inputbox')
local context_menu = require('src.modules.context_menu')
local config = require('src.tools.config')
local icon_lookup = require('src.tools.gio_icon_lookup')
local dock = require('src.modules.crylia_bar.dock')

local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/context_menu/'

local capi = {
  awesome = awesome,
  mouse = mouse,
}

local launcher = gobject {}

function launcher:fetch_apps()
  for _, app in ipairs(Gio.AppInfo.get_all()) do
    local app_id = app:get_id()
    if app:should_show() and not self.app_table[app_id] then
      local GDesktopAppInfo = Gio.DesktopAppInfo.new(app_id)
      local app_icon = app:get_icon()
      local app_name = app:get_name()

      local w = wibox.widget {
        {
          {
            {
              {
                { -- Icon
                  valign = 'center',
                  halign = 'center',
                  image = icon_lookup:get_gicon_path(app_icon)
                      or icon_lookup:get_gicon_path(app_icon, GDesktopAppInfo:get_string('X-AppImage-Old-Icon'))
                      or '',
                  resize = true,
                  widget = wibox.widget.imagebox,
                },
                height = dpi(64),
                width = dpi(64),
                strategy = 'exact',
                widget = wibox.container.constraint,
              },
              {
                { -- Name
                  text = app_name,
                  halign = 'center',
                  valign = 'center',
                  widget = wibox.widget.textbox,
                },
                strategy = 'exact',
                width = dpi(170),
                -- Prevents widget from overflowing
                height = dpi(40),
                widget = wibox.container.constraint,
              },
              layout = wibox.layout.fixed.vertical,
            },
            widget = wibox.container.place,
          },
          margins = dpi(10),
          widget = wibox.container.margin,
        },
        widget = wibox.container.background,
        shape = beautiful.shape[4],
        fg = beautiful.colorscheme.fg,
        bg = beautiful.colorscheme.bg1,
        border_color = beautiful.colorscheme.border_color,
        border_width = dpi(2),

        name = app_name,
        keywords = GDesktopAppInfo:get_string('Keywords'),
        categories = GDesktopAppInfo:get_categories(),
        execute = function()
          app:launch_uris_async()
        end,
      }

      hover.bg_hover { widget = w }

      local cm = context_menu {
        widget_template = wibox.widget {
          {
            {
              {
                {
                  widget = wibox.widget.imagebox,
                  resize = true,
                  valign = 'center',
                  halign = 'center',
                  id = 'icon_role',
                },
                widget = wibox.container.constraint,
                stragety = 'exact',
                width = dpi(24),
                height = dpi(24),
                id = 'const',
              },
              {
                widget = wibox.widget.textbox,
                valign = 'center',
                halign = 'left',
                id = 'text_role',
              },
              layout = wibox.layout.fixed.horizontal,
            },
            widget = wibox.container.margin,
          },
          fg = beautiful.colorscheme.fg,
          widget = wibox.container.background,
        },
        spacing = dpi(10),
        entries = {
          {
            name = 'Launch',
            icon = gcolor.recolor_image(icondir .. 'launch.svg', beautiful.colorscheme.bg_purple),
            callback = function()
              self:toggle(capi.mouse.screen)
              app:launch_uris_async()
            end,
          },
          {
            name = 'Add to Desktop',
            icon = gcolor.recolor_image(icondir .. 'desktop.svg', beautiful.colorscheme.bg_purple),
            callback = function()
              --TODO: Replace desktop:add_to_desktop() once rewritten
              capi.awesome.emit_signal('desktop::add_to_desktop', {
                label = app_name,
                icon = icon_lookup:get_gicon_path(app:get_icon()) or '',
                exec = GDesktopAppInfo:get_string('Exec'),
                desktop_file = GDesktopAppInfo:get_filename() or '',
              })
            end,
          },
          {
            name = 'Pin to Dock',
            icon = gcolor.recolor_image(icondir .. 'pin.svg', beautiful.colorscheme.bg_purple),
            callback = function()
              dock:get_dock_for_screen(capi.mouse.screen):pin_element {
                desktop_file = GDesktopAppInfo:get_filename(),
              }
            end,
          },
        },
      }

      cm:connect_signal('mouse::leave', function()
        cm.visible = false
      end)

      w:buttons(gtable.join {
        abutton {
          modifiers = {},
          button = 1,
          on_release = function()
            app.launch_uris_async(app)
            akeygrabber.stop()
            self.searchbar:set_text('')
            self:filter_apps('')
            self:toggle(capi.mouse.screen)
          end,
        },
        abutton {
          modifiers = {},
          button = 3,
          on_release = function()
            cm:toggle()
          end,
        },
      })
      self.app_table[app_id] = w
    end
  end
end

local function levenshtein_distance(str1, str2)
  local len1 = string.len(str1)
  local len2 = string.len(str2)
  local matrix = {}
  local cost = 0

  if (len1 == 0) then
    return len2
  elseif (len2 == 0) then
    return len1
  elseif (str1 == str2) then
    return 0
  end

  for i = 0, len1, 1 do
    matrix[i] = {}
    matrix[i][0] = i
  end
  for j = 0, len2, 1 do
    matrix[0][j] = j
  end

  for i = 1, len1, 1 do
    for j = 1, len2, 1 do
      if str1:byte(i) == str2:byte(j) then
        cost = 0
      else
        cost = 1
      end

      matrix[i][j] = math.min(
        matrix[i - 1][j] + 1,
        matrix[i][j - 1] + 1,
        matrix[i - 1][j - 1] + cost
      )
    end
  end

  return matrix[len1][len2]
end

function launcher:filter_apps(filter)
  filter = filter or ''
  self.grid:reset()
  local app_list = {}
  for _, app in pairs(self.app_table) do
    if filter == ''
        or fzy.has_match(filter, app.name)
        or fzy.has_match(filter, app.category or '')
        or fzy.has_match(filter, app.keywords or '')
    then
      table.insert(app_list, app)
    end
  end
  table.sort(app_list, function(a, b)
    return a.name < b.name
  end)
  --sort by lowest levenshtein distance
  table.sort(app_list, function(a, b)
    return levenshtein_distance(filter, a.name) < levenshtein_distance(filter, b.name)
  end)
  for _, app in ipairs(app_list) do
    self.grid:add(app)
  end
end

function launcher:toggle(screen)
  if not self.popup.visible then
    self.popup.screen = screen
    self.grid.forced_num_cols = math.floor((screen.geometry.width / 100 * 60) / 200)
    self:focus_searchbar()
    self.popup.widget:get_children_by_id('overflow')[1]:set_scroll_factor(0)
    self.popup.visible = true
  else
    self.cursor = {
      x = 1, y = 1,
    }
    self.popup.visible = false
  end
end

function launcher:selection_remove(x, y)
  self.grid:get_widgets_at(y, x)[1].border_color = beautiful.colorscheme.border_color
end

function launcher:selection_update(x, y)
  local w_old = self.grid:get_widgets_at(y, x)[1]
  local w_new = self.grid:get_widgets_at(self.cursor.y, self.cursor.x)[1]
  w_old.border_color = beautiful.colorscheme.border_color
  w_new.border_color = beautiful.colorscheme.bg_teal
end

local up_offset = 0
function launcher:move_down()
  local row, _ = self.grid:get_dimension()
  if self.cursor.y < row then
    if not self.grid:get_widgets_at(self.cursor.y + 1, self.cursor.x) then return end
    self.cursor.y = self.cursor.y + 1
    self:selection_update(self.cursor.x, self.cursor.y - 1)
    up_offset = up_offset - 1
    if up_offset < 0 then
      up_offset = 0
    end
  end

  if up_offset == 0 then
    if math.floor((capi.mouse.screen.geometry.width / 100 * 60) / 200) < self.cursor.y then
      local overflow = self.popup.widget:get_children_by_id('overflow')[1]
      overflow:set_scroll_factor(overflow:get_scroll_factor() + (1 / 24 * 127 / 100))
    end
  end
end

function launcher:move_up()
  local row, _ = self.grid:get_dimension()
  if self.cursor.y > 1 then
    self.cursor.y = self.cursor.y - 1
    self:selection_update(self.cursor.x, self.cursor.y + 1)
    up_offset = up_offset + 1
    if up_offset > 5 then
      up_offset = 5
    end
  end
  if up_offset == 5 then
    local overflow = self.popup.widget:get_children_by_id('overflow')[1]

    overflow:set_scroll_factor(overflow:get_scroll_factor() - (1 / 24 * 127 / 100))
  end
end

function launcher:move_left()
  if self.cursor.x > 1 then
    self.cursor.x = self.cursor.x - 1
    self:selection_update(self.cursor.x + 1, self.cursor.y)
  end
end

function launcher:move_right()
  local _, col = self.grid:get_dimension()
  if self.cursor.x < col then
    if not self.grid:get_widgets_at(self.cursor.y, self.cursor.x + 1) then return end
    self.cursor.x = self.cursor.x + 1
    self:selection_update(self.cursor.x - 1, self.cursor.y)
  end
end

function launcher:focus_searchbar()
  self.searchbar:focus()
  self.popup.widget:get_children_by_id('searchbar_bg')[1].border_color = beautiful.colorscheme.bg_teal
end

function launcher:unfocus_searchbar()
  self.searchbar:unfocus()
  self.popup.widget:get_children_by_id('searchbar_bg')[1].border_color = beautiful.colorscheme.border_color
end

local instance = nil
if not instance then
  instance = setmetatable(launcher, {
    __call = function(self, screen)
      self.app_table = {}
      self.cursor = {
        x = 1,
        y = 1,
      }

      self:fetch_apps()
      self.grid = wibox.widget {
        homogenous = true,
        expand = false,
        spacing = dpi(10),
        -- 190 is the application element width + 10 spacing
        forced_num_cols = math.floor((capi.mouse.screen.geometry.width / 100 * 50) / 190),
        orientation = 'vertical',
        layout = wibox.layout.grid,
      }

      self.keygrabber = akeygrabber {
        autostart = false,
        stop_key = { 'Escape', 'Return' },
        mask_event_callback = false,
        stop_callback = function(_, k)
          if (k == 'Return') or (k == 'Escape') then
            if k == 'Return' then
              self.grid:get_widgets_at(self.cursor.y, self.cursor.x)[1].execute()
            end
            self:selection_remove(self.cursor.x, self.cursor.y)
            self:toggle(capi.mouse.screen)
            self:filter_apps('')
            self.searchbar:set_text('')
            self.keygrabber:stop()
          end
          self.cursor = {
            x = 1,
            y = 1,
          }
        end,
        keybindings = {
          akey {
            modifiers = {},
            key = 'Down',
            on_press = function()
              self:move_down()
            end,
          },
          akey {
            modifiers = {},
            key = 'Up',
            on_press = function()
              local y = self.cursor.y
              self:move_up()

              -- If it didn't move we want to reenter the searchbar
              if y - self.cursor.y == 0 then
                self:selection_remove(self.cursor.x, self.cursor.y)

                self.keygrabber:stop()
                self:focus_searchbar()
              end
            end,
          },
          akey {
            modifiers = {},
            key = 'Left',
            on_press = function()
              self:move_left()
            end,
          },
          akey {
            modifiers = {},
            key = 'Right',
            on_press = function()
              self:move_right()
            end,
          },
        },
      }

      self.searchbar = inputbox {
        text_hint = 'Search...',
        mouse_focus = false,
        font = beautiful.font .. ' regular 12',
        fg = beautiful.colorscheme.fg,
      }
      self.searchbar:connect_signal('button::press', function()
        self:selection_remove(self.cursor.x, self.cursor.y)
        akeygrabber.stop()
        self:focus_searchbar()
      end)
      self.searchbar:connect_signal('inputbox::keypressed', function(_, _, key)
        if key == 'Escape' then
          self:unfocus_searchbar()
          self:toggle(capi.mouse.screen)
          self.searchbar:set_text('')
          self:filter_apps('')
        elseif key == 'Return' then
          self:unfocus_searchbar()
          self:toggle(capi.mouse.screen)
          self.grid:get_widgets_at(self.cursor.x, self.cursor.y)[1].execute()
          self:filter_apps('')
        elseif key == 'Down' then
          if not (self.keygrabber.running == akeygrabber.current_instance) then
            self:selection_update(1, 1)
            self:unfocus_searchbar()
            self.keygrabber:start()
          end
        else
          self:filter_apps(self.searchbar:get_text())
        end
      end)
      --#region Hover signals to change the cursor to a text cursor
      local old_cursor, old_wibox
      self.searchbar:connect_signal('mouse::enter', function()
        local wid = capi.mouse.current_wibox
        if wid then
          old_cursor, old_wibox = wid.cursor, wid
          wid.cursor = 'xterm'
        end
      end)
      self.searchbar:connect_signal('mouse::leave', function()
        old_wibox.cursor = old_cursor
        old_wibox = nil
      end)
      --#endregion

      self:filter_apps('')

      self.popup = apopup {
        widget = {
          {
            {
              {
                {
                  {
                    self.searchbar.widget,
                    halign = 'left',
                    valign = 'center',
                    id = 'searchbar',
                    buttons = { gtable.join(
                      abutton {
                        modifiers = {},
                        button = 1,
                        on_press = function()
                          self:focus_searchbar()
                        end,
                      }
                    ), },
                    widget = wibox.container.place,
                  },
                  widget = wibox.container.margin,
                  margins = 5,
                },
                widget = wibox.container.constraint,
                strategy = 'exact',
                height = dpi(50),
              },
              widget = wibox.container.background,
              bg = beautiful.colorscheme.bg,
              fg = beautiful.colorscheme.fg,
              border_color = beautiful.colorscheme.border_color,
              border_width = dpi(2),
              shape = beautiful.shape[4],
              id = 'searchbar_bg',
            },
            {
              {
                self.grid,
                layout = require('src.lib.overflow_widget.overflow').vertical,
                scrollbar_width = 0,
                id = 'overflow',
                step = dpi(100),
              },
              height = dpi((122 * 5) + 10 * 4),
              strategy = 'exact',
              widget = wibox.container.constraint,
            },
            spacing = dpi(10),
            layout = wibox.layout.fixed.vertical,
          },
          margins = dpi(20),
          widget = wibox.container.margin,
        },
        ontop = true,
        visible = true,
        stretch = false,
        screen = screen,
        placement = aplacement.centered,
        bg = beautiful.colorscheme.bg,
        border_color = beautiful.colorscheme.border_color,
        border_width = dpi(2),
      }

      -- Let the popup render once
      gtimer.delayed_call(function()
        self.popup.visible = false
      end)
    end,
  })
end
return instance
