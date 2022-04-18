local awful = require("awful")

return function(table)
  for i, t in ipairs(table) do
    awful.spawn.with_shell(t);
  end
end
