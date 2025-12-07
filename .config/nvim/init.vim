set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

nnoremap ]d <cmd>lua vim.diagnostic.goto_next()<CR>
nnoremap [d <cmd>lua vim.diagnostic.goto_prev()<CR>

lua << EOF

require("copilotchat_setup")
------------------------------------------------------------
-- Diagnostics
------------------------------------------------------------
vim.fn.sign_define("DiagnosticSignError", {text = "", texthl = "DiagnosticSignError"})
vim.fn.sign_define("DiagnosticSignWarn",  {text = "", texthl = "DiagnosticSignWarn"})
vim.fn.sign_define("DiagnosticSignInfo",  {text = "", texthl = "DiagnosticSignInfo"})
vim.fn.sign_define("DiagnosticSignHint",  {text = "", texthl = "DiagnosticSignHint"})

vim.diagnostic.config({
   virtual_text = true,
   signs = true,
   underline = true,
   update_in_insert = false,
   severity_sort = true,
})

------------------------------------------------------------
-- Go Language Server (gopls)
------------------------------------------------------------
vim.lsp.config.gopls = {
  default_config = {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_dir = vim.fs.dirname(vim.fs.find({ "go.mod", ".git" }, { upward = true })[1]),
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
        gofumpt = true,
      },
    },
  }
}

vim.lsp.enable("gopls")


------------------------------------------------------------
-- Ruby Language Server (ruby-lsp)
------------------------------------------------------------
vim.lsp.config.ruby_lsp = {
  default_config = {
    cmd = { "ruby-lsp" },
    filetypes = { "ruby", "eruby" },
    root_dir = vim.fs.dirname(vim.fs.find({ "Gemfile", ".git" }, { upward = true })[1]),
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
  }
}

vim.lsp.enable("ruby_lsp")


------------------------------------------------------------
-- Python Language Server (pyright)
------------------------------------------------------------
vim.lsp.config.pyright = {
  default_config = {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_dir = function(fname)
      local root_files = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        "pyrightconfig.json",
        ".git",
      }
      return vim.fs.dirname(vim.fs.find(root_files, { upward = true, path = fname })[1])
    end,
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "openFilesOnly",
          useLibraryCodeForTypes = true,
          typeCheckingMode = "basic",
        },
      },
    },
  }
}

vim.lsp.enable("pyright")


------------------------------------------------------------
-- Blink Completion
------------------------------------------------------------
require("blink.cmp").setup({
  keymap = { preset = "enter" },
  appearance = {
    nerd_font_variant = "mono",
    use_nvim_cmp_icons = true
  },
  completion = {
    documentation = { auto_show = true, window = { border = "rounded" }},
    keyword = { allow_punctuation = true, cmp = { look_ahead = true } },
    menu = {
      auto_show = true,
      border = "rounded",
      ghost_text = {
        enabled = true,
        show_item_with_menu = true
      },
      draw = {
       columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } } },
    },
    list = {
      preselect = true,
      auto_insert = false
    },
  },
  fuzzy = {
    prebuilt_binaries = {
      force_version = "1.0.0",
    },
    implementation = "prefer_rust",
  },
})

EOF
