#!/bin/bash

################################################################################
#
#   Name:           makeOutlookDefault
#
#   Created by:     Kieran Koehnlein
#   Last Updated:   3/21/2017
#
#   Description:    Makes Outlook the default handler for various email-related 
#                   files and protocols
#
################################################################################

DEBUG=true
DEBUG_PATH=~/Desktop/debug.csv
DEBUG_DRYRUN=true

i=0;
dnecount=0;
services=(mailto com.apple.mail.email public.vcard com.apple.ical.ics com.microsoft.outlook16.icalendar)
plistPath="/Users/$3/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist"


if $DEBUG; then
    echo "!!!!!!!!!! LIST BEFORE !!!!!!!!!!"
    /usr/libexec/plistbuddy -c "print:LSHandlers" "$plistPath"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi

#
# Deletes LaunchServices Entries if they are in array "services"
#
if $DEBUG; then echo "Index,Scheme/ContentType,Role" > $DEBUG_PATH; fi #DEBUG
while true; do

    result=$(/usr/libexec/plistbuddy -c "print:LSHandlers:$i" "$plistPath">/dev/null 2>&1)
    commandResult=$?
    
    if [ $commandResult -ne 0 ]; then # Check if result command had an error -- this is when we want to stop
        if $DEBUG; then echo "Command Error Number $dnecount"; fi #DEBUG
        ((dnecount++))
        if [ $dnecount -gt 9 ]; then
            if $DEBUG; then echo "Breaking..."; fi #DEBUG
            break
        fi
    else
    
        dnecount=0;
        scheme=$(/usr/libexec/plistbuddy -c "print:LSHandlers:$i" "/Users/kieran.koehnlein/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist" | grep -m1 "LSHandlerURLScheme" | cut -d"=" -f 2 | sed 's/ //g')
        contentType=$(/usr/libexec/plistbuddy -c "print:LSHandlers:$i" "/Users/kieran.koehnlein/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist" | grep -m1 "LSHandlerContentType" | cut -d"=" -f 2 | sed 's/ //g')
        role=$(/usr/libexec/plistbuddy -c "print:LSHandlers:$i" "/Users/kieran.koehnlein/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist" | grep -m1 "LSHandlerRoleAll" | cut -d"=" -f 2 | sed 's/ //g')

        if [[ " ${services[@]} " =~ " ${scheme} " ]] || [[ " ${services[@]} " =~ " ${contentType} " ]]; then # Check if scheme is in our scheme array 
            if $DEBUG; then echo "Scheme Found: $scheme. Deleting..."; fi #DEBUG
            if $DEBUG_DRYRUN; then
                echo "Dry run, not deleting entries..." # donothing
            else
                /usr/libexec/plistbuddy -c "delete:LSHandlers:${i}:LSHandlerURLScheme" "$plistPath" >/dev/null 2>&1
                /usr/libexec/plistbuddy -c "delete:LSHandlers:${i}:LSHandlerContentType" "$plistPath" >/dev/null 2>&1
                /usr/libexec/plistbuddy -c "delete:LSHandlers:${i}:LSHandlerRoleAll" "$plistPath" >/dev/null 2>&1
            fi
        fi

        if $DEBUG; then echo "$i,$scheme$contentType,$role" >> $DEBUG_PATH; fi #DEBUG
    fi
    ((i++))
done

if $DEBUG_DRYRUN; then
    echo "Dry run, not modifying plist..." #donothing
else
    ((i-=9)) # Return index back to where values cease
    # Create the entries

    # Create the LSHandlers array (suppress errors if exists)
    /usr/libexec/plistbuddy -c "add:LSHandlers array" "$plistPath" >/dev/null 2>&1

    # Set default for mailto links
    /usr/libexec/plistbuddy -c "add:LSHandlers:${i}:LSHandlerURLScheme string mailto" "$plistPath"
    /usr/libexec/plistbuddy -c "add:LSHandlers:${i}:LSHandlerRoleAll string com.microsoft.outlook" "$plistPath"
    #/usr/libexec/plistbuddy -c "add:LSHandlers:${i}:LSHandlerPreferredVersions:LSHandlerRoleAll string -" "$plistPath"

    # Set Outlook as default for email
    ((i++)) # increment index
    /usr/libexec/plistbuddy -c "add:LSHandlers:${i}:LSHandlerContentType string com.apple.mail.email" "$plistPath"
    /usr/libexec/plistbuddy -c "add:LSHandlers:${i}:LSHandlerRoleAll string com.microsoft.outlook" "$plistPath"
    #/usr/libexec/plistbuddy -c "add:LSHandlers:${i}:LSHandlerPreferredVersions:LSHandlerRoleAll string -" "$plistPath"
    ((i++)) # increment index
    /usr/libexec/plistbuddy -c "add:LSHandlers:${i}:LSHandlerContentType string com.microsoft.outlook16.email-message" "$plistPath"
    /usr/libexec/plistbuddy -c "add:LSHandlers:${i}:LSHandlerRoleAll string com.microsoft.outlook" "$plistPath"
    #/usr/libexec/plistbuddy -c "add:LSHandlers:${i}:LSHandlerPreferredVersions:LSHandlerRoleAll string -" "$plistPath"

    # Set Outlook as default for .vcard
    ((i++)) # increment index
    /usr/libexec/plistbuddy -c "add:LSHandlers:${i}:LSHandlerContentType string public.vcard" "$plistPath"
    /usr/libexec/plistbuddy -c "add:LSHandlers:${i}:LSHandlerRoleAll string com.microsoft.outlook" "$plistPath"
    #/usr/libexec/plistbuddy -c "add:LSHandlers:${i}:LSHandlerPreferredVersions:LSHandlerRoleAll string -" "$plistPath"

    # Set Outlook as default for .ics files
    ((i++)) # increment index
    /usr/libexec/plistbuddy -c "add:LSHandlers:${i}:LSHandlerContentType string com.apple.ical.ics" "$plistPath"
    /usr/libexec/plistbuddy -c "add:LSHandlers:${i}:LSHandlerRoleAll string com.microsoft.outlook" "$plistPath"
    #/usr/libexec/plistbuddy -c "add:LSHandlers:${i}:LSHandlerPreferredVersions:LSHandlerRoleAll string -" "$plistPath"

    # Set Outlook as default calendar app
    ((i++)) # increment index
    /usr/libexec/plistbuddy -c "add:LSHandlers:${i}:LSHandlerContentType string com.microsoft.outlook16.icalendar" "$plistPath"
    /usr/libexec/plistbuddy -c "add:LSHandlers:${i}:LSHandlerRoleAll string com.microsoft.outlook" "$plistPath"
    #/usr/libexec/plistbuddy -c "add:LSHandlers:${i}:LSHandlerPreferredVersions:LSHandlerRoleAll string -" "$plistPath"
    
    if $DEBUG; then
        echo "!!!!!!!!!!  LIST AFTER !!!!!!!!!!"
        /usr/libexec/plistbuddy -c "print:LSHandlers" "$plistPath"
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    fi
fi
