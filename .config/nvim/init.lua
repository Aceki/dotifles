vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.foldcolumn = '0'
vim.opt.errorbells = false
vim.opt.visualbell = false
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.exrc = true
vim.opt.secure = true
vim.opt.smartcase = true
vim.opt.cursorline = true
vim.opt.updatetime = 750
vim.opt.encoding = 'utf8'
vim.opt.ffs = {'unix', 'dos', 'mac'}
vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.autoread = true
vim.opt.foldenable = false
vim.opt.foldmethod = 'marker'
vim.opt.foldmarker = {'{', '}'}
vim.opt.foldlevel = 100
vim.opt.clipboard = 'unnamedplus'
vim.opt.cmdheight = 0
vim.opt.list =  true
vim.opt.listchars = {trail = '@'}
vim.opt.syntax = 'off'

vim.cmd([[
call plug#begin('~/.vim/plugged')
Plug 'BurntSushi/ripgrep'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/vim-vsnip'
Plug 'itchyny/lightline.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'morhetz/gruvbox'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'phaazon/hop.nvim'
Plug 'tpope/vim-fugitive'
call plug#end()
]])

vim.cmd('colorscheme gruvbox')
vim.cmd('highlight clear DiagnosticHint')
vim.cmd('highlight link DiagnosticHint DiagnosticWarn')

require("hop").setup()

require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'c',
    'cmake',
    'comment',
    'cpp',
    'dockerfile',
    'json',
    'lua',
    'markdown',
    'yaml'
  },
  sync_install = false,
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  }
})

local telescope = require('telescope')
local actions = require('telescope.actions')
local file_browser = telescope.extensions.file_browser
telescope.setup({
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--trim'
    },
    initial_mode = 'insert',
    mappings = {
      n = {
        ['t'] = actions.select_tab,
        ['<C-i>'] = actions.select_horizontal,
        ['<C-s>'] = actions.select_vertical
      },
      i = {
        ['<C-t>'] = actions.select_tab,
        ['<C-i>'] = actions.select_horizontal,
        ['<C-s>'] = actions.select_vertical
      }
    }
  },
  extensions = {
    file_browser = {
      initial_mode = 'normal',
      hijack_netrw = true,
      quiet = true,
      dir_icon = '',
      grouped = true,
      mappings = {
        n = {
          ['ma'] = file_browser.actions.create,
          ['md'] = file_browser.actions.remove,
          ['mm'] = file_browser.actions.rename,
          ['mc'] = file_browser.actions.copy,
        }
      }
    }
  }
})

telescope.load_extension("file_browser")

vim.api.nvim_set_var('lightline', {
  colorscheme = 'gruvbox',
  active = {
    left = {{'mode', 'paste'}, {'readonly', 'filename', 'modified'}},
    right = {{'lineinfo'}, {'percent'}, {'fileformat', 'fileencoding', 'filetype'}}
  }
})
vim.api.nvim_set_var('AutoPairsShortcutToggle', '<M-8>')
vim.api.nvim_set_var('markdown_folding', 1)

local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn['vsnip#anonymous'](args.body)
    end
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-n>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable,
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources(
    {{ name = 'nvim_lsp' }},
    {{ name = 'vsnip' }},
    {{ name = 'buffer' }}
  )
})
cmp.setup.cmdline('/', {
  sources = {{ name = 'buffer' }},
  mapping = cmp.mapping.preset.cmdline()
})
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({{ name = 'path' }}, {{ name = 'cmdline' }}),
  mapping = cmp.mapping.preset.cmdline()
})

local lsp = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { noremap = true, silent = true }

  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end
lsp.tsserver.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  flags = {
    debounce_text_changes = 150
  }
})
lsp.clangd.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { 'clangd', '--enable-config', '--background-index' },
  flags = {
    debounce_text_changes = 150
  }
})

vim.keymap.set({ 'n', 'v' }, '<Leader>w', '<cmd>HopWord<CR>')
vim.keymap.set('n', '<Leader>a', '<cmd>HopAnywhere<CR>')
vim.keymap.set('n', '<A-o>', '<cmd>tabprevious<CR>')
vim.keymap.set('n', '<A-p>', '<cmd>tabnext<CR>')
vim.keymap.set({'n', 'v', 'o'}, '<A-9>', '<cmd>tabmove -1<CR>')
vim.keymap.set({'n', 'v', 'o'}, '<A-0>', '<cmd>tabmove +1<CR>')
vim.keymap.set('n', 'ff', '<cmd>Telescope find_files<CR>')
vim.keymap.set('n', 'fg', '<cmd>Telescope live_grep<CR>')
vim.keymap.set('n', 'fr', '<cmd>Telescope lsp_references<CR>')
vim.keymap.set('n', '<Home>', '<cmd>pop<CR>')
vim.keymap.set('n', '<A-k>', '<cmd>wincmd k<CR>')
vim.keymap.set('n', '<A-j>', '<cmd>wincmd j<CR>')
vim.keymap.set('n', '<A-h>', '<cmd>wincmd h<CR>')
vim.keymap.set('n', '<A-l>', '<cmd>wincmd l<CR>')
vim.keymap.set('n', '<C-n>', '<cmd>Telescope file_browser<CR>')

vim.cmd("imap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'")
vim.cmd("smap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'")

