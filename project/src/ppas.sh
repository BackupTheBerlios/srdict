#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
echo Linking gsrdict
/usr/bin/ld  -dynamic-linker=/lib/ld-linux.so.2  -s -L. -o gsrdict link.res
if [ $? != 0 ]; then DoExitLink gsrdict; fi
