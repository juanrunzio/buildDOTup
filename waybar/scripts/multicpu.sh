#!/bin/bash

# Usar archivo temporal para almacenar estado anterior
STATE_FILE="/tmp/.waybar_cpu_state"

# Leer tiempos anteriores si existen
if [ -f "$STATE_FILE" ]; then
    read -r -a PREV <<< "$(cat "$STATE_FILE")"
else
    PREV=()
fi

# Leer nuevas líneas de /proc/stat (solo CPUs)
mapfile -t LINES < <(grep '^cpu[0-9]' /proc/stat)

USAGES=()
TOTAL_STRING=""

for i in "${!LINES[@]}"; do
    read -r _ user nice system idle iowait irq softirq steal guest guest_nice <<< "${LINES[i]}"
    total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle_total=$((idle + iowait))
    
    if [ ${#PREV[@]} -gt 0 ]; then
        prev_total=${PREV[i*2]}
        prev_idle=${PREV[i*2+1]}
        diff_total=$((total - prev_total))
        diff_idle=$((idle_total - prev_idle))
        
        if [ $diff_total -gt 0 ]; then
            usage=$(( (100 * (diff_total - diff_idle)) / diff_total ))
        else
            usage=0
        fi
        USAGES+=($usage)
        TOTAL_STRING+="$usage  "
        #TOTAL_STRING+="C$i: $usage%  "
    fi
    
    # Guardar nuevos valores
    NEW_STATE+=($total $idle_total)
done

# Guardar estado para próxima ejecución
echo "${NEW_STATE[@]}" > "$STATE_FILE"

# Solo imprimir si ya tenemos datos previos
if [ ${#USAGES[@]} -gt 0 ]; then
    echo -e "${TOTAL_STRING%  }"
else
    echo -e " ...% (recopilando)"
fi
