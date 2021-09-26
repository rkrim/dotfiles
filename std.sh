#!/usr/bin/env bash
# Standard utilities


# Exit status for return functions
EXIT_SUCCESS=0
EXIT_FAILURE=1


# Check if the argument is a positive number
is_positive_number() {
  if [[ $# != 1 ]]; then
    false
  fi
  decimal_regexp='^[0-9]+$'
  [[ $1 =~ $decimal_regexp ]]
}