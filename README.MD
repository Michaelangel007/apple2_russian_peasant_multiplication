# Russian Peasant Multiplication

From Assembly to Basic to Javascript.

Here are muy implementations of Russian Peasant Multiplication implemented in various languages:

* 6502 Assembly Language (Both ca65 and merlin32 sources)
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

An alternative algorith to implement multiplication using only:

* bit-shift (left and right), and
* addition.

Example of "normal" multiplication:

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

        01010110  (86)
        00111001  (57)
        --------
        01010110  (86 * 2^0 =   86)
       00000000   (86 * 2^1 =  172)
      00000000    (86 * 2^2 =  344)
     01010110     (86 * 2^3 =  688)
    01010110      (86 * 2^4 = 1376)
   01010110       (86 * 2^5 = 2752)
  ==============
  01001100100110  (4902 = 86*2^0 + 86*2^3 + 86*2^4 + 86*2^5)

Example of Russian Peasant multiplication:

In Base 10:

```
               A   B  Sum
              86  57    86
             172  28    86
             344  14    86
             688   7   774
            1376   3  2150
            2752   1  4902

```

In Base 2:

```
               A  B         Sum            Sum  = 0
        01010110  00111001  00000001010110 Sum += A
       010101100  00011100  00000001010110 --
      0101011000  00001110  00000001010110 --
     01010110000  00000111  00001100000110 Sum += A
    010101100000  00000011  00100001100110 Sum += A
   0101011000000  00000001  01001100100110 Sum += A
```
