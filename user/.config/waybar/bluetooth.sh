#!/usr/bin/env sh

if systemctl check -q bluetooth.service; then
    echo "  "
else
    echo " ✕ "
fi
