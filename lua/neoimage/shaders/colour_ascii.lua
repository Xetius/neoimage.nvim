local shaders = require("neoimage.shaders")

local ramp = " .:-=+*#%@"
local ramp_len = #ramp

local hl_cache = {}

local function quantise(val)
  return math.floor(val / 4) * 4
end

local function rgb_to_int(r, g, b)
  return r * 65536 + g * 256 + b
end

local function get_hl_group(r, g, b)
  r, g, b = quantise(r), quantise(g), quantise(b)

  local key = string.format("%d_%d_%d", r, g, b)
  if hl_cache[key] then
    return hl_cache[key]
  end

  local group = "NeoimageColourAscii_" .. key
  vim.api.nvim_set_hl(0, group, {
    fg = rgb_to_int(r, g, b),
  })
  hl_cache[key] = group
  return group
end

local M = {
  name = "colour_ascii",
  colormode = "rgb",
  cell_width = 1,
  cell_height = 1,
}

function M.render_cell(pixels)
  local pixel = pixels[1][1]

  if type(pixel) == "number" then
    pixel = { pixel, pixel, pixel }
  end

  local r, g, b = pixel[1], pixel[2], pixel[3]
  local brightness = 0.299 * r + 0.587 * g + 0.114 * b
  local idx = math.floor(brightness / 256 * ramp_len) + 1
  idx = math.min(idx, ramp_len)

  local char = ramp:sub(idx, idx)
  local hl = get_hl_group(r, g, b)
  return char, hl
end

shaders.register(M)

return M
