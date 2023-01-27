#!/bin/bash

if [[ $1 != -* ]]
then
  echo "Options: [-i] [-u] <file name>"
  exit 0
fi

# setup variables
file=$2
filename=$(basename $file)
filenameonly=$(basename $file .AppImage)
desktopentry="$filenameonly.desktop"
tempdir="$HOME/.cache/appim"
appdir="$HOME/Applications"
icondir="$HOME/.local/share/icons"

echo "Argument: $file"    #prints the file name

if [[ $file == *.AppImage ]]    #checks if the file is an AppImage
then
  echo "The argument is an appimage!"
else
  echo "The argument is NOT an appimage!"
  exit 0
fi

uninstall(){
  rm $appdir/$filename
  echo "removed appimage"
  rm $HOME/.local/share/applications/$desktopentry
  echo "removed desktop entry"
  rm $HOME/.local/share/icons/filename.png
  echo "removed icon"
  echo "$filename uninstalled"
  exit 0
}

install(){
# directory setup
if [ ! -d $tempdir ]    #checks if the temp directory exists
then
  mkdir -p $tempdir
fi

if [ ! -d $appdir ]     #checks if the Applications directory exists
then
  mkdir -p $appdir
fi

if [ ! -d $icondir ]     #checks if the icons directory exists
then
  mkdir -p $icondir
fi

# AppImage extract
chmod +x $file           #makes the file executable
cp $file $tempdir
cd $tempdir
./$filename --appimage-extract
# Icon copy
cp squashfs-root/usr/share/icons/hicolor/512x512/apps/*.png $icondir/$filename.png
mv $filename $appdir

# .desktop file creation
touch $filenameonly.desktop
echo "[Desktop Entry]" >> $desktopentry
echo "Type=Application" >> $desktopentry
echo "Name=$filenameonly" >> $desktopentry
echo "Exec=$appdir/$filename" >> $desktopentry
echo "Icon=$icondir/$filename.png" >> $desktopentry

mv $desktopentry $HOME/.local/share/applications

# cleanup
rm -rf $tempdir
}

while getopts 'iu' OPTION; do
  case "$OPTION" in
    i)
      install
      ;;
    u)
      uninstall
      ;;
    *)
      echo "Options: [-i] [-u] <file name>"
      ;;
  esac
done
