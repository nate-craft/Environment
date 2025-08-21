# Arch Install

## Explanation

This program is designed to take my personal environment from a remote repository or a local
USB drive and install upon a **minimal** Arch Linux installation. This can then be backed up
later to these same mediums with scripts in said environment. Because documents and music
take up much disk space, they are only assumed to be accessible from a local USB drive.
Details can be found in the `install.sh` script.

## Usage

1. Install **minimal** Arch Linux from USB with the `archinstall` script.  
  1A. Access wifi with: `iwctl station wlan0 connect <network_name>`.
  1B. Make sure to select `NetworkManager` as wifi for new system .
2. Reboot into system drive.
3. Login to wifi with `nmtui`.
4. Navigate to `Env` directory.  
  4A. `pacman -Syu git; git clone https://github.com/nate-craft/Environment`.  
  4B. Plug in USB drive containing `Env` and optionally any other backed up files.  
5. Ensure the remote environment directory (USB or git cloned) is the current working directory.
6. Run `./install.sh` and follow prompts.

## Keymap

L-Ctrl and L-Alt are swapped. All mentions below will reference where the keys appear in person,
not to the system (e.g., Alt+B refers to pressing the Alt, then B).

### Navigation

- `Alt+j`          : move to workspace left
- `Alt+k`          : move to workspace right
- `Alt+#`          : move to workspace by number
- `Shift+Alt+#`    : move container to workspace by number
- `Alt+Tab`        : move to workspace next 
- `Shift+Alt+Tab`  : move to workspace previous
- `Sup+j`          : move focus left
- `Sup+k`          : move focus right
- `Sup+f`          : fullscreen
- `Alt+q`          : kill container

### TMUX

- `> panel`        : attach to tmux
- `Alt+b`          : leader prefix
- `Leader+#`       : move to tmux workspace by number
- `Leader+h`       : split across horizontal axis
- `Leader+v`       : split across vertical axis
- `Leader+d`       : detach
- `Alt+w`          : close tmux workspace
- `Alt+v`          : visual mode
- `{VISUAL}, v`    : enter selection mode
- `{VISUAL}, y`    : yank selection and exit selection mode
- `{VISUAL}, Esc`  : exit selection mode

### Misc

- `Shift+Sup+e`    : logout sway
- `Shift+Sup+r`    : reload sway
- `Print`          : screenshot selection to clipboard
- `Alt+Print`      : screenshot focused container to clipboard
- `Shift+Print`    : screenshot selection to "~/Photos/Screenshots/"
- `Shift+Alt+Print`: screenshot focused container to "~/Photos/Screenshots/"

