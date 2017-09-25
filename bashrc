# ~/.bashrc:
# sourced by bash(1) for non-login shells.


# Source Aliases file
if [ -f ~/.aliases ]; then
   source ~/.aliases
fi

# Autocomplete SSH hostnames (no wildcards)
if [ -e "$HOME/.ssh/config" ]; then
    complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;
fi
