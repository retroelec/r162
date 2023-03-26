#!/bin/bash

files="snail1 bee1 stone bananasprite applesprite tomatosprite carrotsprite springsprite signstartsprite sign2sprite sign3sprite sign4sprite signgoalsprite grassplatformsprite rollingstone1sprite fire1sprite"

files2=""
for file in $files; do
  convert -geometry 16x16! ../sprites/${file}.ppm tmp_${file}.png
  files2=$files2" "tmp_${file}.png
done

montage -mode concatenate -tile 5x4 $files2 ts_events.png

rm $files2

files="grassplatformsprite bananasprite signstartsprite sign2sprite sign3sprite sign4sprite signgoalsprite snail1 bee1 stone applesprite tomatosprite carrotsprite springsprite rollingstone1sprite fire1sprite"
topbottom=( top top bottom bottom bottom bottom bottom bottom top bottom top top top top bottom bottom )

files2=""
i=0
for file in $files; do
  sprite2tileset.sh "../sprites/"${file}".ppm" "align"${topbottom[$i]}
  files2=$files2" "ts_${file}.png
  ((i++))
done

montage -mode concatenate -tile 1x16 $files2 ts_eventsdemo.png

rm $files2
