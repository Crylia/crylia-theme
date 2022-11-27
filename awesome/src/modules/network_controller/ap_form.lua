local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
local gtable = require("gears.table")
local gobject = require("gears.object")
local gcolor = require("gears.color")
local gshape = require("gears.shape")
local gfilesystem = require("gears.filesystem")
local wibox = require("wibox")

local icondir = gfilesystem.get_configuration_dir() .. "src/assets/icons/network/"

local capi = {
  awesome = awesome,
  mousegrabber = mousegrabber
}

local ap_form = { mt = {} }

function ap_form:popup_toggle()
  self.visible = not self.visible
end

function ap_form.new(args)
  args = args or {}
  args.screen = args.screen or awful.screen.preferred()

  local settigns_form = {
    password = awful.widget.inputbox {
      widget_template = wibox.template {
        widget = wibox.widget {
          {
            {
              {
                widget = wibox.widget.textbox,
                halign = "left",
                valign = "center",
                id = "text_role",
              },
              widget = wibox.container.margin,
              margins = 5,
              id = "marg"
            },
            widget = wibox.container.constraint,
            strategy = "exact",
            width = 400,
            height = 50,
            id = "const"
          },
          widget = wibox.container.background,
          bg = "#212121",
          fg = "#F0F0F0",
          border_color = "#414141",
          border_width = 2,
          shape = gshape.rounded_rect,
          forced_width = 300,
          forced_height = 50,
        },
        update_callback = function(template_widget, args)
          template_widget.widget.const.marg.text_role.markup = args.text
        end
      }
    },
  }

  local ret = awful.popup {
    widget = {
      {
        { -- Header
          {
            nil,
            {
              {
                widget = wibox.widget.textbox,
                text = args.ssid,
                font = User_config.font.specify .. ",extra bold 16",
                halign = "center",
                valign = "center",
              },
              widget = wibox.container.margin,
              margins = dpi(5)
            },
            { -- Close button
              {
                {
                  widget = wibox.widget.imagebox,
                  image = gcolor.recolor_image(icondir .. "close.svg", Theme_config.network_manager.form.icon_fg),
                  resize = false,
                  valign = "center",
                  halign = "center",
                },
                widget = wibox.container.margin,
                margins = dpi(5),
              },
              widget = wibox.container.background,
              shape = Theme_config.network_manager.form.close_icon_shape,
              id = "close_button",
              bg = Theme_config.network_manager.form.close_bg
            },
            layout = wibox.layout.align.horizontal
          },
          widget = wibox.container.background,
          bg = Theme_config.network_manager.form.header_bg,
          fg = Theme_config.network_manager.form.header_fg,
        },
        { -- Form
          { -- Password
            widget = wibox.widget.textbox,
            text = "Password",
            halign = "center",
            valign = "center"
          },
          {
            widget = wibox.container.margin,
            left = dpi(20),
            right = dpi(20),
          },
          -- Change to inputtextbox container
          settigns_form.password,
          layout = wibox.layout.align.horizontal
        },
        { -- Actions
          { -- Auto connect
            {
              {
                {
                  checked = false,
                  shape = Theme_config.network_manager.form.checkbox_shape,
                  color = Theme_config.network_manager.form.checkbox_fg,
                  paddings = dpi(3),
                  check_color = Theme_config.network_manager.form.checkbox_bg,
                  border_color = Theme_config.network_manager.form.checkbox_bg,
                  border_width = 2,
                  id = "checkbox",
                  widget = wibox.widget.checkbox
                },
                widget = wibox.container.constraint,
                strategy = "exact",
                width = dpi(30),
                height = dpi(30)
              },
              widget = wibox.container.place,
              halign = "center",
              valign = "center"
            },
            {
              widget = wibox.widget.textbox,
              text = "Auto connect",
              halign = "center",
              valign = "center"
            },
            spacing = dpi(10),
            layout = wibox.layout.fixed.horizontal
          },
          nil,
          { -- Connect
            {
              {
                {
                  widget = wibox.widget.textbox,
                  text = "Connect",
                  halign = "center",
                  valign = "center"
                },
                widget = wibox.container.margin,
                margins = dpi(10),
              },
              widget = wibox.container.background,
              bg = Theme_config.network_manager.form.button_bg,
              fg = Theme_config.network_manager.form.button_fg,
              shape = Theme_config.network_manager.form.button_shape,
              id = "connect_button",
            },
            widget = wibox.container.margin,
            margins = dpi(10),
          },
          layout = wibox.layout.align.horizontal
        },
        spacing = dpi(20),
        layout = wibox.layout.fixed.vertical
      },
      widget = wibox.container.margin,
      margins = dpi(10)
    },
    placement = awful.placement.centered,
    ontop = true,
    visible = false,
    width = dpi(600),
    height = dpi(400),
    bg = Theme_config.network_manager.form.bg,
    fg = Theme_config.network_manager.form.fg,
    shape = Theme_config.network_manager.form.shape,
    border_color = Theme_config.network_manager.form.border_color,
    border_width = Theme_config.network_manager.form.border_width,
    type = "dialog",
    screen = args.screen,
  }

  gtable.crush(ret, ap_form, true)

  local checkbox = ret.widget:get_children_by_id("checkbox")[1]
  checkbox:connect_signal("button::press", function()
    checkbox.checked = not checkbox.checked
  end)

  local close_button = ret.widget:get_children_by_id("close_button")[1]
  close_button:connect_signal("button::press", function()
    ret:popup_toggle()
  end)
  Hover_signal(close_button)

  local connect_button = ret.widget:get_children_by_id("connect_button")[1]
  connect_button:connect_signal("button::press", function()
    ret:emit_signal("ap_form::connect", {
      ssid = args.ssid,
      password = settigns_form.password:get_text(),
      auto_connect = ret.widget:get_children_by_id("checkbox")[1].checked
    })
    print("Connect to " .. args.ssid:get_text(), "\nPassword: " .. settigns_form.password:get_text(),
      "\nAuto connect: " .. tostring(ret.widget:get_children_by_id("checkbox")[1].checked))
  end)
  Hover_signal(connect_button)

  return ret
end

function ap_form.mt:__call(...)
  return ap_form.new(...)
end

return setmetatable(ap_form, ap_form.mt)
