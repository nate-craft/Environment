#!/usr/bin/env sh

. ~/Env/globals.sh

msg "Arch Cleaning Started"

if ! prog_exists paru; then
	err "Paru was not installed. Not continuing with cleaning"
	exit 1
fi         

paru --clean

if prog_exists vim || prog_exists nano; then
	if prompt "Do you want to remove any default editors? WARNING: ensure other editors are installed before doing this."; then
		if ! prog_exists helix && ! prog_exists neovim; then
			if prompt "Neither helix nor neovim are install. Are you sure you want to continue?"; then
				paru -Rns vim nano
			fi
		else
			paru -Rns vim nano
		fi
	fi
fi

if prog_exists firefox && prompt "Do you want to remove firefox"; then
	paru -Rns firefox
fi

if prompt "Do you want to remove optional sway utilities?"; then
    paru -Rns swaybg brightnessctl dmenu
fi

if prompt "Do you want to remove xorg compatibility?"; then
    paru -Rns xorg-server xorg-xinit xorg-xwayland
    sudo rm -rf /etc/X11/
    rm -rf ~/.xsession*
fi

if prompt "Do you want to hide unused programs from the application launcher?"; then
	export PATH="$PATH:~/Env/scripts/"
    hide /usr/share/applications/org.pwmt.zathura.desktop
    hide /usr/share/applications/fish.desktop
    hide /usr/share/applications/bvnc.desktop
    hide /usr/share/applications/cmake-gui.desktop
    hide /usr/share/applications/bssh.desktop
    hide /usr/share/applications/avahi-discover.desktop
    hide /usr/share/applications/mpv.desktop
    hide /usr/share/applications/qv4l2.desktop
    hide /usr/share/applications/qvidcap.desktop
    hide /usr/share/applications/org.freedesktop.Xwayland.desktop
	hide /usr/share/applications/xgps*
    hide /usr/share/applications/tuned-gui.desktop
    hide /usr/share/applications/gammastep*
    hide /usr/share/applications/rofi*
    hide /usr/share/applications/footclient.desktop
    hide /usr/share/applications/foot-server.desktop
    hide /usr/share/applications/libreoffice-math.desktop
    hide /usr/share/applications/libreoffice-base.desktop
	hide /usr/share/applications/libreoffice-startcenter.desktop
	hide /usr/share/applications/calibre-ebook-edit.desktop
	hide /usr/share/applications/calibre-ebook-viewer.desktop
	hide /usr/share/applications/calibre-lrfviewer.desktop
	hide /usr/share/applications/jconsole*
	hide /usr/share/applications/jshell*
	hide /usr/share/applications/java*
fi
