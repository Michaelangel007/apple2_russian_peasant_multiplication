# Russian Peasant Multiplication

From Assembly to Basic to Javascript!

Here are my implementations of Russian Peasant Multiplication implemented in various languages:

* 6502 Assembly Language (Both [ca65](rpm_ca65.s) and [merlin32](rpm_m32.s) sources)
* Applesoft BASIC
* JavaScript (Procedural version)
* JavaScript (OOP version)

A .dsk image has been provided as an convenience.

To see how much faster the Assembly version is then the BASIC version:

```
RUN  RPM.BAS
BRUN RPM.BIN
```

And enter in `123456789` * `987654321` respectively for A and B ...

| Version   | Time |
|:----------|:-----|
| Applesoft | 33 s |
| Assembly  | ~1 s |

# So what the heck is it?

An alternative algorithm to implement multiplication using only:

* bit-shifts (left and right), and
* addition.

Example of "traditional" multiplication:

In base 10:

```
             86
           x 57
           ----
            602
           430
           ====
           4902
```

In base 2:

```
        01010110  (86)
        00111001  (57)
        --------
        01010110  (86 * 2^0 =   86)
       00000000   (86 * 2^1 =  172) <- wasted work, partial sum = 0
      00000000    (86 * 2^2 =  344) <- wasted work, partial sum = 0
     01010110     (86 * 2^3 =  688)
    01010110      (86 * 2^4 = 1376)
   01010110       (86 * 2^5 = 2752)
  ==============
  01001100100110  (4902 = 86*2^0 + 86*2^3 + 86*2^4 + 86*2^5)
```

Example of Russian Peasant multiplication:

In Base 10:

```
               A          B   B Odd?   Sum =    0
              86         57   Yes      + A =   86
      x 2 =  172   / 2 = 28   No           =   86
      x 2 =  344   / 2 = 14   No           =   86
      x 2 =  688   / 2 =  7   Yes      + A =  774
      x 2 = 1376   / 2 =  3   Yes      + A = 2150
      x 2 = 2752   / 2 =  1   Yes      + A = 4902
```

In Base 2:

```
               A          B   Sum = 0
        01010110   00111001   + A = 00000001010110 (b is odd)
       010101100   00011100       = 00000001010110
      0101011000   00001110       = 00000001010110
     01010110000   00000111   + A = 00001100000110 (b is odd)
    010101100000   00000011   + A = 00100001100110 (b is odd)
   0101011000000   00000001   + A = 01001100100110 (b is odd)
```

In Base 8:

```
                A          B   B Odd?   Sum =     0
              126         71   Yes      + A =   126
       x 2 =  254   / 2 = 34   No           =   126
       x 2 =  530   / 2 = 16   No           =   126
       x 2 = 1260   / 2 =  7   Yes      + A =  1406
       x 2 = 2540   / 2 =  3   Yes      + A =  4146
       x 2 = 5300   / 2 =  1   Yes      + A = 11446
```

In Base 16:

```
               A          B   B Odd?   Sum =    0
              56         39   Yes      + A =   56
       x 2 =  AC   / 2 = 1C   No           =   56
       x 2 = 158   / 2 =  E   No           =   56
       x 2 = 2B0   / 2 =  7   Yes      + A =  306
       x 2 = 560   / 2 =  3   Yes      + A =  866
       x 2 = AC0   / 2 =  1   Yes      + A = 1326
```

Algorithm:

1. Initialize Sum <- zero
2. If B is odd then add A to Sum.  In C nomenclature:   `Sum += A;`
3. Multiply A by 2 -- that is, Shift A **left** by one.  In C nomenclature: `A <<= 1;`
4. Divide B by 2 -- that is, Shift B **right** by one. In C nomenclature:   ` B >>= 1;`
5. If B is zero then STOP
6. Goto step 2

For a "BigInt" or "BigNumber" library this _isn't_ the most efficient way to
 multiply numbers but it is rather trivial to implement. You only need a few
 functions:

* `isEven()`
* `isZero()`
* `Shl()`
* `Shr()`
* `AddTo()`

