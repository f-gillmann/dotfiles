# dotfiles
Hyprland Dotfiles [WIP]

## Installation
> [!WARNING]
> - This is still work in progress, **stuff will break**!
> - I am not responsible for any damage to your machine!

### Nvidia ⚠️
If you happen to have a Nvidia GPU, please either add your linux kernels headers to `packages/custom.pkgs` or install them beforehand, this file does not exist by default.

For the base `linux` kernel need to add `linux-headers`, for the `linux-zen` kernel you need to add `linux-zen-headers` instead etc.

### Method 1:
Use the `get.sh` script to automatically download the repository.

This will prompt you if you wanna run the `install.sh` afterwards.

```bash
bash -c "$(curl -fsSL dots.florian-gillmann.com/get.sh)"
```

### Method 2:
Clone the repository and run the `install.sh` script manually.
```bash
git clone --recurse-submodules https://github.com/f-gillmann/dotfiles &&
cd dotfiles &&
chmod +x ./install.sh &&
./install.sh
```

## Dependencies
| Type              | Dependency        | 
| ----------------- | ----------------- |
| Window Manager    | hyprland          |
| Screen Lock       | hyprlock          |
| Wallpaper         | swww              |
| Logout Menu       | rofi              |
| Display Manager   | ly                |
| Terminal Emulator | kitty             |
| Shell             | zsh + oh-my-zsh   |
| Prompt            | powerlevel10k     |
| File Manager      | dolphin           |
| Editor            | neovim            |
| Browser           | librewolf         |
| Bootloader        | grub              |
| Widgets           | ags               |
