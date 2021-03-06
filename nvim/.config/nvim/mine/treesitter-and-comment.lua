local ts = require'nvim-treesitter.configs'

ts.setup {
  ensure_installed = "all",
  highlight = {
    enable = true,
  },
  indent = {
    -- FIXME commented as it breaks indent https://github.com/nvim-treesitter/nvim-treesitter/issues/2544
    -- and https://github.com/nvim-treesitter/nvim-treesitter/issues/2369
    enable = true,
  },
  matchup = {
    enable = true,
  },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
      },
    },
    move = {
      enable = true,
      goto_next_start = {
        ["]]"] = "@function.outer",
      },
      goto_previous_start = {
        ["[["] = "@function.outer",
      },
      goto_next_end = {
        ["]["] = "@function.outer",
      },
      goto_previous_end = {
        ["[]"] = "@function.outer",
      },
    },
  },
}

require('Comment').setup({
  pre_hook = function(ctx)
    if vim.bo.filetype == 'typescriptreact' then
      local U = require('Comment.utils')

      local location = nil
      if ctx.ctype == U.ctype.block then
        location = require('ts_context_commentstring.utils').get_cursor_location()
      elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
        location = require('ts_context_commentstring.utils').get_visual_start_location()
      end

      return require('ts_context_commentstring.internal').calculate_commentstring {
        key = ctx.ctype == U.ctype.line and '__default' or '__multiline',
        location = location,
      }
    end
  end,
})
