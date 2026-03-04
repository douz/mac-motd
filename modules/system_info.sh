#!/bin/zsh

# Define variables
osName=$(sw_vers -productName)
osVersion=$(sw_vers -productVersion)
osbuildVersion=$(sw_vers -buildVersion)
kernelVersion=$(sysctl -n kern.version | awk '{print $1" "$4}' | sed 's/.$//')
modelIdentifier=$(sysctl -n hw.model)
procesorName=$(sysctl -n machdep.cpu.brand_string)
procesorCores=$(sysctl -n machdep.cpu.core_count)
memorySize=$(sysctl -n hw.memsize)
memoryType=$(system_profiler SPMemoryDataType | grep -e "Type" | uniq | awk '{print $2}')
memorySpeed=$(system_profiler SPMemoryDataType | grep -e "Speed" | uniq | awk '{print $2" "$3}')
warnTemperature=60
criticalTemperature=80
clear="\e[0m"
smcJson="$(iSMC temp -o json 2>/dev/null)"

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
                }
            }
        }
        END {
            if (best > -1e8) {
                printf "%s\t%s\t%.6f\n", bestName, bestKey, bestQty
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
    IFS=$'\t' read -r name key qty <<<"$row"
    echo "$(format_celsius "$qty") (${name}, ${key})"
}

temp_color() {
    local value="$1"
    if ! is_number "$value"; then
        echo "\e[90m"
    elif awk -v a="$value" -v b="$criticalTemperature" 'BEGIN { exit !(a > b) }'; then
        echo "\e[31m"
    elif awk -v a="$value" -v b="$warnTemperature" 'BEGIN { exit !(a > b) }'; then
        echo "\e[33m"
    else
        echo "\e[32m"
    fi
}

smcRows="$(rows_from_json "$smcJson")"

cpuPrimary="$(pick_max "$smcRows" 'cpu diode filtered|cpu diode virtual|max peci reported|peci sa|cpu performance core|cpu efficiency core' '^(tc0f|tc0e|tcmx|tcsa|tp[0-9a-z]+|te[0-9a-z]+|tf[0-9a-z]+)$')"
if [ -z "$cpuPrimary" ]; then
    cpuPrimary="$(pick_max "$smcRows" 'cpu core' '^tc[0-9a-z]+c$')"
fi
if [ -z "$cpuPrimary" ]; then
    cpuPrimary="$(pick_max "$smcRows" 'cpu' '^tc[0-9a-z]+$')"
fi
cpuSecondary="$(pick_max "$smcRows" 'cpu core' '^tc[0-9a-z]+c$' "$(row_key "$cpuPrimary")")"

gpuPrimary="$(pick_max "$smcRows" 'gpu amd radeon|gpu intel graphics|^gpu [0-9]+' '^(tgdd|tcgc|tg[0-9a-z]+|tf1[0-9a-z]+)$')"
if [ -z "$gpuPrimary" ]; then
    gpuPrimary="$(pick_max "$smcRows" 'gpu' '^tg[0-9a-z]+$')"
fi
gpuSecondary="$(pick_max "$smcRows" 'gpu proximity|gpu diode|gpu heatsink' '^tg[0-9a-z]*p$' "$(row_key "$gpuPrimary")")"

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

cpuText="$(sensor_text "$cpuPrimary")"
if [ -n "$cpuSecondary" ]; then
    cpuText="${cpuText} | $(sensor_text "$cpuSecondary")"
fi
gpuText="$(sensor_text "$gpuPrimary")"
if [ -n "$gpuSecondary" ]; then
    gpuText="${gpuText} | $(sensor_text "$gpuSecondary")"
fi
memText="$(sensor_text "$memPrimary")"
if [ -n "$memSecondary" ]; then
    memText="${memText} | $(sensor_text "$memSecondary")"
fi

cpuColor="$(temp_color "$(row_value "$cpuPrimary")")"
gpuColor="$(temp_color "$(row_value "$gpuPrimary")")"
memColor="$(temp_color "$(row_value "$memPrimary")")"

# Print system info
echo -e "\e[1mSystem Information ${modelIdentifier}\e[0m
\tOS Version: ${osName} ${osVersion} ${osbuildVersion} ${kernelVersion}
\tProcessor.: ${procesorName} ${procesorCores} Cores
\tMemory....: $((${memorySize} / (1024**3))) GB ${memorySpeed} ${memoryType}
\tCPU Temp..: ${cpuColor}${cpuText}${clear}
\tGPU Temp..: ${gpuColor}${gpuText}${clear}
\tMem Temp..: ${memColor}${memText}${clear}
"
