#!/usr/bin/env bash

# Include required libraries
source ./pretty-print.sh
source ./install_helper.sh


### Guard ###
print_title "Check App Store command line installer (mas):"

if [ -z `command -v mas` ]; then
  echo -e "\nRequired installer not found."
  exit $EXIT_FAILURE
else
    echo -e "\nAlready installed."
    read -rn 1 -p "Please, make sure you are signed in 'App Store', press any key to launch the app "
    echo -e ""
    open -a "App Store"
    read -rn 1 -p "Press any key to proceeed with applications installation"
    echo
fi

### Apps Install ###
echo
print_title "Install Apps\n"
mas_apps=(

  # Tools
  "425424353"   # The Unarchiver
	"905953485"		# NordVPN: VPN Fast & Secure
# "1333542190"  # 1Password 7 | Install 1Password 8 from website

  # Developer
  "497799835"   # Xcode
  "1496833156"  # Swift Playgrounds
  "640199958"   # Apple Developer
  "1450874784"  # Transporter

  # Productivity
  "409203825"   # Numbers
  "409201541"   # Pages
  "409183694"   # Keynote

  # Reference
  "430255202"   # MacTracker

  # Communication
  "1176895641"  # Spark – Email App by Readdle
  "1482454543"  # Twitter
# "803453959"   # Slack | Install from website

  # Media Editor
  "408981434"   # iMovie

  # Safari Extensions
  "1440147259"  # AdGuard-For-Safari

  # Customization
  "1284863847"  # Unsplash Wallpapers
)
mas_batch_install mas_apps[@]


rosetta_apps=(
  "935235287"   # Encrypto-Secure-Your-Files (rosetta)
  "1274495053"  # Microsoft-To-Do (rosetta)
  "1278508951"  # Trello (rosetta)
  "568494494"   # Pocket (rosetta)
  "1480068668"  # Messenger (rosetta)
  "1147396723"  # WhatsApp Desktop (rosetta)
  "461369673"   # Vox-Mp3-Flac-Music-Player (rosetta)
  "407963104"   # Pixelmator-Classic (rosetta)
  "512204619"   # Radiant Defense (rosetta)
)

if [ "$ARCH_NAME" == "$ARCH_X86_64" ]; then
  # If arch is emulated
  if [ "$(sysctl -in sysctl.proc_translated)" = "1" ]; then
    print_title "Install Rosetta Apps\n"
  fi
  mas_batch_install rosetta_apps[@]
fi
