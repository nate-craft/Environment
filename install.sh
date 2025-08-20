#!/usr/bin/env sh

# Configurable Globals

ENV_DIR_NAME="Env"
USB="68FF-79C3"
USB_MOUNT_DIR="/mnt/drive"

#   ,----.              ,--.         ,--.                ,--.          ,--.,--.               
#  /  O   \,--.--. ,---.|  ,---.     |  |,--,--,  ,---.,-'  '-. ,--,--.|  ||  | ,---. ,--.--. 
# |  .-.  ||  .--'| .--'|  .-.  |    |  ||      \(  .-''-.  .-'' ,-.  ||  ||  || .-. :|  .--' 
# |  | |  ||  |   \ `--.|  | |  |    |  ||  ||  |.-'  `) |  |  \ '-'  ||  ||  |\   --.|  |    
# `--' `--'`--'    `---'`--' `--'    `--'`--''--'`----'  `--'   `--`--'`--'`--' `----'`--'    
#
# This script is designed to install local files and enable systemd services, scripts, and other
# programs necessary for my Arch Linux installation.
#
# No personal information is present, but many of the choices fit my individual technology stack.
#
# No editing is necessary for the following script, but individual programs can be changed if desired.
#
# For files, this script will attempt to copy the current directory filled with environmental data
# to the given $ENV_DIR_NAME. The current directory must be the backup enviornment directory.
# This is verified within the script. After, an attempt will be made to copy Music, Photos, and Documents from
# the given $USB identifier

# variables (do not touch)

ME="$HOME"
ENV="${HOME}/${ENV_DIR_NAME}"
BLUETOOTH_RULE='polkit.addRule(function(action, subject) {
    if (action.lookup("unit") == "bluetooth.service" && (action.lookup("verb") == "start" || action.lookup("verb") == "stop")) {
        return polkit.Result.YES;
    }
});
'
RFKILL_RULE='polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.rfkill.control" && subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});'
BRIGHTNESS_RULE='
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="/bin/chgrp wheel /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
'
SYSTEMD_DIR="/etc/systemd/system/getty@tty1.service.d/"
SYSTEMD_FILE="/etc/systemd/system/getty@tty1.service.d/override.conf"
SYSTEMD_SWAY="[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin ${USER} %I 38400 linux
"
USB_FSTAB_ENTRY="UUID=${USB} ${USB_MOUNT_DIR} exfat defaults,uid=1000,gid=1000,nosuid,nodev,nofail,x-systemd.automount 0 0"

# script start

if [ -f "globals.sh" ]; then
    . ./globals.sh
else
    printf "%sScript must be executed from the '${ENV_DIR_NAME}' directory on first run!\n" "$(tput setaf 1)"
    exit 0
fi

msg "Arch Installation Started"

if ! prompt "Do you want to continue with a minimal sway environment configuration?"; then
    exit 0
fi

msg "This script will need to prompt for super user permissions to install programs and move files!"

if prompt "Pacman should be synced and updated before installation. Would you like to continue? Continuing without is not recommended"; then
    msg "Pacman will now sync packages to avoid future dependency issues..."
    sudo pacman -Syu
else
    msg "Moving on without updating pacman. This is not recommended!"
fi

if [ "$PWD" != "$ENV" ]; then
    if ! prog_exists rsync; then
        sudo pacman -S --needed rsync
    fi

    mkdir -p "$ENV"
    rsync -a --mkpath --ignore-missing-args ./ "$ENV"

    cd "$ENV" || (msg_err "Could not move into ${ENV}. Not moving directories!" && exit 1)

    # script permissions
     
    if [ -d "$ENV"/scripts/ ]; then     
        chmod +x -R "${ENV}/scripts/"
    else
        msg_err "Unable to run user scripts as these files were never downloaded!"
    fi    
fi

# dependencies

if ! prog_exists git || ! prog_exists ssh; then
    sudo pacman -S --needed git base-devel openssh
fi

# basics

if ! prog_exists sway; then
    sudo pacman -S --needed sway \
        swayidle \
        swaylock \
        polkit \
        foot \
        bat \
        ripgrep \
        fd \
        libnotify \
        bc \
        wl-clipboard \
        networkmanager \
        tmux \
        waybar \
        man \
        7zip \
        unzip \
        dunst \
        slurp \
        grim \
        rofi-wayland \
        jq \
		helix \
        libsixel
fi

# git

if prompt "Do you want to configure your Git settings?"; then
    ask "username" "What is your Git username?"
    git config --global user.name "$username"
    msg "Username set as ${username}"
    ask "email" "What is your Git email?"
    git config --global user.email "$email"
    msg "Email set as ${email}"
    git config --global init.defaultBranch main
fi

# shell

if prompt "Do you want to install shell programs?"; then
    if prompt "Do you want to install dash as the default shell for running scripts?"; then
        sudo pacman -S --needed dash
        sudo rm -f /bin/sh
        sudo ln -sf /bin/dash /bin/sh
    fi

    if prompt "Do you want to install fish as the interative shell?"; then
        sudo pacman -S --needed fish
        command -v fish | sudo tee -a /etc/shells > /dev/null 2>&1
        chsh -s "$(command -v fish)"
    fi
fi

# local files

if prompt "Do you enable local data syncing?"; then

    # copy home files from local env files

    if prompt "Do you want to install '~/.config', '~/', and '/etc/' configuration files?"; then
        cp -pr "${ENV}/user/." "$ME"
        sudo sudo cp -pr "${ENV}/system/." "/etc/" # sudo necessary to maintain root permissions
        chmod +x -R "${ME}/.config/waybar/"
    fi

    # copy user files locally
 
    if prompt "Do you want to sync documents, photos, and music from the USB ${USB}?"; then
        sudo pacman -S --needed exfat-utils

        if ! grep "$USB" /etc/fstab > /dev/null 2>&1; then
            echo "$USB_FSTAB_ENTRY" | sudo tee -a /etc/fstab > /dev/null 2>&1
        fi

        sudo systemctl daemon-reload
        sudo systemctl restart mnt-drive.automount

        if lsblk -o UUID | grep -q "$USB"; then
            rsync -a --mkpath --partial --ignore-missing-args --info=progress2 "$USB_MOUNT_DIR"/Documents ~/
            rsync -a --mkpath --partial --ignore-missing-args --info=progress2 "$USB_MOUNT_DIR"/Music ~/
            rsync -a --mkpath --partial --ignore-missing-args --info=progress2 "$USB_MOUNT_DIR"/Photos ~/
        else
            msg_err "USB ${USB} not available. Not syncing documents and music from remote drive"    
        fi        
    fi    
fi

# utilities

if prompt "Do you want to install utilities like bluetooth, brightness control, printing, and battery management?"; then

    # polkit rules

    if prompt "Do you want to enable bluetooth polkit permissions to enable quick start/stop?"; then
        echo "$BLUETOOTH_RULE" | sudo tee "/etc/polkit-1/rules.d/30-bluetooth.rules" > /dev/null 2>&1
        echo "$RFKILL_RULE" | sudo tee "/etc/polkit-1/rules.d/40-rfkill.rules" > /dev/null 2>&1
        sudo groupadd -f wheel
        sudo usermod -aG wheel "$USER"
        sudo systemctl restart polkit
    fi

    if prompt "Do you want to enable brightness permissions for the wheel user? This is necessary for brightness control."; then
        echo "$UDEV_RULE" | sudo tee /etc/udev/rules.d/90-backlight.rules > /dev/null 2>&1
        sudo udevadm control --reload
        sudo udevadm trigger
    fi

    # printing

    if prompt "Do you want to enable over the air printing?"; then
        sudo pacman -S --needed cups cups-browsed
        sudo systemctl enable cups-browsed
    fi

    if prompt "Do you want to install tuned as a battery profile manager?"; then
        sudo pacman -S --needed tuned
        sudo systemctl enable tuned.service
        sudo systemctl start tuned.service
        if prompt "Do you want to enable the recommended balanced-powersave mode?"; then
            tuned-adm profile balanced-battery
        fi
    fi
fi

# developer dependencies & utilities

if prompt "Do you want to install developer utilities, programs, and libraries?"; then
    if prompt "Do you want to install rust components and programs?"; then
        sudo pacman -S --needed rustup rust-analyzer cmake lldb sccache yazi 
    
        export RUSTUP_HOME="$ME/.local/share/rustup/"
        export CARGO_HOME="$ME/.local/share/cargo/"

        rustup default stable
        rustup component add rustfmt

        cargo install --git https://github.com/nate-craft/yt-feeds
    	cargo install --git https://github.com/Feel-ix-343/markdown-oxide.git 
    fi

    if prompt "Do you want to install Haskell components?"; then
    	curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh 
    fi

    if prompt "Do you want to install virtualization components?"; then
    	paru -S --needed docker docker-compose docker-buildx
    	sudo usermod -aG docker "$USER"
    fi

    if prompt "Do you want to install Java develpoment components and programs?"; then
    	paru -S --needed jdk-openjdk intellij-idea-ce-eap
    fi
fi
 
# core apps

if prompt "Do you want to install user applications?"; then
    if ! prog_exists paru; then
        git clone https://aur.archlinux.org/paru.git
        (
            cd paru || (msg_err "Could not install paru!" && exit 1)
            makepkg -si
        )
        rm -rf paru
    fi
    
    paru -S --needed \
        bluez \
        bluetui \
        gammastep \
        tealdeer \
        mpv \
        yt-dlp \
        imv \
        fzf \
        chafa \
        shellcheck \
        pavucontrol \
        gurk \
        imagemagick \
        zathura \
        zathura-pdf-poppler \
        librewolf-bin \
        libreoffice-fresh \
        freetube-bin \
        adw-gtk-theme \
		qt6-wayland \
        picard \
		calibre \
		htop

    if ! systemd_running NetworkManager.service; then
        sudo systemctl enable NetworkManager.service
        sudo systemctl start NetworkManager.service
    fi

    if prompt "Do you want to install nerd fonts, chinese iconography, and emojis?"; then
        paru -S --needed ttf-jetbrains-mono-nerd noto-fonts-cjk noto-fonts-emoji
        fc-cache -fv
    fi

    if prompt "Do you want to enable screen sharing/recording components?"; then
        paru -S --needed wf-recorder xdg-desktop-portal-gtk
    fi

	if prompt "Do you want to install gaming components?"; then
		paru -S --needed glfw-wayland-minecraft-cursorfix prismlauncher
	fi

    # source-built applications

    if prompt "Do you want to install mpv usability scripts?"; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/installers/unix.sh)"
        git clone https://github.com/po5/thumbfast
        (
            cd thumbfast || (msg_err "Could not install thumbfast" && exit 1)
            mkdir -p ~/.config/mpv/scripts/
            cp -p thumbfast.lua ~/.config/mpv/scripts/
        )
        rm -rf thumbfast
        git clone https://github.com/po5/mpv_sponsorblock
        (
            cd mpv_sponsorblock || (msg_err "Could not install mpv sponsorblock" && exit 1)
            mkdir -p ~/.config/mpv/scripts/
            cp -rp sponsorblock.lua sponsorblock_shared/ ~/.config/mpv/scripts/
        )
        rm -rf mpv_sponsorblock
    fi

    if prompt "Do you want to add iCloud photo syncing?"; then
        paru -S --needed icloudpd
        icloudpd --username --auth-only
        if prompt "Do you want to sync iCloud photos now?"; then
            icloudpd --skip-live-photos --only-print-filenames --folder-structure none --directory ~/Photos/Cloud/
        fi
    fi
fi

if prompt "Installation complete. Would you like to clean up pre-installed files and programs?"; then
	./clean.sh
fi

if prompt "Would you like to enable auto start with swaylock enabled?${NEW_LINE}This will automatically logout of any graphical environment"; then
    if [ -e $SYSTEMD_FILE ]; then
        sudo mkdir -p "$SYSTEMD_DIR"
        sudo touch "$SYSTEMD_FILE"
        echo "$SYSTEMD_SWAY" | sudo tee "$SYSTEMD_FILE" > /dev/null 2>&1
    fi

    sudo systemctl enable getty@tty1
    sudo systemctl start getty@tty1
fi

if prompt "Would you like to reboot now?"; then
    reboot
fi

