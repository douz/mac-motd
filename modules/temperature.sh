#!/bin/zsh

# Define variables
warnDiskTemperature=50
criticalDiskTemperature=61
warnCpuTemperature=60
criticalCpuTemperature=80
diskTemperature=$(smartctl -a /dev/disk1s1 | grep Temperature | awk '{print $2}')
cpuTemperature=$(osx-cpu-temp -C -c)
cpuTemperatureInt=$(echo ${cpuTemperature} | awk '{print int($1)}')
gpuTemperature=$(osx-cpu-temp -C -g)
gpuTemperatureInt=$(echo ${gpuTemperature} | awk '{print int($1)}')
fontColor="\e[97m"
clear="\e[0m"
# Set Disk Temperature color
if [ "${diskTemperature}" -gt "${criticalDiskTemperature}" ]; then
    diskColor="\e[1;41m"
elif [ "${diskTemperature}" -le "${criticalDiskTemperature}" ] && [ "${diskTemperature}" -gt "${warnDiskTemperature}" ] ; then
    diskColor="\e[1;43m"
else
    diskColor="\e[1;42m"
fi
# Set CPU Temperature color
if [ "${cpuTemperatureInt}" -gt "${criticalCpuTemperature}" ]; then
    cpuColor="\e[1;41m"
elif [ "${cpuTemperatureInt}" -le "${criticalCpuTemperature}" ] && [ "${cpuTemperatureInt}" -gt "${warnCpuTemperature}" ] ; then
    cpuColor="\e[1;43m"
else
    cpuColor="\e[1;42m"
fi
# Set GPU Temperature color
if [ "${gpuTemperatureInt}" -gt "${criticalCpuTemperature}" ]; then
    gpuColor="\e[1;41m"
elif [ "${gpuTemperatureInt}" -le "${criticalCpuTemperature}" ] && [ "${gpuTemperatureInt}" -gt "${warnCpuTemperature}" ] ; then
    gpuColor="\e[1;43m"
else
    gpuColor="\e[1;42m"
fi

# Print devices temperature
echo -e "\e[1mSystem Temperature${clear}
  Disk Temp.: ${fontColor}${diskColor} ${diskTemperature}.0°C ${clear}
  CPU Temp..: ${fontColor}${cpuColor} ${cpuTemperature} ${clear}
  GPU Temp..: ${fontColor}${gpuColor} ${gpuTemperature} ${clear}
"