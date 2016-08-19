# Russian Peasant Multiplication

From Assembly to Basic to Javascript. Here is an implementation of Russian Peasant Multiplication implemented in various languages:

* 6502 Assembly Language (Both ca65 and merlin32 sources)
* Applesoft BASIC
* JavaScript (Procedural version)
* JavaScript (OOP version)

An .dsk image has been provided as an convenience.

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

