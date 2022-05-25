--------------------------------
-- This is the network widget --
--------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
require("src.core.signals")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/powermenu/"

return function(s)

  -- Profile picture imagebox
  local profile_picture = wibox.widget {
    image = icondir .. "defaultpfp.svg",
    resize = true,
    forced_height = dpi(200),
    clip_shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 30)
    end,
    widget = wibox.widget.imagebox
  }

  -- Username textbox
  local profile_name = wibox.widget {
    align = 'center',
    valign = 'center',
    text = " ",
    font = "JetBrains Mono Bold 30",
    widget = wibox.widget.textbox
  }

  -- Get the profile script from /var/lib/AccountsService/icons/${USER}
  -- and copy it to the assets folder
  -- TODO: If the user doesnt have AccountsService look into $HOME/.faces
  local update_profile_picture = function()
    awful.spawn.easy_async_with_shell(
      "./.config/awesome/src/scripts/pfp.sh 'userPfp'",
      function(stdout)
        if stdout then
          profile_picture:set_image(stdout:gsub("\n", ""))
        else
          profile_picture:set_image(icondir .. "defaultpfp.svg")
        end
      end
    )
  end
  update_profile_picture()

  -- Get the full username(if set) and the username + hostname
  local update_user_name = function()
    awful.spawn.easy_async_with_shell(
      "./.config/awesome/src/scripts/pfp.sh 'userName' '" .. user_vars.namestyle .. "'",
      function(stdout)
        if stdout:gsub("\n", "") == "Rick Astley" then
          profile_picture:set_image(awful.util.getdir("config") .. "src/assets/userpfp/" .. "rickastley.jpg")
        end
        profile_name:set_text(stdout)
      end
    )
  end
  update_user_name()

  -- Universal Button widget
  local button = function(name, icon, bg_color, callback)
    local item = wibox.widget {
      {
        {
          {
            {
              {
                -- TODO: using gears.color to recolor a SVG will make it look super low res
                -- currently I recolor it in the .svg file directly, but later implement
                -- a better way to recolor a SVG
                -- image = gears.color.recolor_image(icon, color["Grey900"]),
                image = icon,
                resize = true,
                forced_height = dpi(30),
                widget = wibox.widget.imagebox
              },
              margins = dpi(0),
              widget = wibox.container.margin
            },
            {
              {
                text = name,
                font = "JetBrains Mono Bold 30",
                widget = wibox.widget.textbox
              },
              margins = dpi(0),
              widget = wibox.container.margin
            },
            widget = wibox.layout.fixed.horizontal
          },
          margins = dpi(10),
          widget = wibox.container.margin
        },
        fg = color["Grey900"],
        bg = bg_color,
        shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, 10)
        end,
        widget = wibox.container.background,
        id = 'background'
      },
      spacing = dpi(0),
      layout = wibox.layout.align.vertical
    }

    item:connect_signal(
      "button::release",
      function()
        callback()
      end
    )

    return item
  end

  -- Create the power menu actions
  local suspend_command = function()
    awful.spawn("systemctl suspend")
    awesome.emit_signal("module::powermenu:hide")
  end

  local logout_command = function()
    awesome.quit()
  end

  local lock_command = function()
    awful.spawn("dm-tool lock")
    awesome.emit_signal("module::powermenu:hide")
  end

  local shutdown_command = function()
    awful.spawn("shutdown now")
    awesome.emit_signal("module::powermenu:hide")
  end

  local reboot_command = function()
    awful.spawn("reboot")
    awesome.emit_signal("module::powermenu:hide")
  end

  -- Create the buttons with their command and name etc
  local shutdown_button = button("Shutdown", icondir .. "shutdown.svg", color["Blue200"], shutdown_command)
  local reboot_button = button("Reboot", icondir .. "reboot.svg", color["Red200"], reboot_command)
  local suspend_button = button("Suspend", icondir .. "suspend.svg", color["Yellow200"], suspend_command)
  local logout_button = button("Logout", icondir .. "logout.svg", color["Green200"], logout_command)
  local lock_button = button("Lock", icondir .. "lock.svg", color["Orange200"], lock_command)

  -- Signals to change color on hover
  Hover_signal(shutdown_button.background, color["Blue200"], color["Grey900"])
  Hover_signal(reboot_button.background, color["Red200"], color["Grey900"])
  Hover_signal(suspend_button.background, color["Yellow200"], color["Grey900"])
  Hover_signal(logout_button.background, color["Green200"], color["Grey900"])
  Hover_signal(lock_button.background, color["Orange200"], color["Grey900"])

  -- The powermenu widget
  local powermenu = wibox.widget {
    layout = wibox.layout.align.vertical,
    expand = "none",
    nil,
    {
      {
        nil,
        {
          {
            nil,
            {
              nil,
              {
                profile_picture,
                margins = dpi(0),
                widget = wibox.container.margin
              },
              nil,
              expand = "none",
              layout = wibox.layout.align.horizontal
            },
            nil,
            layout = wibox.layout.align.vertical,
            expand = "none"
          },
          spacing = dpi(50),
          {
            profile_name,
            margins = dpi(0),
            widget = wibox.container.margin
          },
          layout = wibox.layout.fixed.vertical
        },
        nil,
        expand = "none",
        layout = wibox.layout.align.horizontal
      },
      {
        nil,
        {
          {
            shutdown_button,
            reboot_button,
            logout_button,
            lock_button,
            suspend_button,
            spacing = dpi(30),
            layout = wibox.layout.fixed.horizontal
          },
          margins = dpi(0),
          widget = wibox.container.margin
        },
        nil,
        expand = "none",
        layout = wibox.layout.align.horizontal
      },
      layout = wibox.layout.align.vertical
    },
    nil
  }

  -- Container for the widget, covers the entire screen
  local powermenu_container = wibox {
    widget = powermenu,
    screen = s,
    type = "splash",
    visible = false,
    ontop = true,
    bg = "#21212188",
    height = s.geometry.height,
    width = s.geometry.width,
    x = s.geometry.x,
    y = s.geometry.y
  }

  -- Close on rightclick
  powermenu_container:buttons(
    gears.table.join(
      awful.button(
        {},
        3,
        function()
          awesome.emit_signal("module::powermenu:hide")
        end
      )
    )
  )

  -- Close on Escape
  local powermenu_keygrabber = awful.keygrabber {
    autostart = false,
    stop_event = 'release',
    keypressed_callback = function(self, mod, key, command)
      if key == 'Escape' then
        awesome.emit_signal("module::powermenu:hide")
      end
    end
  }

  -- Signals
  awesome.connect_signal(
    "module::powermenu:show",
    function()
      if s == mouse.screen then
        powermenu_container.visible = true
        powermenu_keygrabber:start()
      end
    end
  )

  awesome.connect_signal(
    "module::powermenu:hide",
    function()
      powermenu_keygrabber:stop()
      powermenu_container.visible = false
    end
  )
end
