#!/usr/bin/env bash
# ~/.macos-defaults.sh
# cspell:disable
#
# macOS configuration using 'defaults' command

### Helper methods #############################################################

# Get bundle id from App Name
function bundle_id() {
	bundle_id=$(osascript -e "id of app \"$1\"" 2> /dev/null)
	function_return_status=$?
	echo "$bundle_id"
	return $function_return_status
}

# Close Application by name
function close_application() {
	osascript -e "tell application \"$1\" to quit"
	return $?
}

# To-Do:
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
bundle_id=$(bundle_id "$application_name")

# Desktop
defaults write "$bundle_id" "ShowExternalHardDrivesOnDesktop" -bool true
defaults write "$bundle_id" "ShowHardDrivesOnDesktop" -bool true
defaults write "$bundle_id" "ShowMountedServersOnDesktop" -bool true
defaults write "$bundle_id" "ShowRemovableMediaOnDesktop" -bool true

# Window Presentation
defaults write "$bundle_id" "FXDefaultSearchScope" -string "SCcf"
defaults write "$bundle_id" "_FXSortFoldersFirst" -bool true
defaults write "$bundle_id" "ShowStatusBar" -bool true

# Not Working 😔
# defaults write "$bundle_id" ShowPathbar -bool true
# defaults write "$bundle_id" QLEnableTextSelection -bool true

killall $application_name 2> /dev/null

### Dock #######################################################################
application_name="Dock"
bundle_id=$(bundle_id "$application_name")

# Position on screen
defaults write "$bundle_id" "orientation" -string "bottom"

# Icon size
defaults write "$bundle_id" "tilesize" -int 48

# Auto-hiding the dock
defaults write "$bundle_id" "autohide" -bool true
defaults write "$bundle_id" "autohide-delay" -float 0.0001
defaults write "$bundle_id" "autohide-time-modifier" -float 0.5

# Minimize windows into application icon
defaults write "$bundle_id" "minimize-to-application" -bool true
defaults write "$bundle_id" "mineffect" -string "genie"

# Do not show recent applications in Dock
defaults write "$bundle_id" "show-recents" -bool false

# Bounce animation on app launch
defaults write "$bundle_id" "enable-spring-load-actions-on-all-items" -bool true

# Mission Control; Exposé, group apps instances
defaults write "$bundle_id" "expose-group-apps" -bool true

# Disable automatic Spaces rearrange based on recent use
defaults write "$bundle_id" "mru-spaces" -bool false

# Hot corners: top-left; top-right; bottom-left; bottom-right
defaults write "$bundle_id" "wvous-tl-corner" -int 0  # Disabled
defaults write "$bundle_id" "wvous-tr-corner" -int 13 # Lock Screen
defaults write "$bundle_id" "wvous-bl-corner" -int 4  # Desktop
defaults write "$bundle_id" "wvous-br-corner" -int 5  # Start Screen Saver

# Wipe all apps from Dock
#defaults write "$bundle_id" "persistent-apps" -array
#defaults write "$bundle_id" "persistent-others" -array

killall $application_name 2> /dev/null

### Safari #####################################################################
application_name="Safari"
bundle_id=$(bundle_id "$application_name")

defaults write "$bundle_id" UniversalSearchEnabled -bool false
defaults write "$bundle_id" SuppressSearchSuggestions -bool true
defaults write "$bundle_id" SendDoNotTrackHTTPHeader -bool true
defaults write "$bundle_id" NewWindowBehavior -int 0
defaults write "$bundle_id" NewTabBehavior -int 1
defaults write "$bundle_id" ShowFavoritesBar-v2 -bool true
defaults write "$bundle_id" OpenNewTabsInFront -bool false
defaults write "$bundle_id" IncludeDevelopMenu -bool true

defaults write "$bundle_id" ShowAllItemsInReadingList -bool true
defaults write "$bundle_id" ShowIconsInTabs -bool true
defaults write "$bundle_id" ShowSidebarInNewWindows -bool false
defaults write "$bundle_id" ShowSidebarInTopSites -bool false
defaults write "$bundle_id" HistoryAgeInDaysLimit -int 365

# Enable Debug menu
defaults write "$bundle_id" "IncludeInternalDebugMenu" -bool true

# Disable safe file automatically open
defaults write "$bundle_id" "AutoOpenSafeDownloads" -bool false

# Show full URL in address bar
defaults write "$bundle_id" "ShowFullURLInSmartSearchField" -bool true

killall $application_name 2> /dev/null

### Developer ##################################################################

application_name="Simulator"
bundle_id=$(bundle_id "$application_name")

defaults write "$bundle_id" AllowFullscreenMode -bool true

killall $application_name 2> /dev/null

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

### Other ######################################################################

# Don't create '.DS_Store' files on network and USB volumes
defaults write com.apple.desktopservices "DSDontWriteNetworkStores" -bool true
defaults write com.apple.desktopservices "DSDontWriteUSBStores" -bool true

# CoreFoundation Preferences Deamon (cfprefsd -- defaults server)
# Preferences values are cached, need to restart the server to apply changes
killall cfprefsd
