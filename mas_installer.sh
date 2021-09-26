#!/usr/bin/env bash

# Include required libraries
source ./pretty-print.sh
source ./install_helper.sh


### Guard ###
print_title "Check Installer:"

if [ -z `command -v mas` ]; then
  echo -e "\nRequired installer not found"
  exit $EXIT_FAILURE
fi

result=`mas account 2> /dev/null`
if [ $? -ne 0 ]; then
  echo -e "\nAccount issue, please make sure you're connected to the 'App Store'" >&2
  echo -e "To restart from this stage, you can launch '`basename "$0"`'"
  open -a "App Store"
  exit $EXIT_FAILURE
fi


### Apps Install ###
echo
print_title "Install Apps\n"
mas_apps=(

  # Tools
  "1333542190"  # 1Password 7 - Password Manager
  "425424353"   # The Unarchiver
  "1116599239"  # NordVPN-IKE-Unlimited-VPN

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
  "803453959"   # Slack
  "1482454543"  # Twitter

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
