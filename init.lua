-- Pengaturan dasar Neovim
vim.g.mapleader = " " -- Mengatur tombol leader menjadi spasi
vim.o.number = true -- Menampilkan nomor baris
vim.o.relativenumber = true -- Menampilkan nomor baris relatif
vim.o.termguicolors = true -- Mengaktifkan true colors di terminal
vim.o.expandtab = true -- Menggunakan spasi instead of tab
vim.o.shiftwidth = 2 -- Jumlah spasi untuk indentasi
vim.o.tabstop = 2 -- Jumlah spasi untuk tab
vim.o.updatetime = 300 -- Waktu update dalam milidetik

-- Konfigurasi diagnostic (pesan error/warning)
vim.diagnostic.config({
  virtual_text = true, -- Menampilkan diagnostic sebagai teks virtual
  signs = true, -- Menampilkan tanda di gutter
  underline = true, -- Menggarisbawahi kode yang bermasalah
  update_in_insert = true, -- Update diagnostic saat insert mode
  severity_sort = true, -- Mengurutkan berdasarkan tingkat keparahan
})

-- Autocmd untuk menampilkan diagnostic saat kursor diam
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false }) -- Membuka floating window diagnostic
  end,
})

-- Fitur autosave
vim.api.nvim_create_autocmd({"InsertLeave", "TextChanged"}, {
  pattern = "*", -- Untuk semua tipe file
  command = "silent! write", -- Menyimpan file secara otomatis
})

-- Instalasi lazy.nvim (plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" -- Menentukan path instalasi lazy
if not vim.loop.fs_stat(lazypath) then -- Cek apakah lazy sudah terinstall
  vim.fn.system({ -- Jika belum, clone dari GitHub
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath) -- Menambahkan lazy ke runtimepath

-- Daftar plugin yang akan diinstall
require("lazy").setup({

  -- Plugin tema Dracula
  {
    "Mofiqul/dracula.nvim",
    priority = 1000, -- Prioritas tinggi untuk memuat tema lebih awal
    config = function()
      vim.cmd.colorscheme("dracula") -- Mengaktifkan tema Dracula
    end,
  },

  -- Plugin Treesitter untuk syntax highlighting yang lebih baik
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate", -- Perintah untuk update parser
    event = { "BufReadPost", "BufNewFile" }, -- Dimuat saat membuka file
    config = function()
      local ok, ts = pcall(require, "nvim-treesitter.configs")
      if not ok then return end

      ts.setup({
        ensure_installed = { "python", "javascript", "html", "css" }, -- Parser yang akan diinstall
        highlight = { enable = true }, -- Mengaktifkan highlighting
        indent = { enable = true }, -- Mengaktifkan indentasi berbasis treesitter
      })
    end,
  },

  -- Plugin LSP (Language Server Protocol)
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.enable("pyright") -- Mengaktifkan LSP untuk Python
      vim.lsp.enable("ts_ls") -- Mengaktifkan LSP untuk TypeScript/JavaScript
    end,
  },

  -- Plugin autocomplete (nvim-cmp)
  {
    "hrsh7th/nvim-cmp",
    dependencies = { -- Dependencies yang diperlukan
      "hrsh7th/cmp-nvim-lsp", -- Sumber dari LSP
      "hrsh7th/cmp-buffer", -- Sumber dari buffer
      "hrsh7th/cmp-path", -- Sumber dari path file
      "L3MON4D3/LuaSnip", -- Engine snippet
      "saadparwaiz1/cmp_luasnip", -- Integrasi LuaSnip dengan cmp
      "onsails/lspkind.nvim", -- Icons untuk autocomplete
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body) -- Expand snippet
          end,
        },

        window = {
          completion = cmp.config.window.bordered(), -- Window completion dengan border
          documentation = cmp.config.window.bordered(), -- Window documentation dengan border
        },

        formatting = {
          format = lspkind.cmp_format({ -- Formatting dengan icons
            mode = "symbol_text",
            maxwidth = 50,
          }),
        },

        mapping = cmp.mapping.preset.insert({ -- Key mappings untuk autocomplete
          ["<C-Space>"] = cmp.mapping.complete(), -- Ctrl+Space untuk memulai completion
          ["<Tab>"] = cmp.mapping.select_next_item(), -- Tab untuk pilih item berikutnya
          ["<S-Tab>"] = cmp.mapping.select_prev_item(), -- Shift+Tab untuk pilih item sebelumnya
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Enter untuk konfirmasi pilihan
        }),

        sources = { -- Sumber-sumber completion
          { name = "nvim_lsp" }, -- Dari LSP
          { name = "luasnip" }, -- Dari snippet
          { name = "buffer" }, -- Dari buffer terbuka
          { name = "path" }, -- Dari path file
        },
      })
    end,
  },

})