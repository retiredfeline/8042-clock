#
# Uses GNU make for pattern substitution
#
# The primary target will use both assemblers and compare the results
# but if you just use one assembler change the target to
# clock.bin, clock.ihx or clock.ibn
#

default:	compare

compare:	clock.bin clock.ibn clock.zbn
		cmp clock.bin clock.zbn

%.bin:		%.asm
		asm48 -t -s $(<:.asm=.sym) $<

%.hex:		%.asm
		asm48 -f hex $<

%.ihx:		%.asm
		as8048 -l -o $<
		aslink -i -o $(<:.asm=.rel)

%.zbn:		%.ihx
		hex2bin -e zbn -p 00 $<

%.ibn:		%.ihx
		hex2bin -e ibn $<

clean:
		rm -f *.sym *.lst *.rel *.hlr *.bin *.ihx *.ibn *.zbn
