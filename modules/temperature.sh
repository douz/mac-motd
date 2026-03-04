#!/bin/zsh

# Define variables
warnDiskTemperature=50
criticalDiskTemperature=61
warnCpuTemperature=60
criticalCpuTemperature=80
diskDevice="${MOTD_DISK_DEVICE:-/dev/disk1s1}"
smcJson="$(iSMC temp -o json 2>/dev/null)"
fontColor="\e[97m"
clear="\e[0m"

is_number() {
    local value="$1"
    [[ -n "$value" ]] && echo "$value" | awk 'BEGIN { ok=1 } { if ($0 !~ /^[0-9]+(\.[0-9]+)?$/) ok=0 } END { exit !ok }'
}

format_celsius() {
    local value="$1"
    if is_number "$value"; then
        awk -v v="$value" 'BEGIN { printf "%.2f°C", v }'
    else
        echo "N/A"
    fi
}

rows_from_json() {
    local json="$1"
    if [ -z "$json" ]; then
        return
    fi
    echo "$json" | jq -r '
      if type == "object" then
        to_entries[]
        | select(.value.quantity != null)
        | [
            .key,
            (.value.key // ""),
            (.value.quantity | tonumber),
            (.value.unit // "°C")
          ]
        | @tsv
      else
        empty
      end
    ' 2>/dev/null | awk -F '\t' 'tolower($1) !~ /trend|error/'
}

filter_storage_rows() {
    local rows="$1"
    echo "$rows" | awk -F '\t' '
        {
            name = tolower($1)
            # Keep only explicit storage-labeled sensors.
            if (name ~ /(^drive|^ssd|^nand|hdd bay|disk)/) {
                print
            }
        }
    '
}

pick_max() {
    local rows="$1"
    local nameRegex="$2"
    local keyRegex="$3"
    local excludeKey="${4:-}"

    echo "$rows" | awk -F '\t' -v nre="$nameRegex" -v kre="$keyRegex" -v exk="$(echo "$excludeKey" | tr '[:upper:]' '[:lower:]')" '
        BEGIN { best=-1e9 }
        {
            name=$1
            key=$2
            qty=$3
            lname=tolower(name)
            lkey=tolower(key)
            nameMatch=(nre != "" && lname ~ nre)
            keyMatch=(kre != "" && lkey ~ kre)
            if ((nameMatch || keyMatch) && (exk == "" || lkey != exk)) {
                q=qty + 0
                if (q > best) {
                    best=q
                    bestName=name
                    bestKey=key
                    bestQty=q
                    bestUnit=$4
                }
            }
        }
        END {
            if (best > -1e8) {
                printf "%s\t%s\t%.6f\t%s\n", bestName, bestKey, bestQty, bestUnit
            }
        }
    '
}

row_value() {
    local row="$1"
    [ -z "$row" ] && return
    echo "$row" | awk -F '\t' '{ print $3 }'
}

row_key() {
    local row="$1"
    [ -z "$row" ] && return
    echo "$row" | awk -F '\t' '{ print $2 }'
}

sensor_text() {
    local row="$1"
    if [ -z "$row" ]; then
        echo "N/A"
        return
    fi
    local name key qty
    IFS=$'\t' read -r name key qty _ <<<"$row"
    echo "$(format_celsius "$qty") (${name}, ${key})"
}

temp_color() {
    local value="$1"
    local warn="$2"
    local critical="$3"

    if ! is_number "$value"; then
        echo "\e[1;40m"
    elif awk -v a="$value" -v b="$critical" 'BEGIN { exit !(a > b) }'; then
        echo "\e[1;41m"
    elif awk -v a="$value" -v b="$warn" 'BEGIN { exit !(a > b) }'; then
        echo "\e[1;43m"
    else
        echo "\e[1;42m"
    fi
}

render_sensor_row() {
    local label="$1"
    local row="$2"
    local warn="$3"
    local critical="$4"
    local value color text

    value="$(row_value "$row")"
    color="$(temp_color "$value" "$warn" "$critical")"
    text="$(sensor_text "$row")"
    echo "  ${label}: ${fontColor}${color} ${text} ${clear}"
}

render_numeric_row() {
    local label="$1"
    local value="$2"
    local detail="$3"
    local warn="$4"
    local critical="$5"
    local color text

    color="$(temp_color "$value" "$warn" "$critical")"
    if is_number "$value"; then
        text="$(format_celsius "$value") ${detail}"
    else
        text="N/A"
    fi
    echo "  ${label}: ${fontColor}${color} ${text} ${clear}"
}

smcRows="$(rows_from_json "$smcJson")"

cpuPrimary="$(pick_max "$smcRows" 'cpu diode filtered|cpu diode virtual|max peci reported|peci sa|cpu performance core|cpu efficiency core' '^(tc0f|tc0e|tcmx|tcsa|tp[0-9a-z]+|te[0-9a-z]+|tf[0-9a-z]+)$')"
if [ -z "$cpuPrimary" ]; then
    cpuPrimary="$(pick_max "$smcRows" 'cpu core' '^tc[0-9a-z]+c$')"
fi
if [ -z "$cpuPrimary" ]; then
    cpuPrimary="$(pick_max "$smcRows" 'cpu' '^tc[0-9a-z]+$')"
fi
cpuSecondary="$(pick_max "$smcRows" 'cpu core|cpu performance core|cpu efficiency core' '^(tc[0-9a-z]+c|tp[0-9a-z]+|te[0-9a-z]+|tf[0-9a-z]+)$' "$(row_key "$cpuPrimary")")"

gpuPrimary="$(pick_max "$smcRows" 'gpu amd radeon|gpu intel graphics|^gpu [0-9]+' '^(tgdd|tcgc|tg[0-9a-z]+|tf1[0-9a-z]+)$')"
if [ -z "$gpuPrimary" ]; then
    gpuPrimary="$(pick_max "$smcRows" 'gpu' '^tg[0-9a-z]+$')"
fi
gpuSecondary="$(pick_max "$smcRows" 'gpu proximity|gpu diode|gpu heatsink|^gpu [0-9]+' '^(tg[0-9a-z]*p|tg[0-9a-z]+|tf1[0-9a-z]+)$' "$(row_key "$gpuPrimary")")"

memPrimary="$(pick_max "$smcRows" 'memory proximity' '^ts0s$')"
if [ -z "$memPrimary" ]; then
    memPrimary="$(pick_max "$smcRows" 'mem bank|memory [0-9]+|dimm' '^tm[0-9a-z]+$')"
fi
memSecondary="$(pick_max "$smcRows" 'mem bank|memory [0-9]+|dimm' '^tm[0-9a-z]+$' "$(row_key "$memPrimary")")"

if [ -z "$cpuPrimary" ] && [ -n "$cpuSecondary" ]; then
    cpuPrimary="$cpuSecondary"
    cpuSecondary=""
fi
if [ -z "$gpuPrimary" ] && [ -n "$gpuSecondary" ]; then
    gpuPrimary="$gpuSecondary"
    gpuSecondary=""
fi
if [ -z "$memPrimary" ] && [ -n "$memSecondary" ]; then
    memPrimary="$memSecondary"
    memSecondary=""
fi

diskSmartRaw="$(smartctl -a "${diskDevice}" 2>/dev/null | awk 'BEGIN{IGNORECASE=1} /Temperature/ {for (i=1; i<=NF; i++) if ($i ~ /^[0-9]+(\.[0-9]+)?$/) last=$i} END{if (last != "") print last}')"
storageRows="$(filter_storage_rows "$smcRows")"
diskSmcPrimary="$(pick_max "$storageRows" 'drive|ssd|nand|disk|hdd bay' '^th[0-9a-z]+$')"
diskSmcSecondary="$(pick_max "$storageRows" 'drive|ssd|nand|disk|hdd bay' '^th[0-9a-z]+$' "$(row_key "$diskSmcPrimary")")"

if [ -z "$diskSmcPrimary" ] && [ -n "$diskSmcSecondary" ]; then
    diskSmcPrimary="$diskSmcSecondary"
    diskSmcSecondary=""
fi

# Print devices temperature
echo -e "\e[1mSystem Temperature${clear}"

if is_number "$diskSmartRaw"; then
    echo "$(render_numeric_row 'Disk Temp..' "$diskSmartRaw" "(SMART, ${diskDevice})" "$warnDiskTemperature" "$criticalDiskTemperature")"
elif [ -n "$diskSmcPrimary" ]; then
    echo "$(render_sensor_row 'Disk Temp..' "$diskSmcPrimary" "$warnDiskTemperature" "$criticalDiskTemperature")"
else
    echo "$(render_numeric_row 'Disk Temp..' '' '' "$warnDiskTemperature" "$criticalDiskTemperature")"
fi
if [ -n "$diskSmcPrimary" ] && is_number "$diskSmartRaw"; then
    echo "$(render_sensor_row 'Disk Temp+.' "$diskSmcPrimary" "$warnDiskTemperature" "$criticalDiskTemperature")"
fi
if [ -n "$diskSmcSecondary" ]; then
    echo "$(render_sensor_row 'Disk Temp++' "$diskSmcSecondary" "$warnDiskTemperature" "$criticalDiskTemperature")"
fi

echo "$(render_sensor_row 'CPU Temp...' "$cpuPrimary" "$warnCpuTemperature" "$criticalCpuTemperature")"
if [ -n "$cpuSecondary" ]; then
    echo "$(render_sensor_row 'CPU Temp+..' "$cpuSecondary" "$warnCpuTemperature" "$criticalCpuTemperature")"
fi

echo "$(render_sensor_row 'GPU Temp...' "$gpuPrimary" "$warnCpuTemperature" "$criticalCpuTemperature")"
if [ -n "$gpuSecondary" ]; then
    echo "$(render_sensor_row 'GPU Temp+..' "$gpuSecondary" "$warnCpuTemperature" "$criticalCpuTemperature")"
fi

echo "$(render_sensor_row 'Mem Temp...' "$memPrimary" "$warnCpuTemperature" "$criticalCpuTemperature")"
if [ -n "$memSecondary" ]; then
    echo "$(render_sensor_row 'Mem Temp+..' "$memSecondary" "$warnCpuTemperature" "$criticalCpuTemperature")"
fi

echo ""
