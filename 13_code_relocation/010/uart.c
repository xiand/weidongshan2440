#include "s3c2440_soc.h"

void uart0_init(void)
{
    GPHCON &= ~((3<<4) | (3<<6));
    GPHCON |= ((2<<4) | (2<<6));

    GPHUP &= ~((1<<2) | (1<<3));

    //设置波特率
    /*
        UBRDIVn = (int)(UART clock / (buad rate 乘 16)) - 1
        UART clock = 50M
        UBRDIVn = (int)(50000000 / (115200 × 16)) - 1 = 26

    */
    UCON0 = 0x00000005;    //PCLK 中断/查询模式
    UBRDIV0 = 26;

    //设置数据格式
    ULCON0 = 0x00000003;  //8n1:8个数据位，无校验位，1个停止位
}

int putchar(int c)
{
    /* UTRSTAT0 */
	/* UTXH0 */
    while(!(UTRSTAT0 & (1<<2)));
    UTXH0 = (unsigned char)c;
}

int getchar(void)
{
    while(!(UTRSTAT0 & (1<<0)))
    return URXH0;
}

int puts(const char *s)
{
    while(*s)
    {
        putchar(*s);
        s++;
    }
}

//0xABCDEF12
void printHex(unsigned int val)
{
    int i ;
    unsigned char arr[8];
    
    //先取出每一位的值
    for(i = 0; i < 8; i++)
    {
        arr[i] = val & 0xf;
        val >>= 4;
    }
    //打印
    puts("0x");
    for(i = 7; i >= 0; i--)
    {
        if(arr[i] >= 0 && arr[i] <= 9)
        {
            putchar(arr[i] + '0');

        }
        else if(arr[i] >= 0xA && arr[i] <= 0xF)
        {
            putchar(arr[i] - 0xA + 'A');
        }
    }
}
