#!/bin/bash

if [ -z ${files+1} ] || [ -z ${topbottom+1} ]; then
  echo "not a standalone shell-script"
  echo "-> this script should be included by other scripts"
  echo "the variables \"files\" and \"topbottom\" have to be provided"
  exit
fi

files2=""
for file in $files; do
  convert -geometry 16x16! ../sprites/${file}.ppm tmp_${file}.png
  files2=$files2" "tmp_${file}.png
done

montage -mode concatenate -tile 4x4 $files2 ts_events.png

rm $files2

files2=""
i=0
for file in $files; do
  sprite2tileset.sh "../sprites/"${file}".ppm" "align"${topbottom[$i]}
  files2=$files2" "ts_${file}.png
  ((i++))
done

montage -mode concatenate -tile 1x16 $files2 ts_eventsdemo.png

rm $files2
