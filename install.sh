#!/bin/bash
set -e

#colors
WHITE='\033[0;37m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
RESET='\033[0m'

FONTS_DIR="./fonts"
THEMES_DIR="./themes"
FONT_INSTALL_DIR="$HOME/.local/share/fonts/"
THEME_INSTALL_DIR="$HOME/.oh-my-zsh/themes"
ZSH_CONFIG="$HOME/.zshrc"

NEW_THEME=""
SKIP_FONTS="false"

show_options() {
    echo -e $White"Available options:"
    echo -e $White"  -t, --theme \t\t Provide theme name. E.g. '-t uown'"
    echo -e $White"      --skip-fonts \t Skip font installation."
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -t | --theme)
            if [ -z "$2" ] || [[ "$2" =~ "--".* ]]; then
                echo -e $RED"Theme not provided."$RESET
                show_options
                exit 1
            fi
            if [[ $2 =~ .*".zsh-theme" ]]; then
                NEW_THEME="${2%%.*}"
            else
                NEW_THEME="$2"
            fi
            shift 2
            ;;
        --skip-fonts)
            SKIP_FONTS="true"
            shift 1
            ;;
        *)
            break
            ;;
    esac
done

if [[ $SKIP_FONTS == 'false' ]]; then
    echo -e $BLUE"Installing fonts..."$RESET
    eval "mkdir -p $FONT_INSTALL_DIR"
    eval "find $FONTS_DIR -name '*.[o,t]t[fc]' -type f -print0 | xargs -0 -I % cp '%' $FONT_INSTALL_DIR"
    # Reset font cache 
    if command -v fc-cache @>/dev/null ; then
        fc-cache -f $FONT_INSTALL_DIR
    fi
    echo -e $GREEN"Fonts installed"$RESET
fi

install_themes() {
    THEME='*'
    if [ "$1" != "" ]; then
        THEME="$1.zsh-theme"
    fi
    echo -e $BLUE"Installing themes..."$RESET
    eval "cp $THEMES_DIR/$THEME $THEME_INSTALL_DIR"
    echo -e $GREEN"Themes installed"$RESET
}

check_theme() {
    themes_list=$(ls $THEMES_DIR)
    if ! [[ $themes_list =~ $1".zsh-theme" ]]; then
        list=$(echo $themes_list | sed 's/ /\\n /g')
        echo -e $RED"Cannot find '$1' theme"
        echo -e $WHITE"Available themes:"
        echo -e " "$list
        exit 1
    fi
}

if [ -n "$NEW_THEME" ]; then
    check_theme $NEW_THEME
    install_themes $NEW_THEME

    echo -e $BLUE"Activating '$NEW_THEME' theme..."$RESET
    OLD_THEME=$(grep '^ZSH_THEME=' $ZSH_CONFIG| sed 's/\"/\\\"/g')
    eval "sed -i 's/$OLD_THEME/ZSH_THEME=\"$NEW_THEME\"/' $ZSH_CONFIG"
    echo -e $GREEN"Theme activated. Please restart the terminal."$RESET
else
    install_themes
fi