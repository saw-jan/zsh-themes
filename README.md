### How to install

Install [zsh](https://github.com/saw-jan/DocsCol/blob/main/install-zsh-with-oh-my-zsh.md) and [oh-my-zsh](https://github.com/saw-jan/DocsCol/blob/main/install-zsh-with-oh-my-zsh.md)

Installing themes:

1. Clone the repo

   ```bash
   git clone https://github.com/saw-jan/zsh-themes.git
   ```

2. Install

   ```bash
   # make executable
   sudo chmod +x ./install.sh

   # install all fonts and themes
   ./install.sh

    # install themes but not fonts
   ./install.sh --skip-fonts

   # install and activate specific theme
   ./install.sh -t uown
   ```
