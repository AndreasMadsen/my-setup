#Mac Terminal Setup

This is a guide for how to set up your terminal so it looks exactly like mine. The end result should be this:
![Terminal setup example](https://raw.githubusercontent.com/AndreasMadsen/my-setup/master/mac-terminal/example.png)

As always this assumes your running on an effectively blank slate. Furthermore you should have `brew` installed, be sure to run `brew doctor` first. The guide is in 3 parts:

1. [iTerm](#iTerm)
2. [vim](#vim)
3. [zsh](#zsh)

## iTerm

Download and install [iTerm2](http://www.iterm2.com/)

### General

1. Open iTerm
2. Open Settings
3. Uncheck “Confirm Quit iTerm2 command”
4. Uncheck “Copy to clipboard on selection”

### Keymapping

1. Open iTerm
2. Open Settings
4. Select Profiles then the subsection Keys
5. Remove `alt+left` and `alt+right`
3. Select Keys
4. Click `+` and press `alt + left` then select “Send Escape Sequence” and press `b`.
5. Click `+` and press `alt + right` then select “Send Escape Sequence” and press `f`.

### Colorscheme

1. Download and unzip the [solarized](http://ethanschoonover.com/solarized/files/solarized.zip) color scheme
2. Open the `item2-colors-solarized` directory
3. Double click on `Solarized Dark.itermcolors`
4. Open iTerm
5. Open Settings
6. Select Profiles, then the subsection Colors
7. Click Load Presets, then select `Solarized Dark`
8. Select the subsection Window
9. Set Transparency to about `8%`

### Font

1. Download the [“SourceCodePro” font](https://github.com/Lokaltog/powerline-fonts/archive/master.zip)
2. Open the SourceCodePro directory
3. Install the fonts by double clicking on the `*.otf` files, and click “Install Font”. Do it for all the SourceCodePro font files.
4. Open iTerm
5. Open Settings
6. Select Profiles then the subsection Text
7. Click Change Font (Regular Font) and select “Source Code Pro -> Regular -> 12”
8. Do the same for Non-ASCII Font

## vim

Run this:

```shell
brew install vim
echo export PATH='/usr/local/bin:$PATH' >> ~/.bash_profile
curl http://j.mp/spf13-vim3 -L -o - | sh
git config --global core.editor /usr/bin/vim
```

At last edit `~/.vimrc.before` and enable `g:airline_powerline_fonts = 1` by uncommenting that line (remove `"`)

## zsh

1. Install oh-my-zsh using `curl -L http://install.ohmyz.sh | sh`
2. Edit `~/.zshrc` and set `ZSH_THEME="Agnoster”`
3. Edit `~/.oh-my-zsh/themes/agnoster.zsh-theme` and uncomment with `#` the `prompt_context` line in the `build_prompt` function.
