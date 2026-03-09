# Cheatsheet — Tmux & LazyVim

---

## Tmux

> Prefix = `Ctrl-Space` (se presiona, se suelta, y después la tecla)
> `Ctrl-b` también funciona como prefix secundario

### Sesiones
| Atajo | Acción |
|-------|--------|
| `tmux` | Nueva sesión |
| `tmux new -s nombre` | Nueva sesión con nombre |
| `tmux ls` | Listar sesiones |
| `tmux attach` | Conectarse a la última sesión |
| `Ctrl-Space d` | Desconectarse (sesión sigue viva en background) |
| `Ctrl-Space C` | Nueva sesión en el directorio actual |
| `Ctrl-Space K` | Cerrar sesión actual |
| `Ctrl-Space R` | Renombrar sesión actual |
| `Ctrl-Space P` | Sesión anterior |
| `Ctrl-Space N` | Sesión siguiente |
| `Alt-↑` | Sesión anterior (sin prefix) |
| `Alt-↓` | Sesión siguiente (sin prefix) |

### Ventanas (tabs)
| Atajo | Acción |
|-------|--------|
| `Ctrl-Space c` | Nueva ventana en el directorio actual |
| `Ctrl-Space r` | Renombrar ventana actual |
| `Ctrl-Space k` | Cerrar ventana actual |
| `Ctrl-Space w` | Ver y elegir entre todas las ventanas |
| `Alt-1..9` | Ir a ventana por número (sin prefix) |
| `Alt-←` | Ventana anterior (sin prefix) |
| `Alt-→` | Ventana siguiente (sin prefix) |

### Paneles (splits)
| Atajo | Acción |
|-------|--------|
| `Ctrl-Space h` | Split horizontal (panel abajo) |
| `Ctrl-Space v` | Split vertical (panel a la derecha) |
| `Ctrl-Space x` | Cerrar panel actual |
| `Ctrl-Space z` | Zoom al panel actual (toggle fullscreen) |
| `Ctrl-Alt-←/→/↑/↓` | Navegar entre paneles (sin prefix) |
| `Ctrl-Alt-Shift-←/→/↑/↓` | Resize del panel (sin prefix) |
| `Ctrl-Space q` | Recargar config |

### Copy mode
| Atajo | Acción |
|-------|--------|
| `Ctrl-Space [` | Entrar a copy mode |
| `v` | Empezar selección |
| `Ctrl-v` | Selección rectangular |
| `y` | Copiar selección al clipboard |
| `q / Esc` | Salir de copy mode |
| `Ctrl-Space ]` | Pegar |

### Plugins
| Atajo | Acción |
|-------|--------|
| `Ctrl-Space Ctrl-s` | Guardar sesión (resurrect) |
| `Ctrl-Space Ctrl-r` | Restaurar sesión (resurrect) |
| `Ctrl-Space I` | Instalar plugins nuevos (TPM) |
| `Ctrl-Space U` | Actualizar plugins (TPM) |

### Funciones de shell (dentro de tmux)
| Comando | Acción |
|---------|--------|
| `tdl <ai>` | Dev layout: nvim + AI + terminal abajo |
| `tdl <ai> <ai2>` | Dev layout con dos AIs side by side |
| `tdlm <ai>` | Una ventana tdl por cada subdirectorio |
| `tsl <n> <cmd>` | N paneles corriendo el mismo comando |

---

## LazyVim

> Leader = `Space`

### Archivos y búsqueda
| Atajo | Acción |
|-------|--------|
| `Space Space` | Buscar archivos del proyecto |
| `Space /` | Buscar texto en todo el proyecto |
| `Space f r` | Archivos abiertos recientemente |
| `Space f n` | Nuevo archivo |
| `Space e` | Abrir/cerrar explorador (neo-tree) |
| `-` | Abrir Oil (file manager en buffer) |

### Harpoon — navegación rápida
| Atajo | Acción |
|-------|--------|
| `Space a` | Marcar archivo actual |
| `Ctrl-e` | Abrir menú de Harpoon |
| `Ctrl-1/2/3/4` | Saltar al archivo marcado 1/2/3/4 |

### Buffers
| Atajo | Acción |
|-------|--------|
| `Shift-h` | Buffer anterior |
| `Shift-l` | Buffer siguiente |
| `Space b d` | Cerrar buffer actual |
| `Space b o` | Cerrar todos los otros buffers |
| `Space b b` | Listar buffers abiertos |

### Splits y ventanas
| Atajo | Acción |
|-------|--------|
| `Space \|` | Split vertical |
| `Space -` | Split horizontal |
| `Ctrl-h/j/k/l` | Navegar entre splits (también funciona con paneles de tmux) |
| `Ctrl-↑/↓/←/→` | Resize del split |

### Código y LSP
| Atajo | Acción |
|-------|--------|
| `g d` | Ir a definición |
| `g D` | Ir a declaración |
| `g r` | Ver todas las referencias |
| `g i` | Ir a implementación |
| `K` | Ver documentación del símbolo bajo el cursor |
| `Space c r` | Renombrar símbolo en todo el proyecto |
| `Space c a` | Code actions (sugerencias del LSP) |
| `Space c f` | Formatear archivo |
| `[ d` | Error/warning anterior |
| `] d` | Error/warning siguiente |
| `Space x x` | Ver lista de errores del proyecto |

### Git
| Atajo | Acción |
|-------|--------|
| `Space g g` | Abrir lazygit |
| `Space g b` | Git blame línea actual |
| `Space g d` | Git diff archivo actual |
| `] h` | Siguiente hunk (cambio) |
| `[ h` | Hunk anterior |
| `Space g h s` | Stage hunk bajo el cursor |
| `Space g h r` | Revertir hunk bajo el cursor |
| `Space g h p` | Preview del hunk |

### Edición
| Atajo | Acción |
|-------|--------|
| `jk` | Salir de insert mode |
| `Alt-j` | Mover línea o bloque seleccionado abajo |
| `Alt-k` | Mover línea o bloque seleccionado arriba |
| `gcc` | Comentar/descomentar línea |
| `gc` (visual) | Comentar/descomentar selección |
| `>` (visual) | Indentar selección (mantiene la selección) |
| `<` (visual) | Des-indentar selección |
| `Ctrl-d` | Scroll hacia abajo centrado |
| `Ctrl-u` | Scroll hacia arriba centrado |
| `p` (visual) | Pegar sin sobrescribir el clipboard |

### Terminal
| Atajo | Acción |
|-------|--------|
| `Ctrl-/` | Abrir/cerrar terminal flotante |
| `Space f t` | Abrir terminal en split |

### Misc
| Atajo | Acción |
|-------|--------|
| `Space l` | Abrir Lazy (gestor de plugins) |
| `Space u` | Opciones de UI (colores, línea de números, etc.) |
| `Space ?` | Buscar cualquier keymap |
| `Esc` | Limpiar resaltado de búsqueda |
