#!/bin/zsh

# Define variables
bannerText="${bannerText:-Douz}"
randomColorCode=$(jot -n -r 1 30 37)
bannerColor="\e[${randomColorCode}m"
clear="\e[0m"
# Set fonts array
fontsArray=()
fontsArrayCount=0
for font in "${fontsDir}"/*.flf; do
    [ -f "${font}" ] || continue
    fontsArray+=("$(basename "$font")")
    ((fontsArrayCount++))
done
if [ "${fontsArrayCount}" -eq 0 ]; then
    echo "Warning: no figlet fonts found in ${fontsDir}"
    exit 0
fi
randomFontNumber=$(jot -n -r 1 1 ${fontsArrayCount})

# Print banner
echo -e "${bannerColor}"
figlet -w 150 -d "${fontsDir}" -f "${fontsArray[${randomFontNumber}]}" " ${bannerText}"
echo -e "${clear}"
