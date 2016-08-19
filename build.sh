#!/bin/bash

src2dsk    rpm_ca65.s
merlin32   rpm_m32.s

cp         rpm_ca65.bin          disk/rpm_ca65.bin
cp         rpm_m32               disk/rpm_m32.bin

cp         blank_prontodos.dsk rpm.dsk
#a2rm      rpm.dsk RPM.BIN
#a2rm      rpm.dsk RPM.CA65.BIN
#a2rm      rpm.dsk RPM.M32.BIN

a2in  -r a rpm.dsk HELLO         disk/hello.bas.raw
a2in  -r a rpm.dsk RPM.BAS       disk/rpm.bas.raw
a2in  -r a rpm.dsk RPM.DEBUG.BAS disk/rpm.debug.bas.raw
#a2in -r b rpm.dsk RPM.CA65.BIN  disk/rpm_ca65.bin
#a2in -r b rpm.dsk RPM.M32.BIN   disk/rpm_m32.bin
a2in  -r b rpm.dsk RPM.BIN       disk/rpm_m32.bin
