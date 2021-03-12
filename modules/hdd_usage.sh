#!/bin/zsh

# Define variables
barWidth=50
warnDiscUsage=90
barClear="\e[0m"
barContent=""
diskSize=$(diskutil info /dev/disk1s1 | grep Total | awk '{ print int($4) }')
diskFree=$(diskutil info /dev/disk1s1 | grep Free | awk '{ print int($4) }')
diskUsage=$((${diskSize} - ${diskFree}))
diskUsagePercent=$(bc -l <<< "scale=2; (${diskUsage} / ${diskSize}) * 100" | awk '{ print int($1) }')
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
echo -e "\e[1mHDD Usage:\e[0m ${diskUsage} GB out of ${diskSize} G"
echo -e ${barContent}
echo ""