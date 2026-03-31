local M = {}

function M.register()
  vim.api.nvim_create_user_command("Neoimage", function(opts)
    M.execute(opts)
  end, {
    nargs = "+",
    complete = function(arglead, cmdline, cursorpos)
      return M.complete(arglead, cmdline, cursorpos)
    end,
    desc = "neoimage.nvim: ASCII art from images",
  })
end

function M.execute(opts)
  local args = opts.fargs
  local subcmd = args[1]

  if subcmd == "add" then
    local file = args[2]
    local width = tonumber(args[3])
    if not file then
      vim.notify("neoimage: usage: :Neoimage add <file> [width]", vim.log.levels.ERROR)
      return
    end
    require("neoimage").add(file, { width = width })
  else
    vim.notify("neoimage: unknown subcommand: " .. tostring(subcmd), vim.log.levels.ERROR)
  end
end

function M.complete(arglead, cmdline, _cursorpos)
  local parts = vim.split(cmdline, "%s+")

  if #parts == 2 then
    return vim.tbl_filter(function(s)
      return vim.startswith(s, arglead)
    end, { "add" })
  elseif #parts == 3 and parts[2] == "add" then
    return vim.fn.getcompletion(arglead, "file")
  end

  return {}
end

return M
