# dotfiles
Hyprland Dotfiles [WIP]

## Installation
> [!WARNING]
> - This is still work in progress, **stuff will break**!
> - I am not responsible for any damage to your machine!

```bash
bash -c "$(curl -fsSL dots.flg.sh)"
```

This will:
1. Clone the repository to `~/.local/flg-dots`
2. Run the installation script which will:
   - Check system requirements
   - Install dependencies
   - Install yay AUR helper
   - Install all packages (base + AUR)
   - Install Oh My Zsh
   - Install Oh My Posh
   - Install and configure dotfiles

## Updating

To update your dotfiles, simply run the install script again:

```bash
cd ~/.local/flg-dots
./install.sh
```

The script will automatically detect that it's been run before and enter **update mode**, which will:
- Update the dotfiles repository
- Update all packages
- Update Oh My Zsh
- Update Oh My Posh
- Re-apply dotfiles configurations

### Nvidia
If you happen to have a Nvidia GPU, please either add your linux headers (e.g. `linux-headers`) to `packages/custom.pkgs` or install them beforehand, this file does not exist by default.
