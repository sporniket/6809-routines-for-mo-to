# Copy memory to memory

The goal is to copy a sizeable area of memory to another location in memory.

* The routine handles edge cases like memory overlap to perform the copy in the right order.
* The routine does not use stack blasting, to be suitable for the general use case.
* The routine MUST check that it does not write beyond address $ffff and below address $0
* The routine MUST check that it does not read beyond address $ffff and below address $0

## Status

The variant for small copies (up to 256 bytes), copying bytes starting from the lowest address 
to the highest, is written. It has yet to be tested.

To note : the check of the addresses have been done for the write address only.

TODO : 
* Check the read address to find the final range of the possible copy.
* Write the variant that copies starting from the highest address down to the lowest
* Write the wrappers of the forward/backward allowing to copy more than 256 bytes
* Write the final wrapper that is trully the general purpose memcpy
