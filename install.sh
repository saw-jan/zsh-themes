#!/bin/bash
set -e

#colors
WHITE='\033[0;37m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
RESET='\033[0m'

FONTS="./fonts"
THEMES="./themes"
FONT_INSTALL_DIR="$HOME/.local/share/fonts"
THEME_INSTALL_DIR="$HOME/.oh-my-zsh/themes"
ZSH_CONFIG="$HOME/.zshrc"

echo -e $BLUE"Installing fonts..."$RESET
eval "find $FONTS -name '*.[o,t]t[fc]' -type f -print0 | xargs -0 -I % cp '%' $FONT_INSTALL_DIR"
# Reset font cache 
if command -v fc-cache @>/dev/null ; then
    fc-cache -f $FONT_INSTALL_DIR
fi
echo -e $GREEN"Fonts installed"$RESET

echo -e $BLUE"Installing themes..."$RESET
eval "cp $THEMES/* $THEME_INSTALL_DIR"
echo -e $GREEN"Themes installed"$RESET
NEW_THEME=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -t | --theme)
            if [ -z "$2" ]; then
                echo -e $RED"Theme not provided."$RESET
                echo -e $White"Available options:"
                echo -e $White"  -t, --theme \t Theme name. E.g. '-t uown'"
                exit 1
            fi
            NEW_THEME="$2"
            ;;
        *)
            echo -e $RED"Invalid option '$1'."$RESET
            echo -e $White"Available options:"
            echo -e $White"  -t, --theme \t Theme name. E.g. '-t uown'"
            exit 1
            ;;
    esac
    break
done
if [ -n "$NEW_THEME" ]; then
    echo -e $BLUE"Activating '$NEW_THEME' theme..."$RESET
    OLD_THEME=$(grep '^ZSH_THEME=' $ZSH_CONFIG| sed 's/\"/\\\"/g')
    eval "sed -i 's/$OLD_THEME/ZSH_THEME=\"$NEW_THEME\"/' $ZSH_CONFIG"
    echo -e $GREEN"Theme activated. Please restart the terminal."$RESET
fi