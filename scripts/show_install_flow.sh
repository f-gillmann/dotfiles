#!/bin/bash

#-\   |  --  *      ---   **   ---      *  --  |\----#
#--\  |        Made by Florian Gillmann        | \---#
#---\ | https://github.com/f-gillmann/dotfiles |  \--#
#----\|  --  *      ---   **   ---      *  --  |   \-#

# This script provides an overview of the installation process
# Run with: ./scripts/show_install_flow.sh

cat << 'EOF'
╔═════════════════════════════════════════════════════════════════╗
║                    DOTFILES INSTALLATION FLOW                   ║
╚═════════════════════════════════════════════════════════════════╝

    ┌─────────────────────────────────────────────────────────┐
    │  1. SYSTEM CHECKS                                       │
    │  [scripts/system_checks.sh]                             │
    │                                                         │
    │  ✓ Verify not running as root                           │
    │  ✓ Verify Arch or Arch-based Linux                      │
    │  ✓ Prompt confirmation for Arch-based distros           │
    └─────────────────────────────────────────────────────────┘
                              ↓
    ┌─────────────────────────────────────────────────────────┐
    │  2. DEPENDENCY CHECK                                    │
    │  [scripts/check_dependencies.sh]                        │
    │                                                         │
    │  ✓ Check: git, base-devel, stow, unzip                  │
    │  ✓ Install missing dependencies if approved             │
    └─────────────────────────────────────────────────────────┘
                              ↓
    ┌─────────────────────────────────────────────────────────┐
    │  3. INSTALL YAY                                         │
    │  [scripts/install_yay.sh]                               │
    │                                                         │
    │  ✓ Check if yay is installed                            │
    │  ✓ Clone and build yay from AUR                         │
    └─────────────────────────────────────────────────────────┘
                              ↓
    ┌─────────────────────────────────────────────────────────┐
    │  4. PACKAGE INSTALLATION                                │
    │  [scripts/run_package_install.sh]                       │
    │                                                         │
    │  ✓ Install base packages (packages/base.pkgs)           │
    │  ✓ Install AUR packages (packages/aur.pkgs)             │
    │  ✓ Install custom packages if exists                    │
    └─────────────────────────────────────────────────────────┘
                              ↓
    ┌─────────────────────────────────────────────────────────┐
    │  5. INSTALL OH MY ZSH                                   │
    │  [scripts/install_omz.sh]                               │
    │                                                         │
    │  ✓ Check if Oh My Zsh exists                            │
    │  ✓ Verify zsh is available                              │
    │  ✓ Install OMZ and set as default shell                 │
    └─────────────────────────────────────────────────────────┘
                              ↓
    ┌─────────────────────────────────────────────────────────┐
    │  6. INSTALL OH MY POSH                                  │
    │  [scripts/install_oh_my_posh.sh]                        │
    │                                                         │
    │  ✓ Check if Oh My Posh exists                           │
    │  ✓ Download and install to ~/.local/bin                 │
    │  ✓ Verify installation and version                      │
    └─────────────────────────────────────────────────────────┘
                              ↓
    ┌─────────────────────────────────────────────────────────┐
    │  7. INSTALL DOTFILES                                    │
    │  [scripts/run_dotfiles_install.sh]                      │
    │                                                         │
    │  ✓ Stow dotfiles to home directory                      │
    │  ✓ Handle Nvidia-specific configurations                │
    │  ✓ Update XDG user directories                          │
    └─────────────────────────────────────────────────────────┘
                              ↓
    ┌─────────────────────────────────────────────────────────┐
    │  ✓ INSTALLATION COMPLETE                                │
    │                                                         │
    │  Please reboot your system to apply all changes         │
    └─────────────────────────────────────────────────────────┘

╔═════════════════════════════════════════════════════════════════╗
║  ERROR HANDLING: Script stops at first error                    ║
║  Each step validates success before proceeding                  ║
╚═════════════════════════════════════════════════════════════════╝

╔═════════════════════════════════════════════════════════════════╗
║                           UPDATE MODE                           ║
╚═════════════════════════════════════════════════════════════════╝

When running the script again, it detects the previous installation
and enters UPDATE MODE, which:

  ✓ Updates the dotfiles repository (git pull)
  ✓ Checks for new dependencies
  ✓ Updates all packages
  ✓ Updates Oh My Zsh
  ✓ Updates Oh My Posh
  ✓ Re-applies dotfiles

EOF
