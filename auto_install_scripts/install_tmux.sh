#!/bin/bash

set -e

echo "🚀 Iniciando instalación de Tmux (estilo Omarchy + plugins)..."

# ── 1. Instalar dependencias ──────────────────────────────────
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "🍏 macOS detectado. Usando Homebrew..."
  if ! command -v brew &>/dev/null; then
    echo "❌ Homebrew no está instalado. Instálalo primero: https://brew.sh/"
    exit 1
  fi
  brew install tmux git

elif [[ "$OSTYPE" == "linux-gnu"* ]] && command -v pacman &>/dev/null; then
  echo "🐧 Arch Linux detectado. Usando pacman..."
  sudo pacman -Syu --needed --noconfirm tmux git

else
  echo "❌ Sistema operativo no soportado (solo macOS y Arch Linux)."
  exit 1
fi

# ── 2. Instalar TPM ───────────────────────────────────────────
echo "📦 Instalando TPM (Tmux Plugin Manager)..."
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "   -> TPM ya estaba instalado, actualizando..."
  git -C "$HOME/.tmux/plugins/tpm" pull --quiet
else
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  echo "   -> TPM instalado."
fi

# ── 3. Backup de config anterior ──────────────────────────────
echo "📦 Haciendo backup de configuración antigua..."
TMUX_CONF="$HOME/.config/tmux/tmux.conf"
if [ -f "$TMUX_CONF" ]; then
  mv "$TMUX_CONF" "${TMUX_CONF}.bak-$(date +%Y%m%d%H%M%S)"
  echo "   -> $TMUX_CONF respaldado."
fi

# ── 4. Crear directorio de config ─────────────────────────────
mkdir -p "$HOME/.config/tmux"

# ── 5. Escribir tmux.conf ─────────────────────────────────────
echo "🎨 Escribiendo configuración..."

cat <<'TMUXCONF' >"$HOME/.config/tmux/tmux.conf"
# ── Prefix ────────────────────────────────────────────────────
set -g prefix C-Space
set -g prefix2 C-b
bind C-Space send-prefix

# ── General ───────────────────────────────────────────────────
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",*:RGB"
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g history-limit 50000
set -g escape-time 0
set -g focus-events on
set -g set-clipboard on
set -g allow-passthrough on
setw -g aggressive-resize on
set -g detach-on-destroy off

# ── Copy mode ─────────────────────────────────────────────────
setw -g mode-keys vi
bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi y send -X copy-selection-and-cancel
bind -T copy-mode-vi C-v send-keys -X rectangle-toggle

# ── Paneles ───────────────────────────────────────────────────
bind h split-window -v -c "#{pane_current_path}"
bind v split-window -h -c "#{pane_current_path}"
bind x kill-pane

bind -n C-M-Left  select-pane -L
bind -n C-M-Right select-pane -R
bind -n C-M-Up    select-pane -U
bind -n C-M-Down  select-pane -D

bind -n C-M-S-Left  resize-pane -L 5
bind -n C-M-S-Down  resize-pane -D 5
bind -n C-M-S-Up    resize-pane -U 5
bind -n C-M-S-Right resize-pane -R 5

# ── Ventanas ──────────────────────────────────────────────────
bind r command-prompt -I "#W" "rename-window -- '%%'"
bind c new-window -c "#{pane_current_path}"
bind k kill-window

bind -n M-1 select-window -t 1
bind -n M-2 select-window -t 2
bind -n M-3 select-window -t 3
bind -n M-4 select-window -t 4
bind -n M-5 select-window -t 5
bind -n M-6 select-window -t 6
bind -n M-7 select-window -t 7
bind -n M-8 select-window -t 8
bind -n M-9 select-window -t 9
bind -n M-Left  select-window -t -1
bind -n M-Right select-window -t +1

# ── Sesiones ──────────────────────────────────────────────────
bind R command-prompt -I "#S" "rename-session -- '%%'"
bind C new-session -c "#{pane_current_path}"
bind K kill-session
bind P switch-client -p
bind N switch-client -n
bind -n M-Up   switch-client -p
bind -n M-Down switch-client -n

bind q source-file ~/.config/tmux/tmux.conf \; display "Config recargada ✓"

# ── Popup flotante (como Zellij) ──────────────────────────────
bind p run-shell "~/.config/tmux/scripts/popup.sh"

# ── Status bar ────────────────────────────────────────────────
set -g status-position bottom
set -g status-interval 5
set -g status-left-length 30
set -g status-right-length 80
set -g window-status-separator ""

set -g status-style                  "bg=#1a1b26,fg=#c0caf5"
set -g status-left                   "#[bg=#7aa2f7,fg=#1a1b26,bold] #S #[bg=#1a1b26,fg=#7aa2f7]"
set -g status-right                  "#[fg=#9d7cd8]#{?client_prefix,⌨ PREFIX ,}#[fg=#7dcfff]%H:%M #[fg=#c0caf5,dim]%d/%m "
set -g window-status-format          "#[fg=#c0caf5] #I:#W "
set -g window-status-current-format  "#[fg=#24283b,bg=#1a1b26] #[bg=#24283b,fg=#7aa2f7] #I:#W #[fg=#24283b,bg=#1a1b26]"
set -g pane-border-style             "fg=#24283b"
set -g pane-active-border-style      "fg=#7aa2f7"
set -g message-style                 "bg=#ff9e64,fg=#1a1b26,bold"
set -g message-command-style         "bg=#24283b,fg=#ff9e64"
set -g mode-style                    "bg=#7aa2f7,fg=#1a1b26"
setw -g clock-mode-colour "#7aa2f7"

# ── Plugins (TPM) ─────────────────────────────────────────────
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'

set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-nvim 'session'
set -g @continuum-restore 'on'
set -g @continuum-save-interval '10'

run '~/.tmux/plugins/tpm/tpm'
TMUXCONF

# ── 6. Crear script de popup flotante ──────────────────────────
echo "🪟 Creando script de popup flotante..."
mkdir -p "$HOME/.config/tmux/scripts"
cat <<'POPUPEOF' >"$HOME/.config/tmux/scripts/popup.sh"
#!/bin/bash
if [ "$(tmux display-message -p -F "#{session_name}")" = "popup" ]; then
  tmux detach-client
else
  tmux popup -h 70% -w 70% -E "tmux attach -t popup || tmux new -s popup" &
fi
POPUPEOF
chmod +x "$HOME/.config/tmux/scripts/popup.sh"
echo "   -> popup.sh creado."

# ── 7. Symlink para que tmux encuentre el config ──────────────
if [ ! -f "$HOME/.tmux.conf" ] && [ ! -L "$HOME/.tmux.conf" ]; then
  ln -s "$HOME/.config/tmux/tmux.conf" "$HOME/.tmux.conf"
  echo "   -> Symlink ~/.tmux.conf creado."
fi

# ── 8. Instalar plugins ───────────────────────────────────────
echo "📦 Instalando plugins..."
"$HOME/.tmux/plugins/tpm/bin/install_plugins" &>/dev/null || true
echo "   -> Plugins instalados."

echo ""
echo "✅ ¡Instalación de Tmux completada!"
echo ""
echo "   Atajos principales (prefix = Ctrl-Space):"
echo "   Ctrl-Space h         → split horizontal"
echo "   Ctrl-Space v         → split vertical"
echo "   Ctrl-Alt-flechas     → navegar paneles (sin prefix)"
echo "   Ctrl-Space c         → nueva ventana"
echo "   Ctrl-Space C         → nueva sesión"
echo "   Ctrl-Space K         → cerrar sesión"
echo "   Alt-↑/↓              → cambiar sesión"
echo "   Alt-1..9             → ir a ventana"
echo "   Ctrl-Space q         → recargar config"
echo "   Ctrl-Space Ctrl-s    → guardar sesión (resurrect)"
echo "   Ctrl-Space Ctrl-r    → restaurar sesión (resurrect)"
echo "   Ctrl-Space p         → popup flotante (como Zellij)"
