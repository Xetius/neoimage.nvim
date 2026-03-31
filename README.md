# neoimage.nvim

A Neovim plugin that converts images to ASCII art and inserts them into your buffer.

Supports multiple rendering styles via a pluggable shader system — from simple ASCII brightness ramps to full-colour Unicode block art.

## Requirements

- Neovim >= 0.12.0
- [ImageMagick](https://imagemagick.org/) 7 (`magick` CLI must be on your `$PATH`)

Run `:checkhealth neoimage` to verify your setup.

## Installation

### vim.pack (Neovim 0.12+)

```lua
vim.pack.add({
  "https://github.com/Xetius/neoimage.nvim",
})
require("neoimage").setup()
```

### lazy.nvim

```lua
{
  "Xetius/neoimage.nvim",
  opts = {},
}
```

### Manual (local development)

Symlink into the Neovim pack directory:

```sh
mkdir -p ~/.local/share/nvim/site/pack/dev/start
ln -s ~/Projects/neoimage.nvim ~/.local/share/nvim/site/pack/dev/start/neoimage.nvim
```

Then add to your `init.lua`:

```lua
require("neoimage").setup()
```

## Usage

```vim
:Neoimage add <image_file> [width]
```

- `image_file` — path to any image format supported by ImageMagick (PNG, JPG, GIF, BMP, WebP, etc.)
- `width` — output width in characters (default: 80)

The image is inserted at the current cursor position. Height is automatically calculated to maintain the original aspect ratio.

### Examples

```vim
" Insert at 80 characters wide (default)
:Neoimage add photo.jpg

" Insert at 40 characters wide
:Neoimage add ~/images/logo.png 40

" Insert at 120 characters wide
:Neoimage add ./diagram.webp 120
```

## Configuration

Pass options to `setup()` to override defaults:

```lua
require("neoimage").setup({
  default_width = 80,      -- default character width when not specified
  shader = "ascii",        -- "ascii", "colour_ascii", "blocks", or "braille"
  aspect_ratio = 2.0,      -- character cell height/width ratio (tune for your font)
  magick_cmd = "magick",   -- path to ImageMagick binary
})
```

## Shaders

Shaders control how pixel data is mapped to characters and colours. Four built-in shaders are provided:

### `ascii`

Classic ASCII brightness ramp. Maps pixel brightness to characters from the set ` .:-=+*#%@`. No colour — works in any terminal.

```
                  ..::::--
              ..:::::------===
           ..::::----====+++**
         .::::----====++++***##
       ..:::----====++++***###%%
```

### `colour_ascii`

Combines the ASCII brightness ramp with true colour. Each character is chosen by perceived brightness (using the ITU-R BT.601 luma formula: `0.299R + 0.587G + 0.114B`) and coloured with the original pixel's RGB value. Gives the readability of the ASCII ramp with the colour detail of the source image.

Best suited for terminals with true colour support.

### `blocks`

Uses Unicode upper-half block characters (`\u2580`) with terminal foreground and background colours. Each character represents two vertical pixels, giving double the vertical resolution of ASCII. Produces full-colour output.

Best suited for terminals with true colour support.

### `braille`

Uses Braille dot patterns to represent the image. Each character encodes a 2x4 grid of dots, giving 2x horizontal and 4x vertical subpixel resolution. This produces the most detailed output but is monochrome (dots are either on or off based on a brightness threshold).

### Selecting a shader

Set the default shader in `setup()`:

```lua
require("neoimage").setup({
  shader = "blocks",
})
```

Or specify per-call via the Lua API:

```lua
require("neoimage").add("photo.jpg", { width = 60, shader = "braille" })
```

### Custom shaders

You can register your own shaders. A shader is a table with the following fields:

```lua
require("neoimage").setup({
  shaders = {
    my_shader = {
      colormode = "gray",   -- "gray" (0-255 integers) or "rgb" ({r, g, b} tables)
      cell_width = 1,       -- source pixels per output character (horizontal)
      cell_height = 1,      -- source pixels per output character (vertical)
      render_cell = function(pixels)
        -- pixels: cell_height x cell_width nested table of pixel values
        -- returns: character string, optional highlight group name
        local brightness = pixels[1][1]
        local char = brightness > 128 and "#" or " "
        return char, nil
      end,
    },
  },
})
```

## Licence

[GPL-3.0](LICENSE)
