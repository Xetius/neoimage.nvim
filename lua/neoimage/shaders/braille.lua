local shaders = require("neoimage.shaders")

local BRAILLE_BASE = 0x2800

-- Braille dot positions map to bits:
-- [1,1]=0x01  [1,2]=0x08
-- [2,1]=0x02  [2,2]=0x10
-- [3,1]=0x04  [3,2]=0x20
-- [4,1]=0x40  [4,2]=0x80
local dot_map = {
  { 0x01, 0x08 },
  { 0x02, 0x10 },
  { 0x04, 0x20 },
  { 0x40, 0x80 },
}

local M = {
  name = "braille",
  colormode = "gray",
  cell_width = 2,
  cell_height = 4,
  threshold = 128,
}

function M.render_cell(pixels)
  local code = 0
  for row = 1, 4 do
    for col = 1, 2 do
      local val = pixels[row] and pixels[row][col] or 0
      if val < M.threshold then
        code = code + dot_map[row][col]
      end
    end
  end

  local char = vim.fn.nr2char(BRAILLE_BASE + code)
  return char, nil
end

shaders.register(M)

return M
