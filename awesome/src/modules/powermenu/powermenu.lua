--------------------------------
-- This is the network widget --
--------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local capi = {
  awesome = awesome,
  mouse = mouse,
}

-- Icon directory path
local icondir = gears.filesystem.get_configuration_dir() .. "src/assets/icons/powermenu/"

return function(s)

  -- Profile picture imagebox
  local profile_picture = wibox.widget {
    image = icondir .. "defaultpfp.svg",
    resize = true,
    forced_height = dpi(200),
    clip_shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(30))
    end,
    valign = "center",
    halign = "center",
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
      "./.config/awesome/src/scripts/pfp.sh 'userName' '" .. User_config.namestyle .. "'",
      function(stdout)
        if stdout:gsub("\n", "") == "Rick Astley" then
          profile_picture:set_image(gears.filesystem.get_configuration_dir() .. "src/assets/userpfp/" .. "rickastley.jpg")
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
              -- TODO: using gears.color to recolor a SVG will make it look super low res
              -- currently I recolor it in the .svg file directly, but later implement
              -- a better way to recolor a SVG
              image = icon,
              resize = true,
              forced_height = dpi(30),
              valign = "center",
              halign = "center",
              widget = wibox.widget.imagebox
            },
            {
              text = name,
              font = "JetBrains Mono Bold 30",
              widget = wibox.widget.textbox
            },
            widget = wibox.layout.fixed.horizontal
          },
          margins = dpi(10),
          widget = wibox.container.margin
        },
        fg = Theme_config.powermenu.button_fg,
        bg = bg_color,
        shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, dpi(10))
        end,
        widget = wibox.container.background,
        id = 'background'
      },
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
    capi.awesome.emit_signal("module::powermenu:hide")
  end

  local logout_command = function()
    capi.awesome.quit()
  end

  local lock_command = function()
    awful.spawn("dm-tool lock")
    capi.awesome.emit_signal("module::powermenu:hide")
  end

  local shutdown_command = function()
    awful.spawn("shutdown now")
    capi.awesome.emit_signal("module::powermenu:hide")
  end

  local reboot_command = function()
    awful.spawn("reboot")
    capi.awesome.emit_signal("module::powermenu:hide")
  end

  -- Create the buttons with their command and name etc
  local shutdown_button = button("Shutdown", icondir .. "shutdown.svg", Theme_config.powermenu.shutdown_button_bg,
    shutdown_command)
  local reboot_button = button("Reboot", icondir .. "reboot.svg", Theme_config.powermenu.reboot_button_bg, reboot_command)
  local suspend_button = button("Suspend", icondir .. "suspend.svg", Theme_config.powermenu.suspend_button_bg,
    suspend_command)
  local logout_button = button("Logout", icondir .. "logout.svg", Theme_config.powermenu.logout_button_bg, logout_command)
  local lock_button = button("Lock", icondir .. "lock.svg", Theme_config.powermenu.lock_button_bg, lock_command)

  -- Signals to change color on hover
  Hover_signal(shutdown_button.background)
  Hover_signal(reboot_button.background)
  Hover_signal(suspend_button.background)
  Hover_signal(logout_button.background)
  Hover_signal(lock_button.background)

  -- The powermenu widget
  local powermenu = wibox.widget {
    {
      {
        profile_picture,
        profile_name,
        spacing = dpi(50),
        layout = wibox.layout.fixed.vertical
      },
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
        halign = "center",
        valign = "center",
        widget = wibox.container.place
      },
      layout = wibox.layout.fixed.vertical
    },
    halign = "center",
    valign = "center",
    widget = wibox.container.place
  }

  -- Container for the widget, covers the entire screen
  local powermenu_container = wibox {
    widget = powermenu,
    screen = s,
    type = "splash",
    visible = false,
    ontop = true,
    bg = Theme_config.powermenu.container_bg,
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
          capi.awesome.emit_signal("module::powermenu:hide")
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
        capi.awesome.emit_signal("module::powermenu:hide")
      end
    end
  }

  -- Signals
  capi.awesome.connect_signal(
    "module::powermenu:show",
    function()
      if s == capi.mouse.screen then
        powermenu_container.visible = true
        powermenu_keygrabber:start()
      end
    end
  )

  capi.awesome.connect_signal(
    "module::powermenu:hide",
    function()
      powermenu_keygrabber:stop()
      powermenu_container.visible = false
    end
  )
end