local shaders = require("neoimage.shaders")

local UPPER_HALF = "\u{2580}"

local hl_cache = {}

local function rgb_to_int(r, g, b)
  return r * 65536 + g * 256 + b
end

local function quantise(val)
  return math.floor(val / 4) * 4
end

local function get_hl_group(fg_r, fg_g, fg_b, bg_r, bg_g, bg_b)
  fg_r, fg_g, fg_b = quantise(fg_r), quantise(fg_g), quantise(fg_b)
  bg_r, bg_g, bg_b = quantise(bg_r), quantise(bg_g), quantise(bg_b)

  local key = string.format("%d_%d_%d_%d_%d_%d", fg_r, fg_g, fg_b, bg_r, bg_g, bg_b)
  if hl_cache[key] then
    return hl_cache[key]
  end

  local group = "NeoimageBlock_" .. key
  vim.api.nvim_set_hl(0, group, {
    fg = rgb_to_int(fg_r, fg_g, fg_b),
    bg = rgb_to_int(bg_r, bg_g, bg_b),
  })
  hl_cache[key] = group
  return group
end

local M = {
  name = "blocks",
  colormode = "rgb",
  cell_width = 1,
  cell_height = 2,
}

function M.render_cell(pixels)
  local top = pixels[1][1]
  local bottom = pixels[2] and pixels[2][1] or top

  if type(top) == "number" then
    top = { top, top, top }
  end
  if type(bottom) == "number" then
    bottom = { bottom, bottom, bottom }
  end

  local hl = get_hl_group(top[1], top[2], top[3], bottom[1], bottom[2], bottom[3])
  return UPPER_HALF, hl
end

shaders.register(M)

return M
