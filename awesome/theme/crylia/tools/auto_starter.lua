local awful = require("awful")

function Autostarter(table)
  for i, t in ipairs(table) do
    awful.spawn.with_shell(t);
  end
end
