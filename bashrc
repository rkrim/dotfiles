# ~/.bashrc
# sourced by bash(1) for non-login shells.


### Helper functions ###########################################################

# Compare arg1 with arg2 taking arg3 as a version number separator
# return -1 if arg1 > arg2, 0 if arg1 == arg2, 1 if arg1 < arg2
# Original from: https://stackoverflow.com/questions/4023830/how-compare-two-strings-in-dot-separated-version-format-in-bash
# Added version trim
version_compare () {

    if [[ $1 == $2 ]]; then
        return 0
    fi

    local IFS=$3
    local index version1=($1) version2=($2)

    # fill empty fields in version1 with zeros
    for ((index=${#version1[@]}; index<${#version2[@]}; index++)); do
        version1[index]=0
    done

    for ((index=0; index<${#version1[@]}; index++)); do
        if [[ -z ${version2[i]} ]]; then
            # fill empty fields in ver2 with zeros
            version2[index]=0
        fi

        if ((10#${version1[index]%%[^0-9]*} > 10#${version2[index]%%[^0-9]*})); then
            return -1
        fi

        if ((10#${version1[index]%%[^0-9]*} < 10#${version2[index]%%[^0-9]*})); then
            return 1
        fi
    done

    return 0
}

update_key_binding () {
  bind '"\e[3~": delete-char' # fn+delete > delete char
}

update_term_behavior () {
  case $TERM in
    ansi)
    update_key_binding
    ;;

    *)
    ;;
  esac
}




### Configuration ##############################################################


# Bash history
export HISTCONTROL=ignoredups


# Add Bash Completion
COMPLETION_1_FILENAME="/usr/local/etc/bash_completion"
COMPLETION_2_FILENAME="/usr/local/share/bash-completion/bash_completion"
COMPLETION_1_MIN_VERSION="3.2"
COMPLETION_2_MIN_VERSION="4.1"
VERSION_SEPARATOR="."
result_1=$(version_compare $COMPLETION_1_MIN_VERSION $BASH_VERSION $VERSION_SEPARATOR; echo $?)
if [[ $result_1 == 0 || $result_1 == 1 ]]; then
  COMPLETION_FILENAME=$COMPLETION_1_FILENAME

  result_2=$(version_compare $COMPLETION_2_MIN_VERSION $BASH_VERSION $VERSION_SEPARATOR; echo $?)
  if [[ $result_2 == 0 || $result_2 == 1 ]]; then
    COMPLETION_FILENAME=$COMPLETION_2_FILENAME
  fi
fi

if [[ -n $COMPLETION_FILENAME && -f $COMPLETION_FILENAME ]]; then
  source $COMPLETION_FILENAME
else
  echo "bash_completion not installed or file location has changed"
fi


# Source Aliases file
if [ -f ~/.aliases ]; then
   source ~/.aliases
fi

# Autocomplete SSH hostnames (no wildcards)
if [ -e "$HOME/.ssh/config" ]; then
    complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;
fi

# Make terminal have approximately the same behavior what ever the $TERM
update_term_behavior
