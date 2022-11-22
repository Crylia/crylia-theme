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
ap_form._private = {}

ap_form.settigns_form = {
  ssid = awful.widget.inputbox {
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

function ap_form:popup_toggle()
  self._private.popup.visible = not self._private.popup.visible
end

function ap_form.new(args)
  args = args or {}
  args.screen = args.screen or awful.screen.preferred()
  local ret = gobject {}
  ret._private = {}
  gtable.crush(ret, ap_form, true)

  gtable.crush(ret, args)

  ret._private.popup = awful.popup {
    widget = {
      { -- Header
        {
          nil,
          {
            {
              widget = wibox.widget.textbox,
              text = args.SSID,
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
            },
            widget = wibox.container.background,
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
        { -- SSID
          {
            widget = wibox.widget.textbox,
            text = "SSID",
            halign = "center",
            valign = "center"
          },
          nil,
          -- Change to inputtextbox container
          ret.settigns_form.ssid,
          layout = wibox.layout.align.horizontal
        },
        { -- Password
          {
            widget = wibox.widget.textbox,
            text = "Password",
            halign = "center",
            valign = "center"
          },
          nil,
          -- Change to inputtextbox container
          ret.settigns_form.password,
          layout = wibox.layout.align.horizontal
        },
        spacing = dpi(10),
        layout = wibox.layout.fixed.vertical
      },
      { -- Actions
        { -- Auto connect
          {
            {
              checked = false,
              shape = Theme_config.network_manager.form.checkbox_shape,
              color = Theme_config.network_manager.form.checkbox_bg,
              check_color = Theme_config.network_manager.form.checkbox_fg,
              check_border_color = Theme_config.network_manager.form.check_border_color,
              check_border_width = Theme_config.network_manager.form.check_border_width,
              widget = wibox.widget.checkbox
            },
            widget = wibox.container.constraint,
            strategy = "exact",
            width = dpi(30),
            height = dpi(30)
          },
          {
            widget = wibox.widget.textbox,
            text = "Auto connect",
            halign = "center",
            valign = "center"
          },
          layout = wibox.layout.fixed.horizontal
        },
        nil,
        { -- Connect
          {
            {
              widget = wibox.widget.textbox,
              text = "Connect",
              halign = "center",
              valign = "center"
            },
            widget = wibox.container.background,
            bg = Theme_config.network_manager.form.button_bg,
            fg = Theme_config.network_manager.form.button_fg,
          },
          widget = wibox.container.margin,
          margins = dpi(10),
        },
        layout = wibox.layout.align.horizontal
      },
      layout = wibox.layout.align.vertical
    },
    placement = awful.placement.centered,
    ontop = true,
    visible = false,
    width = dpi(600),
    height = dpi(400),
    bg = Theme_config.network_manager.form.bg,
    fg = Theme_config.network_manager.form.fg,
    shape = Theme_config.network_manager.form.shape,
    type = "dialog",
    screen = args.screen,
  }

  ret._private.popup.widget:get_children_by_id("close_button")[1]:connect_signal("button::press", function()
    ret:popup_toggle()
  end)

  ret.settigns_form.ssid:connect_signal(
    "submit",
    function(text)
    end
  )

  ret.settigns_form.ssid:connect_signal(
    "stopped",
    function()
    end
  )

  ret.settigns_form.password:connect_signal(
    "submit",
    function(text)
    end
  )

  ret.settigns_form.password:connect_signal(
    "stopped",
    function()
    end
  )

  return ret
end

function ap_form.mt:__call(...)
  return ap_form.new(...)
end

return setmetatable(ap_form, ap_form.mt)
