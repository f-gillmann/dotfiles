# dotfiles
Hyprland Dotfiles [WIP]

## Installation
> [!WARNING]
> - This is still work in progress, **stuff will break**!
> - I am not responsible for any damage to your machine!

The install script assumes that you are using a base Arch Linux, without any big modifications or desktop environments preinstalled.

**But** the script still tries to back up *some* of your dotfiles already present in `~/.config` and it will also backup your `grub` and `sddm` configs. Review the `Backup files` block inside the `install.sh` script to see what is being backed up.

### Nvidia
If you happen to have a Nvidia GPU, please either add your linux headers (e.g. `linux-headers`) to `packages/custom.pkgs` or install them beforehand, this file does not exist by default.

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
