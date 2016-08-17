/* Procedural Version */
"use strict"; // Idiotic JavaScript design requires kludge for type safety

/*
To run from the command line:

    node rpm_proc [-v] [# [#]]

Legend:
   []  Paramater is optional
   -v  Turn on verbose output
   #   Number

Requires: node.js
*/

var LOG  = 0; // Verbose logging
var BASE = 10;

var defaultA = "86";
var defaultB = "57";


// --------------------------------------------------------------------------------

// BCD Utility Functions

/** lhs += rhs
  */
// ========================================================================
function Add2( lhs, rhs )
{
    var n     = lhs.length;
    var carry = 0;
    var sum   = 0;

    for( var i = 0; i < n; ++i )
    {
        sum   = lhs[i] + rhs[i] + carry;
        carry = (sum >= BASE) | 0;

        if (sum >= BASE)
            sum -= BASE;

        lhs[ i ] = sum;
    }
}


/** Print array BCD digits
  * Stored little endian: LSB[0] MSB[n]
  */
// ========================================================================
function Dump( array, prefix )
{
    var n    = array.length;
    var text = prefix ? prefix : "";

    for( var i = n - 1; i >= 0; --i )
        text += array[ i ];

    console.log( text );
}


/** Convert string to BCD array, aka, atoi()
    Remaining digits are zero filled
  * @param {Number[]} array
  * @param {String}   text
  */
// ========================================================================
function Fill( array, text )
{
    var i;
    var n = array.length;
    var m = text.length;
    var v;

    // Extra error checking would verify m > n

    // Set all digits from string -- set in reverse order
    for( i = 0; i < m; ++i )
        array[ (m-1) - i ] = text.charCodeAt( i ) - 48;

    // Set remaining digits to zero
    for( ; i < n; ++i )
        array[ i ] = 0;
}


// ========================================================================
function isOdd( array )
{
    return array[0] & 1 ? true : false;
}


// ========================================================================
function isZero( array )
{
    var i;
    var n    = array.length;
    var zero = true; // default to all zeroes until we find otherwise

    for( i = 0; i < n; ++i )
        zero &= (array[i] == 0);

    return zero;
}


// Print array digits in reverse
// ========================================================================
function Print( array, prefix )
{
    var i;
    var n    = array.length;
    var text = prefix ? prefix : "";
    var zero = true; // assume leading zero -> skip digit

    for( i = n - 1; i >= 0; --i )
    {
        zero &= (array[ i ] == 0);
        if( !zero )
            text += array[ i ];
    }

    console.log( text );
}


// ========================================================================
function Shl1( array )
{
    var i;
    var n     = array.length;
    var carry = 0;
    var sum   = 0;

    for( i = 0; i < n; ++i )
    {
        sum   = array[ i ]*2 + carry;
        carry = (sum >= BASE) | 0;

        if (sum >= BASE)
            sum -= BASE;

        array[ i ] = sum;
    }
}


// ========================================================================
function Shr1( array )
{
    var i;
    var n     = array.length;
    var carry = 0;
    var q     = 0;
    var div   = 0;
    var rem   = 0;

    for( i = n-1; i >= 0; --i )
    {
        div      = array[ i ] + carry; // dividend
        q        = (div / 2) | 0; // 2 is divisor
        array[i] = q;
        rem      = div - q*2; // 2 is divisor
        carry    = rem * BASE;
    }
}


// --------------------------------------------------------------------------------


/** Russian Peasant Multiplication with native integers
  * @param {Number} a
  * @param {Number} b
  */
// ========================================================================
function RPM( x, y )
{
    var a   = x; // Javascript has no native unsigned 32-bit nor 64-bit integers
    var b   = y; // ctypes.UInt64() is only Firefox "extension"
    var sum = 0;

    while( b )
    {
        if (b & 1)
            sum += a;

if(LOG) console.log( "A: " + a + ", B: " + b + ", Sum: " + sum );
        if (a < 0)
            return console.log( "ERROR: 31-bit integer overflow. Number too large after shifting left: " + x );

        a <<= 1;
        b >>= 1;
    }

    console.log( x + " x " + y + " = " + sum );
}


/** Russian Peasant Multiplication with strings
  * @param {String} a
  * @param {String} b
  */
// ========================================================================
function RPM_String( a, b )
{
    var n = a.length; // i.e. 32-bit,                     e.g. 999
    var m = b.length; // i.e. 32-bit                      e.g. 999
    var s = n + m   ; // i.e  32-bit * 32b-bit = 64-bit   e.g. 998001

    var digitsA = new Array( s );
    var digitsB = new Array( s );
    var digitsS = new Array( s );

    Fill( digitsA,  a  );
    Fill( digitsB,  b  );
    Fill( digitsS, "0" );

    while( true )
    {
        var done = isZero( digitsB );
        if( done )
            break;

        var odd = isOdd( digitsB );
        if( odd )
            Add2( digitsS, digitsA ); // S += A

if(LOG) Dump( digitsA, " A =  " );
        Shl1( digitsA );              // A <<= 1
if(LOG) Dump( digitsA, " A << " );
if(LOG) Dump( digitsB, " B =  " );
        Shr1( digitsB );              // B >>= 1
if(LOG) Dump( digitsB, " B >> " );
if(LOG) Dump( digitsS, "Sum:  " );
    }
    Print( digitsS );
}


// ========================================================================
function main()
{
    var args  = process.argv.slice( process.execArgv.length + 2 );
    var param = 0;

    if (args[0] === '-v')
    {
        LOG = 1;
        param++; // skip switches to first paramater
    }

    var params = [];
    params.push( (args[param+0] === undefined) ? defaultA : args[param+0] );
    params.push( (args[param+1] === undefined) ? defaultB : args[param+1] );

    console.log( "= Integer = " );
    RPM( params[0] | 0, params[1] | 0);
    console.log( "\n" );

    console.log( "= BCD String =" );
    RPM_String( params[0], params[1] );
    console.log( "\n" );
}

main();

