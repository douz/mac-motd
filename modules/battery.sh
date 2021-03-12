#!/bin/zsh

# Define variables
barWidth=50
warnBatteryLevel=50
criticalBatteryLevel=20
barClear="\e[0m"
barContent=""
batteryCharge=$(pmset -g batt | grep -e "InternalBattery" | awk '{print $3}' | awk -F '%' '{print $1}')
barUsageWidth=$(((${batteryCharge} * ${barWidth}) / 100))
# Set bar color depending on charge level
if [ "${batteryCharge}" -gt "${warnBatteryLevel}" ]; then
    barColor="\e[32m"
elif [ "${batteryCharge}" -le "${warnBatteryLevel}" ] && [ "${batteryCharge}" -gt "${criticalBatteryLevel}" ] ; then
    barColor="\e[33m"
else
    barColor="\e[31m"
fi

# Set battery charge bar
barContent="[${barColor}"
for sec in {1..${barUsageWidth}}; do
    barContent="${barContent}|"
done
barContent="${barContent}${barClear}"

# Set battery uncharged bar
barUsageLeft=$((${barWidth} - ${barUsageWidth}))
if [ "${barUsageLeft}" -gt 0 ]; then 
    for sec in {1..${barUsageLeft}}; do
        barContent="${barContent}-"
    done
fi
barContent="${barContent}]"

# Print the result
echo -e "\e[1mBattery Charge:\e[0m ${batteryCharge}%"
echo -e ${barContent}
echo ""