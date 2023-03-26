#!/bin/bash
sed -e 's/anonym/blinky/g' -e 's/ANONYM/BLINKY/g' -e 's/Anonym/Blinky/g' anonym.asm > blinkygen.asm
sed -e 's/anonym/blinky/g' -e 's/ANONYM/BLINKY/g' -e 's/Anonym/Blinky/g' anonymvars.asm > blinkyvars.asm
sed -e 's/anonym/pinky/g' -e 's/ANONYM/PINKY/g' -e 's/Anonym/Pinky/g' anonym.asm > pinkygen.asm
sed -e 's/anonym/pinky/g' -e 's/ANONYM/PINKY/g' -e 's/Anonym/Pinky/g' anonymvars.asm > pinkyvars.asm
sed -e 's/anonym/inky/g' -e 's/ANONYM/INKY/g' -e 's/Anonym/Inky/g' anonym.asm > inkygen.asm
sed -e 's/anonym/inky/g' -e 's/ANONYM/INKY/g' -e 's/Anonym/Inky/g' anonymvars.asm > inkyvars.asm
sed -e 's/anonym/clyde/g' -e 's/ANONYM/CLYDE/g' -e 's/Anonym/Clyde/g' anonym.asm > clydegen.asm
sed -e 's/anonym/clyde/g' -e 's/ANONYM/CLYDE/g' -e 's/Anonym/Clyde/g' anonymvars.asm > clydevars.asm
xa pacman.asm -o pacman -l pacman.lst
cheat1=`grep cheat pacman.lst | awk '{ print $2 }' | awk -F, '{ print $1 }'`
cheat2=`echo $[$cheat1]`
echo "Cheat-Poke (Bit 0: Skip-Level, 1: No-Collision, 2: Infinite-Lives):" > cheat.txt
echo $cheat2 >> cheat.txt
