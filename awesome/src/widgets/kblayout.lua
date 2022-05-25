------------------------------
-- This is the audio widget --
------------------------------

-- Awesome Libs
local awful = require("awful")
local color = require("src.theme.colors")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
require("src.core.signals")

-- Icon directory path
local icondir = awful.util.getdir("config") .. "src/assets/icons/kblayout/"

return function(s)
  local kblayout_widget = wibox.widget {
    {
      {
        {
          {
            {
              id = "icon",
              widget = wibox.widget.imagebox,
              resize = false,
              image = gears.color.recolor_image(icondir .. "keyboard.svg", color["Grey900"])
            },
            id = "icon_layout",
            widget = wibox.container.place
          },
          top = dpi(2),
          widget = wibox.container.margin,
          id = "icon_margin"
        },
        spacing = dpi(10),
        {
          id = "label",
          align = "center",
          valign = "center",
          widget = wibox.widget.textbox
        },
        id = "kblayout_layout",
        layout = wibox.layout.fixed.horizontal
      },
      id = "container",
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin
    },
    bg = color["Green200"],
    fg = color["Grey900"],
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 5)
    end,
    widget = wibox.container.background
  }

  local function get_kblayout()
    awful.spawn.easy_async_with_shell(
      [[ setxkbmap -query | grep layout | awk '{print $2}' ]],
      function(stdout)
        local layout = stdout:gsub("\n", "")
        kblayout_widget.container.kblayout_layout.label.text = layout
        awesome.emit_signal("update::background:kblayout")
      end
    )
  end

  local function create_kb_layout_item(keymap)
    -- TODO: Add more, too lazy rn
    local longname, shortname

    local xkeyboard_country_code = {
      { "af", "أفغانيش(Afghanistan)", "AFG" }, -- Afghanistan
      { "al", "Shqip(Albania)", "ALB" }, -- Albania
      { "am", "Hայերեն(Armenia)", "ARM" }, -- Armenia
      { "ara", "عربي(Arab)", "ARB" }, -- Arabic
      { "at", "Österreichisch (Austria)", "AUT" }, -- Austria
      { "az", "Azərbaycan(Azerbaijan)", "AZE" }, -- Azerbaijan
      { "ba", "Bosanski(Bosnia and Herzegovina)", "BIH" }, -- Bosnia and Herzegovina
      { "bd", "", "BGD" }, -- Bangladesh
      { "be", "", "BEL" }, -- Belgium
      { "bg", "", "BGR" }, -- Bulgaria
      { "br", "", "BRA" }, -- Brazil
      { "bt", "", "BTN" }, -- Bhutan
      { "bw", "", "BWA" }, -- Botswana
      { "by", "", "BLR" }, -- Belarus
      { "ca", "", "CAN" }, -- Canada
      { "cd", "", "COD" }, -- Congo
      { "ch", "", "CHE" }, -- Switzerland
      { "cm", "", "CMR" }, -- Cameroon
      { "cn", "", "CHN" }, -- China
      { "cz", "", "CZE" }, -- Czechia
      { "de", "Deutsch (Germany)", "GER" }, -- Germany
      { "dk", "", "DNK" }, -- Denmark
      { "ee", "", "EST" }, -- Estonia
      { "es", "", "ESP" }, -- Spain
      { "et", "", "ETH" }, -- Ethiopia
      { "eu", "?", "?" }, -- EurKey
      { "fi", "", "FIN" }, -- Finland
      { "fo", "", "FRO" }, -- Faroe Islands
      { "fr", "", "FRA" }, -- France
      { "gb", "English (Bri'ish)", "ENG" }, -- United Kingdom
      { "ge", "", "GEO" }, -- Georgia
      { "gh", "", "GHA" }, -- Ghana
      { "gn", "", "GIN" }, -- Guinea
      { "gr", "", "GRC" }, -- Greece
      { "hr", "", "HRV" }, -- Croatia
      { "hu", "", "HUN" }, -- Hungary
      { "ie", "", "IRL" }, -- Ireland
      { "il", "", "ISR" }, -- Israel
      { "in", "", "IND" }, -- India
      { "iq", "", "IRQ" }, -- Iraq
      { "ir", "", "IRN" }, -- Iran
      { "is", "", "ISL" }, -- Iceland
      { "it", "", "ITA" }, -- Italy
      { "jp", "", "JPN" }, -- Japan
      { "ke", "", "KEN" }, -- Kenya
      { "kg", "", "KGZ" }, -- Kyrgyzstan
      { "kh", "", "KHM" }, -- Cambodia
      { "kr", "", "KOR" }, -- Korea
      { "kz", "", "KAZ" }, -- Kazakhstan
      { "la", "", "LAO" }, -- Laos
      { "latam", "?", "?" }, -- Latin America
      { "latin", "?", "?" }, -- Latin
      { "lk", "", "LKA" }, -- Sri Lanka
      { "lt", "", "LTU" }, -- Lithuania
      { "lv", "", "LVA" }, -- Latvia
      { "ma", "", "MAR" }, -- Morocco
      { "mao", "?", "?" }, -- Maori
      { "me", "", "MNE" }, -- Montenegro
      { "mk", "", "MKD" }, -- Macedonia
      { "ml", "", "MLI" }, -- Mali
      { "mm", "", "MMR" }, -- Myanmar
      { "mn", "", "MNG" }, -- Mongolia
      { "mt", "", "MLT" }, -- Malta
      { "mv", "", "MDV" }, -- Maldives
      { "ng", "", "NGA" }, -- Nigeria
      { "nl", "", "NLD" }, -- Netherlands
      { "no", "", "NOR" }, -- Norway
      { "np", "", "NRL" }, -- Nepal
      { "ph", "", "PHL" }, -- Philippines
      { "pk", "", "PAK" }, -- Pakistan
      { "pl", "", "POL" }, -- Poland
      { "pt", "", "PRT" }, -- Portugal
      { "ro", "", "ROU" }, -- Romania
      { "rs", "", "SRB" }, -- Serbia
      { "ru", "Русский (Russia)", "RUS" }, -- Russia
      { "se", "", "SWE" }, -- Sweden
      { "si", "", "SVN" }, -- Slovenia
      { "sk", "", "SVK" }, -- Slovakia
      { "sn", "", "SEN" }, -- Senegal
      { "sy", "", "SYR" }, -- Syria
      { "th", "", "THA" }, -- Thailand
      { "tj", "", "TJK" }, -- Tajikistan
      { "tm", "", "TKM" }, -- Turkmenistan
      { "tr", "", "TUR" }, -- Turkey
      { "tw", "", "TWN" }, -- Taiwan
      { "tz", "", "TZA" }, -- Tanzania
      { "ua", "", "UKR" }, -- Ukraine
      { "us", "English (United States)", "USA" }, -- USA
      { "uz", "", "UZB" }, -- Uzbekistan
      { "vn", "", "VNM" }, -- Vietnam
      { "za", "", "ZAF" } -- South Africa
    }

    for _, c in ipairs(xkeyboard_country_code) do
      if c[1] == keymap then
        longname = c[2]
        shortname = c[3]
      end
    end

    local kb_layout_item = wibox.widget {
      {
        {
          -- Short name e.g. GER, ENG, RUS
          {
            {
              text = shortname,
              widget = wibox.widget.textbox,
              font = user_vars.font.extrabold,
              id = "shortname"
            },
            fg = color["Red200"],
            widget = wibox.container.background,
            id = "background2"
          },
          {
            {
              text = longname,
              widget = wibox.widget.textbox,
              font = user_vars.font.bold,
              id = "longname",
            },
            fg = color["Purple200"],
            widget = wibox.container.background,
            id = "background1"
          },
          spacing = dpi(15),
          layout = wibox.layout.fixed.horizontal,
          id = "container"
        },
        margins = dpi(10),
        widget = wibox.container.margin,
        id = "margin"
      },
      shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 8)
      end,
      bg = color["Grey800"],
      fg = color["White"],
      widget = wibox.container.background,
      id = "background",
      keymap = keymap
    }

    -- TODO: Hover effects, this is more pain than I'm willing to take for now
    awesome.connect_signal(
      "update::background:kblayout",
      function()
        awful.spawn.easy_async_with_shell(
          [[ setxkbmap -query | grep layout | awk '{print $2}' ]],
          function(stdout)
            local layout = stdout:gsub("\n", "")
            if kb_layout_item.keymap == layout then
              kb_layout_item.bg = color["DeepPurple200"]
              kb_layout_item:get_children_by_id("background2")[1].fg = color["Grey900"]
              kb_layout_item:get_children_by_id("background1")[1].fg = color["Grey900"]
            else
              kb_layout_item.bg = color["Grey800"]
              kb_layout_item:get_children_by_id("background2")[1].fg = color["Red200"]
              kb_layout_item:get_children_by_id("background1")[1].fg = color["Purple200"]
            end
          end
        )
      end
    )

    get_kblayout()

    kb_layout_item:connect_signal(
      "button::press",
      function()
        awful.spawn.easy_async_with_shell(
          "setxkbmap " .. keymap,
          function()
            awesome.emit_signal("kblayout::hide:kbmenu")
            mousegrabber.stop()
            get_kblayout()
          end
        )
      end
    )
    return kb_layout_item
  end

  local function get_kblist()
    local kb_layout_items = {
      layout = wibox.layout.fixed.vertical,
      spacing = dpi(10)
    }
    for i, keymap in pairs(user_vars.kblayout) do
      kb_layout_items[i] = create_kb_layout_item(keymap)
    end
    local cont = {
      {
        kb_layout_items,
        margins = dpi(10),
        widget = wibox.container.margin
      },
      layout = wibox.layout.fixed.vertical,
    }
    return cont
  end

  local kb_menu_widget = awful.popup {
    screen = s,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 12)
    end,
    widget = wibox.container.background,
    bg = color["Grey900"],
    fg = color["White"],
    border_width = dpi(4),
    border_color = color["Grey800"],
    width = dpi(100),
    max_height = dpi(600),
    visible = false,
    ontop = true,
    placement = function(c) awful.placement.align(c, { position = "top_right", margins = { right = dpi(255), top = dpi(60) } }) end
  }

  kb_menu_widget:connect_signal(
    "mouse::leave",
    function()
      mousegrabber.run(
        function()
          kblayout_widget.bg = color["Green200"]
          awesome.emit_signal("kblayout::hide:kbmenu")
          mousegrabber.stop()
          return true
        end,
        "arrow"
      )
    end
  )

  kb_menu_widget:connect_signal(
    "mouse::enter",
    function()
      mousegrabber.stop()
    end
  )

  kb_menu_widget:setup(
    get_kblist()
  )

  local function toggle_kb_layout()
    awful.spawn.easy_async_with_shell(
      "setxkbmap -query | grep layout: | awk '{print $2}'",
      function(stdout)
        for j, n in ipairs(user_vars.kblayout) do
          if stdout:match(n) then
            if j == #user_vars.kblayout then
              awful.spawn.easy_async_with_shell(
                "setxkbmap " .. user_vars.kblayout[1],
                function()
                  get_kblayout()
                end
              )
            else
              awful.spawn.easy_async_with_shell(
                "setxkbmap " .. user_vars.kblayout[j + 1],
                function()
                  get_kblayout()
                end
              )
            end
          end
        end
      end
    )
  end

  awesome.connect_signal(
    "kblayout::toggle",
    function()
      toggle_kb_layout()
    end
  )

  -- Signals
  Hover_signal(kblayout_widget, color["Green200"], color["Grey900"])

  local kblayout_keygrabber = awful.keygrabber {
    autostart = false,
    stop_event = 'release',
    keypressed_callback = function(self, mod, key, command)
      awesome.emit_signal("kblayout::hide:kbmenu")
      mousegrabber.stop()
    end
  }

  kblayout_widget:connect_signal(
    "button::press",
    function()
      mousegrabber.stop()
      if kb_menu_widget.visible then
        kb_menu_widget.visible = false
        kblayout_keygrabber:stop()
      else
        kb_menu_widget.visible = true
        kblayout_keygrabber:start()
      end
    end
  )

  awesome.connect_signal(
    "kblayout::hide:kbmenu",
    function()
      kb_menu_widget.visible = false
      kblayout_keygrabber:stop()
    end
  )

  get_kblayout()
  kb_menu_widget.visible = false
  return kblayout_widget
end
