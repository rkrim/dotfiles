# shellcheck shell=bash
# ~/.std.sh
# cspell:disable
#
# Shell Standard utilities

# Prevent multiple sourcing
if [ -n "$SHELL_SOURCED_STD" ]; then
	# shellcheck disable=SC2317
	return 0 2> /dev/null || true
fi
# Mark as sourced in current session (don't export to child processes)
SHELL_SOURCED_STD=1

# Exit status for return functions
EXIT_SUCCESS=0
EXIT_FAILURE=1

### Environment detection ###
ENV_OS_NAME="$(sw_vers -productName)"
ENV_OS_VERSION="$(sw_vers -productVersion)"
ENV_OS_BUILD_VERSION="$(sw_vers -buildVersion)"
ENV_ARCH_NAME="$(uname -m)"
ENV_ARCH_ARM64="arm64"
ENV_ARCH_X86_64="x86_64"

# Check if the argument is a positive number
is_positive_number() {
	if [[ $# -ne 1 ]]; then
		false
	fi
	decimal_regexp='^[0-9]+$'
	[[ $1 =~ $decimal_regexp ]]
}
