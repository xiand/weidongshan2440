
#include "s3c2440_soc.h"
#include "uart.h"
#include "init.h"

char g_Char = 'A';
char g_Char3 = 'a';
const char g_Char2 = 'B';
int g_A = 0;
int g_B;

int main(void)
{
	// extern int __code_start, __bss_start;
	// uart0_init();

	puts("\n\rg_A = ");
	printHex(g_A);
	puts("\n\r");

	// puts("\n\__code_start = ");
	// printHex(__code_start);

	// printHex(&__code_start);
	// puts("\n\r");

	// puts("\n\__bss_start = ");
	// printHex(__bss_start);
	// printHex(&__bss_start);
	// puts("\n\r");
	
	
	while (1)
	{
		putchar(g_Char);
		g_Char++;         /* nor启动时, 此代码无效 */

		putchar(g_Char3);
		g_Char3++;         /* nor启动时, 此代码无效 */
		delay(1000000);
	}

	
	return 0;
}



