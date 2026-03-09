#!/bin/bash

# Salir inmediatamente si un comando falla
set -e

echo "🚀 Iniciando instalación del shell (bash + starship, estilo Omarchy)..."

# ── 1. Instalar dependencias ──────────────────────────────────
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "🍏 macOS detectado. Usando Homebrew..."
  if ! command -v brew &>/dev/null; then
    echo "❌ Homebrew no está instalado. Instálalo primero: https://brew.sh/"
    exit 1
  fi
  brew install starship fzf fd ripgrep bat eza zoxide lazygit bash bash-completion@2

elif [[ "$OSTYPE" == "linux-gnu"* ]] && command -v pacman &>/dev/null; then
  echo "🐧 Arch Linux detectado. Usando pacman..."
  sudo pacman -Syu --needed --noconfirm \
    starship fzf fd ripgrep bat eza zoxide lazygit \
    bash bash-completion

else
  echo "❌ Sistema operativo no soportado (solo macOS y Arch Linux)."
  exit 1
fi

# ── 2. Backup de archivos anteriores ──────────────────────────
echo "📦 Haciendo backup de configuraciones antiguas..."
for file in ~/.bashrc ~/.bash_profile ~/.config/starship.toml; do
  if [ -f "$file" ]; then
    mv "$file" "${file}.bak-$(date +%Y%m%d%H%M%S)"
    echo "   -> $file respaldado."
  fi
done

# ── 3. Escribir .bashrc ───────────────────────────────────────
echo "🎨 Escribiendo .bashrc estilo Omarchy..."

cat <<'BASHRC' >"$HOME/.bashrc"
# ============================================================
#  .bashrc
# ============================================================

# Si no es shell interactivo, salir
[[ $- != *i* ]] && return

# ── Detección de OS ──────────────────────────────────────────
_OS="unknown"
[[ "$OSTYPE" == "darwin"* ]]       && _OS="macos"
[[ -f /etc/arch-release ]]         && _OS="arch"

# ── PATH ─────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# macOS — Homebrew
if [[ "$_OS" == "macos" ]]; then
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# ── Historia ─────────────────────────────────────────────────
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=50000
export HISTFILESIZE=50000
export HISTCONTROL="erasedups:ignorespace"
shopt -s histappend
shopt -s cmdhist

# ── Opciones ─────────────────────────────────────────────────
shopt -s checkwinsize
shopt -s globstar
shopt -s autocd
shopt -s cdspell

# ── Variables de entorno ─────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-FiRX"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# ── Aliases principales (estilo Omarchy) ─────────────────────

# tmux — alias principal como en Omarchy
t() {
    if tmux has-session 2>/dev/null; then
        tmux attach
    else
        tmux new-session -s main
    fi
}

# Neovim
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# Listado con eza
if command -v eza &>/dev/null; then
    alias ls='eza --color=always --group-directories-first'
    alias ll='eza -la --color=always --group-directories-first --icons --git'
    alias la='eza -a --color=always --group-directories-first'
    alias lt='eza -T --color=always --group-directories-first --icons -L 2'
else
    alias ls='ls --color=auto'
    alias ll='ls -lahF'
    alias la='ls -A'
fi

# Navegación
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'
alias -- -='cd -'

# Git
alias g='git'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gp='git push'
alias gpl='git pull'
alias gs='git status'
alias lg='lazygit'

# Utilidades
command -v bat &>/dev/null && alias cat='bat --style=plain'
alias df='df -h'
alias reload='source ~/.bashrc'
alias bashrc='nvim ~/.bashrc'
alias tmuxrc='nvim ~/.config/tmux/tmux.conf'
alias nvimrc='nvim ~/.config/nvim/lua/plugins/'

# Clipboard
if [[ "$_OS" == "macos" ]]; then
    alias copy='pbcopy'
    alias paste='pbpaste'
elif command -v wl-copy &>/dev/null; then
    alias copy='wl-copy'
    alias paste='wl-paste'
elif command -v xclip &>/dev/null; then
    alias copy='xclip -selection clipboard'
    alias paste='xclip -selection clipboard -o'
fi

# ── Funciones útiles ─────────────────────────────────────────

# mkcd — crear carpeta y entrar
mkcd() { mkdir -p "$1" && cd "$1"; }

# ff — buscar archivo con fzf y abrirlo en nvim
ff() {
    local file
    file=$(fzf --preview 'bat --color=always {}' 2>/dev/null) && nvim "$file"
}

# extract — descomprimir cualquier formato
extract() {
    case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz)  tar xzf "$1" ;;
        *.tar.xz)  tar xJf "$1" ;;
        *.tar)     tar xf  "$1" ;;
        *.gz)      gunzip  "$1" ;;
        *.zip)     unzip   "$1" ;;
        *.7z)      7z x    "$1" ;;
        *)         echo "No sé cómo extraer '$1'" ;;
    esac
}

# tdl — tmux dev layout (abre nvim + shell side-by-side)
tdl() {
    local name="${1:-$(basename "$PWD")}"
    tmux new-session -d -s "$name" -c "$PWD" 2>/dev/null || true
    tmux split-window -h -p 35 -t "$name" -c "$PWD"
    tmux select-pane -t "$name" -L
    tmux send-keys -t "$name" "nvim ." Enter
    tmux attach -t "$name" 2>/dev/null || tmux switch-client -t "$name"
}

# ── Herramientas modernas ─────────────────────────────────────

# Zoxide — cd inteligente
command -v zoxide &>/dev/null && eval "$(zoxide init bash)"

# FZF
if command -v fzf &>/dev/null; then
    command -v fd &>/dev/null && \
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

    export FZF_DEFAULT_OPTS="
        --height 60% --layout=reverse --border rounded
        --prompt '∷ ' --pointer '▶' --marker '✓'
        --color=bg+:#24283b,bg:#1a1b26,hl:#7aa2f7
        --color=fg:#c0caf5,fg+:#c0caf5,prompt:#7aa2f7,hl+:#7aa2f7
        --color=info:#7dcfff,pointer:#7dcfff,marker:#9ece6a
    "

    # Cargar keybindings (Ctrl-r, Ctrl-t, Alt-c)
    if [[ "$_OS" == "macos" ]]; then
        BREW_PREFIX=$(brew --prefix 2>/dev/null)
        source "${BREW_PREFIX}/opt/fzf/shell/key-bindings.bash" 2>/dev/null || true
        source "${BREW_PREFIX}/opt/fzf/shell/completion.bash"   2>/dev/null || true
    else
        source /usr/share/fzf/key-bindings.bash 2>/dev/null || true
        source /usr/share/fzf/completion.bash   2>/dev/null || true
    fi
fi

# ── Bash completion ───────────────────────────────────────────
if [[ "$_OS" == "macos" ]]; then
    BREW_PREFIX=$(brew --prefix 2>/dev/null)
    [[ -r "${BREW_PREFIX}/etc/profile.d/bash_completion.sh" ]] && \
        source "${BREW_PREFIX}/etc/profile.d/bash_completion.sh"
else
    [[ -r /usr/share/bash-completion/bash_completion ]] && \
        source /usr/share/bash-completion/bash_completion
fi

# ── Starship prompt ───────────────────────────────────────────
command -v starship &>/dev/null && eval "$(starship init bash)"

# ── Overrides locales (no tocar este archivo) ─────────────────
[[ -f "$HOME/.bashrc.local" ]] && source "$HOME/.bashrc.local"
BASHRC

# ── 4. Escribir .bash_profile ─────────────────────────────────
cat <<'PROFILE' >"$HOME/.bash_profile"
# Delegar todo a .bashrc
[[ -f "$HOME/.bashrc" ]] && source "$HOME/.bashrc"
PROFILE

# ── 5. Escribir config de Starship (Tokyo Night) ──────────────
echo "⭐ Escribiendo config de Starship..."
mkdir -p "$HOME/.config"

cat <<'STARSHIP' >"$HOME/.config/starship.toml"
format = """
$os\
$directory\
$git_branch\
$git_status\
$python\
$ruby\
$node\
$cmd_duration\
$line_break\
$character"""

palette = "tokyo_night"

[palettes.tokyo_night]
blue   = "#7aa2f7"
cyan   = "#7dcfff"
green  = "#9ece6a"
orange = "#ff9e64"
purple = "#9d7cd8"
red    = "#f7768e"
yellow = "#e0af68"
fg     = "#c0caf5"
bg_hl  = "#24283b"

[os]
disabled = false
style    = "fg:blue bold"
format   = "[$symbol ]($style)"

[os.symbols]
Arch  = ""
Macos = ""
Linux = ""

[directory]
style             = "fg:blue bold"
read_only         = " 󰌾"
truncation_length = 3
truncate_to_repo  = true
format            = "[$path]($style)[$read_only]($read_only_style) "

[git_branch]
symbol = " "
style  = "fg:purple bold"
format = "[$symbol$branch]($style) "

[git_status]
style    = "fg:orange"
format   = "([$all_status$ahead_behind]($style) )"
ahead    = "⇡${count}"
behind   = "⇣${count}"
modified = "!${count}"
staged   = "+${count}"
untracked = "?${count}"

[python]
symbol       = " "
style        = "fg:yellow"
format       = "[$symbol$virtualenv]($style) "
detect_files = ["pyproject.toml", "requirements.txt", ".python-version"]

[ruby]
symbol       = " "
style        = "fg:red"
format       = "[$symbol$version]($style) "
detect_files = [".ruby-version", "Gemfile"]

[nodejs]
symbol       = " "
style        = "fg:green"
format       = "[$symbol$version]($style) "
detect_files = ["package.json", ".nvmrc"]

[cmd_duration]
min_time = 2000
style    = "fg:yellow"
format   = "[󱦟 $duration]($style) "

[character]
success_symbol = "[❯](fg:green bold)"
error_symbol   = "[❯](fg:red bold)"
vimcmd_symbol  = "[❮](fg:purple bold)"
STARSHIP

# ── 6. Escribir .inputrc ──────────────────────────────────────
echo "⌨️  Escribiendo .inputrc (Readline)..."

cat <<'INPUTRC' >"$HOME/.inputrc"
set meta-flag on
set input-meta on
set output-meta on
set convert-meta off
set completion-ignore-case on
set completion-prefix-display-length 2
set show-all-if-ambiguous on
set show-all-if-unmodified on

# Flechas ↑↓ buscan en historial filtrando lo que ya escribiste
"\e[A": history-search-backward
"\e[B": history-search-forward
"\e[C": forward-char
"\e[D": backward-char

# Slash automático al autocompletar symlinks a directorios
set mark-symlinked-directories on

# No autocompletar archivos ocultos salvo que empieces con punto
set match-hidden-files off

# Mostrar todos los resultados de autocompletado sin paginar
set page-completions off

# Si hay más de 200 opciones, preguntar antes de mostrar
set completion-query-items 200

# Mostrar info extra al completar (como ls -F)
set visible-stats on

# Autocompletar inteligente considerando el texto después del cursor
set skip-completed-text on

# Colores en el autocompletado
set colored-stats on

# Tab cicla entre candidatos, Shift-Tab cicla hacia atrás
TAB: menu-complete
"\e[Z": menu-complete-backward

# Mostrar el prefijo común antes de ciclar
set menu-complete-display-prefix on
INPUTRC

echo ""
echo "✅ ¡Instalación del shell completada!"
echo ""
echo "👉 Para activar los cambios:"
echo "   source ~/.bashrc"
echo ""
echo "   Aliases principales:"
echo "   t          → tmux attach o nueva sesión"
echo "   v          → nvim"
echo "   lg         → lazygit"
echo "   ll         → eza (ls mejorado)"
echo "   ff         → fzf → abrir en nvim"
echo "   z <dir>    → zoxide (cd inteligente)"
echo "   tdl        → tmux dev layout"
echo "   mkcd <dir> → mkdir + cd"
echo "   extract    → descomprimir cualquier formato"
echo "   Ctrl-r     → buscar en historial con fzf"
