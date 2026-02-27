#!/bin/zsh

# Define variables
warnDiskTemperature=50
criticalDiskTemperature=61
warnCpuTemperature=60
criticalCpuTemperature=80
diskDevice="${MOTD_DISK_DEVICE:-/dev/disk1s1}"
diskTemperature=$(smartctl -a "${diskDevice}" 2>/dev/null | awk '/Temperature/ {print $2; exit}')
cpuTemperature=$(osx-cpu-temp -C -c)
cpuTemperatureInt=$(echo ${cpuTemperature} | awk '{print int($1)}')
gpuTemperature=$(osx-cpu-temp -C -g)
gpuTemperatureInt=$(echo ${gpuTemperature} | awk '{print int($1)}')
fontColor="\e[97m"
clear="\e[0m"
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
  Disk Temp.: ${fontColor}${diskColor} ${diskTemperature} ${clear}
  CPU Temp..: ${fontColor}${cpuColor} ${cpuTemperature} ${clear}
  GPU Temp..: ${fontColor}${gpuColor} ${gpuTemperature} ${clear}
"
