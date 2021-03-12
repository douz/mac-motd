#!/bin/zsh

# Define variables
bannerText="Douz"
randomColorCode=$(jot -n -r 1 30 37)
bannerColor="\e[${randomColorCode}m"
clear="\e[0m"
# Set fonts array
fontsArray=()
fontsArrayCount=0
for font in $(ls ${fontsDir}); do
    fontsArray+=($font)
    ((fontsArrayCount++))
done
radomFontNumber=$(jot -n -r 1 1 ${fontsArrayCount})

# Print banner
echo -e ${bannerColor}
figlet -w 150 -d ${fontsDir} -f ${fontsArray[${radomFontNumber}]} " ${bannerText}"
echo -e ${clear}