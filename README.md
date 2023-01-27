# appim

A lightweight cli tool that lets you install and uninstall appimages.

## Install

```bash
sudo curl https://raw.githubusercontent.com/WalkingGarbage/appim/main/appim.sh > /usr/local/bin/appim
sudo chmod +x /usr/local/bin/appim 
```

## Dependencies

**Optional**: `fzf` for file selection in case appim can't find the application icon.

## Usage

| Flag | Description             |
| ---- | ----------------------- |
| -i   | Installs the appimage   |
| -u   | Uninstalls the appimage |


**Note**: The name of the desktop entry will be the name of the AppImage, so if you want to rename the application edit the name of the file before installing it.

**Example**:

```bash
appim -i balenaEtcher-1.13.1-x64.AppImage
```

will install Balena Etcher under the name `balenaEtcher-1.13.1-x64`. To uninstall it:

```bash
appim -u balenaEtcher-1.13.1-x64.AppImage
```

## Locations

In case you want to manually edit something:

- **AppImages final location**: `$HOME/Applications`

- **Desktop entries**: `$HOME/.local/share/applications`

- **Icons**: `$HOME/.local/share/icons`

- **temp** (gets automatically deleted): `$HOME/.cache/appim`
