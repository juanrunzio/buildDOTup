#!/bin/bash

set -e

echo "🚀 Iniciando instalación de Emacs + Doom Emacs..."

# ── Directorios ───────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOOM_CONFIG_SRC="$SCRIPT_DIR/../doom" # carpeta doom dentro del repo
DOOM_CONFIG_DST="$HOME/.config/doom"

# ── 1. Instalar dependencias ──────────────────────────────────
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "🍏 macOS detectado. Usando Homebrew..."
  if ! command -v brew &>/dev/null; then
    echo "❌ Homebrew no está instalado. Instálalo primero: https://brew.sh/"
    exit 1
  fi
  brew install --quiet \
    git ripgrep fd \
    node sqlite3 \
    aspell \
    poppler \
    libvterm \
    tree-sitter \
    coreutils \
    cmake \
    pyright \
    rust-analyzer \
    haskell-language-server
  brew install --quiet llvm # clangd
  brew install --cask emacs-app font-jetbrains-mono-nerd-font

elif [[ "$OSTYPE" == "linux-gnu"* ]] && command -v pacman &>/dev/null; then
  echo "🐧 Arch Linux detectado. Usando pacman..."
  sudo pacman -Syu --needed --noconfirm \
    emacs \
    git ripgrep fd \
    nodejs npm sqlite \
    aspell aspell-en aspell-es \
    poppler \
    libvterm \
    tree-sitter \
    cmake \
    clang \
    pyright \
    rust-analyzer

  # haskell-language-server desde AUR
  if command -v yay &>/dev/null; then
    yay -S --needed --noconfirm haskell-language-server
  elif command -v paru &>/dev/null; then
    paru -S --needed --noconfirm haskell-language-server
  else
    echo "⚠️  Sin AUR helper — haskell-language-server no instalado."
    echo "   Instalalo manualmente si usás Haskell."
  fi

else
  echo "❌ Sistema operativo no soportado (solo macOS y Arch Linux)."
  exit 1
fi

# ── 2. Instalar Doom Emacs ────────────────────────────────────
echo "📥 Instalando Doom Emacs..."
if [ -d "$HOME/.config/emacs" ]; then
  echo "   -> Doom ya estaba instalado, actualizando..."
  "$HOME/.config/emacs/bin/doom" upgrade --no-config 2>/dev/null || true
else
  git clone --depth 1 https://github.com/doomemacs/doomemacs "$HOME/.config/emacs"
  echo "   -> Doom Emacs clonado."
fi

# Agregar doom al PATH si no está
DOOM_BIN="$HOME/.config/emacs/bin"
if [[ ":$PATH:" != *":$DOOM_BIN:"* ]]; then
  export PATH="$DOOM_BIN:$PATH"
fi

# ── 3. Backup de config anterior ──────────────────────────────
echo "📦 Haciendo backup de configuración anterior..."
if [ -d "$DOOM_CONFIG_DST" ]; then
  mv "$DOOM_CONFIG_DST" "${DOOM_CONFIG_DST}.bak-$(date +%Y%m%d%H%M%S)"
  echo "   -> $DOOM_CONFIG_DST respaldado."
fi

# ── 4. Copiar config del repo ─────────────────────────────────
echo "📂 Copiando config de Doom desde el repo..."
if [ ! -d "$DOOM_CONFIG_SRC" ]; then
  echo "❌ No se encontró la carpeta 'doom' en $SCRIPT_DIR"
  echo "   Asegurate de que la carpeta doom/ esté junto a este script."
  exit 1
fi
cp -r "$DOOM_CONFIG_SRC" "$DOOM_CONFIG_DST"
echo "   -> Config copiada a $DOOM_CONFIG_DST"

# ── 5. Doom install + sync ────────────────────────────────────
echo "⚙️  Corriendo doom install..."
"$HOME/.config/emacs/bin/doom" install --no-config

echo "🔄 Corriendo doom sync..."
"$HOME/.config/emacs/bin/doom" sync

# ── 6. Agregar doom al PATH en .bashrc ───────────────────────
echo "🔧 Agregando doom al PATH..."
BASHRC="$HOME/.bashrc"
if ! grep -q "doom/bin\|emacs/bin" "$BASHRC" 2>/dev/null; then
  echo '' >>"$BASHRC"
  echo '# Doom Emacs' >>"$BASHRC"
  echo 'export PATH="$HOME/.config/emacs/bin:$PATH"' >>"$BASHRC"
  echo "   -> PATH actualizado en .bashrc"
fi

echo ""
echo "✅ ¡Instalación de Doom Emacs completada!"
echo ""
echo "👉 Próximos pasos:"
echo "   1. source ~/.bashrc"
echo "   2. emacs  (la primera vez tarda en cargar todo)"
echo "   3. doom doctor  (para verificar que todo esté bien)"
echo ""
echo "   Atajos principales (Evil mode):"
echo "   SPC SPC    → buscar archivo"
echo "   SPC /      → buscar texto en proyecto"
echo "   SPC g g    → abrir Magit"
echo "   SPC o t    → abrir vterm"
echo "   SPC h r r  → recargar config (doom/reload)"
echo "   SPC q q    → salir de Emacs"
