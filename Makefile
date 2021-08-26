#
# Uses GNU make for pattern substitution
#
# The primary target will use both assemblers and compare the results
# but if you just use one assembler change the target to
# clock.abn, clock.ihx or clock.ibn
#

default:	compare

compare:	clock.ibn clock.zbn clock.abn
		cmp clock.abn clock.zbn

# assemble with as8048
%.ihx:		%.asm
		as8048 -l -o $<
		aslink -i -o $(<:.asm=.rel)

# assemble with asm48
%.hex:		%.asm
		asm48 -f hex $<

# this is the one we use
%.ibn:		%.ihx
		hex2bin -e ibn $<

# this one is to compare
%.zbn:		%.ihx
		hex2bin -e zbn -p 00 $<

%.abn:		%.asm
		asm48 -t -o $(<:.asm=.abn) -s $(<:.asm=.sym) $<

clean:
		rm -f *.sym *.lst *.rel *.hlr *.ihx *.zbn *.abn
