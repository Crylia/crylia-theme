local ipairs = ipairs
local math = math
local pairs = pairs
local setmetatable = setmetatable
local table = table

--Awesome Libs
local abutton = require('awful.button')
local aplacement = require('awful.placement')
local apopup = require('awful.popup')
local aspawn = require('awful.spawn')
local atooltip = require('awful.tooltip')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local gshape = require('gears.shape')
local gtable = require('gears.table')
local wibox = require('wibox')

--Own Libs
local toggle_button = require('awful.widget.toggle_widget')
local inputwidget = require('src.modules.inputbox')

local capi = {
  screen = screen,
}

local assets_dir = os.getenv('HOME') .. '/.config/awesome/src/assets/'
local icon_dir = os.getenv('HOME') .. '/.config/awesome/src/assets/icons/setup/'

local setup = { mt = {} }

local widget_list = {
  'Audio',
  'Battery',
  'Bluetooth',
  'Clock',
  'Cpu Frequency',
  'Cpu Temperature',
  'Cpu Usage',
  'Date',
  'Gpu Temperature',
  'Gpu Usage',
  'Keyboard Layout',
  'Tiling Layout',
  'Network',
  'Power Button',
  'Ram Usage',
  'Systray',
  'Taglist',
  'Tasklist',
}

local statusbar_list = {
  'Battery',
  'Backlight',
  'CPU Temp',
  'CPU Usage',
  'GPU Temp',
  'GPU Usage',
  'Microphone',
  'RAM',
  'Volume',
}

--[[
  Creates the pages for the setup module
  1. Welcome, short explanation and thanking for downloading
  2. Selecting the wallpaper
  3. Selecting the bar and widgets
  4. Selecting the Notification Center widgets and weather
  5. Choose/change default programs
  6. Setup tiling layouts
  7. Titlebar settings
  8. Font and Icon theme
  9. Final page, with a button to restart awesome
]]
local function create_pages()
  local pages = {}
  table.insert(pages, setup:welcome_page())
  table.insert(pages, setup:wallpaper_page())
  table.insert(pages, setup:bar_page())
  table.insert(pages, setup:notification_page())
  table.insert(pages, setup:programs_page())
  table.insert(pages, setup:layouts_page())
  --table.insert(pages, setup:titlebar_page())
  table.insert(pages, setup:font_page())
  table.insert(pages, setup:final_page())
  return pages
end

--- The first page, with a short explanation and thanking for downloading
function setup:welcome_page()
  return wibox.widget {
    {
      { -- Left side with text etc
        {
          {
            {
              {
                widget = wibox.widget.textbox,
                markup = 'Welcome to Crylia-Theme',
                font = 'Raleway Bold 36',
                halign = 'left',
                valign = 'center',
              },
              {
                widget = wibox.widget.textbox,
                markup = 'Thank you for downloading Crylia-Theme, a beautiful and customizable config for AwesomeWM',
                font = 'Comforta Regular 28',
                halign = 'left',
                valign = 'center',
              },
              spacing = dpi(40),
              layout = wibox.layout.fixed.vertical,
            },
            widget = wibox.container.margin,
            left = dpi(50),
          },
          widget = wibox.container.place,
          valign = 'center',
        },
        widget = wibox.container.constraint,
        width = dpi((capi.screen.primary.geometry.width * 0.6) / 2),
        strategy = 'exact',
      },
      { -- Right side with image
        {
          {
            widget = wibox.widget.imagebox,
            image = gfilesystem.get_configuration_dir() .. 'src/assets/CT.svg',
            resize = true,
            valign = 'center',
            halign = 'center',
          },
          widget = wibox.container.margin,
          margins = dpi(50),
        },
        forced_width = dpi((capi.screen.primary.geometry.width * 0.6) / 2),
        widget = wibox.container.place,
      },
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.constraint,
    width = dpi(capi.screen.primary.geometry.width * 0.6),
    strategy = 'exact',
  }
end

--- The second page, with a list of wallpapers to choose from
function setup:wallpaper_page()

  local path_promt = inputwidget {
    text_hint = 'Path to image...',
    mouse_focus = true,
    font = 'JetBrainsMono Nerd Font 12 Regular',
  }

  local widget = wibox.widget {
    {
      {
        { -- Image
          {
            widget = wibox.widget.imagebox,
            resize = true,
            image = assets_dir .. 'space.jpg',
            valign = 'center',
            halign = 'center',
            clip_shape = beautiful.shape[12],
            id = 'wallpaper',
          },
          widget = wibox.container.constraint,
          width = dpi(600),
          height = dpi(600 * 9 / 16),
          strategy = 'exact',
        },
        { -- Button
          {
            {
              {
                {
                  {
                    {
                      widget = wibox.widget.imagebox,
                      image = icon_dir .. 'choose.svg',
                      valign = 'center',
                      halign = 'center',
                      resize = true,
                    },
                    widget = wibox.container.constraint,
                    width = dpi(36),
                    height = dpi(36),
                    strategy = 'exact',
                  },
                  widget = wibox.container.margin,
                  left = dpi(10),
                },
                {
                  widget = wibox.widget.textbox,
                  markup = 'Choose Wallpaper',
                  halign = 'center',
                  valign = 'center',
                },
                spacing = dpi(20),
                layout = wibox.layout.fixed.horizontal,
              },
              widget = wibox.container.background,
              bg = beautiful.colorscheme.bg_yellow,
              fg = beautiful.colorscheme.bg,
              shape = beautiful.shape[12],
              id = 'choose_image',
            },
            widget = wibox.container.constraint,
            width = dpi(300),
            height = dpi(60),
            strategy = 'exact',
          },
          valign = 'center',
          halign = 'center',
          widget = wibox.container.place,
        },
        { -- Path
          {
            {
              nil,
              { -- Text
                {
                  path_promt.widget,
                  widget = wibox.container.constraint,
                  width = dpi(600),
                  height = dpi(50),
                  strategy = 'exact',
                },
                widget = wibox.container.place,
                halign = 'center',
                valign = 'center',
              },
              { -- Button
                {
                  widget = wibox.widget.imagebox,
                  image = icon_dir .. 'close.svg',
                  rezise = true,
                  id = 'close',
                },
                widget = wibox.container.background,
                bg = gcolor.transparent,
                fg = beautiful.colorscheme.bg_red,
              },
              layout = wibox.layout.align.horizontal,
            },
            widget = wibox.container.background,
            bg = beautiful.colorscheme.bg1,
            fg = beautiful.colorscheme.fg,
            shape = beautiful.shape[12],
          },
          widget = wibox.container.constraint,
          width = dpi(600),
          height = dpi(50),
          strategy = 'exact',
        },
        spacing = dpi(28),
        layout = wibox.layout.fixed.vertical,
      },
      widget = wibox.container.place,
      halign = 'center',
      valign = 'center',
    },
    widget = wibox.container.constraint,
    width = (capi.screen.primary.geometry.width * 0.6),
    strategy = 'exact',
  }

  --Wallpaper
  local wallpaper = widget:get_children_by_id('wallpaper')[1]

  --Choose Image button
  local choose_image_button = widget:get_children_by_id('choose_image')[1]

  --Close button
  local close_button = widget:get_children_by_id('close')[1]

  choose_image_button:buttons(gtable.join(
    abutton({}, 1, function()
      aspawn.easy_async_with_shell(
        "zenity --file-selection --title='Select an Image File' --file-filter='Image File | *.jpg *.png'",
        function(stdout)
          stdout = stdout:gsub('\n', '')
          if stdout ~= '' then
            wallpaper:set_image(stdout)
            path_promt:set_text(stdout)
            self.wallpaper = stdout
          end
        end)
    end)
  ))

  close_button:buttons(gtable.join(
    abutton({}, 1, function()
      path_promt:set_text('')
      wallpaper:set_image(nil)
    end)
  ))

  return widget
end

-- Get a list of widgets from a verbal list
local function get_widgets()
  local widgets = {}

  for _, widget in pairs(widget_list) do
    local tb = toggle_button {
      size = dpi(30),
      color = beautiful.colorscheme.bg_blue,
    }

    local w = wibox.widget {
      nil,
      {
        {
          {
            widget = wibox.widget.textbox,
            text = widget,
            halign = 'left',
            valign = 'center',
            font = beautiful.user_config.font,
          },
          widget = wibox.container.margin,
          margins = dpi(5),
        },
        widget = wibox.widget.background,
        bg = beautiful.colorscheme.bg1,
        fg = beautiful.colorscheme.fg,
        shape = beautiful.shape[8],
        border_color = beautiful.colorscheme.bg2,
        border_width = dpi(2),
      },
      {
        tb,
        widget = wibox.container.margin,
        left = dpi(10),
      },
      id = 'toggle_button',
      layout = wibox.layout.align.horizontal,
    }

    table.insert(widgets, w)
  end

  return widgets
end

--- The third page, to customize the bar
function setup:bar_page()
  local widget = wibox.widget {
    { -- Top bar
      {
        { -- Title
          {
            widget = wibox.widget.textbox,
            text = 'Top Bar',
            halign = 'center',
            valign = 'center',
          },
          widget = wibox.container.margin,
          margins = dpi(10),
        },
        { -- Bar preview
          {
            {
              {
                {
                  widget = wibox.widget.checkbox,
                  checked = true,
                  id = 'topbar_checkbox',
                  shape = gshape.circle,
                  color = beautiful.colorscheme.bg_green,
                  padding = dpi(4),
                },
                widget = wibox.container.constraint,
                width = 30,
                height = 30,
                strategy = 'exact',
              },
              widget = wibox.container.place,
              halign = 'right',
              valign = 'center',
            },
            {
              {
                widget = wibox.widget.imagebox,
                image = '/home/crylia/Downloads/2022-12-08_23-19.png', --icon_dir .. "topbar.svg",
                resize = true,
                clip_shape = beautiful.shape[4],
                halign = 'center',
                valign = 'center',
              },
              widget = wibox.container.constraint,
              width = dpi(capi.screen.primary.geometry.width * 0.6),
              strategy = 'exact',
            },
            spacing = dpi(10),
            layout = wibox.layout.fixed.horizontal,
          },
          widget = wibox.container.margin,
          left = dpi(70),
          right = dpi(70),
        },
        {
          {
            { -- Widget selector
              {
                {
                  {
                    {
                      widget = wibox.widget.textbox,
                      text = 'Left Widgets',
                      halign = 'center',
                      valign = 'center',
                    },
                    {
                      layout = require('src.lib.overflow_widget.overflow').vertical,
                      spacing = dpi(10),
                      step = dpi(50),
                      scrollbar_width = 0,
                      id = 'left_top_widget_selector',
                    },
                    spacing = dpi(10),
                    layout = wibox.layout.fixed.vertical,
                  },
                  widget = wibox.container.margin,
                  margins = dpi(10),
                },
                widget = wibox.container.background,
                border_color = beautiful.colorscheme.bg1,
                border_width = dpi(2),
                shape = beautiful.shape[8],
              },
              {
                {
                  {
                    {
                      widget = wibox.widget.textbox,
                      text = 'Center Widgets',
                      halign = 'center',
                      valign = 'center',
                    },
                    {
                      layout = require('src.lib.overflow_widget.overflow').vertical,
                      spacing = dpi(10),
                      step = dpi(50),
                      scrollbar_width = 0,
                      id = 'center_top_widget_selector',
                    },
                    spacing = dpi(10),
                    layout = wibox.layout.fixed.vertical,
                  },
                  widget = wibox.container.margin,
                  margins = dpi(10),
                },
                widget = wibox.container.background,
                border_color = beautiful.colorscheme.bg1,
                border_width = dpi(2),
                shape = beautiful.shape[8],
              },
              {
                {
                  {
                    {
                      widget = wibox.widget.textbox,
                      text = 'Right Widgets',
                      halign = 'center',
                      valign = 'center',
                    },
                    {
                      layout = require('src.lib.overflow_widget.overflow').vertical,
                      spacing = dpi(10),
                      step = dpi(50),
                      scrollbar_width = 0,
                      id = 'right_top_widget_selector',
                    },
                    spacing = dpi(10),
                    layout = wibox.layout.fixed.vertical,
                  },
                  widget = wibox.container.margin,
                  margins = dpi(10),
                },
                widget = wibox.container.background,
                border_color = beautiful.colorscheme.bg1,
                border_width = dpi(2),
                shape = beautiful.shape[8],
              },
              expand = 'none',
              forced_width = dpi(capi.screen.primary.geometry.width * 0.6) * 0.4,
              layout = wibox.layout.align.horizontal,
            },
            widget = wibox.container.constraint,
            height = dpi(capi.screen.primary.geometry.width * 0.6 * 9 / 16) * 0.3,
            strategy = 'exact',
          },
          widget = wibox.container.margin,
          left = dpi(140),
          right = dpi(140),
        },
        spacing = dpi(20),
        layout = wibox.layout.fixed.vertical,
      },
      {
        widget = wibox.container.background,
        bg = gcolor.transparent,
        id = 'top_overlay',
      },
      layout = wibox.layout.stack,
    },
    {
      { -- Bottom bar
        { -- Widget selector
          {
            {
              {
                {
                  {
                    {
                      widget = wibox.widget.textbox,
                      text = 'Left Widgets',
                      halign = 'center',
                      valign = 'center',
                    },
                    {
                      widget = require('src.lib.overflow_widget.overflow').vertical,
                      spacing = dpi(10),
                      step = dpi(50),
                      scrollbar_width = 0,
                      id = 'left_bottom_widget_selector',
                    },
                    spacing = dpi(10),
                    layout = wibox.layout.fixed.vertical,
                  },
                  widget = wibox.container.margin,
                  margins = dpi(10),
                },
                widget = wibox.container.background,
                border_color = beautiful.colorscheme.bg1,
                border_width = dpi(2),
                shape = beautiful.shape[8],
              },
              {
                {
                  {
                    {
                      widget = wibox.widget.textbox,
                      text = 'Center Widgets',
                      halign = 'center',
                      valign = 'center',
                    },
                    {
                      widget = require('src.lib.overflow_widget.overflow').vertical,
                      spacing = dpi(10),
                      step = dpi(50),
                      scrollbar_width = 0,
                      id = 'center_bottom_widget_selector',
                    },
                    spacing = dpi(10),
                    layout = wibox.layout.fixed.vertical,
                  },
                  widget = wibox.container.margin,
                  margins = dpi(10),
                },
                widget = wibox.container.background,
                border_color = beautiful.colorscheme.bg1,
                border_width = dpi(2),
                shape = beautiful.shape[8],
              },
              {
                {
                  {
                    {
                      widget = wibox.widget.textbox,
                      text = 'Right Widgets',
                      halign = 'center',
                      valign = 'center',
                    },
                    {
                      widget = require('src.lib.overflow_widget.overflow').vertical,
                      spacing = dpi(10),
                      step = dpi(50),
                      scrollbar_width = 0,
                      id = 'right_bottom_widget_selector',
                    },
                    spacing = dpi(10),
                    layout = wibox.layout.fixed.vertical,
                  },
                  widget = wibox.container.margin,
                  margins = dpi(10),
                },
                widget = wibox.container.background,
                border_color = beautiful.colorscheme.bg1,
                border_width = dpi(2),
                shape = beautiful.shape[8],
              },
              expand = 'none',
              forced_width = dpi(capi.screen.primary.geometry.width * 0.6) * 0.4,
              layout = wibox.layout.align.horizontal,
            },
            widget = wibox.container.constraint,
            height = dpi(capi.screen.primary.geometry.width * 0.6 * 9 / 16) * 0.3,
            strategy = 'exact',
          },
          widget = wibox.container.margin,
          left = dpi(140),
          right = dpi(140),
        },
        { -- Bar preview
          {
            {
              {
                {
                  widget = wibox.widget.checkbox,
                  checked = false,
                  id = 'bottombar_checkbox',
                  shape = gshape.circle,
                  color = beautiful.colorscheme.bg_green,
                  padding = dpi(4),
                },
                widget = wibox.container.constraint,
                width = 30,
                height = 30,
                strategy = 'exact',
              },
              widget = wibox.container.place,
              halign = 'right',
              valign = 'center',
            },
            {
              {
                widget = wibox.widget.imagebox,
                image = '/home/crylia/Downloads/2022-12-08_23-19.png', --icon_dir .. "topbar.svg",
                resize = true,
                clip_shape = beautiful.shape[4],
                halign = 'center',
                valign = 'center',
              },
              widget = wibox.container.constraint,
              width = dpi(capi.screen.primary.geometry.width * 0.6),
              strategy = 'exact',
            },
            spacing = dpi(10),
            layout = wibox.layout.fixed.horizontal,
          },
          widget = wibox.container.margin,
          left = dpi(70),
          right = dpi(70),
        },
        { -- Title
          {
            widget = wibox.widget.textbox,
            text = 'Bottom Bar',
            halign = 'center',
            valign = 'center',
          },
          widget = wibox.container.margin,
          margins = dpi(10),
        },
        spacing = dpi(20),
        layout = wibox.layout.fixed.vertical,
      },
      {
        widget = wibox.container.background,
        bg = beautiful.colorscheme.bg .. 'BB',
        id = 'bottom_overlay',
      },
      layout = wibox.layout.stack,
    },
    spacing_widget = wibox.widget.separator,
    spacing = dpi(5),
    forced_width = dpi(capi.screen.primary.geometry.width * 0.6),
    layout = wibox.layout.flex.vertical,
  }

  local top_checkbox, bottom_checkbox = widget:get_children_by_id('topbar_checkbox')[1],
      widget:get_children_by_id('bottombar_checkbox')[1]

  local top_overlay, bottom_overlay = widget:get_children_by_id('top_overlay')[1],
      widget:get_children_by_id('bottom_overlay')[1]

  top_checkbox:buttons(gtable.join(
    abutton({}, 1, nil, function()
      top_checkbox.checked = not top_checkbox.checked
      bottom_checkbox.checked = not top_checkbox.checked
      if top_checkbox.checked then
        top_overlay.bg = gcolor.transparent
        bottom_overlay.bg = beautiful.colorscheme.bg .. 'BB'
      else
        top_overlay.bg = beautiful.colorscheme.bg .. 'BB'
        bottom_overlay.bg = gcolor.transparent
      end
    end
    )
  ))

  bottom_checkbox:buttons(gtable.join(
    abutton({}, 1, nil, function()
      bottom_checkbox.checked = not bottom_checkbox.checked
      top_checkbox.checked = not bottom_checkbox.checked
      if bottom_checkbox.checked then
        top_overlay.bg = beautiful.colorscheme.bg .. 'BB'
        bottom_overlay.bg = gcolor.transparent
      else
        top_overlay.bg = gcolor.transparent
        bottom_overlay.bg = beautiful.colorscheme.bg .. 'BB'
      end
    end
    )
  ))

  widget:get_children_by_id('left_top_widget_selector')[1].children = get_widgets()
  widget:get_children_by_id('center_top_widget_selector')[1].children = get_widgets()
  widget:get_children_by_id('right_top_widget_selector')[1].children = get_widgets()
  widget:get_children_by_id('left_bottom_widget_selector')[1].children = get_widgets()
  widget:get_children_by_id('center_bottom_widget_selector')[1].children = get_widgets()
  widget:get_children_by_id('right_bottom_widget_selector')[1].children = get_widgets()


  return widget
end

local function get_status_bars()
  local widgets = wibox.widget {
    layout = wibox.layout.flex.horizontal,
    spacing = dpi(100),
    { layout = wibox.layout.fixed.vertical, id = 'left', spacing = dpi(10) },
    { layout = wibox.layout.fixed.vertical, id = 'right', spacing = dpi(10) },
  }

  for i, widget in pairs(statusbar_list) do
    local tb = toggle_button {
      size = dpi(30),
      color = beautiful.colorscheme.bg_blue,
    }

    local w = wibox.widget {
      nil,
      {
        {
          widget = wibox.widget.textbox,
          text = widget,
          halign = 'left',
          valign = 'center',
          font = beautiful.user_config.font .. ' Regular, 14',
        },
        widget = wibox.container.margin,
        margins = dpi(5),
      },
      {
        tb,
        widget = wibox.container.margin,
        left = dpi(10),
      },
      id = 'toggle_button',
      layout = wibox.layout.align.horizontal,
    }
    if i <= math.ceil(#statusbar_list / 2) then
      widgets:get_children_by_id('left')[1]:add(w)
    else
      widgets:get_children_by_id('right')[1]:add(w)
    end
  end

  return widgets
end

--- The fourth page, to customize the notification center
function setup:notification_page()
  local secrets = {
    api_key = inputwidget {
      text_hint = 'API Key...',
      font = 'JetBrainsMono Nerd Font 12 Regular',
      mouse_focus = true,
    },
    city_id = inputwidget {
      text_hint = 'City ID...',
      font = 'JetBrainsMono Nerd Font 12 Regular',
      mouse_focus = true,
    },
  }

  local widget = wibox.widget {
    {
      {
        {
          widget = wibox.widget.textbox,
          text = 'Notification Center Setup',
          font = beautiful.user_config.font .. ' Regular 24',
          halign = 'center',
          valign = 'center',
        },
        widget = wibox.container.margin,
        margins = dpi(10),
      },
      {
        { -- Status bars
          { -- Title
            {
              widget = wibox.widget.textbox,
              text = 'Status bars',
              font = beautiful.user_config.font .. ' Regular 16',
              halign = 'center',
            },
            widget = wibox.container.margin,
            top = dpi(5),
            bottom = dpi(100),
          },
          {
            { -- Icon
              widget = wibox.widget.imagebox,
              image = icon_dir .. 'status_bars.png',
              resize = false,
              forced_width = dpi(250),
              halign = 'center',
              id = 'sb_icon',
            },
            {
              get_status_bars(),
              widget = wibox.container.margin,
              left = dpi(100),
              right = dpi(100),
            },
            expand = 'none',
            layout = wibox.layout.flex.vertical,
          },
          nil,
          layout = wibox.layout.align.vertical,
        },
        { -- OpenWeatherMap API
          { -- Title
            {
              widget = wibox.widget.textbox,
              text = 'OpenWeatherMap API',
              font = beautiful.user_config.font .. ' Regular 16',
              halign = 'center',
            },
            widget = wibox.container.margin,
            top = dpi(5),
          },
          {
            {
              { -- Icon
                {
                  widget = wibox.widget.imagebox,
                  image = icon_dir .. 'openweathermap.png',
                  resize = true,
                  halign = 'center',
                  id = 'opw_icon',
                },
                widget = wibox.container.constraint,
                width = dpi(250),
                strategy = 'exact',
              },
              { -- Secrets
                { -- API Key
                  {
                    {
                      widget = wibox.widget.textbox,
                      text = 'API Key',
                      font = beautiful.user_config.font .. ' Regular 16',
                      halign = 'center',
                      valign = 'center',
                    },
                    widget = wibox.container.margin,
                    right = dpi(20),
                  },
                  {
                    {
                      secrets.api_key.widget,
                      widget = wibox.container.margin,
                      left = dpi(10),
                    },
                    id = 'api_key_input',
                    forced_height = dpi(50),
                    forced_width = dpi(400),
                    widget = wibox.container.background,
                    border_color = beautiful.colorscheme.bg1,
                    border_width = dpi(2),
                    shape = beautiful.shape[4],
                  },
                  layout = wibox.layout.align.horizontal,
                },
                { -- City ID
                  {
                    {
                      widget = wibox.widget.textbox,
                      text = 'City ID',
                      font = beautiful.user_config.font .. ' Regular 16',
                      halign = 'center',
                      valign = 'center',
                    },
                    widget = wibox.container.margin,
                    right = dpi(20),
                  },
                  {
                    {
                      secrets.city_id.widget,
                      widget = wibox.container.margin,
                      left = dpi(10),
                    },
                    id = 'city_id_input',
                    forced_height = dpi(50),
                    forced_width = dpi(400),
                    widget = wibox.container.background,
                    border_color = beautiful.colorscheme.bg1,
                    border_width = dpi(2),
                    shape = beautiful.shape[4],
                  },
                  layout = wibox.layout.align.horizontal,
                },
                spacing = dpi(40),
                layout = wibox.layout.flex.vertical,
              },
              { -- Unit selection
                { -- Celsius
                  {
                    {
                      {
                        widget = wibox.widget.checkbox,
                        checked = true,
                        color = beautiful.colorscheme.green,
                        paddings = dpi(4),
                        shape = gshape.circle,
                        id = 'celsius_selector',
                      },
                      widget = wibox.container.constraint,
                      width = dpi(24),
                      height = dpi(24),
                    },
                    widget = wibox.container.place,
                    halign = 'center',
                    valign = 'center',
                  },
                  {
                    widget = wibox.widget.textbox,
                    text = 'Celsius °C',
                    font = beautiful.user_config.font .. ' Regular 14',
                    halign = 'center',
                    valign = 'center',
                  },
                  spacing = dpi(10),
                  layout = wibox.layout.fixed.vertical,
                },
                { -- Fahrenheit
                  {
                    {
                      {
                        widget = wibox.widget.checkbox,
                        checked = false,
                        color = beautiful.colorscheme.green,
                        paddings = dpi(4),
                        shape = gshape.circle,
                        id = 'Fahrenheit_selector',
                      },
                      widget = wibox.container.constraint,
                      width = dpi(24),
                      height = dpi(24),
                    },
                    widget = wibox.container.place,
                    halign = 'center',
                    valign = 'center',
                  },
                  {
                    widget = wibox.widget.textbox,
                    text = 'Fahrenheit °F',
                    font = beautiful.user_config.font .. ' Regular 14',
                    halign = 'center',
                    valign = 'center',
                  },
                  spacing = dpi(10),
                  layout = wibox.layout.fixed.vertical,
                },
                layout = wibox.layout.flex.horizontal,
              },
              spacing = dpi(100),
              layout = wibox.layout.fixed.vertical,
            },
            widget = wibox.container.place,
            halign = 'center',
            valign = 'center',
          },
          nil,
          layout = wibox.layout.align.vertical,
        },
        spacing_widget = wibox.widget.separator {
          color = beautiful.colorscheme.bg1,
        },
        spacing = dpi(5),
        layout = wibox.layout.flex.horizontal,
      },
      nil,
      layout = wibox.layout.align.vertical,
    },
    widget = wibox.container.constraint,
    width = dpi(capi.screen.primary.geometry.width * 0.6),
    strategy = 'exact',
  }

  -- Toggle both checkboxes so they act as radio buttons
  local celsius_selector = widget:get_children_by_id('celsius_selector')[1]
  local fahrenheit_selector = widget:get_children_by_id('Fahrenheit_selector')[1]
  celsius_selector:buttons(gtable.join(
    abutton({}, 1, nil, function()
      celsius_selector.checked = true
      fahrenheit_selector.checked = false
    end)
  ))
  fahrenheit_selector:buttons(gtable.join(
    abutton({}, 1, nil, function()
      celsius_selector.checked = false
      fahrenheit_selector.checked = true
    end)
  ))

  local opw_icon = widget:get_children_by_id('opw_icon')[1]
  opw_icon:buttons(gtable.join(
    abutton({}, 1, nil, function()
      aspawn.with_shell('xdg-open https://openweathermap.org/')
    end)
  ))

  local api_key_input = widget:get_children_by_id('api_key_input')[1]
  local city_id_input = widget:get_children_by_id('city_id_input')[1]
  api_key_input:buttons(gtable.join(
    abutton({}, 1, nil, function()
      secrets.api_key:focus()
    end)
  ))

  city_id_input:buttons(gtable.join(
    abutton({}, 1, nil, function()
      secrets.city_id:focus()
    end)
  ))

  --#region Mouse changes
  local old_mouse, old_wibox
  local function mouse_enter(icon)
    local wb = mouse.current_wibox
    if wb then
      old_mouse, old_wibox = wb.cursor, wb
      wb.cursor = icon
    end
  end

  local function mouse_leave()
    if old_wibox then
      old_wibox.cursor = old_mouse
      old_wibox = nil
    end
  end

  api_key_input:connect_signal('mouse::enter', function() mouse_enter('xterm') end)
  api_key_input:connect_signal('mouse::leave', mouse_leave)
  city_id_input:connect_signal('mouse::enter', function() mouse_enter('xterm') end)
  city_id_input:connect_signal('mouse::leave', mouse_leave)
  opw_icon:connect_signal('mouse::enter', function() mouse_enter('hand1') end)
  opw_icon:connect_signal('mouse::leave', mouse_leave)
  celsius_selector:connect_signal('mouse::enter', function() mouse_enter('hand1') end)
  celsius_selector:connect_signal('mouse::leave', mouse_leave)
  fahrenheit_selector:connect_signal('mouse::enter', function() mouse_enter('hand1') end)
  fahrenheit_selector:connect_signal('mouse::leave', mouse_leave)

  --#endregion

  return widget
end

--- The fifth page, to customize the default programs
function setup:programs_page()
  local applications = {
    power_manager = inputwidget { mouse_focus = true, font = 'JetBrainsMono Nerd Font 12 Regular', hint_text = 'e.g. xfce4-power-manager-settings' },
    web_browser = inputwidget { mouse_focus = true, font = 'JetBrainsMono Nerd Font 12 Regular', hint_text = 'e.g. firefox' },
    terminal = inputwidget { mouse_focus = true, font = 'JetBrainsMono Nerd Font 12 Regular', hint_text = 'e.g. kitty' },
    text_editor = inputwidget { mouse_focus = true, font = 'JetBrainsMono Nerd Font 12 Regular', hint_text = 'e.g. code' },
    music_player = inputwidget { mouse_focus = true, font = 'JetBrainsMono Nerd Font 12 Regular', hint_text = 'e.g. flatpak run com.spotify.Client' },
    gtk_settings = inputwidget { mouse_focus = true, font = 'JetBrainsMono Nerd Font 12 Regular', hint_text = 'e.g. lxappearance' },
    file_manager = inputwidget { mouse_focus = true, font = 'JetBrainsMono Nerd Font 12 Regular', hint_text = 'e.g. nautilus' },
    screen_manager = inputwidget { mouse_focus = true, font = 'JetBrainsMono Nerd Font 12 Regular', hint_text = 'e.g. arandr' },
  }

  local widget = wibox.widget {
    {
      { -- Title
        {
          widget = wibox.widget.textbox,
          text = 'Default Applications',
          font = beautiful.user_config.font .. ' Regular 24',
          halign = 'center',
          valign = 'center',
        },
        widget = wibox.container.margin,
        margins = dpi(10),
      },
      {
        { -- Left side Applications
          {
            { -- power_manager
              {
                {
                  widget = wibox.widget.textbox,
                  text = 'Power Manager',
                  font = beautiful.user_config.font .. ' Regular 14',
                  halign = 'center',
                  valign = 'center',
                },
                widget = wibox.container.margin,
                right = dpi(20),
              },
              nil,
              {
                {
                  applications.power_manager.widget,
                  widget = wibox.container.margin,
                  left = dpi(10),
                },
                id = 'power_manager_input',
                forced_height = dpi(50),
                forced_width = dpi(350),
                widget = wibox.container.background,
                border_color = beautiful.colorscheme.bg1,
                border_width = dpi(2),
                shape = beautiful.shape[4],
              },
              expand = 'none',
              layout = wibox.layout.align.horizontal,
            },
            { -- web_browser
              {
                {
                  widget = wibox.widget.textbox,
                  text = 'Web Browser',
                  font = beautiful.user_config.font .. ' Regular 14',
                  halign = 'center',
                  valign = 'center',
                },
                widget = wibox.container.margin,
                right = dpi(20),
              },
              nil,
              {
                {
                  applications.web_browser.widget,
                  widget = wibox.container.margin,
                  left = dpi(10),
                },
                id = 'web_browser_input',
                forced_height = dpi(50),
                forced_width = dpi(350),
                widget = wibox.container.background,
                border_color = beautiful.colorscheme.bg1,
                border_width = dpi(2),
                shape = beautiful.shape[4],
              },
              expand = 'none',
              layout = wibox.layout.align.horizontal,
            },
            { -- terminal
              {
                {
                  widget = wibox.widget.textbox,
                  text = 'Terminal',
                  font = beautiful.user_config.font .. ' Regular 14',
                  halign = 'center',
                  valign = 'center',
                },
                widget = wibox.container.margin,
                right = dpi(20),
              },
              nil,
              {
                {
                  applications.terminal.widget,
                  widget = wibox.container.margin,
                  left = dpi(10),
                },
                id = 'terminal_input',
                forced_height = dpi(50),
                forced_width = dpi(350),
                widget = wibox.container.background,
                border_color = beautiful.colorscheme.bg1,
                border_width = dpi(2),
                shape = beautiful.shape[4],
              },
              expand = 'none',
              layout = wibox.layout.align.horizontal,
            },
            { -- text_editor
              {
                {
                  widget = wibox.widget.textbox,
                  text = 'Text Editor',
                  font = beautiful.user_config.font .. ' Regular 14',
                  halign = 'center',
                  valign = 'center',
                },
                widget = wibox.container.margin,
                right = dpi(20),
              },
              nil,
              {
                {
                  applications.text_editor.widget,
                  widget = wibox.container.margin,
                  left = dpi(10),
                },
                id = 'text_editor_input',
                forced_height = dpi(50),
                forced_width = dpi(350),
                widget = wibox.container.background,
                border_color = beautiful.colorscheme.bg1,
                border_width = dpi(2),
                shape = beautiful.shape[4],
              },
              expand = 'none',
              layout = wibox.layout.align.horizontal,
            },
            spacing = dpi(40),
            layout = wibox.layout.fixed.vertical,
          },
          widget = wibox.container.place,
          valign = 'center',
          halign = 'center',
        },
        { -- Right side Applications
          {
            { -- music_player
              {
                {
                  widget = wibox.widget.textbox,
                  text = 'Music Player',
                  font = beautiful.user_config.font .. ' Regular 14',
                  halign = 'center',
                  valign = 'center',
                },
                widget = wibox.container.margin,
                right = dpi(20),
              },
              nil,
              {
                {
                  applications.music_player.widget,
                  widget = wibox.container.margin,
                  left = dpi(10),
                },
                id = 'music_player_input',
                forced_height = dpi(50),
                forced_width = dpi(350),
                widget = wibox.container.background,
                border_color = beautiful.colorscheme.bg1,
                border_width = dpi(2),
                shape = beautiful.shape[4],
              },
              expand = 'none',
              layout = wibox.layout.align.horizontal,
            },
            { -- gtk settings
              {
                {
                  widget = wibox.widget.textbox,
                  text = 'GTK Settings',
                  font = beautiful.user_config.font .. ' Regular 14',
                  halign = 'center',
                  valign = 'center',
                },
                widget = wibox.container.margin,
                right = dpi(20),
              },
              nil,
              {
                {
                  applications.gtk_settings.widget,
                  widget = wibox.container.margin,
                  left = dpi(10),
                },
                id = 'gtk_settings_input',
                forced_height = dpi(50),
                forced_width = dpi(350),
                widget = wibox.container.background,
                border_color = beautiful.colorscheme.bg1,
                border_width = dpi(2),
                shape = beautiful.shape[4],
              },
              expand = 'none',
              layout = wibox.layout.align.horizontal,
            },
            { -- file manager
              {
                {
                  widget = wibox.widget.textbox,
                  text = 'File Manager',
                  font = beautiful.user_config.font .. ' Regular 14',
                  halign = 'center',
                  valign = 'center',
                },
                widget = wibox.container.margin,
                right = dpi(20),
              },
              nil,
              {
                {
                  applications.file_manager.widget,
                  widget = wibox.container.margin,
                  left = dpi(10),
                },
                id = 'file_manager_input',
                forced_height = dpi(50),
                forced_width = dpi(350),
                widget = wibox.container.background,
                border_color = beautiful.colorscheme.bg1,
                border_width = dpi(2),
                shape = beautiful.shape[4],
              },
              expand = 'none',
              layout = wibox.layout.align.horizontal,
            },
            { -- Screen Manager
              {
                {
                  widget = wibox.widget.textbox,
                  text = 'Screen Manager',
                  font = beautiful.user_config.font .. ' Regular 14',
                  halign = 'center',
                  valign = 'center',
                },
                widget = wibox.container.margin,
                right = dpi(20),
              },
              nil,
              {
                {
                  applications.screen_manager.widget,
                  widget = wibox.container.margin,
                  left = dpi(10),
                },
                id = 'screen_manager_input',
                forced_height = dpi(50),
                forced_width = dpi(350),
                widget = wibox.container.background,
                border_color = beautiful.colorscheme.bg1,
                border_width = dpi(2),
                shape = beautiful.shape[4],
              },
              expand = 'none',
              layout = wibox.layout.align.horizontal,
            },
            spacing = dpi(40),
            layout = wibox.layout.fixed.vertical,
          },
          widget = wibox.container.place,
          valign = 'center',
          halign = 'center',
        },
        layout = wibox.layout.flex.horizontal,
      },
      nil,
      layout = wibox.layout.align.vertical,
    },
    widget = wibox.container.constraint,
    width = dpi(capi.screen.primary.geometry.width * 0.6),
    strategy = 'exact',
  }

  local power_manager_input = widget:get_children_by_id('power_manager_input')[1]
  local web_browser_input = widget:get_children_by_id('web_browser_input')[1]
  local terminal_input = widget:get_children_by_id('terminal_input')[1]
  local text_editor_input = widget:get_children_by_id('text_editor_input')[1]
  local music_player_input = widget:get_children_by_id('music_player_input')[1]
  local gtk_settings_input = widget:get_children_by_id('gtk_settings_input')[1]
  local file_manager_input = widget:get_children_by_id('file_manager_input')[1]
  local screen_manager_input = widget:get_children_by_id('screen_manager_input')[1]

  applications.power_manager:buttons(gtable.join {
    abutton({}, 1, function()
      applications.power_manager:focus()
    end),
  })
  applications.web_browser:buttons(gtable.join {
    abutton({}, 1, function()
      applications.web_browser:focus()
    end),
  })
  applications.terminal:buttons(gtable.join {
    abutton({}, 1, function()
      applications.terminal:focus()
    end),
  })
  applications.text_editor:buttons(gtable.join {
    abutton({}, 1, function()
      applications.text_editor:focus()
    end),
  })
  applications.music_player:buttons(gtable.join {
    abutton({}, 1, function()
      applications.music_player:focus()
    end),
  })
  applications.gtk_settings:buttons(gtable.join {
    abutton({}, 1, function()
      applications.gtk_settings:focus()
    end),
  })
  applications.file_manager:buttons(gtable.join {
    abutton({}, 1, function()
      applications.file_manager:focus()
    end),
  })
  applications.screen_manager:buttons(gtable.join {
    abutton({}, 1, function()
      applications.screen_manager:focus()
    end),
  })

  --#region Mouse changes
  local old_mouse, old_wibox
  local function mouse_enter(icon)
    local wb = mouse.current_wibox
    if wb then
      old_mouse, old_wibox = wb.cursor, wb
      wb.cursor = icon
    end
  end

  local function mouse_leave()
    if old_wibox then
      old_wibox.cursor = old_mouse
      old_wibox = nil
    end
  end

  power_manager_input:connect_signal('mouse::enter', function() mouse_enter('xterm') end)
  power_manager_input:connect_signal('mouse::leave', mouse_leave)
  web_browser_input:connect_signal('mouse::enter', function() mouse_enter('xterm') end)
  web_browser_input:connect_signal('mouse::leave', mouse_leave)
  terminal_input:connect_signal('mouse::enter', function() mouse_enter('xterm') end)
  terminal_input:connect_signal('mouse::leave', mouse_leave)
  text_editor_input:connect_signal('mouse::enter', function() mouse_enter('xterm') end)
  text_editor_input:connect_signal('mouse::leave', mouse_leave)
  music_player_input:connect_signal('mouse::enter', function() mouse_enter('xterm') end)
  music_player_input:connect_signal('mouse::leave', mouse_leave)
  gtk_settings_input:connect_signal('mouse::enter', function() mouse_enter('xterm') end)
  gtk_settings_input:connect_signal('mouse::leave', mouse_leave)
  file_manager_input:connect_signal('mouse::enter', function() mouse_enter('xterm') end)
  file_manager_input:connect_signal('mouse::leave', mouse_leave)
  screen_manager_input:connect_signal('mouse::enter', function() mouse_enter('xterm') end)
  screen_manager_input:connect_signal('mouse::leave', mouse_leave)

  --#endregion

  return widget
end

local function get_layouts()
  local layouts = {
    ['cornerne']    = beautiful.theme.layout_cornerne,
    ['cornernw']    = beautiful.theme.layout_cornernw,
    ['cornerse']    = beautiful.theme.layout_cornerse,
    ['cornersw']    = beautiful.theme.layout_cornersw,
    ['dwindle']     = beautiful.theme.layout_dwindle,
    ['fairh']       = beautiful.theme.layout_fairh,
    ['fairv']       = beautiful.theme.layout_fairv,
    ['floating']    = beautiful.theme.layout_floating,
    ['fullscreen']  = beautiful.theme.layout_fullscreen,
    ['magnifier']   = beautiful.theme.layout_magnifier,
    ['max']         = beautiful.theme.layout_max,
    ['spiral']      = beautiful.theme.layout_spiral,
    ['tile bottom'] = beautiful.theme.layout_cornerse,
    ['tile left']   = beautiful.theme.layout_cornernw,
    ['tile top']    = beautiful.theme.layout_cornersw,
    ['tile']        = beautiful.theme.layout_cornerne,
  }

  local list = {}

  for layout, icon in pairs(layouts) do
    local w = wibox.widget {
      {
        {
          {
            {
              {
                image = icon,
                resize = true,
                widget = wibox.widget.imagebox,
              },
              widget = wibox.container.constraint,
              width = dpi(64),
              height = dpi(64),
            },
            margins = dpi(10),
            widget = wibox.container.margin,
          },
          bg = beautiful.colorscheme.bg_red,
          shape = beautiful.shape[8],
          widget = wibox.container.background,
        },
        margins = dpi(10),
        widget = wibox.container.margin,
      },
      widget = wibox.container.background,
      border_color = beautiful.colorscheme.bg1,
      border_width = dpi(2),
      shape = beautiful.shape[8],
      selected = false,
    }

    w:buttons(gtable.join {
      abutton({}, 1, function()
        if w.selected then
          w.border_color = beautiful.colorscheme.bg1
          w.selected = false
        else
          w.border_color = beautiful.colorscheme.bg_red
          w.selected = true
        end
      end),
    })

    atooltip {
      objects = { w },
      mode = 'inside',
      align = 'bottom',
      timeout = 0.5,
      text = layout,
      preferred_positions = { 'right', 'left', 'top', 'bottom' },
      margin_leftright = dpi(8),
      margin_topbottom = dpi(8),
    }

    table.insert(list, w)
  end

  return list
end

--- The sixth page, to choose the layouts
function setup:layouts_page()
  local layouts = get_layouts()

  local widget = wibox.widget {
    {
      { -- Title
        {
          widget = wibox.widget.textbox,
          text = 'Layouts',
          font = beautiful.user_config.font .. ' Regular, 24',
          halign = 'center',
          valign = 'center',
        },
        widget = wibox.container.margin,
        margins = dpi(10),
      },
      {
        {
          spacing = dpi(20),
          forced_num_cols = 4,
          forced_num_rows = 4,
          horizontal_homogeneous = true,
          vertical_homogeneous = true,
          layout = wibox.layout.grid,
          id = 'layout_grid',
        },
        widget = wibox.container.place,
        halign = 'center',
        valign = 'center',
      },
      nil,
      layout = wibox.layout.align.vertical,
    },
    widget = wibox.container.constraint,
    width = dpi(capi.screen.primary.geometry.width * 0.6),
    strategy = 'exact',
  }

  local layout_grid = widget:get_children_by_id('layout_grid')[1]

  for _, layout in ipairs(layouts) do
    layout_grid:add(layout)
  end

  return widget
end

local function create_titlebar(pos)
  if pos == 'right' then
    return wibox.container.background
  elseif pos == 'left' then
    return wibox.container.background
  elseif pos == 'top' then
    return wibox.container.background
  end
end

local function create_selectboxes()
  return wibox.container.background
end

--- The seventh page, to customize the titlebar
function setup:titlebar_page()
  local titlebar_right = create_titlebar('right')
  local titlebar_left = create_titlebar('left')
  local titlebar_center = create_titlebar('top')

  local selectbox_right = create_selectboxes()
  local selectbox_left = create_selectboxes()
  local selectbox_center = create_selectboxes()

  local widget = wibox.widget {
    {
      { -- Title
        {
          widget = wibox.widget.textbox,
          text = 'Layouts',
          font = beautiful.user_config.font .. ' Regular, 24',
          halign = 'center',
          valign = 'center',
        },
        widget = wibox.container.margin,
        margins = dpi(10),
      },
      { -- Main content
        { -- Titlebar pos selection
          {
            { -- Top tb
              { -- Radio button
                {
                  {
                    widget = wibox.widget.checkbox,
                    checked = true,
                    id = 'top_tb_radio',
                    shape = gshape.circle,
                    color = beautiful.colorscheme.bg_teal,
                    paddings = dpi(4),
                  },
                  width = dpi(45),
                  height = dpi(45),
                  strategy = 'exact',
                  widget = wibox.container.constraint,
                },
                widget = wibox.container.place,
              },
              { -- Image
                {
                  image = icon_dir .. 'titlebar_top.png',
                  resize = true,
                  valign = 'center',
                  halign = 'center',
                  widget = wibox.widget.imagebox,
                },
                width = dpi(500),
                strategy = 'exact',
                widget = wibox.container.constraint,
              },
              id = 'top_tb',
              layout = wibox.layout.fixed.horizontal,
            },
            widget = wibox.container.place,
          },
          { -- Left tb
            {
              { -- Radio button
                {
                  {
                    widget = wibox.widget.checkbox,
                    checked = false,
                    id = 'left_tb_radio',
                    shape = gshape.circle,
                    color = beautiful.colorscheme.bg_teal,
                    paddings = dpi(4),
                  },
                  width = dpi(45),
                  height = dpi(45),
                  strategy = 'exact',
                  widget = wibox.container.constraint,
                },
                widget = wibox.container.place,
              },
              { -- Image
                {
                  image = icon_dir .. 'titlebar_left.png',
                  resize = true,
                  valign = 'center',
                  halign = 'center',
                  widget = wibox.widget.imagebox,
                },
                width = dpi(500),
                strategy = 'exact',
                widget = wibox.container.constraint,
              },
              id = 'left_tb',
              layout = wibox.layout.fixed.horizontal,
            },
            widget = wibox.container.place,
          },
          layout = wibox.layout.flex.vertical,
        },
        {
          { -- Right side
            titlebar_right,
            --[[ selectbox_right, ]]
            layout = wibox.layout.fixed.vertical,
          },
          { -- Center
            --[[ titlebar_center,
            selectbox_center, ]]
            layout = wibox.layout.fixed.vertical,
          },
          { -- Left side
            --[[ titlebar_left,
            selectbox_left, ]]
            layout = wibox.layout.fixed.vertical,
          },
          layout = wibox.layout.flex.vertical,
        },
        spacing_widget = wibox.widget.separator {
          color = beautiful.colorscheme.bg1,
        },
        spacing = dpi(5),
        layout = wibox.layout.flex.horizontal,
      },
      nil,
      layout = wibox.layout.align.vertical,
    },
    widget = wibox.container.constraint,
    width = dpi(capi.screen.primary.geometry.width * 0.6),
    strategy = 'exact',
  }

  local top_tb = widget:get_children_by_id('top_tb')[1]
  local left_tb = widget:get_children_by_id('left_tb')[1]
  local top_tb_radio = widget:get_children_by_id('top_tb_radio')[1]
  local left_tb_radio = widget:get_children_by_id('left_tb_radio')[1]

  top_tb:buttons(gtable.join(abutton({}, 1, function()
    top_tb_radio.checked = true
    left_tb_radio.checked = false
  end)))
  left_tb:buttons(gtable.join(abutton({}, 1, function()
    top_tb_radio.checked = false
    left_tb_radio.checked = true
  end)))

  return widget
end

--- The eighth page, to chose the font and icon theme
function setup:font_page()
  local widget = wibox.widget {
    widget = wibox.container.constraint,
    width = dpi(capi.screen.primary.geometry.width * 0.6),
    strategy = 'exact',
  }

  return widget
end

--- The ninth page, finish page, restart awesome
function setup:final_page()
  local widget = wibox.widget {
    widget = wibox.container.constraint,
    width = dpi(capi.screen.primary.geometry.width * 0.6),
    strategy = 'exact',
  }

  return widget
end

--- Show the next page
function setup:next()
  self.main_content:scroll(capi.screen.primary.geometry.width * 0.6)
end

--- Show the previous page
function setup:prev()
  self.main_content:scroll(-capi.screen.primary.geometry.width * 0.6)
end

function setup.new(args)
  args = args or {}

  -- Always display on the main screen
  local screen = capi.screen.primary

  local self = apopup {
    widget = {
      {
        nil,
        {
          { -- Main content
            widget = require('src.lib.overflow_widget.overflow').horizontal,
            scrollbar_width = 0,
            step = 1.075,
            id = 'main_content',
          },
          { -- Left button
            {
              {
                {
                  widget = wibox.widget.imagebox,
                  image = icon_dir .. 'left.svg',
                  rezise = true,
                },
                widget = wibox.container.background,
                id = 'page_left',
                bg = beautiful.colorscheme.bg .. '88',
              },
              widget = wibox.container.constraint,
              width = dpi(64),
              height = dpi(64),
              strategy = 'exact',
            },
            valign = 'center',
            halign = 'left',
            widget = wibox.container.place,
          },
          { -- Right button
            {
              {
                {
                  widget = wibox.widget.imagebox,
                  image = icon_dir .. 'right.svg',
                  rezise = true,
                },
                widget = wibox.container.background,
                id = 'page_right',
                bg = beautiful.colorscheme.bg .. '88',
              },
              widget = wibox.container.constraint,
              width = dpi(64),
              height = dpi(64),
              strategy = 'exact',
            },
            valign = 'center',
            halign = 'right',
            widget = wibox.container.place,
          },

          layout = wibox.layout.stack,
        },
        {
          { -- Current Page
            widget = wibox.widget.textbox,
            halign = 'center',
            valign = 'center',
            id = 'current_page',
          },
          widget = wibox.container.margin,
          margins = dpi(10),
        },
        layout = wibox.layout.align.vertical,
      },
      widget = wibox.container.constraint,
      width = dpi(screen.geometry.width * 0.6),
      height = dpi(screen.geometry.width * 0.6 * 9 / 16),
      strategy = 'exact',
    },
    screen = screen,
    bg = beautiful.colorscheme.bg,
    border_color = beautiful.colorscheme.bg1,
    border_width = dpi(2),
    placement = aplacement.centered,
    ontop = false, -- !CHANGE THIS TO TRUE WHEN DONE TESTING!
    visible = true,
  }

  gtable.crush(self, setup, true)

  self.main_content = self.widget:get_children_by_id('main_content')[1]

  self.main_content.children = create_pages()

  self.page = 1

  -- Current page
  local current_page = self.widget:get_children_by_id('current_page')[1]

  current_page:set_text(self.page .. ' / ' .. #self.main_content.children)

  -- Left button
  local page_left = self.widget:get_children_by_id('page_left')[1]
  page_left:buttons(gtable.join(
    abutton({}, 1, function()
      if self.page == 1 then return end
      self:prev()
      self.page = self.page - 1
      current_page:set_text(self.page .. ' / ' .. #self.main_content.children)
    end)
  ))

  -- Right button
  local page_right = self.widget:get_children_by_id('page_right')[1]
  page_right:buttons(gtable.join(
    abutton({}, 1, function()
      if self.page == #self.main_content.children then return end
      self:next()
      self.page = self.page + 1
      current_page:set_text(self.page .. ' / ' .. #self.main_content.children)
    end)
  ))

end

function setup.mt:__call(...)
  return setup.new(...)
end

return setmetatable(setup, setup.mt)
