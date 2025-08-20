#!/usr/bin/env sh

if nmcli -t -f active dev wifi | rg yes > /dev/null; then
	echo "   "
else
	echo " ✕ "
fi
