#!/bin/zsh

# Define variables
barWidth=50
warnDiscUsage=90
barClear="\e[0m"
barContent=""
diskMount="${DOUZ_HDD_MOUNT_POINT:-}"

if [ -z "${diskMount}" ]; then
    if df -g /System/Volumes/Data >/dev/null 2>&1; then
        diskMount="/System/Volumes/Data"
    else
        diskMount="/"
    fi
fi

diskStats="$(df -g "${diskMount}" | awk 'NR==2 { print $2" "$3" "$5 }')"
diskSize="$(echo "$diskStats" | awk '{ print $1 }')"
diskUsage="$(echo "$diskStats" | awk '{ print $2 }')"
diskUsagePercent="$(echo "$diskStats" | awk '{ gsub("%", "", $3); print $3 }')"
if [ -z "${diskUsagePercent}" ] || [ -z "${diskSize}" ] || [ -z "${diskUsage}" ]; then
    echo -e "\e[1mHDD Usage:\e[0m unavailable"
    echo ""
    exit 0
fi
barUsageWidth=$(((${diskUsagePercent} * ${barWidth}) / 100))
barColor="\e[33m"
# Set bar color to red if warning value is reached
if [ "${diskUsagePercent}" -ge "${warnDiscUsage}" ]; then
    barColor="\e[31m"
fi

# Set disk usage bar
barContent="[${barColor}"
for sec in {1..${barUsageWidth}}; do
    barContent="${barContent}|"
done
barContent="${barContent}${barClear}"

# Set free disk space bar
barUsageLeft=$((${barWidth} - ${barUsageWidth}))
if [ "${barUsageLeft}" -gt 0 ]; then 
    for sec in {1..${barUsageLeft}}; do
        barContent="${barContent}-"
    done
fi
barContent="${barContent}]"

# Print the result
echo -e "\e[1mHDD Usage:\e[0m ${diskUsage}GB out of ${diskSize}GB"
echo -e ${barContent}
echo ""
