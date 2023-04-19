local abutton = require('awful.button')
local aplacement = require('awful.placement')
local apopup = require('awful.popup')
local awidget = require('awful.widget')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gtable = require('gears.table')
local gcolor = require('gears.color')
local gshape = require('gears.shape')
local gfilesystem = require('gears.filesystem')
local NM = require('lgi').NM
local wibox = require('wibox')

local hover = require('src.tools.hover')

local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/network/'

local capi = {
  awesome = awesome,
  mouse = mouse,
  mousegrabber = mousegrabber,
}

local ap_form = { mt = {} }

function ap_form:popup_toggle()
  self.visible = not self.visible
end

function ap_form.new(args)
  args = args or {}
  args.screen = args.screen

  local password = awidget.inputbox { hint_text = 'Password...' }

  local ret = apopup {
    widget = {
      {
        { -- Header
          {
            nil,
            {
              {
                widget = wibox.widget.textbox,
                text = NM.utils_ssid_to_utf8(args.NetworkManagerAccessPoint.Ssid),
                font = beautiful.user_config.font.specify .. ',extra bold 16',
                halign = 'center',
                valign = 'center',
              },
              widget = wibox.container.margin,
              margins = dpi(5),
            },
            { -- Close button
              {
                {
                  widget = wibox.widget.imagebox,
                  image = gcolor.recolor_image(icondir .. 'close.svg', beautiful.colorscheme.bg),
                  resize = false,
                  valign = 'center',
                  halign = 'center',
                },
                widget = wibox.container.margin,
                margins = dpi(5),
              },
              widget = wibox.container.background,
              shape = beautiful.shape[8],
              id = 'close_button',
              bg = beautiful.colorscheme.bg_red,
            },
            layout = wibox.layout.align.horizontal,
          },
          widget = wibox.container.background,
          bg = beautiful.colorscheme.bg,
          fg = beautiful.colorscheme.bg_red,
        },
        { -- Form
          { -- Password
            widget = wibox.widget.textbox,
            text = 'Password',
            halign = 'center',
            valign = 'center',
          },
          {
            widget = wibox.container.margin,
            left = dpi(20),
            right = dpi(20),
          },
          -- Change to inputtextbox container
          {
            {
              {
                password,
                widget = wibox.container.margin,
                margins = 5,
                id = 'marg',
              },
              widget = wibox.container.constraint,
              strategy = 'exact',
              width = 400,
              height = 50,
              id = 'const',
            },
            widget = wibox.container.background,
            bg = beautiful.colorscheme.bg,
            fg = beautiful.colorscheme.fg,
            border_color = beautiful.colorscheme.border_color,
            border_width = dpi(2),
            shape = gshape.rounded_rect,
            forced_width = 300,
            forced_height = 50,
            id = 'password_container',
          },
          layout = wibox.layout.align.horizontal,
        },
        { -- Actions
          { -- Auto connect
            {
              {
                {
                  checked = false,
                  shape = beautiful.shape[4],
                  color = beautiful.colorscheme.bg,
                  paddings = dpi(3),
                  check_color = beautiful.colorscheme.bg_red,
                  border_color = beautiful.colorscheme.bg_red,
                  border_width = dpi(2),
                  id = 'checkbox',
                  widget = wibox.widget.checkbox,
                },
                widget = wibox.container.constraint,
                strategy = 'exact',
                width = dpi(30),
                height = dpi(30),
              },
              widget = wibox.container.place,
              halign = 'center',
              valign = 'center',
            },
            {
              widget = wibox.widget.textbox,
              text = 'Auto connect',
              halign = 'center',
              valign = 'center',
            },
            spacing = dpi(10),
            layout = wibox.layout.fixed.horizontal,
          },
          nil,
          { -- Connect
            {
              {
                {
                  widget = wibox.widget.textbox,
                  text = 'Connect',
                  halign = 'center',
                  valign = 'center',
                },
                widget = wibox.container.margin,
                margins = dpi(10),
              },
              widget = wibox.container.background,
              bg = beautiful.colorscheme.bg_blue,
              fg = beautiful.colorscheme.bg,
              shape = beautiful.shape[8],
              id = 'connect_button',
            },
            widget = wibox.container.margin,
            margins = dpi(10),
          },
          layout = wibox.layout.align.horizontal,
        },
        spacing = dpi(20),
        layout = wibox.layout.fixed.vertical,
      },
      widget = wibox.container.margin,
      margins = dpi(10),
    },
    placement = aplacement.centered,
    ontop = true,
    visible = false,
    width = dpi(600),
    height = dpi(400),
    bg = beautiful.colorscheme.bg,
    fg = beautiful.colorscheme.fg,
    border_color = beautiful.colorscheme.border_color,
    border_width = dpi(2),
    type = 'dialog',
    screen = args.screen,
  }

  local password_container = ret.widget:get_children_by_id('password_container')[1]

  gtable.crush(ret, ap_form, true)

  -- Focus the searchbar when its left clicked
  password_container:buttons(gtable.join {
    abutton({}, 1, function()
      password:focus()
    end),
  })

  --#region Hover signals to change the cursor to a text cursor
  local old_cursor, old_wibox
  password_container:connect_signal('mouse::enter', function()
    local wid = capi.mouse.current_wibox
    if wid then
      old_cursor, old_wibox = wid.cursor, wid
      wid.cursor = 'xterm'
    end
  end)
  password_container:connect_signal('mouse::leave', function()
    old_wibox.cursor = old_cursor
    old_wibox = nil
  end)
  --#endregion

  local checkbox = ret.widget:get_children_by_id('checkbox')[1]
  checkbox:connect_signal('button::press', function()
    checkbox.checked = not checkbox.checked
  end)

  local close_button = ret.widget:get_children_by_id('close_button')[1]
  close_button:connect_signal('button::press', function()
    ret:popup_toggle()
  end)
  hover.bg_hover { widget = close_button }

  local connect_button = ret.widget:get_children_by_id('connect_button')[1]
  connect_button:connect_signal('button::press', function()
    password:stop()
    args.ap:connect(args.NetworkManagerAccessPoint, password:get_text(),
      ret.widget:get_children_by_id('checkbox')[1].checked)
    ret:popup_toggle()
  end)
  hover.bg_hover { widget = connect_button }

  return ret
end

function ap_form.mt:__call(...)
  return ap_form.new(...)
end

return setmetatable(ap_form, ap_form.mt)
