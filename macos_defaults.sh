#!/usr/bin/env bash
# macOS configuration



### Helper methods #############################################################

# Get bundle id from App Name
function bundle_id() {
	bundle_id=`osascript -e "id of app \"$1\"" 2>/dev/null`
	return_status=$?
	echo $bundle_id
	return $return_status
}

# Close Application by name
function close_application() {
	osascript -e "tell application \"$1\" to quit"
	return $?
}

# ToDo:
# Should take application_name and config, finds the bundle_id and apply config
# How to deal with config and global domain?
# function write_config() {
	# if [[ $bundle_id ]]; then
	# 	echo "found::"$bundle_id
	# else
	# 	echo "BundleId for Application '$application_name' not found, skipping"
	# fi
# }



### Configuration ##############################################################

# Close System Preferences App before starting
close_application "System Preferences"


### Finder #####################################################################
application_name="Finder"
bundle_id=`bundle_id "$application_name"`


# Desktop
defaults write $bundle_id ShowExternalHardDrivesOnDesktop -bool true
defaults write $bundle_id ShowHardDrivesOnDesktop -bool true
defaults write $bundle_id ShowMountedServersOnDesktop -bool true
defaults write $bundle_id ShowRemovableMediaOnDesktop -bool true

# Window Presentation
defaults write $bundle_id FXDefaultSearchScope -string "SCcf"
defaults write $bundle_id _FXSortFoldersFirst -bool true
defaults write $bundle_id ShowStatusBar -bool true

# Not Working 😔
# defaults write $bundle_id ShowPathbar -bool true
# defaults write $bundle_id QLEnableTextSelection -bool true

killall $application_name


### Dock #######################################################################
application_name="Dock"
bundle_id=`bundle_id "$application_name"`

# Auto-hiding the dock
defaults write $bundle_id autohide -bool true
defaults write $bundle_id autohide-delay -float 0

# Minimiza windows into applicatin icon
defaults write $bundle_id minimize-to-application -bool true

# Remove Show recent applications in Dock
defaults write $bundle_id show-recents -bool false

# Mission Control
defaults write $bundle_id expose-group-apps -bool true

# Disable automatic Spaces rearrange based on recent use
defaults write $bundle_id mru-spaces -bool false

killall $application_name


### Safari #####################################################################
application_name="Safari"
bundle_id=`bundle_id "$application_name"`

defaults write $bundle_id UniversalSearchEnabled -bool false
defaults write $bundle_id SuppressSearchSuggestions -bool true
defaults write $bundle_id SendDoNotTrackHTTPHeader -bool true
defaults write $bundle_id NewWindowBehavior -int 0
defaults write $bundle_id NewTabBehavior -int 1
defaults write $bundle_id ShowFavoritesBar-v2 -bool true
defaults write $bundle_id OpenNewTabsInFront -bool false
defaults write $bundle_id IncludeDevelopMenu -bool true
defaults write $bundle_id IncludeInternalDebugMenu -bool true
defaults write $bundle_id ShowIconsInTabs -bool true
defaults write $bundle_id ShowAllItemsInReadingList -bool true
defaults write $bundle_id ShowFullURLInSmartSearchField -bool true
defaults write $bundle_id ShowIconsInTabs -bool true
defaults write $bundle_id ShowSidebarInNewWindows -bool false
defaults write $bundle_id ShowSidebarInTopSites -bool false
defaults write $bundle_id AutoOpenSafeDownloads -bool false
defaults write $bundle_id HistoryAgeInDaysLimit -int 365

killall $application_name


### Developer ##################################################################

application_name="Simulator"
bundle_id=`bundle_id "$application_name"`

defaults write $bundle_id AllowFullscreenMode -bool true

killall $application_name



### General UI/UX ##############################################################

# Show battery percentage
defaults write com.apple.menuextra.battery ShowPercent -bool true
killall SystemUIServer

# Show scroll bars: Values: Automatic, WhenScrolling, Always
defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"

# Show all files extension
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true


### Security ###################################################################

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0


################################################################################

# Prevent ImageCapture from opening automatically when devices are plugged in
defaults write com.apple.ImageCapture disableHotPlug -bool true

defaults write com.apple.TextEdit RichText -int 0
defaults write com.apple.reminders RemindersDebugMenu -boolean true
