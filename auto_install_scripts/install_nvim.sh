#!/bin/bash

# Salir inmediatamente si un comando falla
set -e

echo "🚀 Iniciando instalación de Neovim (LazyVim estilo Omarchy)..."

# ── 1. Instalar dependencias ──────────────────────────────────
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍏 macOS detectado. Usando Homebrew..."
    if ! command -v brew &>/dev/null; then
        echo "❌ Homebrew no está instalado. Instálalo primero: https://brew.sh/"
        exit 1
    fi
    brew install neovim git ripgrep fd fzf lazygit gcc node npm

elif [[ "$OSTYPE" == "linux-gnu"* ]] && command -v pacman &>/dev/null; then
    echo "🐧 Arch Linux detectado. Usando pacman..."
    sudo pacman -Syu --needed --noconfirm neovim git ripgrep fd fzf lazygit gcc nodejs npm wl-clipboard

else
    echo "❌ Sistema operativo no soportado (solo macOS y Arch Linux)."
    exit 1
fi

# ── 2. Backup de configuraciones anteriores ───────────────────
echo "📦 Haciendo backup de configuraciones antiguas..."
for dir in ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; do
    if [ -d "$dir" ]; then
        mv "$dir" "${dir}.bak-$(date +%Y%m%d%H%M%S)"
        echo "   -> $dir respaldado."
    fi
done

# ── 3. Clonar LazyVim starter ─────────────────────────────────
echo "📥 Clonando configuración base de LazyVim..."
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# ── 4. Aplicar parches estilo Omarchy ─────────────────────────
echo "🎨 Aplicando configuración estilo Omarchy..."

# Desactivar scroll animado de Snacks
cat << 'EOF' > ~/.config/nvim/lua/plugins/snacks.lua
return {
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false },
    }
  }
}
EOF

# Desactivar noticias de LazyVim al arrancar
cat << 'EOF' > ~/.config/nvim/lua/plugins/lazyvim-news.lua
return {
  {
    "LazyVim/LazyVim",
    opts = {
      news = { lazyvim = false, neovim = false },
    }
  }
}
EOF

# Tema Tokyo Night (igual que Omarchy)
cat << 'EOF' > ~/.config/nvim/lua/plugins/theme.lua
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    }
  }
}
EOF

# Harpoon — navegación rápida entre archivos (lo usa DHH)
cat << 'EOF' > ~/.config/nvim/lua/plugins/harpoon.lua
return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()
      vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end,    { desc = "Harpoon: agregar" })
      vim.keymap.set("n", "<C-e>",     function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: menú" })
      vim.keymap.set("n", "<C-1>",     function() harpoon:list():select(1) end)
      vim.keymap.set("n", "<C-2>",     function() harpoon:list():select(2) end)
      vim.keymap.set("n", "<C-3>",     function() harpoon:list():select(3) end)
      vim.keymap.set("n", "<C-4>",     function() harpoon:list():select(4) end)
    end,
  }
}
EOF

# Oil.nvim — file manager tipo buffer (Omarchy lo prefiere sobre netrw)
cat << 'EOF' > ~/.config/nvim/lua/plugins/oil.lua
return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      view_options = { show_hidden = true },
    },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Abrir Oil (file manager)" },
    },
  }
}
EOF

# Keymaps adicionales (splits, navegación, calidad de vida)
cat << 'EOF' > ~/.config/nvim/lua/plugins/keymaps.lua
return {
  {
    "folke/which-key.nvim",
    opts = {
      preset = "helix",
    },
  }
}
EOF

cat << 'EOF' > ~/.config/nvim/lua/config/keymaps.lua
-- Salir de insert con jk
vim.keymap.set("i", "jk", "<Esc>", { desc = "Salir de insert" })

-- Splits
vim.keymap.set("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split vertical" })
vim.keymap.set("n", "<leader>-", "<cmd>split<cr>",  { desc = "Split horizontal" })

-- Centrar cursor al navegar
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n",     "nzzzv")
vim.keymap.set("n", "N",     "Nzzzv")

-- Pegar sin sobrescribir el clipboard
vim.keymap.set("v", "p", '"_dP')

-- Mover líneas con Alt+j/k
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==")
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==")
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv")
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv")
EOF

echo ""
echo "✅ ¡Instalación de Neovim completada!"
echo ""
echo "👉 Próximo paso: abrí nvim"
echo "   Los plugins se instalan automáticamente la primera vez."
echo ""
echo "   Atajos útiles:"
echo "   <Space>        → menú principal (which-key)"
echo "   <Space>ff      → buscar archivos"
echo "   <Space>fg      → buscar en archivos (grep)"
echo "   -              → abrir Oil (file manager)"
echo "   <Space>a       → Harpoon: marcar archivo"
echo "   Ctrl-e         → Harpoon: menú"
echo "   jk             → salir de insert mode"
