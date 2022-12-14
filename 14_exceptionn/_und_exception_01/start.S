
.text
.global _start

_start:
	b reset      /*vector 0: reset*/
	b do_und     /*vector 4 : und*/

do_und:
	/*
	*执行到这里之前：
	*1.lr_und保存有被中断模式中的下一条即将执行的指令的地址
	*2.SPSR_und保存有被中断模式的CPSR
	*3.CPSR中的M4-M0被设置为11011，进入到und模式
	*4.跳到0x4的地址执行程序
	*/

	/*sp_und未设置，先设置栈*/
	ldr sp, =0x34000000

	/*在und异常处理函数中有可能会修改r0-r12，所有先保存*/
	/*lr 是异常处理完后的返回地址，也要保存*/
	stmdb sp!, {r0-r12, lr}

	/*保存现场*/
	/*处理und异常*/
	mrs r0, cpsr 
	ldr r1, =und_string
	bl printException

	/*恢复现场*/
	ldmia sp!, {r0-r12, pc}^    /*^会把SPSR的值恢复到cpsr中*/

und_string:
	.string "undefined instruction exception"	

reset:
	/* 关闭看门狗 */
	ldr r0, =0x53000000
	ldr r1, =0
	str r1, [r0]

	/* 设置MPLL, FCLK : HCLK : PCLK = 400m : 100m : 50m */
	/* LOCKTIME(0x4C000000) = 0xFFFFFFFF */
	ldr r0, =0x4C000000
	ldr r1, =0xFFFFFFFF
	str r1, [r0]

	/* CLKDIVN(0x4C000014) = 0X5, tFCLK:tHCLK:tPCLK = 1:4:8  */
	ldr r0, =0x4C000014
	ldr r1, =0x5
	str r1, [r0]

	/* 设置CPU工作于异步模式 */
	mrc p15,0,r0,c1,c0,0
	orr r0,r0,#0xc0000000   //R1_nF:OR:R1_iA
	mcr p15,0,r0,c1,c0,0

	/* 设置MPLLCON(0x4C000004) = (92<<12)|(1<<4)|(1<<0) 
	 *  m = MDIV+8 = 92+8=100
	 *  p = PDIV+2 = 1+2 = 3
	 *  s = SDIV = 1
	 *  FCLK = 2*m*Fin/(p*2^s) = 2*100*12/(3*2^1)=400M
	 */
	ldr r0, =0x4C000004
	ldr r1, =(92<<12)|(1<<4)|(1<<0)
	str r1, [r0]

	/* 一旦设置PLL, 就会锁定lock time直到PLL输出稳定
	 * 然后CPU工作于新的频率FCLK
	 */
	
	

	/* 设置内存: sp 栈 */
	/* 分辨是nor/nand启动
	 * 写0到0地址, 再读出来
	 * 如果得到0, 表示0地址上的内容被修改了, 它对应ram, 这就是nand启动
	 * 否则就是nor启动
	 */
	mov r1, #0
	ldr r0, [r1] /* 读出原来的值备份 */
	str r1, [r1] /* 0->[0] */ 
	ldr r2, [r1] /* r2=[0] */
	cmp r1, r2   /* r1==r2? 如果相等表示是NAND启动 */
	ldr sp, =0x40000000+4096 /* 先假设是nor启动 */
	moveq sp, #4096  /* nand启动 */
	streq r0, [r1]   /* 恢复原来的值 */
	
	bl sdram_init


	/*重定位text段 rodata段，data段整个程序*/
	//mov r1, #0 
	//ldr r2, =_start   /*第一条指令的运行时的地址/
	//ldr r3, =__bss_start   /*bss段的起始地址*/


//cpy:
//	ldr r4, [r1]
//	str r4, [r2]
//	add r1, r1, #4
//	add r2, r2, #4
//	cmp r2, r3
//	ble cpy

	//mov r0, #0
	//ldr r1, = _start
	//ldr r2, = __bss_start
	//sub r2, r2, r1

	bl copy2sdram /*src dest len*/




	/*清楚bss段*/
//	ldr r1, =__bss_start
//	ldr r2, =_end
//	mov r3, #0

	
//clean:
//	str r3, [r1]
//	add r1, r1, #4
//	cmp r1, r2
//	ble clean

	//ldr r0, =__bss_start
	//ldr r1, =_end
	bl clean_bss /*start ,end addr*/


	bl uart0_init
	bl print1
	/*故意加入一条未定义指令*/
und_code:
	.word 0xdeadc0de    /*未定义指令*/
	bl print2

	//bl main
	ldr pc, =main

halt:
	b halt
	
