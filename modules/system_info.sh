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
cpuTemperature=$(osx-cpu-temp -C -c)
cpuTemperatureInt=$(echo ${cpuTemperature} | awk '{print int($1)}')
gpuTemperature=$(osx-cpu-temp -C -g)
gpuTemperatureInt=$(echo ${gpuTemperature} | awk '{print int($1)}')
# Set CPU Temperature color
if [ "${cpuTemperatureInt}" -gt "${criticalTemperature}" ]; then
    cpuColor="\e[31m"
elif [ "${cpuTemperatureInt}" -le "${criticalTemperature}" ] && [ "${cpuTemperatureInt}" -gt "${warnTemperature}" ] ; then
    cpuColor="\e[33m"
else
    cpuColor="\e[32m"
fi
# Set GPU Temperature color
if [ "${gpuTemperatureInt}" -gt "${criticalTemperature}" ]; then
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