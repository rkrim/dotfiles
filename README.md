# 🚀 Dotfiles

> An opinionated macOS workstation bootstrap for shells, development runtimes, AI tools, desktop applications, and personal configuration.

## ✨ Features

- 🍺 **Automated Homebrew setup** - Installs and manages packages with better output than `brew bundle`
- 🔗 **Symlinked dotfiles** - Keeps your configurations in sync
- ⚙️ **Optional system preferences** - Provides `macos_defaults.sh` for manual macOS customization
- 🛠️ **Version managers** - Prefers [mise](https://mise.jdx.dev/) and falls back to [asdf](https://asdf-vm.com/)
- 🎨 **Shell customization** - Bash, Zsh, and Nushell configurations with modern tooling

## 🎯 Quick Start

Requirements: macOS, Bash, Git, and an internet connection.

> [!CAUTION]
> The installer upgrades Homebrew, requires interactive confirmations, and may request administrator access. When updating an existing destination repository, accepting the update discards its local changes with `git reset --hard`.

Run this one-liner to install everything:

```bash
/bin/bash <(curl -fsSL https://raw.githubusercontent.com/rkrim/dotfiles/main/dotfiles_installer.sh)
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
/bin/bash <(curl -fsSL https://raw.githubusercontent.com/rkrim/dotfiles/main/dotfiles_installer.sh) '~/my-custom-path'
```

## 📋 What Gets Installed

### Package Managers
- **Homebrew** - macOS package manager
- **mise with asdf fallback** - Runtime version management for Node.js, Java, Python, Ruby, Rust, and related tools

### Development Tools
- Git, Node.js, Python, Ruby, Rust
- Modern CLI tools (eza, bat, fd, ripgrep, etc.)
- Shell tooling for Bash, Zsh, and Nushell, with Starship, Carapace, Atuin, and Zoxide

### Applications

- **Development** - Ghostty, VS Code, Zed, Android Studio, DBeaver, and more
- **Productivity** - Obsidian, Notion, Zen Browser, Syncthing, LocalSend, and more
- **AI-oriented** - Claude, OpenCode, Ollama, Jan, and more
- App Store applications via `mas`
- See [`cli_install.sh`](https://github.com/rkrim/dotfiles/blob/main/cli_install.sh) for the complete installation list

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

After installation, top-level entries in `~/Developer/dotfiles/home_files/` are symlinked into your home directory with a leading dot. Existing files are moved to `~/.dotfiles.old`.

- `.bashrc` → Shell configuration
- `.aliases` → Command aliases
- `.gitconfig` → Git settings
- `.tool-versions` → Runtime versions (mise/asdf)
- `.config` → Application configuration
- And more...

To apply the optional macOS preferences separately:

```bash
./macos_defaults.sh
```

## 🤝 Contributing

Feel free to fork and customize for your own use! These dotfiles are highly personalized but may serve as inspiration.

## 📄 License

[MIT License](LICENSE) - Feel free to use and modify as needed.
