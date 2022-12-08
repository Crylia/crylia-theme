local cairo = require("lgi").cairo
local gcolor = require("gears.color")
local gdk = require("lgi").Gdk
local gsurface = require("gears.surface")
local gtable = require("gears.table")

local color_helper = { mt = {} }
color_helper.color_rules = {}

function color_helper.set_color_rule(c, color)
  color_helper.color_rules[c.instance] = color
end

function color_helper.get_color_rule(c)
  return color_helper.color_rules[c.instance]
end

function color_helper.lighten(color, amount)
  local r, g, b
  r, g, b = gcolor.parse_color(color)
  r = 255 * r
  g = 255 * g
  b = 255 * b
  r = r + math.floor(2.55 * amount)
  g = g + math.floor(2.55 * amount)
  b = b + math.floor(2.55 * amount)
  r = r > 255 and 255 or r
  g = g > 255 and 255 or g
  b = b > 255 and 255 or b
  return ("#%02x%02x%02x"):format(r, g, b)
end

function color_helper.duotone_gradient_vertical(color_1, color_2, height, offset_1, offset_2)
  local fill_pattern = cairo.Pattern.create_linear(0, 0, 0, height)
  local r, g, b, a
  r, g, b, a = gcolor.parse_color(color_1)
  fill_pattern:add_color_stop_rgba(offset_1 or 0, r, g, b, a)
  r, g, b, a = gcolor.parse_color(color_2)
  fill_pattern:add_color_stop_rgba(offset_2 or 1, r, g, b, a)
  return fill_pattern
end

function color_helper.get_dominant_color(client)
  local color, pb, bytes
  local tally, content, cgeo = {}, gsurface(client.content), client:geometry()
  local x_offset, y_offset, x_lim = 2, 2, math.floor(cgeo.width / 2)

  for x_pos = 0, x_lim, 2 do
    for y_pos = 0, 8, 1 do
      pb = gdk.pixbuf_get_from_surface(content, x_offset + x_pos, y_offset + y_pos, 1, 1)
      bytes = pb:get_pixels()
      color = "#" .. bytes:gsub(".", function(c)
        return ("%02x"):format(c:byte())
      end)
      if not tally[color] then
        tally[color] = 1
      else
        tally[color] = tally[color] + 1
      end
    end
  end
  local mode
  local mode_c = 0
  for k, v in pairs(tally) do
    if v > mode_c then
      mode_c = v
      mode = k
    end
  end
  color = mode
  color_helper.set_color_rule(client, color)
  return color
end

function color_helper.new(args)
  local ret = {}

  gtable.crush(ret, color_helper, true)

  return ret
end

function color_helper.mt:__call(...)
  return color_helper.new(...)
end

return setmetatable(color_helper, color_helper.mt)
