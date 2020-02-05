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

