# generate level 1 playfield data
java -cp $R162HOME/utils/Tiled2R162/bin com.retroelec.r162.tiles.Tiled2R162 tiles1/tl_level1.tmx level1/level1data.asm 4
# generate level 2 playfield data
java -cp $R162HOME/utils/Tiled2R162/bin com.retroelec.r162.tiles.Tiled2R162 tiles2/level.tmx level2/level2data.asm 4
# generate wboy executable
xa wboy.asm -o wboy -l wboy.map
# generate include file for level data files
cat wboy.map | awk -F, '{ print $1" ="$2 }' | sed 's/= 0x/= $/' > wboydef.inc
grep ^\#define ../atmega/6502def.inc >> wboydef.inc
#rm wboy.map
# generate level files
cd level1
xa level1.asm -o level1.dat
cd ..
cd level2
xa level2.asm -o level2.dat
cd ..
rm wboydef.inc
# max size of wboy binary is 27696 bytes
sizewboy=`ls -l wboy | awk '{ print $5 }'`
sizelevel1=`ls -l level1/level1.dat | awk '{ print $5 }'`
sizelevel2=`ls -l level2/level2.dat | awk '{ print $5 }'`
maxsizelevel=$((27696-sizewboy))
sizetot=$((sizewboy+sizelevel1))
if [ $sizelevel1 -gt $maxsizelevel ]; then
  echo "level1 binary too large!"
  echo "used: "$sizelevel1", available: "$maxsizelevel
  exit
fi
diff=$((maxsizelevel-sizelevel1))
echo "level 1: number of bytes left: "$diff
if [ $sizelevel2 -gt $maxsizelevel ]; then
  echo "level2 binary too large!"
  echo "used: "$sizelevel2", available: "$maxsizelevel
  exit
fi
diff=$((maxsizelevel-sizelevel2))
echo "level 2: number of bytes left: "$diff

echo "cp wboy /media/daniel/R162/BIN/"
echo "cp level1/level1.dat /media/daniel/R162/DATA/WBOY/"
echo "cp level2/level2.dat /media/daniel/R162/DATA/WBOY/"
