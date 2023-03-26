#!/bin/sh

CONVPIC4MCR162DIR=$HOME/co/r162/src/tools
DATAOUT=tiles.data

rm -f $DATAOUT

echo "; dummy" >> $DATAOUT
echo ".byt 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0" >> $DATAOUT

for file in `ls wall*.ppm`
do
  echo "; "$file >> $DATAOUT
  $CONVPIC4MCR162DIR/icon2tile.sh $file >> $DATAOUT
done

echo "; empty" >> $DATAOUT
echo ".byt 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0" >> $DATAOUT

for file in `ls pill.ppm superpill.ppm`
do
  echo "; "$file >> $DATAOUT
  $CONVPIC4MCR162DIR/icon2tile.sh $file >> $DATAOUT
done
