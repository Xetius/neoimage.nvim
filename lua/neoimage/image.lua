local config = require("neoimage.config")

local M = {}

function M.get_dimensions(filepath, callback)
  local cmd = config.options.magick_cmd
  vim.system({ cmd, "identify", "-format", "%w %h", filepath }, { text = true }, function(result)
    if result.code ~= 0 then
      vim.schedule(function()
        callback(nil, "magick identify failed: " .. (result.stderr or "unknown error"))
      end)
      return
    end
    local w, h = result.stdout:match("^(%d+)%s+(%d+)")
    if not w or not h then
      vim.schedule(function()
        callback(nil, "failed to parse image dimensions from: " .. result.stdout)
      end)
      return
    end
    vim.schedule(function()
      callback({ width = tonumber(w), height = tonumber(h) })
    end)
  end)
end

function M.compute_target_size(orig_w, orig_h, target_char_width, cell_w, cell_h)
  local aspect = config.options.aspect_ratio
  local pixel_w = target_char_width * cell_w
  local pixel_h = math.floor(orig_h / orig_w * pixel_w / aspect + 0.5)
  pixel_h = math.max(cell_h, math.floor(pixel_h / cell_h + 0.5) * cell_h)
  return pixel_w, pixel_h
end

function M.load_pixels(filepath, width, height, colormode, callback)
  local cmd = config.options.magick_cmd
  local format = colormode == "rgb" and "rgb:-" or "gray:-"
  local args = {
    cmd, filepath,
    "-resize", width .. "x" .. height .. "!",
    "-depth", "8",
  }
  if colormode == "gray" then
    table.insert(args, "-colorspace")
    table.insert(args, "Gray")
  end
  table.insert(args, format)

  vim.system(args, {}, function(result)
    if result.code ~= 0 then
      vim.schedule(function()
        callback(nil, "magick convert failed: " .. (result.stderr or "unknown error"))
      end)
      return
    end
    vim.schedule(function()
      callback(result.stdout)
    end)
  end)
end

return M
