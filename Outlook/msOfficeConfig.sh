#!/bin/bash

################################################################################
#
#   Name:           Microsoft Office Configuration Script
#
#   Created by:     Kieran Koehnlein
#   Last Updated:   3/21/2017
#
#   Description:    Sets office configuration options to be used in conjunction
#                   with the MAUCacheServer Configuration Profile
#
################################################################################

# Trust Micsoroft Auto Update app
if [ -e "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app" ]
    then
        /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -R -f -trusted "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app"
fi

if [ -e "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/Microsoft AU Daemon.app" ]
    then
        /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -R -f -trusted "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/Microsoft AU Daemon.app"
fi

# Delete user level preferences for all existing users.
localUsers=$( dscl . list /Users UniqueID | awk '$2 >= 501 {print $1}' )
echo "$localUsers" | while read userName; do
    defaults delete /Users/$userName/Library/Preferences/com.microsoft.autoupdate2.plist HowToCheck
done

# Delete system level preferences
defaults delete /Library/Preferences/com.microsoft.autoupdate2

# Set system level preferences, disabling First Run dialog for all applications.
/usr/bin/defaults write /Library/Preferences/com.microsoft.Word kSubUIAppCompletedFirstRunSetup1507 -bool true
/usr/bin/defaults write /Library/Preferences/com.microsoft.Excel kSubUIAppCompletedFirstRunSetup1507 -bool true
/usr/bin/defaults write /Library/Preferences/com.microsoft.Powerpoint kSubUIAppCompletedFirstRunSetup1507 -bool true
/usr/bin/defaults write /Library/Preferences/com.microsoft.Outlook kSubUIAppCompletedFirstRunSetup1507 -bool true
/usr/bin/defaults write /Library/Preferences/com.microsoft.onenote.mac kSubUIAppCompletedFirstRunSetup1507 -bool true
