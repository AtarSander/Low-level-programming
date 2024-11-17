all: barcode128.o main.o main
main: main.o barcode128.o
	gcc -m32 -no-pie -g -o main main.o barcode128.o


main.o: barcode128.asm main.c
	gcc -m32 -no-pie -c -g -O0 -std=c99 main.c -o main.o


barcode128.o: barcode128.asm
	nasm -f elf -g -l barcode128.lst -o barcode128.o barcode128.asm

clean:
	rm -f main *.o