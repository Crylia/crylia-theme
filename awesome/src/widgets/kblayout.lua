local pairs = pairs
local setmetatable = setmetatable
local tunpack = table.unpack

-- Awesome Libs
local abutton = require('awful.button')
local apopup = require('awful.popup')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local gcolor = require('gears.color')
local gfilesystem = require('gears.filesystem')
local gtable = require('gears.table')
local gtimer = require('gears.timer')
local wibox = require('wibox')

-- Local libs
local hover = require('src.tools.hover')
local kb_helper = require('src.tools.helpers.kb_helper')

local capi = {
  mouse = mouse,
}

-- Icon directory path
local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/kblayout/'

local kb_layout_popup

local function create_kb_layout_list()
  local widget = wibox.widget {
    {
      {
        id = 'list',
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(10),
      },
      widget = wibox.container.margin,
      margins = dpi(10),
    },
    widget = wibox.container.background,
    bg = beautiful.colorscheme.bg,
  }

  local list = widget:get_children_by_id('list')[1]
  for _, keymap in pairs(beautiful.user_config.kblayout) do
    -- TODO: Add more, too lazy rn
    local xkeyboard_country_code = {
      ['af'] = { 'أفغانيش(Afghanistan)', 'AFG' }, -- Afghanistan
      ['al'] = { 'Shqip(Albania)', 'ALB' }, -- Albania
      ['am'] = { 'Hայերեն(Armenia)', 'ARM' }, -- Armenia
      ['ara'] = { 'عربي(Arab)', 'ARB' }, -- Arabic
      ['at'] = { 'Österreichisch (Austria)', 'AUT' }, -- Austria
      ['az'] = { 'Azərbaycan(Azerbaijan)', 'AZE' }, -- Azerbaijan
      ['ba'] = { 'Bosanski(Bosnia and Herzegovina)', 'BIH' }, -- Bosnia and Herzegovina
      ['bd'] = { '', 'BGD' }, -- Bangladesh
      ['be'] = { '', 'BEL' }, -- Belgium
      ['bg'] = { '', 'BGR' }, -- Bulgaria
      ['br'] = { '', 'BRA' }, -- Brazil
      ['bt'] = { '', 'BTN' }, -- Bhutan
      ['bw'] = { '', 'BWA' }, -- Botswana
      ['by'] = { '', 'BLR' }, -- Belarus
      ['ca'] = { '', 'CAN' }, -- Canada
      ['cd'] = { '', 'COD' }, -- Congo
      ['ch'] = { '', 'CHE' }, -- Switzerland
      ['cm'] = { '', 'CMR' }, -- Cameroon
      ['cn'] = { '', 'CHN' }, -- China
      ['cz'] = { '', 'CZE' }, -- Czechia
      ['de'] = { 'Deutsch (Germany)', 'GER' }, -- Germany
      ['dk'] = { '', 'DNK' }, -- Denmark
      ['ee'] = { '', 'EST' }, -- Estonia
      ['es'] = { '', 'ESP' }, -- Spain
      ['et'] = { '', 'ETH' }, -- Ethiopia
      ['eu'] = { '?', '?' }, -- EurKey
      ['fi'] = { '', 'FIN' }, -- Finland
      ['fo'] = { '', 'FRO' }, -- Faroe Islands
      ['fr'] = { '', 'FRA' }, -- France
      ['gb'] = { "English (Bri'ish)", 'ENG' }, -- United Kingdom
      ['ge'] = { '', 'GEO' }, -- Georgia
      ['gh'] = { '', 'GHA' }, -- Ghana
      ['gn'] = { '', 'GIN' }, -- Guinea
      ['gr'] = { '', 'GRC' }, -- Greece
      ['hr'] = { '', 'HRV' }, -- Croatia
      ['hu'] = { '', 'HUN' }, -- Hungary
      ['ie'] = { '', 'IRL' }, -- Ireland
      ['il'] = { '', 'ISR' }, -- Israel
      ['in'] = { '', 'IND' }, -- India
      ['iq'] = { '', 'IRQ' }, -- Iraq
      ['ir'] = { '', 'IRN' }, -- Iran
      ['is'] = { '', 'ISL' }, -- Iceland
      ['it'] = { '', 'ITA' }, -- Italy
      ['jp'] = { '', 'JPN' }, -- Japan
      ['ke'] = { '', 'KEN' }, -- Kenya
      ['kg'] = { '', 'KGZ' }, -- Kyrgyzstan
      ['kh'] = { '', 'KHM' }, -- Cambodia
      ['kr'] = { '', 'KOR' }, -- Korea
      ['kz'] = { '', 'KAZ' }, -- Kazakhstan
      ['la'] = { '', 'LAO' }, -- Laos
      ['latm'] = { '?', '?' }, -- Latin America
      ['latn'] = { '?', '?' }, -- Latin
      ['lk'] = { '', 'LKA' }, -- Sri Lanka
      ['lt'] = { '', 'LTU' }, -- Lithuania
      ['lv'] = { '', 'LVA' }, -- Latvia
      ['ma'] = { '', 'MAR' }, -- Morocco
      ['mao'] = { '?', '?' }, -- Maori
      ['me'] = { '', 'MNE' }, -- Montenegro
      ['mk'] = { '', 'MKD' }, -- Macedonia
      ['ml'] = { '', 'MLI' }, -- Mali
      ['mm'] = { '', 'MMR' }, -- Myanmar
      ['mn'] = { '', 'MNG' }, -- Mongolia
      ['mt'] = { '', 'MLT' }, -- Malta
      ['mv'] = { '', 'MDV' }, -- Maldives
      ['ng'] = { '', 'NGA' }, -- Nigeria
      ['nl'] = { '', 'NLD' }, -- Netherlands
      ['no'] = { '', 'NOR' }, -- Norway
      ['np'] = { '', 'NRL' }, -- Nepal
      ['ph'] = { '', 'PHL' }, -- Philippines
      ['pk'] = { '', 'PAK' }, -- Pakistan
      ['pl'] = { '', 'POL' }, -- Poland
      ['pt'] = { '', 'PRT' }, -- Portugal
      ['ro'] = { '', 'ROU' }, -- Romania
      ['rs'] = { '', 'SRB' }, -- Serbia
      ['ru'] = { 'Русский (Russia)', 'RUS' }, -- Russia
      ['se'] = { '', 'SWE' }, -- Sweden
      ['si'] = { '', 'SVN' }, -- Slovenia
      ['sk'] = { '', 'SVK' }, -- Slovakia
      ['sn'] = { '', 'SEN' }, -- Senegal
      ['sy'] = { '', 'SYR' }, -- Syria
      ['th'] = { '', 'THA' }, -- Thailand
      ['tj'] = { '', 'TJK' }, -- Tajikistan
      ['tm'] = { '', 'TKM' }, -- Turkmenistan
      ['tr'] = { '', 'TUR' }, -- Turkey
      ['tw'] = { '', 'TWN' }, -- Taiwan
      ['tz'] = { '', 'TZA' }, -- Tanzania
      ['ua'] = { '', 'UKR' }, -- Ukraine
      ['us'] = { 'English (United States)', 'USA' }, -- USA
      ['uz'] = { '', 'UZB' }, -- Uzbekistan
      ['vn'] = { '', 'VNM' }, -- Vietnam
      ['za'] = { '', 'ZAF' }, -- South Africa
    }

    local longname, shortname = tunpack(xkeyboard_country_code[keymap])

    local kb_layout_item = wibox.widget {
      {
        {
          {
            id = 'shortname',
            markup = '<span foreground="' .. beautiful.colorscheme.bg_purple .. '">' .. shortname .. '</span>',
            widget = wibox.widget.textbox,
            valign = 'center',
            halign = 'center',
          },
          {
            id = 'longname',
            markup = '<span foreground="' .. beautiful.colorscheme.bg_red .. '">' .. longname .. '</span>',
            widget = wibox.widget.textbox,
            font = beautiful.user_config.font.bold,
          },
          spacing = dpi(15),
          layout = wibox.layout.fixed.horizontal,
        },
        margins = dpi(10),
        widget = wibox.container.margin,
      },
      id = 'hover',
      shape = beautiful.shape[6],
      border_width = dpi(2),
      border_color = beautiful.colorscheme.border_color,
      bg = beautiful.colorscheme.bg,
      widget = wibox.container.background,
    }

    kb_helper:connect_signal('KB::layout_changed', function(_, k)
      if keymap == k then
        kb_layout_item.bg = beautiful.colorscheme.bg_purple
        kb_layout_item.border_color = beautiful.colorscheme.bg_purple
        kb_layout_item:get_children_by_id('shortname')[1].markup = '<span foreground="' .. beautiful.colorscheme.bg .. '">' .. shortname .. '</span>'
        kb_layout_item:get_children_by_id('longname')[1].markup = '<span foreground="' .. beautiful.colorscheme.bg .. '">' .. longname .. '</span>'
      else
        kb_layout_item.bg = beautiful.colorscheme.bg
        kb_layout_item.border_color = beautiful.colorscheme.border_color
        kb_layout_item:get_children_by_id('shortname')[1].markup = '<span foreground="' .. beautiful.colorscheme.bg_purple .. '">' .. shortname .. '</span>'
        kb_layout_item:get_children_by_id('longname')[1].markup = '<span foreground="' .. beautiful.colorscheme.bg_red .. '">' .. longname .. '</span>'
      end
    end)

    kb_helper:get_layout_async(function(k)
      if keymap == k then
        kb_layout_item.bg = beautiful.colorscheme.bg_purple
        kb_layout_item.border_color = beautiful.colorscheme.bg_purple
        kb_layout_item:get_children_by_id('shortname')[1].markup = '<span foreground="' .. beautiful.colorscheme.bg .. '">' .. shortname .. '</span>'
        kb_layout_item:get_children_by_id('longname')[1].markup = '<span foreground="' .. beautiful.colorscheme.bg .. '">' .. longname .. '</span>'
      else
        kb_layout_item.bg = beautiful.colorscheme.bg
        kb_layout_item.border_color = beautiful.colorscheme.border_color
        kb_layout_item:get_children_by_id('shortname')[1].markup = '<span foreground="' .. beautiful.colorscheme.bg_purple .. '">' .. shortname .. '</span>'
        kb_layout_item:get_children_by_id('longname')[1].markup = '<span foreground="' .. beautiful.colorscheme.bg_red .. '">' .. longname .. '</span>'
      end
    end)

    hover.bg_hover { widget = kb_layout_item }

    kb_layout_item:buttons { gtable.join(
      abutton({}, 1, function()
        kb_helper:set_layout(keymap)
      end)
    ), }

    list:add(kb_layout_item)
  end

  return widget
end

return setmetatable({}, { __call = function(_, screen)
  local kblayout_widget = wibox.widget {
    {
      {
        {
          {
            widget = wibox.widget.imagebox,
            resize = true,
            valign = 'center',
            halign = 'center',
            image = gcolor.recolor_image(icondir .. 'keyboard.svg', beautiful.colorscheme.bg),
          },
          widget = wibox.container.constraint,
          width = dpi(24),
          height = dpi(24),
          strategy = 'exact',
        },
        {
          id = 'text_role',
          halign = 'center',
          valign = 'center',
          widget = wibox.widget.textbox,
        },
        spacing = dpi(10),
        layout = wibox.layout.fixed.horizontal,
      },
      left = dpi(8),
      right = dpi(8),
      widget = wibox.container.margin,
    },
    bg = beautiful.colorscheme.bg_green,
    fg = beautiful.colorscheme.bg,
    shape = beautiful.shape[6],
    widget = wibox.container.background,
  }

  hover.bg_hover { widget = kblayout_widget }

  kb_helper:get_layout_async(function(stdout)
    kblayout_widget:get_children_by_id('text_role')[1].text = stdout:gsub('\n', '')
  end)

  kb_helper:connect_signal('KB::layout_changed', function(_, k)
    kblayout_widget:get_children_by_id('text_role')[1].text = k
  end)

  kb_layout_popup = apopup {
    widget = create_kb_layout_list(),
    border_color = beautiful.colorscheme.border_color,
    border_width = dpi(2),
    screen = screen,
    ontop = true,
    visible = true,
    bg = beautiful.colorscheme.bg,
  }

  -- Delayed call to make the popup invisible,
  -- needed to give it time to evaluate its dimensions
  gtimer.delayed_call(function()
    kb_layout_popup.visible = false
  end)

  kblayout_widget:buttons { gtable.join(
    abutton({}, 1, function()
      local geo = capi.mouse.coords()
      kb_layout_popup.y = dpi(70)
      kb_layout_popup.x = geo.x - kb_layout_popup.width / 2
      kb_layout_popup.visible = not kb_layout_popup.visible
    end)
  ), }

  return kblayout_widget
end, })
