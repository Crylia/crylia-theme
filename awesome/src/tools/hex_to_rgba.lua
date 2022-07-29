function RGB_to_hex(r, g, b)
  r = r or 0
  g = g or 0
  b = b or 0

  return string.format("#%02X%02X%02X", math.floor((r * 255) + 0.5), math.floor((g * 255) + 0.5),
    math.floor((b * 255) + 0.5))
end
