
ASM = asm

monrom.ssd:
	cd src ; beebasm -i monitor.asm -v -d -do ../monrom.ssd ; cd ..

clean:
	rm monrom
	rm monrom.ssd

all: monrom.ssd

.PHONY: all clean monrom.ssd
