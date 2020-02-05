# Russian Peasant Multiplication

From Assembly to Basic to C to Javascript!

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

# Algorithm

1. Initialize sum <- ZERO.
2. IF b is ZERO then STOP.
3. IF b is ODD then ADD a to sum.
4. MULTIPLY a by 2. That is, shift a **left** once.
5. DIVIDE b by 2. That is, shift b **right** once.
6. GOTO step 2

Paste the following program into an [online C compiler](https://www.onlinegdb.com/online_c_compiler)

```c
#include <stdio.h>

int RPM( int a, int b )
{
    int sum = 0;

    while( b )
    {
        if( b & 1 )
            sum += a;

        a <<= 1;
        b >>= 1;
    }

    return sum;
}

int main()
{
    return printf( "%d\n", RPM( 86, 57 ) );
}
```

# Examples

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
      x 00111001  (57) -+
        --------        V
        01010110  (86 * 1*2^0 =   86)
       00000000   (86 * 0*2^1 =  172) <- wasted work, partial sum = 0
      00000000    (86 * 0*2^2 =  344) <- wasted work, partial sum = 0
     01010110     (86 * 1*2^3 =  688)
    01010110      (86 * 1*2^4 = 1376)
   01010110       (86 * 1*2^5 = 2752)
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
               A          B   B Odd?   Sum = 0
        01010110   00111001   Yes      + A = 00000001010110
       010101100   00011100   No           = 00000001010110
      0101011000   00001110   No           = 00000001010110
     01010110000   00000111   Yes      + A = 00001100000110
    010101100000   00000011   Yes      + A = 00100001100110
   0101011000000   00000001   Yes      + A = 01001100100110
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

# Bases

Does this algorithm work in other bases such as 2, 8, or 16?

Consider the question:

Q. Does multipling by 2 work in other bases?

A. Yes.

Q. Why?

A. When we write a number in a different base we have the _same_ **representation** but a _different_ **presentation.**

Adding, subtracting, multiplying, dividing all _function_ the same _regardless_ of which base we use.

This is the _exact_ same reason that 0.999999... = 1.0. The exact same _represented_ number is _presented_ differently -- which
 confuses the uninformed.  It is a "Mathematical illusion."

Proof:

```
       1 = 1                Tautology
     1/3 = 1/3              Divide by sides by 3
 3 * 1/3 = 3 * 1/3          Multiply by sides by 3
 3 * 1/3 = 3 * 0.333333...  Express integer fraction in decimal
     1   = 3 * 0.333333...  Simply left side (fractions cancel)
     1   =     0.999999...  Simply right side
```

QED.

# Efficiency

For a "BigInt" or "BigNumber" library this _is NOT_ the most efficient (\*) way to
 multiply numbers as it doesn't scale (\*\*).  However, it is rather trivial to implement. You only need a few
 functions:

* `isEven()`
* `isZero()`
* `Shl()`
* `Shr()`
* `AddTo()`

Notes:

(\*) Almost everyone uses FFT (Fast Fourier Transforms), Toom, and/or Karatsuba for multiplication. For example [GMP](https://gmplib.org/manual/), GNU Multiple Precision arithmetic library, uses **[seven](https://gmplib.org/manual/Multiplication-Algorithms.html#Multiplication-Algorithms)** different multiplication algorithms!

* Basecase
* Karatsuba
* Toom-3
* Toom-4
* Toom-6.5
* Toom-8.5
* FFT

(\*\*) What do we mean by "Doesn't scale"?  As the input numbers uses more bits we end up doing more work other other algorithms.

# References

* https://tspiteri.gitlab.io/gmp-mpfr-sys/gmp/Algorithms.html#Multiplication-Algorithms
* https://en.wikipedia.org/wiki/Multiplication_algorithm
* Multiplication is associative
* Multiplication is commutative
* https://en.wikipedia.org/wiki/Order_of_operations
