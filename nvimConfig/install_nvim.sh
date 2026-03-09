#!/bin/bash

# Salir inmediatamente si un comando falla
set -e

echo "🚀 Iniciando instalación de Neovim (LazyVim estilo Omarchy)..."

# 1. Instalar dependencias según el sistema operativo
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍏 macOS detectado. Usando Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew no está instalado. Instálalo primero desde https://brew.sh/"
        exit 1
    fi
    brew install neovim git ripgrep fd fzf lazygit gcc
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🐧 Linux detectado."
    if command -v pacman &> /dev/null; then
        echo "⚙️ Arch Linux detectado. Usando pacman..."
        sudo pacman -Syu --needed neovim git ripgrep fd fzf lazygit gcc wl-clipboard
    elif command -v apt &> /dev/null; then
        echo "⚙️ Debian/Ubuntu detectado. Usando apt..."
        sudo apt update
        sudo apt install -y neovim git ripgrep fd-find fzf build-essential xclip
    else
        echo "❌ Gestor de paquetes no soportado automáticamente. Instala dependencias manualmente."
        exit 1
    fi
else
    echo "❌ Sistema operativo no soportado."
    exit 1
fi

# 2. Respaldar configuración anterior
echo "📦 Haciendo backup de configuraciones antiguas..."
for dir in ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; do
    if [ -d "$dir" ]; then
        mv "$dir" "${dir}.bak-$(date +%Y%m%d%H%M%S)"
        echo "   -> $dir respaldado."
    fi
done

# 3. Clonar LazyVim
echo "📥 Clonando configuración base de LazyVim..."
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# Inyectar los parches específicos de Omarchy?

# Desactivar el scroll animado de Snacks
#cat << 'EOF' > ~/.config/nvim/lua/plugins/snacks-animated-scrolling-off.lua
#return {
#  {
#    "folke/snacks.nvim",
#    opts = {
#      scroll = { enabled = false },
#    }
#  }
#}
#EOF
#
## Desactivar las noticias de LazyVim al iniciar
#cat << 'EOF' > ~/.config/nvim/lua/plugins/disable-news-alert.lua
#return {
#  {
#    "LazyVim/LazyVim",
#    opts = {
#      news = { lazyvim = false, neovim = false },
#    }
#  }
#}
#EOF
#
## Configurar un tema estático (reemplaza al symlink dinámico de Omarchy)
#cat << 'EOF' > ~/.config/nvim/lua/plugins/theme.lua
#return {
#  {
#    "LazyVim/LazyVim",
#    opts = {
#      colorscheme = "tokyonight",
#    }
#  }
#}
#EOF
#
echo "✅ ¡Instalación completada con éxito!"
