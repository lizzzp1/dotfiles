set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

lua << EOF

require("copilotchat_setup")
require('telescope').setup{}
local lspconfig = require'lspconfig'
local util = require'lspconfig/util'
local blink_cmp = require('blink.cmp')
local capabilities = blink_cmp.get_lsp_capabilities()
lspconfig['lua_ls'].setup({ capabilities = capabilities })

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

vim.cmd [[
  highlight! link @function Function
  highlight! link @variable Identifier
  highlight! link @string String
]]

-- Go Language Server
lspconfig.gopls.setup{
    cmd = {"gopls"},
    filetypes = {"go"},
    capabilities = capabilities,
    root_dir = util.root_pattern("go.mod", ".git"),
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
        },
    },
}

-- Ruby Language Server
lspconfig.ruby_lsp.setup({
  cmd = { "ruby-lsp" },
  filetypes = { "ruby", "eruby" },
  root_dir = util.root_pattern("Gemfile", ".git"),
  init_options = {
    formatter = "auto",
    diagnostics = true,
    formatting = true,
    addonSettings = {
      ["Ruby LSP Rails"] = {
        enablePendingMigrationsPrompt = false,
      },
    },
    completion = {
      auto_complete = true,
      show_documentation = true,
    },
  },
})

-- Python Language Server
local root_files = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    'pyrightconfig.json',
    '.git',
}

lspconfig.pyright.setup{
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_dir = function(fname)
        return util.root_pattern(unpack(root_files))(fname)
    end,
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                useLibraryCodeForTypes = true,
                typeCheckingMode = "basic",
            },
        }
    }
}

require('blink.cmp').setup({
  keymap = { preset = 'default' },
  appearance = {
    nerd_font_variant = 'mono'
  },
  completion = {
    documentation = { auto_show = true }
  },
  fuzzy = {
    prebuilt_binaries = {
       force_version = '1.0.0',
    },
    implementation = "prefer_rust",
  }
})

EOF
