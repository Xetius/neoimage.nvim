local M = {}

function M.parse_pixels(raw, width, height, colormode)
  local grid = {}
  local bpp = colormode == "rgb" and 3 or 1
  for y = 1, height do
    local row = {}
    for x = 1, width do
      local offset = ((y - 1) * width + (x - 1)) * bpp + 1
      if colormode == "rgb" then
        local r, g, b = raw:byte(offset, offset + 2)
        row[x] = { r, g, b }
      else
        row[x] = raw:byte(offset)
      end
    end
    grid[y] = row
  end
  return grid
end

function M.render(grid, width, height, shader)
  local lines = {}
  local highlights = {}
  local cell_w = shader.cell_width
  local cell_h = shader.cell_height
  local line_idx = 0

  for y = 1, height, cell_h do
    line_idx = line_idx + 1
    local chars = {}
    local col = 0
    for x = 1, width, cell_w do
      local cell = {}
      for cy = 0, cell_h - 1 do
        local crow = {}
        for cx = 0, cell_w - 1 do
          local py = y + cy
          local px = x + cx
          if grid[py] and grid[py][px] then
            crow[cx + 1] = grid[py][px]
          else
            crow[cx + 1] = 0
          end
        end
        cell[cy + 1] = crow
      end
      local char, hl_group = shader.render_cell(cell)
      chars[#chars + 1] = char
      if hl_group then
        highlights[#highlights + 1] = { line_idx - 1, col, hl_group }
      end
      col = col + #char
    end
    lines[line_idx] = table.concat(chars)
  end

  return { lines = lines, highlights = highlights }
end

return M
