# dotfiles
My personal dotfiles

## Install instruction
To launch installation process, you need to run `dotfiles_installer.sh`

```
/bin/bash <(curl -fsSL https://raw.githubusercontent.com/rkrim/dotfiles/master/dotfiles_installer.sh)
```

This will copy the git repo locally and start the installation.

By default `dotfiles_installer.sh` clones the repo to **~/Developer/dotfiles**.

The script can take en argument to change the destination path.

**Example:**
```
/bin/bash <(curl -fsSL https://raw.githubusercontent.com/rkrim/dotfiles/master/dotfiles_installer.sh) '~/anotherRelativeDirectory'
```

After the clone process, it will launch `cli_install.sh`

`cli_install.sh` will do different things:
- Install Brew packages (nicer than `brew bundle`)
- Creates Symlink to dotfiles
- Make changes to personal system prefences
