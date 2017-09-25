#!/usr/bin/env bash



# Close System Preferences App before starting
osascript -e 'tell application "System Preferences" to quit'

### General UI/UX ##############################################################


### Security ###################################################################

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0


### Dock #######################################################################

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0



### Finder #####################################################################
### Photos #####################################################################

# Prevent ImageCapture from opening automatically when devices are plugged in
defaults write com.apple.ImageCapture disableHotPlug -bool true


# Disable smart quotes '' and dashes ""
#defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
#defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false



killall Dock
