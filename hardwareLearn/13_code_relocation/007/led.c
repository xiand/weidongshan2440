#include "s3c2440_soc.h"

void delay(volatile int d)
{
    while(d--);
}

int led_test(void)
{
    int val = 0;    
    int tmp;

    GPFCON &= ~((3<<8) | (3<<10) | (3<<12));
    GPFCON |= ((1<<8) | (1<<10) | (1<<12));

    while(1)
    {
        tmp = ~val;
        tmp &= 7;

        GPFCON &= ~(7<<4);
        GPFCON |= (tmp<<4);
        delay(100000);
        val++;
        if(val == 8)
            val = 0;
    }
}

