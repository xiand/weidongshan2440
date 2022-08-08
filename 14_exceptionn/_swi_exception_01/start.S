
.text
.global _start

_start:
	b reset      /*vector 0: reset*/
	ldr pc, und_addr    /*vector 4 : und*/
	ldr pc, swi_addr   /*vector  8 : swi*/

und_addr:
	.word do_und

swi_addr:
	.word do_swi

do_und:
	/*
	*ִ�е�����֮ǰ��
	*1.lr_und�����б��ж�ģʽ�е���һ������ִ�е�ָ��ĵ�ַ
	*2.SPSR_und�����б��ж�ģʽ��CPSR
	*3.CPSR�е�M4-M0������Ϊ11011�����뵽undģʽ
	*4.����0x4�ĵ�ִַ�г���
	*/

	/*sp_undδ���ã�������ջ*/
	ldr sp, =0x34000000

	/*��und�쳣�����������п��ܻ��޸�r0-r12�������ȱ���*/
	/*lr ���쳣�������ķ��ص�ַ��ҲҪ����*/
	stmdb sp!, {r0-r12, lr}

	/*�����ֳ�*/
	/*����und�쳣*/
	mrs r0, cpsr 
	ldr r1, =und_string
	bl printException

	/*�ָ��ֳ�*/
	ldmia sp!, {r0-r12, pc}^    /*^���SPSR��ֵ�ָ���cpsr��*/

und_string:
	.string "undefined instruction exception"	

.align 4

do_swi:
	/*ִ�е�����֮ǰ��
	*1.lr_svc�����б��ж�ģʽ�е���һ������ִ�е�ָ��ĵ�ַ
	*2.spsr_svc�����б��ж�ģʽ��CPSR
	*3.CPSR�е�M4-M0������Ϊ10011�����뵽svcģʽ
	*4.����0x08�ĵط�ִ�г���
	*/

	/*sp_svcδ���ã���������*/
	ldr sp, =0x33e00000

	/*��swi�쳣�����������п��ܻ��޸�r0-r12�������ȱ���*/
	/*lr���쳣���������ķ��ص�ַ��ҲҪ����*/
	stmdb sp!, {r0-r12, lr}

	/*�����ֳ�*/
	/*����swi�쳣*/
	mrs r0, cpsr
	ldr r1, =swi_string
	bl printException

	/*�ָ��ֳ�*/
	ldmia sp!, {r0-r12, pc}^  /*^���spsr��ֵ�ָ���cpsr��*/

swi_string:
	.string "swi exception"	

.align 4

reset:
	/* �رտ��Ź� */
	ldr r0, =0x53000000
	ldr r1, =0
	str r1, [r0]

	/* ����MPLL, FCLK : HCLK : PCLK = 400m : 100m : 50m */
	/* LOCKTIME(0x4C000000) = 0xFFFFFFFF */
	ldr r0, =0x4C000000
	ldr r1, =0xFFFFFFFF
	str r1, [r0]

	/* CLKDIVN(0x4C000014) = 0X5, tFCLK:tHCLK:tPCLK = 1:4:8  */
	ldr r0, =0x4C000014
	ldr r1, =0x5
	str r1, [r0]

	/* ����CPU�������첽ģʽ */
	mrc p15,0,r0,c1,c0,0
	orr r0,r0,#0xc0000000   //R1_nF:OR:R1_iA
	mcr p15,0,r0,c1,c0,0

	/* ����MPLLCON(0x4C000004) = (92<<12)|(1<<4)|(1<<0) 
	 *  m = MDIV+8 = 92+8=100
	 *  p = PDIV+2 = 1+2 = 3
	 *  s = SDIV = 1
	 *  FCLK = 2*m*Fin/(p*2^s) = 2*100*12/(3*2^1)=400M
	 */
	ldr r0, =0x4C000004
	ldr r1, =(92<<12)|(1<<4)|(1<<0)
	str r1, [r0]

	/* һ������PLL, �ͻ�����lock timeֱ��PLL����ȶ�
	 * Ȼ��CPU�������µ�Ƶ��FCLK
	 */
	
	

	/* �����ڴ�: sp ջ */
	/* �ֱ���nor/nand����
	 * д0��0��ַ, �ٶ�����
	 * ����õ�0, ��ʾ0��ַ�ϵ����ݱ��޸���, ����Ӧram, �����nand����
	 * �������nor����
	 */
	mov r1, #0
	ldr r0, [r1] /* ����ԭ����ֵ���� */
	str r1, [r1] /* 0->[0] */ 
	ldr r2, [r1] /* r2=[0] */
	cmp r1, r2   /* r1==r2? �����ȱ�ʾ��NAND���� */
	ldr sp, =0x40000000+4096 /* �ȼ�����nor���� */
	moveq sp, #4096  /* nand���� */
	streq r0, [r1]   /* �ָ�ԭ����ֵ */
	
	bl sdram_init


	/*�ض�λtext�� rodata�Σ�data����������*/
	//mov r1, #0 
	//ldr r2, =_start   /*��һ��ָ�������ʱ�ĵ�ַ/
	//ldr r3, =__bss_start   /*bss�ε���ʼ��ַ*/


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




	/*���bss��*/
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

	/* ��λ֮��cpu����svcģʽ
	*���ڣ���Ҫ�л���usrģʽ
	*/
	mrs r0, cpsr   /*���� cpsr*/
	bic r0, r0, #0xf /*�޸�M4-M0λ 0b10000������usrģʽ*/
	msr cpsr, r0

	/*���� sp_usr*/
	ldr sp, =0x33f00000

	ldr pc, =sdram

sdram:
	bl uart0_init

	bl print1
	/*�������һ��δ����ָ��*/
und_code:
	.word 0xdeadc0de    /*δ����ָ��*/
	bl print2

	//bl main
	ldr pc, =main

halt:
	b halt
	