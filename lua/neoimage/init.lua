local config = require("neoimage.config")
local image = require("neoimage.image")
local render = require("neoimage.render")
local shaders = require("neoimage.shaders")

require("neoimage.shaders.ascii")
require("neoimage.shaders.blocks")
require("neoimage.shaders.braille")
require("neoimage.shaders.colour_ascii")

local M = {}

local ns = vim.api.nvim_create_namespace("neoimage")

function M.setup(opts)
  config.setup(opts)

  for name, shader in pairs(config.options.shaders) do
    shader.name = shader.name or name
    shaders.register(shader)
  end
end

function M.add(filepath, opts)
  opts = opts or {}
  local width = opts.width or config.options.default_width
  local shader_name = opts.shader or config.options.shader
  local shader = shaders.get(shader_name)

  if not shader then
    vim.notify("neoimage: unknown shader: " .. shader_name, vim.log.levels.ERROR)
    return
  end

  filepath = vim.fn.expand(filepath)
  if vim.fn.filereadable(filepath) ~= 1 then
    vim.notify("neoimage: file not found: " .. filepath, vim.log.levels.ERROR)
    return
  end

  vim.notify("neoimage: loading " .. vim.fn.fnamemodify(filepath, ":t") .. "...")

  image.get_dimensions(filepath, function(dims, err)
    if not dims then
      vim.notify("neoimage: " .. err, vim.log.levels.ERROR)
      return
    end

    local pixel_w, pixel_h = image.compute_target_size(
      dims.width, dims.height, width, shader.cell_width, shader.cell_height
    )

    image.load_pixels(filepath, pixel_w, pixel_h, shader.colormode, function(raw, load_err)
      if not raw then
        vim.notify("neoimage: " .. load_err, vim.log.levels.ERROR)
        return
      end

      local grid = render.parse_pixels(raw, pixel_w, pixel_h, shader.colormode)
      local result = render.render(grid, pixel_w, pixel_h, shader)

      local buf = vim.api.nvim_get_current_buf()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      vim.api.nvim_buf_set_lines(buf, row, row, false, result.lines)

      for _, hl in ipairs(result.highlights) do
        vim.api.nvim_buf_set_extmark(buf, ns, row + hl[1], hl[2], {
          end_col = hl[2] + 1,
          hl_group = hl[3],
        })
      end
    end)
  end)
end

return M
