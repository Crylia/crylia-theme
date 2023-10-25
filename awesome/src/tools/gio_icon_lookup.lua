local setmetatable = setmetatable

-- Libraries
local lgi = require('lgi')
local Gtk = lgi.require('Gtk', '3.0')

local icon_lookup = {}

function icon_lookup:get_gicon_path(app, icon_string)
  if (not app) and (not icon_string) or not self.gtk_theme then return end
  
  if icon_string then
    local icon = self.gtk_theme:lookup_icon(icon_string or "", 64, 0)
    if icon then
      return icon:get_filename() or ''
    end
  end
    
  if app then
    local icon_info = self.gtk_theme:lookup_by_gicon(app, 64, 0)
    if icon_info then
      return icon_info:get_filename()
    end
  end

  return nil
end

local instance = nil
if not instance then
  instance = setmetatable(icon_lookup, {
    __call = function(self, theme_name,...)
      self.gtk_theme = Gtk.IconTheme.get_default()
    
      return self
    end,
  })
end
return instance
