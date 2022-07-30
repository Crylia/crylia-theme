local lgi = require("lgi")
local Gtk = lgi.require("Gtk", "3.0")

local gtk_theme = Gtk.IconTheme.new()
Gtk.IconTheme.set_custom_theme(gtk_theme, User_config.icon_theme)

function Get_gicon_path(app)
  local icon_info = gtk_theme:lookup_by_gicon(app, 64, 0)
  if icon_info then
    local path = icon_info:get_filename()
    if path then
      return path
    end
  end
  return ""
end
