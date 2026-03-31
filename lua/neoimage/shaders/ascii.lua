local shaders = require("neoimage.shaders")

local ramp = " .:-=+*#%@"
local ramp_len = #ramp

local M = {
  name = "ascii",
  colormode = "gray",
  cell_width = 1,
  cell_height = 1,
}

function M.render_cell(pixels)
  local brightness = pixels[1][1]
  local idx = math.floor(brightness / 256 * ramp_len) + 1
  idx = math.min(idx, ramp_len)
  return ramp:sub(idx, idx), nil
end

shaders.register(M)

return M
