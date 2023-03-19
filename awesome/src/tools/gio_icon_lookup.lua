-- Libraries
local lgi = require('lgi')
local Gtk = lgi.require('Gtk', '3.0')

-- Init a new Gtk theme from the users string
local gtk_theme = Gtk.IconTheme.get_default()

---Gets the icon path from an AppInfo gicon.
---@param app Gio.AppInfo|nil
---@param icon_string string|nil
---@return string|nil path
function Get_gicon_path(app, icon_string)
  if (not app) and (not icon_string) then return end
  if icon_string then
    return gtk_theme:lookup_icon(icon_string, 64, 0):get_filename() or ''
  end

  local icon_info = gtk_theme:lookup_by_gicon(app, 64, 0)
  if icon_info then
    return icon_info:get_filename()
  end
  return nil
end
