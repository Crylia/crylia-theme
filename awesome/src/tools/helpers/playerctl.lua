-- 99.9% Stolen from bling

local gobject = require("gears.object")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local gstring = require("gears.string")

local playerctl = { mt = {} }
playerctl._private = {}

function playerctl:play_pause(player)
  player = player or self._private.manager.players[1]
  if player then
    player:play_pause()
  end
end

function playerctl:next(player)
  player = player or self._private.manager.players[1]
  if player then
    player:next()
  end
end

function playerctl:previous(player)
  player = player or self._private.manager.players[1]
  if player then
    player:previous()
  end
end

function playerctl:cycle_loop(player)
  player = player or self._private.manager.players[1]
  if player then
    local loop_status = player.loop_status
    if loop_status == "NONE" then
      player:set_loop_status("TRACK")
    elseif loop_status == "TRACK" then
      player:set_loop_status("PLAYLIST")
    elseif loop_status == "PLAYLIST" then
      player:set_loop_status("NONE")
    end
  end
end

function playerctl:cycle_shuffle(player)
  player = player or self._private.manager.players[1]
  if player then
    player:set_shuffle(not player.shuffle)
  end
end

function playerctl:set_position(position, player)
  player = player or self._private.manager.players[1]
  if player then
    player:set_position(position * 1000000)
  end
end

function playerctl:get_manager()
  return self._private.manager
end

function playerctl:get_current_player()
  return self._private.manager.players[1].name
end

local function emit_metadata_callback(self, title, artist, art_url, album, new, player_name)
  title = gstring.xml_escape(title)
  artist = gstring.xml_escape(artist)
  album = gstring.xml_escape(album)

  if player_name == "spotify" then
    art_url = art_url:gsub("open.spotify.com", "i.scdn.co")
  end

  if not art_url or art_url == "" then
  else
    awesome.emit_signal("playerctl::title_artist_album", title, artist, "", player_name)
    self:emit_signal("metadata", title, artist, "", album, new, player_name)
  end
end

local function metadata_callback(self, player, metadata)
  if self.update_on_activity then
    self._private.manager:mover_player_to_front(player)
  end

  local data = metadata.value
  local title = data["xesam:title"] or ""
  local artist = data["xesam:artist"] or ""
  for i = 2, #data["xesam:artist"] do
    artist = artist .. ", " .. data["xesam:artist"][i]
  end
  local art_url = data["mpris:artUrl"] or ""
  local album = data["xesam:album"] or ""

  if player == self._private.manager.players[1] then
    if (not player == self._private.last_player) or (not title == self._private.manager.last_title) or
        (not artist == self._private.manager.last_artist) or (not art_url == self._private.manager.last_art_url) then
      if (title == "") and (artist == "") and (art_url == "") then return end

      if (not self._private.metadata_timer) and self._private.metadata_timer.started then
        self._private.metadata_timer:stop()
      end

      self._private.metadata_timer = gtimer {
        timeout = 1,
        autostart = true,
        single_shot = true,
        callback = function()
          emit_metadata_callback(self, title, artist, art_url, album, true, player.name)
        end
      }

      self._private.manager.pos_timer:again()
      self._private.manager.last_title = title
      self._private.manager.last_artist = artist
      self._private.manager.last_art_url = art_url
      self._private.last_player = player
    end
  end
end

local function pos_callback(self)
  local player = self._private.manager.players[1]
  if player then
    local pos = player:get_position() / 1000000
    local dur = (player.metadata.value["mpris:length"] or 0) / 1000000
    if (not pos == self._private.last_pos) or (not dur == self._private.last_length) then
      self._private.pos = pos
      self._private.dur = dur
      self:emit_signal("position", pos, dur, player.player_name)
    end
  end
end

local function playback_status_callback(self, player, status)
  if self.update_on_activity then
    self._private.manager:mover_player_to_front(player)
  end

  if player == self._private.manager.players[1] then
    self._private.active_player = player

    if status == "PLAYING" then
      self:emit_signal("playerctl::playback_status", true, player.player_name)
      awesome.emit_signal("playerctl::playback_status", true, player.player_name)
    else
      self:emit_signal("playerctl::playback_status", false, player.player_name)
      awesome.emit_signal("playerctl::playback_status", false, player.player_name)
    end
  end
end

local function loop_callback(self, player, loop_status)
  if self.update_on_activity then
    self._private.manager:mover_player_to_front(player)
  end

  if player == self._private.manager.players[1] then
    self._private.active_player = player
    self:emit_signal("loop_status", loop_status, player.player_name)
  end

end

local function shuffle_callback(self, player, shuffle)
  if self.update_on_activity then
    self._private.manager:mover_player_to_front(player)
  end

  if player == self._private.manager.players[1] then
    self._private.active_player = player
    self:emit_signal("shuffle", shuffle, player.player_name)
  end
end

local function exit_callback(self, player)
  if player == self._private.manager.players[1] then
    self:emit_signal("playerctl::exit", player.player_name)
  end
end

local function name_is_selected(self, name)
  if self.ignore[name.name] then
    return false
  end
  if self.priority > 0 then
    for _, arg in pairs(self.priority) do
      if arg == name.name or arg == "%any" then
        return true
      end
    end
    return false
  end
end

local function init_player(self, name)
  if name_is_selected(self, name) then
    local player = self._private.Playerctl.Player.new_from_name(name)
    self._private.manager:manage_player(player)
    player.on_metadata = function(p, m)
      metadata_callback(self, p, m)
    end
    player.on_playback_status = function(p, s)
      playback_status_callback(self, p, s)
    end
    player.on_loop_status = function(p, s)
      loop_callback(self, p, s)
    end
    player.on_shuffle = function(p, s)
      shuffle_callback(self, p, s)
    end
    player.on_exit = function(p)
      exit_callback(self, p)
    end

    if not self._private.pos_timer.started then
      self._private.pos_timer:start()
    end
  end
end

local function player_compare(self, a, b)
  local player_a = self._private.Playerctl.Player(a)
  local player_b = self._private.Playerctl.Player(b)
  local i = math.huge
  local ai = nil
  local bi = nil

  if player_a == player_b then
    return 0
  end

  for index, name in ipairs(self.priority) do
    if name == "%any" then
      i = (i == math.huge) and index or i
    elseif name == player_a.player_name then
      ai = ai or index
    elseif name == player_b.player_name then
      bi = bi or index
    end
  end

  if not ai and not bi then
    return 0
  elseif not ai then
    return (bi < i) and 1 or -1
  elseif not bi then
    return (ai < i) and -1 or 1
  elseif ai == bi then
    return 0
  else
    return (ai < bi) and -1 or 1
  end
end

local function get_current_player(self, player)
  local title = player:get_title() or "Unknown"
  local artist = player:get_artist() or "Unknown"
  local album = player:get_album() or "Unknown"
  local art_url = player:print_metadata_prop("mpris:artUtl") or ""

  emit_metadata_callback(self, title, artist, art_url, album, false, player.player_name)
  playback_status_callback(self, player, player.playback_status)
  loop_callback(self, player, player.loop_status)
end

local function start_manager(self)
  self._private.manager = self.private.Playerctl.PlayerManager()

  if #self.priority > 0 then
    self._private.manager:set_sort_func(function(a, b)
      return player_compare(self, a, b)
    end)
  end

  self._private.pos_timer = gtimer {
    timeout = 1,
    callback = function()
      pos_callback(self)
    end
  }

  for _, name in ipairs(self._private.manager.player_names) do
    init_player(self, name)
  end

  if self._private.manager.players[1] then
    get_current_player(self, self._private.manager.players[1])
  end

  local _self = self

  function self._private.manager:on_name_appeared(name)
    init_player(_self, name)
  end

  function self._private.manager:on_player_appeared(player)
    if player == self.players[1] then
      _self._private.active_player = player
    end
  end

  function self._private.manager:on_player_vanished(player)
    if #self.players == 0 then
      _self._private.metadata_timer:stop()
      _self._private.pos_timer:stop()
      _self:emit_signal("playerctl::noplayers")
      awesome.emit_signal("playerctl::noplayers")
    elseif player == _self._private.active_player then
      _self._private.active_player = self.players[1]
      get_current_player(_self, _self._private.active_player)
    end
  end
end

function playerctl.new(args)
  args = args or {}

  local ret = gobject {}
  gtable.crush(ret, playerctl, true)

  ret.update_on_activity = true
  ret.interval = 1


  ret._private = {}

  ret._private.Playerctl = require("lgi").Playerctl
  ret._private.manager = nil

  gtimer.delayed_call(function()
    start_manager(ret)
  end)

  return ret
end

function playerctl.mt:__call(...)
  return playerctl.new(...)
end

return setmetatable(playerctl, playerctl.mt)
