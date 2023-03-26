gcc -Wall -c utils.c
gcc -Wall -c level.c
gcc -Wall -c move.c
gcc -Wall loderun.c -o loderunner move.o level.o utils.o -lncurses
rm -f utils.o level.o move.o
