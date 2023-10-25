local setmetatable = setmetatable

-- Awesome Libs
local abutton = require('awful.button')
local akey = require('awful.key')
local akeygrabber = require('awful.keygrabber')
local aspawn = require('awful.spawn')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gfilesystem = require('gears.filesystem')
local gtable = require('gears.table')
local wibox = require('wibox')
local gsurface = require('gears.surface')

local hover = require('src.tools.hover')

local capi = {
  awesome = awesome,
  screen = screen,
}

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/powermenu/'

local instance = nil
local powermenu = {}

local function get_button(type)
  local icon, name, bg_color, command

  if type == 'shutdown' then
    icon = icondir .. 'shutdown.svg'
    name = 'Shutdown'
    bg_color = beautiful.colorscheme.bg_blue
    command = 'shutdown now'
  elseif type == 'reboot' then
    icon = icondir .. 'reboot.svg'
    name = 'Reboot'
    bg_color = beautiful.colorscheme.bg_red
    command = 'reboot'
  elseif type == 'logout' then
    icon = icondir .. 'logout.svg'
    name = 'Logout'
    bg_color = beautiful.colorscheme.bg_yellow
    command = 'awesome-client "awesome.quit()"'
  elseif type == 'lock' then
    icon = icondir .. 'lock.svg'
    name = 'Lock'
    bg_color = beautiful.colorscheme.bg_green
    command = 'dm-tool lock'
  elseif type == 'suspend' then
    icon = icondir .. 'suspend.svg'
    name = 'Suspend'
    bg_color = beautiful.colorscheme.bg_purple
    command = 'systemctl suspend'
  end

  local widget = wibox.widget {
    {
      {
        {
          {
            {
              image = icon,
              resize = true,
              valign = 'center',
              halign = 'center',
              widget = wibox.widget.imagebox,
            },
            {
              text = name,
              font = 'JetBrains Mono Bold 30',
              valign = 'center',
              halign = 'center',
              widget = wibox.widget.textbox,
            },
            widget = wibox.layout.fixed.horizontal,
          },
          widget = wibox.container.place,
        },
        margins = dpi(10),
        widget = wibox.container.margin,
      },
      fg = beautiful.colorscheme.bg,
      bg = bg_color,
      shape = beautiful.shape[12],
      widget = wibox.container.background,
      id = 'background',
    },
    height = dpi(70),
    strategy = 'exact',
    widget = wibox.container.constraint,
  }

  hover.bg_hover { widget = widget.background, overlay = 12, press_overlay = 24 }

  widget:buttons(gtable.join(
    abutton({}, 1, function()
      aspawn(command)
    end)
  ))

  return widget
end

function powermenu:toggle()
  self.keygrabber:start()
  self.w.visible = not self.w.visible
end

if instance == nil then
  instance = setmetatable(powermenu, {
    __call = function(self)
      self.w = wibox {
        widget = {
          {
            {
              {
                {
                  image = gsurface.load_uncached(gfilesystem.get_configuration_dir() .. 'src/assets/userpfp/userpfp.png'),
                  resize = true,
                  clip_shape = beautiful.shape[30],
                  valign = 'center',
                  halign = 'center',
                  id = 'icon_role',
                  widget = wibox.widget.imagebox,
                },
                widget = wibox.container.constraint,
                width = dpi(200),
                height = dpi(200),
                strategy = 'exact',
              },
              {
                halign = 'center',
                valign = 'center',
                font = 'JetBrains Mono Bold 30',
                id = 'text_role',
                widget = wibox.widget.textbox,
              },
              spacing = dpi(50),
              layout = wibox.layout.fixed.vertical,
            },
            {
              {
                get_button('shutdown'),
                get_button('reboot'),
                get_button('logout'),
                get_button('lock'),
                get_button('suspend'),
                spacing = dpi(30),
                layout = wibox.layout.fixed.horizontal,
              },
              widget = wibox.container.place,
            },
            spacing = dpi(50),
            layout = wibox.layout.fixed.vertical,
          },
          widget = wibox.container.place,
        },
        screen = capi.screen.primary,
        type = 'splash',
        visible = false,
        ontop = true,
        bg = beautiful.colorscheme.bg .. '88',
        height = capi.screen.primary.geometry.height,
        width = capi.screen.primary.geometry.width,
        x = capi.screen.primary.geometry.x,
        y = capi.screen.primary.geometry.y,
      }

      self.w:buttons { gtable.join(
        abutton({}, 3, function()
          self:toggle()
          self.keygrabber:stop()
        end)
      ), }

      self.keygrabber = akeygrabber {
        autostart = false,
        stop_event = 'release',
        stop_key = 'Escape',
        keybindings = {
          akey {
            modifiers = {},
            key = 'Escape',
            on_press = function()
              self:toggle()
            end,
          },
        },
      }

      -- Get the profile script from /var/lib/AccountsService/icons/${USER}
      -- and copy it to the assets folder
      -- TODO: If the user doesnt have AccountsService look into $HOME/.faces
      --[[ aspawn.easy_async_with_shell("./.config/awesome/src/scripts/pfp.sh 'userPfp'", function(stdout)
        print(stdout)
        if stdout then
          self.w:get_children_by_id('icon_role')[1].image = gsurface.load_uncached(gfilesystem.get_configuration_dir() .. 'src/assets/userpfp/userpfp.png')
        else
          self.w:get_children_by_id('icon_role')[1].image = icondir .. 'defaultpfp.svg'
        end
      end) ]]

      aspawn.easy_async_with_shell("./.config/awesome/src/scripts/pfp.sh 'userName' '" .. beautiful.user_config.namestyle .. "'", function(stdout)
        self.w:get_children_by_id('text_role')[1].text = stdout:gsub('\n', '')
      end)
    end,
  })
end
return instance
