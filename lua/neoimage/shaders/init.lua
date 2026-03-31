local M = {}

local registry = {}

function M.register(shader)
  registry[shader.name] = shader
end

function M.get(name)
  return registry[name]
end

function M.list()
  return vim.tbl_keys(registry)
end

return M
