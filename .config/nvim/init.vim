set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" Load the LSP configuration

lua << EOF
local lspconfig = require'lspconfig'
local util = require'lspconfig/util'

-- Go Language Server
lspconfig.gopls.setup{
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_dir = util.root_pattern("go.mod", ".git"),
}

-- Ruby Language Server
lspconfig.ruby_lsp.setup{
    cmd = { "ruby-lsp" },
    filetypes = { "ruby", "eruby" },
    root_dir = util.root_pattern("Gemfile", ".git"),
    init_options = {
        formatter = "auto"
    },
    single_file_support = true,
}

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
                useLibraryCodeForTypes = true
            }
        }
    },
}
EOF
