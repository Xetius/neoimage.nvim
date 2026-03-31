local M = {}

function M.check()
  vim.health.start("neoimage.nvim")

  if vim.fn.has("nvim-0.12") == 1 then
    vim.health.ok("Neovim >= 0.12.0")
  else
    vim.health.error("Neovim >= 0.12.0 required", { "Upgrade Neovim to 0.12.0 or later" })
  end

  local cfg = require("neoimage.config").options
  local cmd = cfg.magick_cmd or "magick"

  local result = vim.system({ cmd, "--version" }, { text = true }):wait()
  if result.code == 0 then
    local version_line = vim.split(result.stdout, "\n")[1] or ""
    vim.health.ok("ImageMagick found: " .. version_line)
  else
    vim.health.error(cmd .. " not found or not executable", {
      "Install ImageMagick 7: https://imagemagick.org/script/download.php",
    })
  end

  local test = vim.system({ cmd, "logo:", "-resize", "1x1", "-depth", "8", "gray:-" }, {}):wait()
  if test.code == 0 and #test.stdout == 1 then
    vim.health.ok("ImageMagick raw pixel output works")
  else
    vim.health.warn("ImageMagick raw pixel output test failed", {
      "Ensure ImageMagick is correctly installed with delegate libraries",
    })
  end

  if next(cfg) then
    vim.health.ok("setup() has been called")
  else
    vim.health.warn("setup() not called", { 'Add require("neoimage").setup() to your config' })
  end

  local shader_name = cfg.shader or "ascii"
  local shaders = require("neoimage.shaders")
  local shader = shaders.get(shader_name)
  if shader then
    vim.health.ok("Default shader: " .. shader_name)
  else
    vim.health.warn("Default shader '" .. shader_name .. "' not found")
  end
end

return M
