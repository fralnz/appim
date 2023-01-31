#!/bin/bash
# Made by: WalkingGarbage (https://github.com/WalkingGarbage/)
# Any feedback is appreciated

if [[ $1 != -* ]]
then
  echo "Options: [-i,-s] [-u,-r] <file name>"
  exit 0
fi

# setup variables
file=$2
filename=$(basename "$file")
filenameonly=$(basename "$file" .AppImage)
desktopentry="$filenameonly.desktop"
if [[ ! -z "$XDG_CACHE_HOME" ]]; then
  tempdir="$XDG_CACHE_HOME/appim"
else
  tempdir="$HOME/.cache"
fi
appdir="$HOME/Applications"
icondir="$HOME/.local/share/icons"

checkappimage(){
  echo "Argument: $file"    #prints the file name

  if [[ $file == *.AppImage || $file == *.appimage ]]    #checks if the file is an AppImage
  then
    echo "[OK] AppImage recognized"
  else
    echo "[ERR] The argument is NOT an appimage"
    exit 0
  fi
}

update(){
  sudo curl https://raw.githubusercontent.com/WalkingGarbage/appim/main/appim.sh > /usr/local/bin/appim
  sudo chmod +x /usr/local/bin/appim 
}

list(){
  printf "List of installed AppImages:\n\n"
  cd "$appdir" || echo "[ERR] Can't find $HOME/Applications"
  ls | egrep '\.AppImage$|\.appimage$'
}

uninstall(){
  checkappimage
  rm "$appdir"/"$filename"
  echo "removed appimage"
  rm "$HOME"/.local/share/applications/"$desktopentry"
  echo "removed desktop entry"
  rm "$HOME"/.local/share/icons/"$filename".png
  echo "removed icon"
  echo "$filename uninstalled"
  exit 0
}

geticon(){
  cd squashfs-root
  counticon=`ls -1 *icon.png 2>/dev/null | wc -l`      #count the number of images that have icon in the name 
  countsvg=`ls -1 *.svg 2>/dev/null | wc -l`           #count the number of images in the root directory (png)
  countpng=`ls -1 *.png 2>/dev/null | wc -l`           #count the number of images in the root directory (svg)
  cd ..

  if [[ -f "squashfs-root/usr/share/icons/hicolor/512x512/apps/*.png" ]]; then              #most common place for icons
    cp squashfs-root/usr/share/icons/hicolor/512x512/apps/*.png "$icondir"/"$filename".png
    echo "[OK] Icon found"
  elif [[ $counticon != 0 ]]; then
    cp squashfs-root/*icon.png "$icondir"/"$filename".png
    echo "[OK] Icon found"
  elif [[ $countpng == 1 ]]; then
    cp squashfs-root/*.png "$icondir"/"$filename".png
    echo "[OK] Icon found"
  elif [[ $countsvg == 1 ]]; then
    cp squashfs-root/*.svg "$icondir"/"$filename".png
    echo "[OK] Icon found"
  else
    cd squashfs-root
    read -n1 -p "[WARN] Icon not found: do you want to manually select it? [y/N]" select
    echo ""           #empty line
    case $select in
      y|Y) icon=$(fzf); cp "$icon" "$icondir"/"$filename".png; echo "[OK] Icon selected";;
      *) echo "[WARN] Missing icon";;
    esac
  fi
}

install(){

checkappimage
# directory setup
mkdir -p "$tempdir" "$appdir" "$icondir"

# AppImage extract
chmod +x "$file"           #makes the file executable
cp "$file" "$tempdir"
cd "$tempdir" || echo "[ERR] Can't find $tempdir"
./"$filename" --appimage-extract &>/dev/null
echo "[OK] AppImage extracted"
# Icon copy
mv "$filename" "$appdir"
echo "[OK] Moved AppImage"
geticon

# .desktop file creation
cat << EOF > "$desktopentry"
[Desktop Entry]
Type=Application
Name=$filenameonly
Exec=$appdir/$filename
Icon=$icondir/$filename.png
EOF

echo "[OK] Desktop entry created"

mv "$desktopentry" "$HOME"/.local/share/applications    #Move the desktop entry

echo "[OK] Moved desktop entry"
# cleanup
rm -rf "$tempdir"
echo "[OK] Cache cleared"

echo "[DONE] AppImage installed"
}

while getopts 'iusrl' OPTION; do
  case "$OPTION" in
    i|s)
      install
      ;;
    r)
      uninstall
      ;;
    l)
      list
      ;;
    u)
      update
      ;;
    *)
      echo "Options: [-i,-s] [-u,-r] <file name>"
      ;;
  esac
done
