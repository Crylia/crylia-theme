--------------------------------
-- This is the profile widget --
--------------------------------

-- Awesome Libs
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/profile/"

return function()

  local profile_widget = wibox.widget {
    {
      {
        {
          {
            {
              {
                image = gears.surface.load_uncached(awful.util.getdir("config") .. "src/assets/userpfp/crylia.png"),
                id = "icon",
                valign = "center",
                halign = "center",
                clip_shape = function(cr, width, height)
                  gears.shape.rounded_rect(cr, width, height, dpi(12))
                end,
                widget = wibox.widget.imagebox
              },
              strategy = "exact",
              widget = wibox.container.constraint
            },
            id = "icon_margin",
            margins = dpi(20),
            widget = wibox.container.margin
          },
          {
            {
              {
                {
                  { -- Username
                    id = "username_prefix",
                    image = gears.color.recolor_image(icondir .. "user.svg",
                      Theme_config.notification_center.profile.username_icon_color),
                    valign = "center",
                    halign = "left",
                    resize = false,
                    widget = wibox.widget.imagebox
                  },
                  { -- Username
                    id = "username",
                    valign = "center",
                    align = "left",
                    widget = wibox.widget.textbox
                  },
                  spacing = dpi(10),
                  layout = wibox.layout.fixed.horizontal
                },
                {
                  {
                    id = "os_prefix",
                    image = gears.color.recolor_image(icondir .. "laptop.svg",
                      Theme_config.notification_center.profile.os_prefix_icon_color),
                    valign = "center",
                    halign = "left",
                    resize = false,
                    widget = wibox.widget.imagebox
                  },
                  { -- OS
                    id = "os",
                    valign = "center",
                    align = "left",
                    widget = wibox.widget.textbox
                  },
                  spacing = dpi(10),
                  layout = wibox.layout.fixed.horizontal
                },
                {
                  {
                    id = "kernel_prefix",
                    image = gears.color.recolor_image(icondir .. "penguin.svg",
                      Theme_config.notification_center.profile.kernel_icon_color),
                    valign = "center",
                    halign = "left",
                    resize = false,
                    widget = wibox.widget.imagebox
                  },
                  { -- Kernel
                    id = "kernel",
                    valign = "center",
                    align = "left",
                    widget = wibox.widget.textbox
                  },
                  spacing = dpi(10),
                  layout = wibox.layout.fixed.horizontal
                },
                {
                  {
                    id = "uptime_prefix",
                    image = gears.color.recolor_image(icondir .. "clock.svg",
                      Theme_config.notification_center.profile.uptime_icon_color),
                    valign = "center",
                    halign = "left",
                    resize = false,
                    widget = wibox.widget.imagebox
                  },
                  { -- Uptime
                    id = "uptime",
                    valign = "center",
                    align = "left",
                    widget = wibox.widget.textbox
                  },
                  spacing = dpi(10),
                  id = "uptime_layout",
                  layout = wibox.layout.fixed.horizontal
                },
                spacing = dpi(5),
                id = "info_layout",
                layout = wibox.layout.flex.vertical
              },
              id = "text_margin",
              widget = wibox.container.constraint
            },
            id = "text_container",
            bottom = dpi(20),
            left = dpi(20),
            widget = wibox.container.margin
          },
          id = "text_container_wrapper",
          widget = wibox.layout.fixed.vertical
        },
        id = "wrapper",
        fg = Theme_config.notification_center.profile.fg,
        border_color = Theme_config.notification_center.profile.border_color,
        border_width = Theme_config.notification_center.profile.border_width,
        shape = Theme_config.notification_center.profile.shape,
        widget = wibox.container.background
      },
      id = "const",
      strategy = "exact",
      width = dpi(250),
      height = dpi(350),
      widget = wibox.container.constraint
    },
    top = dpi(20),
    left = dpi(10),
    right = dpi(20),
    bottom = dpi(10),
    widget = wibox.container.margin
  }

  local function get_os_name_pretty()
    awful.spawn.easy_async_with_shell(
      "cat /etc/os-release | grep -w NAME",
      function(stdout)
        profile_widget:get_children_by_id("os")[1].text = stdout:match("\"(.+)\"")
      end
    )
  end

  -- function to get and set the kernel version
  local function get_kernel_version()
    awful.spawn.easy_async_with_shell(
      "uname -r",
      function(stdout)
        profile_widget:get_children_by_id("kernel")[1].text = stdout:match("(%d+%.%d+%.%d+)")
      end
    )
  end

  --function to get the username and hostname
  local function get_user_hostname()
    awful.spawn.easy_async_with_shell(
      "echo $USER@$(hostname)",
      function(stdout)
        profile_widget:get_children_by_id("username")[1].text = stdout:gsub("\n", "") or ""
      end
    )
  end

  -- function to fetch uptime async
  local function get_uptime()
    awful.spawn.easy_async_with_shell("uptime -p", function(stdout)

      local hours = stdout:match("(%d+) hours") or 0
      local minutes = stdout:match("(%d+) minutes") or 0

      profile_widget:get_children_by_id("uptime")[1].text = hours .. "h, " .. minutes .. "m"
    end)
  end

  get_os_name_pretty()
  get_kernel_version()
  get_user_hostname()

  gears.timer {
    timeout = 60,
    autostart = true,
    call_now = true,
    callback = get_uptime
  }

  return profile_widget

end
