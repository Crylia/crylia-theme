local Playerctl = require('lgi').Playerctl
local http_request = require('http.request')
local Cairo = require('lgi').cairo
local Gdk = require('lgi').Gdk
local GdkPixbuf = require('lgi').GdkPixbuf
local gfilesystem = require('gears.filesystem')
local gtimer = require('gears.timer')
local gcolor = require('gears.color')
local gtable = require('gears.table')
local beautiful = require('beautiful')

local icondir = gfilesystem.get_configuration_dir() .. 'src/assets/icons/notifications/'

Gdk.init {}

local instance = nil

local music_player = {}

--#region Audio control mappings

function music_player:next() self.player:next() end

function music_player:prev() self.player:previous() end

function music_player:play_pause() self.player:play_pause() end

function music_player:play() self.player:play() end

function music_player:pause() self.player:pause() end

--TODO: Needs validation
function music_player:get_length()
  local length = self.player:print_metadata_prop('mpris:length') or 0
  return tonumber(length) / 1000000
end

function music_player:set_shuffle()
  self.player:set_shuffle(not self.player.shuffle)
end

-- None, Track, Playlist, loops trough them if not specified
function music_player:set_loop_status(state)
  if state then
    self.player:set_loop_status(state)
    return
  end
  if self.player.loop_status == 'NONE' then
    self.player:set_loop_status('PLAYLIST')
  elseif self.player.loop_status == 'PLAYLIST' then
    self.player:set_loop_status('TRACK')
  elseif self.player.loop_status == 'TRACK' then
    self.player:set_loop_status('NONE')
  end
end

--#endregion

--#region Metadata getter and setter

function music_player:get_artist() return self.player:get_artist() end

function music_player:get_title() return self.player:get_title() end

function music_player:get_album() return self.player:get_album() end

function music_player:get_position() return (self.player:get_position() / 1000000) end

function music_player:set_position() return self.player:set_position() end

function music_player:get_art(url)
  url = url or self.player:print_metadata_prop('mpris:artUrl')
  if url and url:match('^https?://') then
    local scheme = http_request.new_from_uri(url)
    if not scheme then return end
    local headers, stream = assert(scheme:go())
    if not (stream or headers) then return end
    local body = assert(stream:get_body_as_string())
    if headers:get ':status' ~= '200' then
      error(body)
    end
    local loader = GdkPixbuf.PixbufLoader()
    loader:write(body)
    loader:close()

    local image = loader:get_pixbuf()

    local surface = Cairo.ImageSurface.create(Cairo.Format.ARGB32, image:get_width(), image:get_height())
    local cr = Cairo.Context(surface)

    -- Render the image onto the surface
    Gdk.cairo_set_source_pixbuf(cr, image, 0, 0)
    cr:paint()

    body = nil
    loader = nil
    image = nil
    collectgarbage()

    return surface
  elseif url and url:match('^file://') then
    return url:gsub('%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end):gsub('^file://', '')
  end
  return icondir .. 'default_image.svg'
end

--#endregion

local priority_players = {
  'vlc',
  'spotify',
}

function music_player:player_gets_priority(name)
  -- If for some reason there is no player, manage the new one
  if not name then return true end

  for _, n in ipairs(priority_players) do
    if name.name:lower():match(n) then return true end
  end

  -- If the currently managed player is playing, don't change it
  if self.player.playback_status == 'PLAYING' then return false end
  return true
end

local function start_manage(self, w, name)

  if not self:player_gets_priority(name) then return end
  self.player = Playerctl.Player.new_from_name(name)

  self.playermanager:manage_player(self.player)

  if not self.player.player_name then return end

  local function on_metadata(_, metadata)
    if not metadata then return end
    w:get_children_by_id('title')[1].text = metadata.value['xesam:title'] or 'Unknown Title'
    w:get_children_by_id('artist')[1].text = metadata.value['xesam:artist'] and metadata.value['xesam:artist'][1] or 'Unknown Artist'
    local length = (metadata.value['mpris:length'] or 0) / 1000000
    w:get_children_by_id('length')[1].text = string.format('%02d:%02d', math.floor(length / 60), math.floor(length % 60))
    w:get_children_by_id('progress')[1].max_value = length
    w:get_children_by_id('album_art')[1].image = self:get_art(metadata.value['mpris:artUrl'])
    self.gtimer = gtimer {
      timeout = 1,
      autostart = true,
      callback = function()
        local position = self:get_position()
        w:get_children_by_id('position')[1].text = string.format('%02d:%02d', math.floor(position / 60), math.floor(position % 60))
        w:get_children_by_id('progress')[1].value = position
      end,
    }
  end

  self.player.on_metadata = on_metadata
  on_metadata(nil, self.player.metadata)

  local function on_loop_status(_, status)
    if status == 'TRACK' then
      w:get_children_by_id('repeat')[1].image = gcolor.recolor_image(icondir .. 'repeat-once.svg',
        beautiful.colorscheme.bg_green)
    elseif status == 'PLAYLIST' then
      w:get_children_by_id('repeat')[1].image = gcolor.recolor_image(icondir .. 'repeat.svg',
        beautiful.colorscheme.bg_green)
    else
      w:get_children_by_id('repeat')[1].image = gcolor.recolor_image(icondir .. 'repeat.svg',
        beautiful.colorscheme.bg1)
    end
  end

  self.player.on_loop_status = on_loop_status
  on_loop_status(nil, self.player.loop_status)

  local function on_shuffle(_, status)
    if status then
      w:get_children_by_id('shuffle')[1].image = gcolor.recolor_image(icondir .. 'shuffle.svg',
        beautiful.colorscheme.bg_green)
    else
      w:get_children_by_id('shuffle')[1].image = gcolor.recolor_image(icondir .. 'shuffle.svg',
        beautiful.colorscheme.bg1)
    end
  end

  self.player.on_shuffle = on_shuffle
  on_shuffle(nil, self.player.shuffle)
end

if not instance then
  instance = setmetatable(music_player, { __call = function(_, w)
    if not w then return end

    local ret = {}

    gtable.crush(ret, music_player)

    ret.playermanager = Playerctl.PlayerManager()
    ret.player = Playerctl.Player()

    if ret.player.player_name then
      start_manage(ret, w, Playerctl:list_players()[1])
    end

    ret.playermanager.on_name_appeared = function(_, name)
      start_manage(ret, w, name)
    end

    ret.playermanager.on_name_vanished = function()
      start_manage(ret, w, Playerctl:list_players()[1])
    end

    return ret
  end, })
end
return instance
