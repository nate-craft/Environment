#!/usr/bin/env fish

# Path

set -gx PATH $PATH $HOME/Env/scripts
set -gx PATH $PATH $HOME/.local/bin
set -gx PATH $PATH $CARGO_HOME/bin/
set -gx PATH $PATH $JAVA_HOME/bin/

set -Ux EDITOR helix
set -Ux BROWSER librewolf
set -Ux SHELL fish
set -Ux TERMINAL foot
set -Ux visual $EDITOR
set -Ux PAGER 'bat --paging=always'
set -Ux ELECTRON_OZONE_PLATFORM_HINT wayland
set -Ux JAVA_HOME /usr/lib/jvm/java-24-openjdk
set -Ux _JAVA_AWT_WM_NONREPARENTING 1

# XDG

set -Ux XDG_CURRENT_DESKTOP sway
set -Ux XDG_CONFIG_HOME "$HOME/.config"
set -Ux XDG_DATA_HOME "$HOME/.local/share"

# Config

set -Ux MYVIMRC "$XDG_CONFIG_HOME/nvim/init.lua"
set -Ux ZDOTDIR "$XDG_CONFIG_HOME/zsh"
set -Ux TMUX_CONF "$XDG_CONFIG_HOME/tmux/tmux.conf"
set -Ux GNUPGHOME "$XDG_CONFIG_HOME/gnupg"
set -Ux PKIHOME "$XDG_CONFIG_HOME/pki"
set -Ux RUSTUP_HOME "$XDG_DATA_HOME/rustup"
set -Ux CARGO_HOME "$XDG_DATA_HOME/cargo"

# Rust Environment 

test -f /usr/bin/sccache; and set -Ux RUSTC_WRAPPER sccache

# Sway Launch

if test -z "$DISPLAY" -a (tty) = /dev/tty1
    exec sway
end

# Abbreviations

abbr --add music "clear; mpv --no-video --shuffle ~/Music --no-resume-playback"
abbr --add photos "icloudpd --skip-live-photos --only-print-filenames --folder-structure none --directory ~/Photos/Cloud/"
abbr --add server "ssh 192.168.7.222"
abbr --add ls "ls --color=always"
abbr --add open xdg-open
abbr --add hx "$EDITOR"
abbr --add vi "$EDITOR"
abbr --add javac "javac --enable-preview --source 24"
abbr --add java "java --enable-preview"

# Functions 

function fish_prompt
    set_color "$fish_color_cwd"
    echo -n (path basename "$PWD")
    set_color normal
    echo -n ' > '
end

function fish_greeting
end

# Key Binds

bind \ci beginning-of-line
bind \ce edit_command_buffer
bind \t complete

# Launch TMUX

if status is-interactive
    test -z "$TMUX"; and panel
end
