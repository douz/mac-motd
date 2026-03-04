#!/bin/zsh

# Define variables
warnDiskTemperature=50
criticalDiskTemperature=61
warnCpuTemperature=60
criticalCpuTemperature=80
diskDevice="${MOTD_DISK_DEVICE:-/dev/disk1s1}"
diskTemperature=$(smartctl -a "${diskDevice}" 2>/dev/null | awk '/Temperature/ {print $2; exit}')
smcOutput="$(iSMC temp -o table 2>/dev/null)"
fontColor="\e[97m"
clear="\e[0m"

extract_temp() {
    local pattern="$1"
    echo "$smcOutput" | awk -v pattern="$pattern" '
        tolower($0) ~ tolower(pattern) {
            if (match($0, /[0-9]+(\.[0-9]+)?[[:space:]]*(°C|°F|C|F)/)) {
                value = substr($0, RSTART, RLENGTH)
                gsub(/[[:space:]]*(°C|°F|C|F)/, "", value)
                print value
                exit
            } else if (match($0, /[0-9]+(\.[0-9]+)?/)) {
                print substr($0, RSTART, RLENGTH)
                exit
            }
        }'
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

cpuTemperatureRaw="$(extract_temp "(cpu|performance core|efficiency core|tc[[:alnum:]]+|tp[[:alnum:]]+|te[[:alnum:]]+|tf[[:alnum:]]+)")"
if [ -z "${cpuTemperatureRaw}" ]; then
    cpuTemperatureRaw="$(echo "$smcOutput" | awk 'match($0, /[0-9]+(\.[0-9]+)?/) { print substr($0, RSTART, RLENGTH); exit }')"
fi
gpuTemperatureRaw="$(extract_temp "(gpu|tg[[:alnum:]]+)")"
cpuTemperature="$(format_temp "${cpuTemperatureRaw}")"
gpuTemperature="$(format_temp "${gpuTemperatureRaw}")"
cpuTemperatureInt="$(temp_to_int "${cpuTemperatureRaw}")"
gpuTemperatureInt="$(temp_to_int "${gpuTemperatureRaw}")"
# Set Disk Temperature color
if [[ "${diskTemperature}" =~ '^[0-9]+$' ]] && [ "${diskTemperature}" -gt "${criticalDiskTemperature}" ]; then
    diskColor="\e[1;41m"
elif [[ "${diskTemperature}" =~ '^[0-9]+$' ]] && [ "${diskTemperature}" -le "${criticalDiskTemperature}" ] && [ "${diskTemperature}" -gt "${warnDiskTemperature}" ] ; then
    diskColor="\e[1;43m"
elif [[ "${diskTemperature}" =~ '^[0-9]+$' ]]; then
    diskColor="\e[1;42m"
else
    diskColor="\e[1;40m"
    diskTemperature="N/A"
fi
# Set CPU Temperature color
if [ -z "${cpuTemperatureInt}" ]; then
    cpuColor="\e[1;40m"
elif [ "${cpuTemperatureInt}" -gt "${criticalCpuTemperature}" ]; then
    cpuColor="\e[1;41m"
elif [ "${cpuTemperatureInt}" -le "${criticalCpuTemperature}" ] && [ "${cpuTemperatureInt}" -gt "${warnCpuTemperature}" ] ; then
    cpuColor="\e[1;43m"
else
    cpuColor="\e[1;42m"
fi
# Set GPU Temperature color
if [ -z "${gpuTemperatureInt}" ]; then
    gpuColor="\e[1;40m"
elif [ "${gpuTemperatureInt}" -gt "${criticalCpuTemperature}" ]; then
    gpuColor="\e[1;41m"
elif [ "${gpuTemperatureInt}" -le "${criticalCpuTemperature}" ] && [ "${gpuTemperatureInt}" -gt "${warnCpuTemperature}" ] ; then
    gpuColor="\e[1;43m"
else
    gpuColor="\e[1;42m"
fi

# Print devices temperature
echo -e "\e[1mSystem Temperature${clear}
  Disk Temp.: ${fontColor}${diskColor} ${diskTemperature} ${clear}
  CPU Temp..: ${fontColor}${cpuColor} ${cpuTemperature} ${clear}
  GPU Temp..: ${fontColor}${gpuColor} ${gpuTemperature} ${clear}
"
