# 🚀 Dotfiles

> My personal macOS environment configuration

## ✨ Features

- 🍺 **Automated Homebrew setup** - Installs and manages packages with better output than `brew bundle`
- 🔗 **Symlinked dotfiles** - Keeps your configurations in sync
- ⚙️ **System preferences** - Customizes macOS settings for development
- 🛠️ **Version managers** - Supports both [mise](https://mise.jdx.dev/) and [asdf](https://asdf-vm.com/) with intelligent fallback
- 🎨 **Shell customization** - Bash and Zsh configurations with modern tooling

## 🎯 Quick Start

Run this one-liner to install everything:

```bash
/bin/bash <(curl -fsSL https://raw.githubusercontent.com/rkrim/dotfiles/master/dotfiles_installer.sh)
```

This will:
1. Clone the repository to `~/Developer/dotfiles`
2. Install Homebrew (if not present)
3. Install all configured packages and tools
4. Set up symlinks to dotfiles
5. Configure your development environment

### 📂 Custom Installation Path

Want to install somewhere else? Just specify the path:

```bash
/bin/bash <(curl -fsSL https://raw.githubusercontent.com/rkrim/dotfiles/master/dotfiles_installer.sh) '~/my-custom-path'
```

## 📋 What Gets Installed

### Package Managers
- **Homebrew** - macOS package manager
- **mise** or **asdf** - Runtime version manager (Node.js, Python, Ruby, etc.)

### Development Tools
- Git, Node.js, Python, Ruby, Rust
- Modern CLI tools (eza, bat, fd, ripgrep, etc.)
- Shell enhancements (starship, zsh-autosuggestions, etc.)

### Applications
- VS Code, iTerm2, and other productivity tools
- App Store apps via `mas`

## 🔧 Manual Installation

If you prefer to review before installing:

```bash
# Clone the repository
git clone https://github.com/rkrim/dotfiles.git ~/Developer/dotfiles

# Review the scripts
cd ~/Developer/dotfiles

# Run the installer
./cli_install.sh
```

## 📝 Configuration

After installation, your dotfiles will be symlinked from `~/Developer/dotfiles/home_files/` to your home directory:

- `.bashrc` → Shell configuration
- `.aliases` → Command aliases
- `.gitconfig` → Git settings
- `.tool-versions` → Runtime versions (mise/asdf)
- And more...

## 🤝 Contributing

Feel free to fork and customize for your own use! These dotfiles are highly personalized but may serve as inspiration.

## 📄 License

[MIT License](LICENSE) - Feel free to use and modify as needed.
