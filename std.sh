#!/usr/bin/env bash
# Standard utilities


# Exit status for return functions
EXIT_SUCCESS=0
EXIT_FAILURE=1

### Environment detection ###
osName="$(sw_vers -productName)"
osVersion="$(sw_vers -productVersion)"
osBuildVersion="$(sw_vers -buildVersion)"
arch_name="$(uname -m)"
arch_x86_64="x86_64"
arch_arm64="arm64"

# Check if the argument is a positive number
is_positive_number() {
  if [[ $# != 1 ]]; then
    false
  fi
  decimal_regexp='^[0-9]+$'
  [[ $1 =~ $decimal_regexp ]]
}
