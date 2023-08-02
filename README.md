# Atari Assembly Tutorial
This repo contains the code for the 
[6502 Assembly Course](https://www.udemy.com/course/programming-games-for-the-atari-2600/)
from Udemy, taught by Gustavo Pezzi. 


## Dependencies
- Stella VCS Emulator
- dasm 6502 macroassembler
- GNU Make
- Some kind of POSIX Shell (Bash would work fine)

The two header files come from the dasm project itself (with all relevant credit 
due, of course).


## Building
Run `make` in the root of the repo


## Running
Run `stella -fullscreen 0 target/<name>.bin`

Hint: Try this on pride.bin first! ;)


## Cleanup
Run `make clean` to delete all the binaries in the "target" folder. This might
seem wasteful, but they're so small and assemble so quickly it really doesn't
matter. ¯\\_(ツ)_/¯


## TODO
1. Finish the class
2. Use this as a testbed for github actions and see if I can get that to play
   nice 👀
