all: mif_program.exe
	echo All done


vpath %.h inc

mif_program.exe: mif_program.o
	gcc -o $@ $<

mif_program.o: mif_program.s
	gcc -c $<

mif_program.s: mif_program.i
	gcc -S $<

mif_program.i: mif_program.c
	cpp $< mif_program.i

clean:
	rm mif_program.exe mif_program.o mif_program.s mif_program.i

