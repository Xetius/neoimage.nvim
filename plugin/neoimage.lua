if vim.g.loaded_neoimage then
  return
end
vim.g.loaded_neoimage = true

require("neoimage.command").register()
