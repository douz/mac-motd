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
smcOutput="$(smctemp 2>/dev/null)"

extract_temp() {
    local pattern="$1"
    echo "$smcOutput" | awk -v pattern="$pattern" 'BEGIN { IGNORECASE=1 } $0 ~ pattern { if (match($0, /[0-9]+(\.[0-9]+)?/)) { print substr($0, RSTART, RLENGTH); exit } }'
}

format_temp() {
    local value="$1"
    if [[ "$value" =~ '^[0-9]+(\.[0-9]+)?$' ]]; then
        awk -v v="$value" 'BEGIN { printf "%.1f°C", v }'
    else
        echo "N/A"
    fi
}

temp_to_int() {
    local value="$1"
    if [[ "$value" =~ '^[0-9]+(\.[0-9]+)?$' ]]; then
        awk -v v="$value" 'BEGIN { print int(v) }'
    else
        echo ""
    fi
}

cpuTemperatureRaw="$(extract_temp "(cpu|tc[[:alnum:]]+)")"
if [ -z "${cpuTemperatureRaw}" ]; then
    cpuTemperatureRaw="$(echo "$smcOutput" | awk 'match($0, /[0-9]+(\.[0-9]+)?/) { print substr($0, RSTART, RLENGTH); exit }')"
fi
gpuTemperatureRaw="$(extract_temp "(gpu|tg[[:alnum:]]+)")"
cpuTemperature="$(format_temp "${cpuTemperatureRaw}")"
gpuTemperature="$(format_temp "${gpuTemperatureRaw}")"
cpuTemperatureInt="$(temp_to_int "${cpuTemperatureRaw}")"
gpuTemperatureInt="$(temp_to_int "${gpuTemperatureRaw}")"
# Set CPU Temperature color
if [ -z "${cpuTemperatureInt}" ]; then
    cpuColor="\e[90m"
elif [ "${cpuTemperatureInt}" -gt "${criticalTemperature}" ]; then
    cpuColor="\e[31m"
elif [ "${cpuTemperatureInt}" -le "${criticalTemperature}" ] && [ "${cpuTemperatureInt}" -gt "${warnTemperature}" ] ; then
    cpuColor="\e[33m"
else
    cpuColor="\e[32m"
fi
# Set GPU Temperature color
if [ -z "${gpuTemperatureInt}" ]; then
    gpuColor="\e[90m"
elif [ "${gpuTemperatureInt}" -gt "${criticalTemperature}" ]; then
    gpuColor="\e[31m"
elif [ "${gpuTemperatureInt}" -le "${criticalTemperature}" ] && [ "${gpuTemperatureInt}" -gt "${warnTemperature}" ] ; then
    gpuColor="\e[33m"
else
    gpuColor="\e[32m"
fi

# Print system info
echo -e "\e[1mSystem Information ${modelIdentifier}\e[0m
\tOS Version: ${osName} ${osVersion} ${osbuildVersion} ${kernelVersion}
\tProcessor.: ${procesorName} ${procesorCores} Cores
\tMemory....: $((${memorySize} / (1024**3))) GB ${memorySpeed} ${memoryType}
\tCPU Temp..: ${cpuColor}${cpuTemperature}${clear}
\tGPU Temp..: ${gpuColor}${gpuTemperature}${clear}
"
