local M = {}

M.defaults = {
  default_width = 80,
  shader = "ascii",
  aspect_ratio = 2.0,
  magick_cmd = "magick",
  shaders = {},
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M
