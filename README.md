# 6809-routines-for-mo-to

A collection of routines in assembly 6809 for a family of french made computers from the 1980 era, the Thomson MO5. I also own a TO8, so at some point, it will be a target too.

In order to learn 6809, I started to write some routines, and then I needed to goes beyond [an online emulation sandbox of that CPU](https://6809.uk).

So the goal is to put each routine inside an image disk, with a BASIC loader that would serve as demo/test program.

## Creation of a floppy disk image

The process would be the following, for each routine : 
* Starting from a bootable DOS disk as reference image, duplicate that image.
* A loader written in BASIC, that also serves as a demo/test suite program, automatically starts
* The program load the routine at a predetermined location in memory, setup data in memory, then call the routines
* That’s all.

### The reference bootable DOS disk

See [the dedicated page on dcmoto.free.fr](http://dcmoto.free.fr/programmes/dos-3.5/index.html)

### The loader

Follows some principles seen on a forum post. 

The loader reserve memory starting from 0x5C00, load a few binary modules (most likely the routine to test, and some complimentary data).

Then for each demo/test calls, it sets up some values using `POKE`, computes the execution point of the routine, and calls it with `EXEC`.

**Sample auto.bat**, found there : https://forum.system-cfg.com/viewtopic.php?p=99363#p99363

```basic
===========================
AUTO.BAT
===========================
10 CLEAR,&H5BFF
20 LOCATE0,0,0
40 LOADM"MYROUTIN"
50 LOADM"MYDATA"
60 EXEC&H9F80
```

### Memory organisation

The module being loaded at address `X`, let the first 256 bytes (from `X` to `X+255` included) be an exchange buffer, and the routines starts at `X+256`.

Ideas to implement : 
| Offset from X| Size | Content|
|---|---|---|
|0|2|number of routines (up to 16)|
|2|4|jmp to the first routine|
|6|4|jmp to the second routine|
|10|4|jmp to the third routine|
|...|...|...|
|62|4|jmp to the sixteenth routine|
|66|190|data|

Most likely, the first data would be data for CPU registers, in the order suitable for pulu : a,b,x,y.

## Licence

GPL 3 or later

## Requirement

The makefiles uses the spasm toolbox, and thus require that toolbox to be installed. This require to install the suitable version of python.