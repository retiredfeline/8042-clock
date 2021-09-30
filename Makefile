#
# Uses GNU make for pattern substitution
#
# The primary target will use both assemblers and compare the results
# but if you just use one assembler change the target to
# clock.abn, clock.ihx, clock.ibn or clock.rom
#
FIRMWARE_END=0x3FF

default:	clock.rom

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

# generate rom from ibn by adding checksum at end
%.rom:		%.ibn
		srec_cat $< -binary -crop 0 $(FIRMWARE_END) -fill 0xFF 0 $(FIRMWARE_END) -checksum-neg-b-e $(FIRMWARE_END) 1 1 -o $(<:.ibn=.rom) -binary

# this one is to compare
%.zbn:		%.ihx
		hex2bin -e zbn -p 00 $<

%.abn:		%.asm
		asm48 -t -o $(<:.asm=.abn) -s $(<:.asm=.sym) $<

clean:
		rm -f *.sym *.lst *.rel *.hlr *.ihx *.zbn *.abn
