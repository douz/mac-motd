#!/bin/zsh

# Define variables
maxNumAttendees=10
includeEventProps="title,attendees,datetime"

# Print calendar events
echo -e "\e[1mUpcoming Events:\e[0m"

if [ $(icalBuddy -n eventsToday+1 |wc -l) -gt 0 ]; then
    icalBuddy -f -n -na ${maxNumAttendees} -iep ${includeEventProps}  eventsToday+1
else
    echo -e "There are no upcoming events for today or tomorrow in your calendar"
fi
echo ""