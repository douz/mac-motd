#!/bin/zsh

# Export variables
export baseDir=$(cd `dirname $0` && pwd)
export modulesDir="${baseDir}/modules"
export fontsDir="${baseDir}/fonts"

# Set modules to load
modulesArray=(banner system_info hdd_usage battery calendar_events)

# Load modules
for module in $modulesArray; do
    if [ -f ${modulesDir}/$module.sh ]; then
        ${modulesDir}/$module.sh
    else
        echo "Error: module ${module} not found"
    fi
done