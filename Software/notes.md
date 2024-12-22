
# instructions

consider adding a set of jump instructions that is relative to PC, rather than just an immediate address. This would allow for programs to be dynamically ran out of ram, or even the stack.

Need to finish test coverage of all the instructions and corner cases

# math

finish corner case testing of existing math functions

sine CORDIC needs more testing. I am not sure it is always converging correctly. Consider caching the sine/cosine outputs in the future if desired - or maybe just return both always?

sqrt and ln are broken due to some change in the offset addressing. consider ditching the LUT approach and just write a hyperbolic CORDIC implementation.

# file system

consider a FAT16 FS implementation on SD card. This would be simple on SPI bus. James has a video on it.