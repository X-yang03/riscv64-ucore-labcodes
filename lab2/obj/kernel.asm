
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	43260613          	addi	a2,a2,1074 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	1a3010ef          	jal	ra,ffffffffc02019f0 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	9b250513          	addi	a0,a0,-1614 # ffffffffc0201a08 <etext+0x6>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	25e010ef          	jal	ra,ffffffffc02012c8 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	438010ef          	jal	ra,ffffffffc02014e2 <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	404010ef          	jal	ra,ffffffffc02014e2 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200140:	00002517          	auipc	a0,0x2
ffffffffc0200144:	91850513          	addi	a0,a0,-1768 # ffffffffc0201a58 <etext+0x56>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00002517          	auipc	a0,0x2
ffffffffc020015a:	92250513          	addi	a0,a0,-1758 # ffffffffc0201a78 <etext+0x76>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00002597          	auipc	a1,0x2
ffffffffc0200166:	8a058593          	addi	a1,a1,-1888 # ffffffffc0201a02 <etext>
ffffffffc020016a:	00002517          	auipc	a0,0x2
ffffffffc020016e:	92e50513          	addi	a0,a0,-1746 # ffffffffc0201a98 <etext+0x96>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00002517          	auipc	a0,0x2
ffffffffc0200182:	93a50513          	addi	a0,a0,-1734 # ffffffffc0201ab8 <etext+0xb6>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	2e658593          	addi	a1,a1,742 # ffffffffc0206470 <end>
ffffffffc0200192:	00002517          	auipc	a0,0x2
ffffffffc0200196:	94650513          	addi	a0,a0,-1722 # ffffffffc0201ad8 <etext+0xd6>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00006597          	auipc	a1,0x6
ffffffffc02001a2:	6d158593          	addi	a1,a1,1745 # ffffffffc020686f <end+0x3ff>
ffffffffc02001a6:	00000797          	auipc	a5,0x0
ffffffffc02001aa:	e9078793          	addi	a5,a5,-368 # ffffffffc0200036 <kern_init>
ffffffffc02001ae:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001bc:	95be                	add	a1,a1,a5
ffffffffc02001be:	85a9                	srai	a1,a1,0xa
ffffffffc02001c0:	00002517          	auipc	a0,0x2
ffffffffc02001c4:	93850513          	addi	a0,a0,-1736 # ffffffffc0201af8 <etext+0xf6>
}
ffffffffc02001c8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ca:	eedff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ce <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ce:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d0:	00002617          	auipc	a2,0x2
ffffffffc02001d4:	85860613          	addi	a2,a2,-1960 # ffffffffc0201a28 <etext+0x26>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00002517          	auipc	a0,0x2
ffffffffc02001e0:	86450513          	addi	a0,a0,-1948 # ffffffffc0201a40 <etext+0x3e>
void print_stackframe(void) {
ffffffffc02001e4:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e6:	1c6000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001ea <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ea:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ec:	00002617          	auipc	a2,0x2
ffffffffc02001f0:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0201c08 <commands+0xe0>
ffffffffc02001f4:	00002597          	auipc	a1,0x2
ffffffffc02001f8:	a3458593          	addi	a1,a1,-1484 # ffffffffc0201c28 <commands+0x100>
ffffffffc02001fc:	00002517          	auipc	a0,0x2
ffffffffc0200200:	a3450513          	addi	a0,a0,-1484 # ffffffffc0201c30 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00002617          	auipc	a2,0x2
ffffffffc020020e:	a3660613          	addi	a2,a2,-1482 # ffffffffc0201c40 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	a5658593          	addi	a1,a1,-1450 # ffffffffc0201c68 <commands+0x140>
ffffffffc020021a:	00002517          	auipc	a0,0x2
ffffffffc020021e:	a1650513          	addi	a0,a0,-1514 # ffffffffc0201c30 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	a5260613          	addi	a2,a2,-1454 # ffffffffc0201c78 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	a6a58593          	addi	a1,a1,-1430 # ffffffffc0201c98 <commands+0x170>
ffffffffc0200236:	00002517          	auipc	a0,0x2
ffffffffc020023a:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0201c30 <commands+0x108>
ffffffffc020023e:	e79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc0200242:	60a2                	ld	ra,8(sp)
ffffffffc0200244:	4501                	li	a0,0
ffffffffc0200246:	0141                	addi	sp,sp,16
ffffffffc0200248:	8082                	ret

ffffffffc020024a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
ffffffffc020024c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024e:	ef1ff0ef          	jal	ra,ffffffffc020013e <print_kerninfo>
    return 0;
}
ffffffffc0200252:	60a2                	ld	ra,8(sp)
ffffffffc0200254:	4501                	li	a0,0
ffffffffc0200256:	0141                	addi	sp,sp,16
ffffffffc0200258:	8082                	ret

ffffffffc020025a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	1141                	addi	sp,sp,-16
ffffffffc020025c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025e:	f71ff0ef          	jal	ra,ffffffffc02001ce <print_stackframe>
    return 0;
}
ffffffffc0200262:	60a2                	ld	ra,8(sp)
ffffffffc0200264:	4501                	li	a0,0
ffffffffc0200266:	0141                	addi	sp,sp,16
ffffffffc0200268:	8082                	ret

ffffffffc020026a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026a:	7115                	addi	sp,sp,-224
ffffffffc020026c:	e962                	sd	s8,144(sp)
ffffffffc020026e:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200270:	00002517          	auipc	a0,0x2
ffffffffc0200274:	90050513          	addi	a0,a0,-1792 # ffffffffc0201b70 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200278:	ed86                	sd	ra,216(sp)
ffffffffc020027a:	e9a2                	sd	s0,208(sp)
ffffffffc020027c:	e5a6                	sd	s1,200(sp)
ffffffffc020027e:	e1ca                	sd	s2,192(sp)
ffffffffc0200280:	fd4e                	sd	s3,184(sp)
ffffffffc0200282:	f952                	sd	s4,176(sp)
ffffffffc0200284:	f556                	sd	s5,168(sp)
ffffffffc0200286:	f15a                	sd	s6,160(sp)
ffffffffc0200288:	ed5e                	sd	s7,152(sp)
ffffffffc020028a:	e566                	sd	s9,136(sp)
ffffffffc020028c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	e29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200292:	00002517          	auipc	a0,0x2
ffffffffc0200296:	90650513          	addi	a0,a0,-1786 # ffffffffc0201b98 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00002c97          	auipc	s9,0x2
ffffffffc02002ac:	880c8c93          	addi	s9,s9,-1920 # ffffffffc0201b28 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00002997          	auipc	s3,0x2
ffffffffc02002b4:	91098993          	addi	s3,s3,-1776 # ffffffffc0201bc0 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00002917          	auipc	s2,0x2
ffffffffc02002bc:	91090913          	addi	s2,s2,-1776 # ffffffffc0201bc8 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00002b17          	auipc	s6,0x2
ffffffffc02002c6:	90eb0b13          	addi	s6,s6,-1778 # ffffffffc0201bd0 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00002a97          	auipc	s5,0x2
ffffffffc02002ce:	95ea8a93          	addi	s5,s5,-1698 # ffffffffc0201c28 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	598010ef          	jal	ra,ffffffffc020186e <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	6ea010ef          	jal	ra,ffffffffc02019d2 <strchr>
ffffffffc02002ec:	c925                	beqz	a0,ffffffffc020035c <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002ee:	00144583          	lbu	a1,1(s0)
ffffffffc02002f2:	00040023          	sb	zero,0(s0)
ffffffffc02002f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f8:	f5fd                	bnez	a1,ffffffffc02002e6 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002fa:	dce9                	beqz	s1,ffffffffc02002d4 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002fc:	6582                	ld	a1,0(sp)
ffffffffc02002fe:	00002d17          	auipc	s10,0x2
ffffffffc0200302:	82ad0d13          	addi	s10,s10,-2006 # ffffffffc0201b28 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	69c010ef          	jal	ra,ffffffffc02019a8 <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	688010ef          	jal	ra,ffffffffc02019a8 <strcmp>
ffffffffc0200324:	f57d                	bnez	a0,ffffffffc0200312 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200326:	00141793          	slli	a5,s0,0x1
ffffffffc020032a:	97a2                	add	a5,a5,s0
ffffffffc020032c:	078e                	slli	a5,a5,0x3
ffffffffc020032e:	97e6                	add	a5,a5,s9
ffffffffc0200330:	6b9c                	ld	a5,16(a5)
ffffffffc0200332:	8662                	mv	a2,s8
ffffffffc0200334:	002c                	addi	a1,sp,8
ffffffffc0200336:	fff4851b          	addiw	a0,s1,-1
ffffffffc020033a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020033c:	f8055ce3          	bgez	a0,ffffffffc02002d4 <kmonitor+0x6a>
}
ffffffffc0200340:	60ee                	ld	ra,216(sp)
ffffffffc0200342:	644e                	ld	s0,208(sp)
ffffffffc0200344:	64ae                	ld	s1,200(sp)
ffffffffc0200346:	690e                	ld	s2,192(sp)
ffffffffc0200348:	79ea                	ld	s3,184(sp)
ffffffffc020034a:	7a4a                	ld	s4,176(sp)
ffffffffc020034c:	7aaa                	ld	s5,168(sp)
ffffffffc020034e:	7b0a                	ld	s6,160(sp)
ffffffffc0200350:	6bea                	ld	s7,152(sp)
ffffffffc0200352:	6c4a                	ld	s8,144(sp)
ffffffffc0200354:	6caa                	ld	s9,136(sp)
ffffffffc0200356:	6d0a                	ld	s10,128(sp)
ffffffffc0200358:	612d                	addi	sp,sp,224
ffffffffc020035a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020035c:	00044783          	lbu	a5,0(s0)
ffffffffc0200360:	dfc9                	beqz	a5,ffffffffc02002fa <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200362:	03448863          	beq	s1,s4,ffffffffc0200392 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200366:	00349793          	slli	a5,s1,0x3
ffffffffc020036a:	0118                	addi	a4,sp,128
ffffffffc020036c:	97ba                	add	a5,a5,a4
ffffffffc020036e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200372:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200376:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	e591                	bnez	a1,ffffffffc0200384 <kmonitor+0x11a>
ffffffffc020037a:	b749                	j	ffffffffc02002fc <kmonitor+0x92>
            buf ++;
ffffffffc020037c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037e:	00044583          	lbu	a1,0(s0)
ffffffffc0200382:	ddad                	beqz	a1,ffffffffc02002fc <kmonitor+0x92>
ffffffffc0200384:	854a                	mv	a0,s2
ffffffffc0200386:	64c010ef          	jal	ra,ffffffffc02019d2 <strchr>
ffffffffc020038a:	d96d                	beqz	a0,ffffffffc020037c <kmonitor+0x112>
ffffffffc020038c:	00044583          	lbu	a1,0(s0)
ffffffffc0200390:	bf91                	j	ffffffffc02002e4 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020039a:	b7f1                	j	ffffffffc0200366 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	85250513          	addi	a0,a0,-1966 # ffffffffc0201bf0 <commands+0xc8>
ffffffffc02003a6:	d11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc02003aa:	b72d                	j	ffffffffc02002d4 <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	06430313          	addi	t1,t1,100 # ffffffffc0206410 <is_panic>
ffffffffc02003b4:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	02031c63          	bnez	t1,ffffffffc0200400 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	8432                	mv	s0,a2
ffffffffc02003d0:	00006717          	auipc	a4,0x6
ffffffffc02003d4:	04f72023          	sw	a5,64(a4) # ffffffffc0206410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003da:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	85aa                	mv	a1,a0
ffffffffc02003de:	00002517          	auipc	a0,0x2
ffffffffc02003e2:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0201ca8 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00001517          	auipc	a0,0x1
ffffffffc02003f8:	72c50513          	addi	a0,a0,1836 # ffffffffc0201b20 <etext+0x11e>
ffffffffc02003fc:	cbbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200400:	064000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200404:	4501                	li	a0,0
ffffffffc0200406:	e65ff0ef          	jal	ra,ffffffffc020026a <kmonitor>
ffffffffc020040a:	bfed                	j	ffffffffc0200404 <__panic+0x58>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	524010ef          	jal	ra,ffffffffc0201948 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	89650513          	addi	a0,a0,-1898 # ffffffffc0201cc8 <commands+0x1a0>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	4fc0106f          	j	ffffffffc0201948 <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	4d60106f          	j	ffffffffc020192c <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	50a0106f          	j	ffffffffc0201964 <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	30678793          	addi	a5,a5,774 # ffffffffc0200774 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00002517          	auipc	a0,0x2
ffffffffc0200488:	95c50513          	addi	a0,a0,-1700 # ffffffffc0201de0 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	96450513          	addi	a0,a0,-1692 # ffffffffc0201df8 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	96e50513          	addi	a0,a0,-1682 # ffffffffc0201e10 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	97850513          	addi	a0,a0,-1672 # ffffffffc0201e28 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	98250513          	addi	a0,a0,-1662 # ffffffffc0201e40 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	98c50513          	addi	a0,a0,-1652 # ffffffffc0201e58 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	99650513          	addi	a0,a0,-1642 # ffffffffc0201e70 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	9a050513          	addi	a0,a0,-1632 # ffffffffc0201e88 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0201ea0 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	9b450513          	addi	a0,a0,-1612 # ffffffffc0201eb8 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	9be50513          	addi	a0,a0,-1602 # ffffffffc0201ed0 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	9c850513          	addi	a0,a0,-1592 # ffffffffc0201ee8 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	9d250513          	addi	a0,a0,-1582 # ffffffffc0201f00 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0201f18 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	9e650513          	addi	a0,a0,-1562 # ffffffffc0201f30 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	9f050513          	addi	a0,a0,-1552 # ffffffffc0201f48 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0201f60 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	a0450513          	addi	a0,a0,-1532 # ffffffffc0201f78 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0201f90 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	a1850513          	addi	a0,a0,-1512 # ffffffffc0201fa8 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	a2250513          	addi	a0,a0,-1502 # ffffffffc0201fc0 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0201fd8 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	a3650513          	addi	a0,a0,-1482 # ffffffffc0201ff0 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	a4050513          	addi	a0,a0,-1472 # ffffffffc0202008 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0202020 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	a5450513          	addi	a0,a0,-1452 # ffffffffc0202038 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0202050 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	a6850513          	addi	a0,a0,-1432 # ffffffffc0202068 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	a7250513          	addi	a0,a0,-1422 # ffffffffc0202080 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0202098 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	a8650513          	addi	a0,a0,-1402 # ffffffffc02020b0 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	a8c50513          	addi	a0,a0,-1396 # ffffffffc02020c8 <commands+0x5a0>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	a8e50513          	addi	a0,a0,-1394 # ffffffffc02020e0 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	a8e50513          	addi	a0,a0,-1394 # ffffffffc02020f8 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	a9650513          	addi	a0,a0,-1386 # ffffffffc0202110 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0202128 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	aa250513          	addi	a0,a0,-1374 # ffffffffc0202140 <commands+0x618>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76563          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x96>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	62870713          	addi	a4,a4,1576 # ffffffffc0201ce4 <commands+0x1bc>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	6aa50513          	addi	a0,a0,1706 # ffffffffc0201d78 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	67e50513          	addi	a0,a0,1662 # ffffffffc0201d58 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	63250513          	addi	a0,a0,1586 # ffffffffc0201d18 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	6a650513          	addi	a0,a0,1702 # ffffffffc0201d98 <commands+0x270>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200706:	00006797          	auipc	a5,0x6
ffffffffc020070a:	d2a78793          	addi	a5,a5,-726 # ffffffffc0206430 <ticks>
ffffffffc020070e:	639c                	ld	a5,0(a5)
ffffffffc0200710:	06400713          	li	a4,100
ffffffffc0200714:	0785                	addi	a5,a5,1
ffffffffc0200716:	02e7f733          	remu	a4,a5,a4
ffffffffc020071a:	00006697          	auipc	a3,0x6
ffffffffc020071e:	d0f6bb23          	sd	a5,-746(a3) # ffffffffc0206430 <ticks>
ffffffffc0200722:	c315                	beqz	a4,ffffffffc0200746 <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200724:	60a2                	ld	ra,8(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	69650513          	addi	a0,a0,1686 # ffffffffc0201dc0 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	60250513          	addi	a0,a0,1538 # ffffffffc0201d38 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	66450513          	addi	a0,a0,1636 # ffffffffc0201db0 <commands+0x288>
}
ffffffffc0200754:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200756:	961ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020075a <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075a:	11853783          	ld	a5,280(a0)
ffffffffc020075e:	0007c863          	bltz	a5,ffffffffc020076e <trap+0x14>
    switch (tf->cause) {
ffffffffc0200762:	472d                	li	a4,11
ffffffffc0200764:	00f76363          	bltu	a4,a5,ffffffffc020076a <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200768:	8082                	ret
            print_trapframe(tf);
ffffffffc020076a:	ee1ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc020076e:	f3fff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc0200774 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200774:	14011073          	csrw	sscratch,sp
ffffffffc0200778:	712d                	addi	sp,sp,-288
ffffffffc020077a:	e002                	sd	zero,0(sp)
ffffffffc020077c:	e406                	sd	ra,8(sp)
ffffffffc020077e:	ec0e                	sd	gp,24(sp)
ffffffffc0200780:	f012                	sd	tp,32(sp)
ffffffffc0200782:	f416                	sd	t0,40(sp)
ffffffffc0200784:	f81a                	sd	t1,48(sp)
ffffffffc0200786:	fc1e                	sd	t2,56(sp)
ffffffffc0200788:	e0a2                	sd	s0,64(sp)
ffffffffc020078a:	e4a6                	sd	s1,72(sp)
ffffffffc020078c:	e8aa                	sd	a0,80(sp)
ffffffffc020078e:	ecae                	sd	a1,88(sp)
ffffffffc0200790:	f0b2                	sd	a2,96(sp)
ffffffffc0200792:	f4b6                	sd	a3,104(sp)
ffffffffc0200794:	f8ba                	sd	a4,112(sp)
ffffffffc0200796:	fcbe                	sd	a5,120(sp)
ffffffffc0200798:	e142                	sd	a6,128(sp)
ffffffffc020079a:	e546                	sd	a7,136(sp)
ffffffffc020079c:	e94a                	sd	s2,144(sp)
ffffffffc020079e:	ed4e                	sd	s3,152(sp)
ffffffffc02007a0:	f152                	sd	s4,160(sp)
ffffffffc02007a2:	f556                	sd	s5,168(sp)
ffffffffc02007a4:	f95a                	sd	s6,176(sp)
ffffffffc02007a6:	fd5e                	sd	s7,184(sp)
ffffffffc02007a8:	e1e2                	sd	s8,192(sp)
ffffffffc02007aa:	e5e6                	sd	s9,200(sp)
ffffffffc02007ac:	e9ea                	sd	s10,208(sp)
ffffffffc02007ae:	edee                	sd	s11,216(sp)
ffffffffc02007b0:	f1f2                	sd	t3,224(sp)
ffffffffc02007b2:	f5f6                	sd	t4,232(sp)
ffffffffc02007b4:	f9fa                	sd	t5,240(sp)
ffffffffc02007b6:	fdfe                	sd	t6,248(sp)
ffffffffc02007b8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007bc:	100024f3          	csrr	s1,sstatus
ffffffffc02007c0:	14102973          	csrr	s2,sepc
ffffffffc02007c4:	143029f3          	csrr	s3,stval
ffffffffc02007c8:	14202a73          	csrr	s4,scause
ffffffffc02007cc:	e822                	sd	s0,16(sp)
ffffffffc02007ce:	e226                	sd	s1,256(sp)
ffffffffc02007d0:	e64a                	sd	s2,264(sp)
ffffffffc02007d2:	ea4e                	sd	s3,272(sp)
ffffffffc02007d4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d8:	f83ff0ef          	jal	ra,ffffffffc020075a <trap>

ffffffffc02007dc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007dc:	6492                	ld	s1,256(sp)
ffffffffc02007de:	6932                	ld	s2,264(sp)
ffffffffc02007e0:	10049073          	csrw	sstatus,s1
ffffffffc02007e4:	14191073          	csrw	sepc,s2
ffffffffc02007e8:	60a2                	ld	ra,8(sp)
ffffffffc02007ea:	61e2                	ld	gp,24(sp)
ffffffffc02007ec:	7202                	ld	tp,32(sp)
ffffffffc02007ee:	72a2                	ld	t0,40(sp)
ffffffffc02007f0:	7342                	ld	t1,48(sp)
ffffffffc02007f2:	73e2                	ld	t2,56(sp)
ffffffffc02007f4:	6406                	ld	s0,64(sp)
ffffffffc02007f6:	64a6                	ld	s1,72(sp)
ffffffffc02007f8:	6546                	ld	a0,80(sp)
ffffffffc02007fa:	65e6                	ld	a1,88(sp)
ffffffffc02007fc:	7606                	ld	a2,96(sp)
ffffffffc02007fe:	76a6                	ld	a3,104(sp)
ffffffffc0200800:	7746                	ld	a4,112(sp)
ffffffffc0200802:	77e6                	ld	a5,120(sp)
ffffffffc0200804:	680a                	ld	a6,128(sp)
ffffffffc0200806:	68aa                	ld	a7,136(sp)
ffffffffc0200808:	694a                	ld	s2,144(sp)
ffffffffc020080a:	69ea                	ld	s3,152(sp)
ffffffffc020080c:	7a0a                	ld	s4,160(sp)
ffffffffc020080e:	7aaa                	ld	s5,168(sp)
ffffffffc0200810:	7b4a                	ld	s6,176(sp)
ffffffffc0200812:	7bea                	ld	s7,184(sp)
ffffffffc0200814:	6c0e                	ld	s8,192(sp)
ffffffffc0200816:	6cae                	ld	s9,200(sp)
ffffffffc0200818:	6d4e                	ld	s10,208(sp)
ffffffffc020081a:	6dee                	ld	s11,216(sp)
ffffffffc020081c:	7e0e                	ld	t3,224(sp)
ffffffffc020081e:	7eae                	ld	t4,232(sp)
ffffffffc0200820:	7f4e                	ld	t5,240(sp)
ffffffffc0200822:	7fee                	ld	t6,248(sp)
ffffffffc0200824:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200826:	10200073          	sret

ffffffffc020082a <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020082a:	00006797          	auipc	a5,0x6
ffffffffc020082e:	c0e78793          	addi	a5,a5,-1010 # ffffffffc0206438 <free_area>
ffffffffc0200832:	e79c                	sd	a5,8(a5)
ffffffffc0200834:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200836:	0007a823          	sw	zero,16(a5)
}
ffffffffc020083a:	8082                	ret

ffffffffc020083c <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	c0c56503          	lwu	a0,-1012(a0) # ffffffffc0206448 <free_area+0x10>
ffffffffc0200844:	8082                	ret

ffffffffc0200846 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200846:	715d                	addi	sp,sp,-80
ffffffffc0200848:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020084a:	00006917          	auipc	s2,0x6
ffffffffc020084e:	bee90913          	addi	s2,s2,-1042 # ffffffffc0206438 <free_area>
ffffffffc0200852:	00893783          	ld	a5,8(s2)
ffffffffc0200856:	e486                	sd	ra,72(sp)
ffffffffc0200858:	e0a2                	sd	s0,64(sp)
ffffffffc020085a:	fc26                	sd	s1,56(sp)
ffffffffc020085c:	f44e                	sd	s3,40(sp)
ffffffffc020085e:	f052                	sd	s4,32(sp)
ffffffffc0200860:	ec56                	sd	s5,24(sp)
ffffffffc0200862:	e85a                	sd	s6,16(sp)
ffffffffc0200864:	e45e                	sd	s7,8(sp)
ffffffffc0200866:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200868:	2d278363          	beq	a5,s2,ffffffffc0200b2e <best_fit_check+0x2e8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020086c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200870:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200872:	8b05                	andi	a4,a4,1
ffffffffc0200874:	2c070163          	beqz	a4,ffffffffc0200b36 <best_fit_check+0x2f0>
    int count = 0, total = 0;
ffffffffc0200878:	4401                	li	s0,0
ffffffffc020087a:	4481                	li	s1,0
ffffffffc020087c:	a031                	j	ffffffffc0200888 <best_fit_check+0x42>
ffffffffc020087e:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200882:	8b09                	andi	a4,a4,2
ffffffffc0200884:	2a070963          	beqz	a4,ffffffffc0200b36 <best_fit_check+0x2f0>
        count ++, total += p->property;
ffffffffc0200888:	ff87a703          	lw	a4,-8(a5)
ffffffffc020088c:	679c                	ld	a5,8(a5)
ffffffffc020088e:	2485                	addiw	s1,s1,1
ffffffffc0200890:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200892:	ff2796e3          	bne	a5,s2,ffffffffc020087e <best_fit_check+0x38>
ffffffffc0200896:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200898:	1f1000ef          	jal	ra,ffffffffc0201288 <nr_free_pages>
ffffffffc020089c:	37351d63          	bne	a0,s3,ffffffffc0200c16 <best_fit_check+0x3d0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02008a0:	4505                	li	a0,1
ffffffffc02008a2:	15d000ef          	jal	ra,ffffffffc02011fe <alloc_pages>
ffffffffc02008a6:	8a2a                	mv	s4,a0
ffffffffc02008a8:	3a050763          	beqz	a0,ffffffffc0200c56 <best_fit_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02008ac:	4505                	li	a0,1
ffffffffc02008ae:	151000ef          	jal	ra,ffffffffc02011fe <alloc_pages>
ffffffffc02008b2:	89aa                	mv	s3,a0
ffffffffc02008b4:	38050163          	beqz	a0,ffffffffc0200c36 <best_fit_check+0x3f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02008b8:	4505                	li	a0,1
ffffffffc02008ba:	145000ef          	jal	ra,ffffffffc02011fe <alloc_pages>
ffffffffc02008be:	8aaa                	mv	s5,a0
ffffffffc02008c0:	30050b63          	beqz	a0,ffffffffc0200bd6 <best_fit_check+0x390>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02008c4:	293a0963          	beq	s4,s3,ffffffffc0200b56 <best_fit_check+0x310>
ffffffffc02008c8:	28aa0763          	beq	s4,a0,ffffffffc0200b56 <best_fit_check+0x310>
ffffffffc02008cc:	28a98563          	beq	s3,a0,ffffffffc0200b56 <best_fit_check+0x310>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02008d0:	000a2783          	lw	a5,0(s4)
ffffffffc02008d4:	2a079163          	bnez	a5,ffffffffc0200b76 <best_fit_check+0x330>
ffffffffc02008d8:	0009a783          	lw	a5,0(s3)
ffffffffc02008dc:	28079d63          	bnez	a5,ffffffffc0200b76 <best_fit_check+0x330>
ffffffffc02008e0:	411c                	lw	a5,0(a0)
ffffffffc02008e2:	28079a63          	bnez	a5,ffffffffc0200b76 <best_fit_check+0x330>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008e6:	00006797          	auipc	a5,0x6
ffffffffc02008ea:	b8278793          	addi	a5,a5,-1150 # ffffffffc0206468 <pages>
ffffffffc02008ee:	639c                	ld	a5,0(a5)
ffffffffc02008f0:	00002717          	auipc	a4,0x2
ffffffffc02008f4:	86870713          	addi	a4,a4,-1944 # ffffffffc0202158 <commands+0x630>
ffffffffc02008f8:	630c                	ld	a1,0(a4)
ffffffffc02008fa:	40fa0733          	sub	a4,s4,a5
ffffffffc02008fe:	870d                	srai	a4,a4,0x3
ffffffffc0200900:	02b70733          	mul	a4,a4,a1
ffffffffc0200904:	00002697          	auipc	a3,0x2
ffffffffc0200908:	f4c68693          	addi	a3,a3,-180 # ffffffffc0202850 <nbase>
ffffffffc020090c:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020090e:	00006697          	auipc	a3,0x6
ffffffffc0200912:	b0a68693          	addi	a3,a3,-1270 # ffffffffc0206418 <npage>
ffffffffc0200916:	6294                	ld	a3,0(a3)
ffffffffc0200918:	06b2                	slli	a3,a3,0xc
ffffffffc020091a:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc020091c:	0732                	slli	a4,a4,0xc
ffffffffc020091e:	26d77c63          	bleu	a3,a4,ffffffffc0200b96 <best_fit_check+0x350>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200922:	40f98733          	sub	a4,s3,a5
ffffffffc0200926:	870d                	srai	a4,a4,0x3
ffffffffc0200928:	02b70733          	mul	a4,a4,a1
ffffffffc020092c:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020092e:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200930:	42d77363          	bleu	a3,a4,ffffffffc0200d56 <best_fit_check+0x510>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200934:	40f507b3          	sub	a5,a0,a5
ffffffffc0200938:	878d                	srai	a5,a5,0x3
ffffffffc020093a:	02b787b3          	mul	a5,a5,a1
ffffffffc020093e:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200940:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200942:	3ed7fa63          	bleu	a3,a5,ffffffffc0200d36 <best_fit_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc0200946:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200948:	00093c03          	ld	s8,0(s2)
ffffffffc020094c:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200950:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200954:	00006797          	auipc	a5,0x6
ffffffffc0200958:	af27b623          	sd	s2,-1300(a5) # ffffffffc0206440 <free_area+0x8>
ffffffffc020095c:	00006797          	auipc	a5,0x6
ffffffffc0200960:	ad27be23          	sd	s2,-1316(a5) # ffffffffc0206438 <free_area>
    nr_free = 0;
ffffffffc0200964:	00006797          	auipc	a5,0x6
ffffffffc0200968:	ae07a223          	sw	zero,-1308(a5) # ffffffffc0206448 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc020096c:	093000ef          	jal	ra,ffffffffc02011fe <alloc_pages>
ffffffffc0200970:	3a051363          	bnez	a0,ffffffffc0200d16 <best_fit_check+0x4d0>
    free_page(p0);
ffffffffc0200974:	4585                	li	a1,1
ffffffffc0200976:	8552                	mv	a0,s4
ffffffffc0200978:	0cb000ef          	jal	ra,ffffffffc0201242 <free_pages>
    free_page(p1);
ffffffffc020097c:	4585                	li	a1,1
ffffffffc020097e:	854e                	mv	a0,s3
ffffffffc0200980:	0c3000ef          	jal	ra,ffffffffc0201242 <free_pages>
    free_page(p2);
ffffffffc0200984:	4585                	li	a1,1
ffffffffc0200986:	8556                	mv	a0,s5
ffffffffc0200988:	0bb000ef          	jal	ra,ffffffffc0201242 <free_pages>
    assert(nr_free == 3);
ffffffffc020098c:	01092703          	lw	a4,16(s2)
ffffffffc0200990:	478d                	li	a5,3
ffffffffc0200992:	36f71263          	bne	a4,a5,ffffffffc0200cf6 <best_fit_check+0x4b0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200996:	4505                	li	a0,1
ffffffffc0200998:	067000ef          	jal	ra,ffffffffc02011fe <alloc_pages>
ffffffffc020099c:	89aa                	mv	s3,a0
ffffffffc020099e:	32050c63          	beqz	a0,ffffffffc0200cd6 <best_fit_check+0x490>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02009a2:	4505                	li	a0,1
ffffffffc02009a4:	05b000ef          	jal	ra,ffffffffc02011fe <alloc_pages>
ffffffffc02009a8:	8aaa                	mv	s5,a0
ffffffffc02009aa:	30050663          	beqz	a0,ffffffffc0200cb6 <best_fit_check+0x470>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02009ae:	4505                	li	a0,1
ffffffffc02009b0:	04f000ef          	jal	ra,ffffffffc02011fe <alloc_pages>
ffffffffc02009b4:	8a2a                	mv	s4,a0
ffffffffc02009b6:	2e050063          	beqz	a0,ffffffffc0200c96 <best_fit_check+0x450>
    assert(alloc_page() == NULL);
ffffffffc02009ba:	4505                	li	a0,1
ffffffffc02009bc:	043000ef          	jal	ra,ffffffffc02011fe <alloc_pages>
ffffffffc02009c0:	2a051b63          	bnez	a0,ffffffffc0200c76 <best_fit_check+0x430>
    free_page(p0);
ffffffffc02009c4:	4585                	li	a1,1
ffffffffc02009c6:	854e                	mv	a0,s3
ffffffffc02009c8:	07b000ef          	jal	ra,ffffffffc0201242 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02009cc:	00893783          	ld	a5,8(s2)
ffffffffc02009d0:	1f278363          	beq	a5,s2,ffffffffc0200bb6 <best_fit_check+0x370>
    assert((p = alloc_page()) == p0);
ffffffffc02009d4:	4505                	li	a0,1
ffffffffc02009d6:	029000ef          	jal	ra,ffffffffc02011fe <alloc_pages>
ffffffffc02009da:	54a99e63          	bne	s3,a0,ffffffffc0200f36 <best_fit_check+0x6f0>
    assert(alloc_page() == NULL);
ffffffffc02009de:	4505                	li	a0,1
ffffffffc02009e0:	01f000ef          	jal	ra,ffffffffc02011fe <alloc_pages>
ffffffffc02009e4:	52051963          	bnez	a0,ffffffffc0200f16 <best_fit_check+0x6d0>
    assert(nr_free == 0);
ffffffffc02009e8:	01092783          	lw	a5,16(s2)
ffffffffc02009ec:	50079563          	bnez	a5,ffffffffc0200ef6 <best_fit_check+0x6b0>
    free_page(p);
ffffffffc02009f0:	854e                	mv	a0,s3
ffffffffc02009f2:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02009f4:	00006797          	auipc	a5,0x6
ffffffffc02009f8:	a587b223          	sd	s8,-1468(a5) # ffffffffc0206438 <free_area>
ffffffffc02009fc:	00006797          	auipc	a5,0x6
ffffffffc0200a00:	a577b223          	sd	s7,-1468(a5) # ffffffffc0206440 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200a04:	00006797          	auipc	a5,0x6
ffffffffc0200a08:	a567a223          	sw	s6,-1468(a5) # ffffffffc0206448 <free_area+0x10>
    free_page(p);
ffffffffc0200a0c:	037000ef          	jal	ra,ffffffffc0201242 <free_pages>
    free_page(p1);
ffffffffc0200a10:	4585                	li	a1,1
ffffffffc0200a12:	8556                	mv	a0,s5
ffffffffc0200a14:	02f000ef          	jal	ra,ffffffffc0201242 <free_pages>
    free_page(p2);
ffffffffc0200a18:	4585                	li	a1,1
ffffffffc0200a1a:	8552                	mv	a0,s4
ffffffffc0200a1c:	027000ef          	jal	ra,ffffffffc0201242 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200a20:	4515                	li	a0,5
ffffffffc0200a22:	7dc000ef          	jal	ra,ffffffffc02011fe <alloc_pages>
ffffffffc0200a26:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200a28:	4a050763          	beqz	a0,ffffffffc0200ed6 <best_fit_check+0x690>
ffffffffc0200a2c:	651c                	ld	a5,8(a0)
ffffffffc0200a2e:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200a30:	8b85                	andi	a5,a5,1
ffffffffc0200a32:	48079263          	bnez	a5,ffffffffc0200eb6 <best_fit_check+0x670>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200a36:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200a38:	00093b03          	ld	s6,0(s2)
ffffffffc0200a3c:	00893a83          	ld	s5,8(s2)
ffffffffc0200a40:	00006797          	auipc	a5,0x6
ffffffffc0200a44:	9f27bc23          	sd	s2,-1544(a5) # ffffffffc0206438 <free_area>
ffffffffc0200a48:	00006797          	auipc	a5,0x6
ffffffffc0200a4c:	9f27bc23          	sd	s2,-1544(a5) # ffffffffc0206440 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200a50:	7ae000ef          	jal	ra,ffffffffc02011fe <alloc_pages>
ffffffffc0200a54:	44051163          	bnez	a0,ffffffffc0200e96 <best_fit_check+0x650>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200a58:	4589                	li	a1,2
ffffffffc0200a5a:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200a5e:	01092b83          	lw	s7,16(s2)
    free_pages(p0 + 4, 1);
ffffffffc0200a62:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200a66:	00006797          	auipc	a5,0x6
ffffffffc0200a6a:	9e07a123          	sw	zero,-1566(a5) # ffffffffc0206448 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200a6e:	7d4000ef          	jal	ra,ffffffffc0201242 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200a72:	8562                	mv	a0,s8
ffffffffc0200a74:	4585                	li	a1,1
ffffffffc0200a76:	7cc000ef          	jal	ra,ffffffffc0201242 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200a7a:	4511                	li	a0,4
ffffffffc0200a7c:	782000ef          	jal	ra,ffffffffc02011fe <alloc_pages>
ffffffffc0200a80:	3e051b63          	bnez	a0,ffffffffc0200e76 <best_fit_check+0x630>
ffffffffc0200a84:	0309b783          	ld	a5,48(s3)
ffffffffc0200a88:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200a8a:	8b85                	andi	a5,a5,1
ffffffffc0200a8c:	3c078563          	beqz	a5,ffffffffc0200e56 <best_fit_check+0x610>
ffffffffc0200a90:	0389a703          	lw	a4,56(s3)
ffffffffc0200a94:	4789                	li	a5,2
ffffffffc0200a96:	3cf71063          	bne	a4,a5,ffffffffc0200e56 <best_fit_check+0x610>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200a9a:	4505                	li	a0,1
ffffffffc0200a9c:	762000ef          	jal	ra,ffffffffc02011fe <alloc_pages>
ffffffffc0200aa0:	8a2a                	mv	s4,a0
ffffffffc0200aa2:	38050a63          	beqz	a0,ffffffffc0200e36 <best_fit_check+0x5f0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200aa6:	4509                	li	a0,2
ffffffffc0200aa8:	756000ef          	jal	ra,ffffffffc02011fe <alloc_pages>
ffffffffc0200aac:	36050563          	beqz	a0,ffffffffc0200e16 <best_fit_check+0x5d0>
    assert(p0 + 4 == p1);
ffffffffc0200ab0:	354c1363          	bne	s8,s4,ffffffffc0200df6 <best_fit_check+0x5b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200ab4:	854e                	mv	a0,s3
ffffffffc0200ab6:	4595                	li	a1,5
ffffffffc0200ab8:	78a000ef          	jal	ra,ffffffffc0201242 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200abc:	4515                	li	a0,5
ffffffffc0200abe:	740000ef          	jal	ra,ffffffffc02011fe <alloc_pages>
ffffffffc0200ac2:	89aa                	mv	s3,a0
ffffffffc0200ac4:	30050963          	beqz	a0,ffffffffc0200dd6 <best_fit_check+0x590>
    assert(alloc_page() == NULL);
ffffffffc0200ac8:	4505                	li	a0,1
ffffffffc0200aca:	734000ef          	jal	ra,ffffffffc02011fe <alloc_pages>
ffffffffc0200ace:	2e051463          	bnez	a0,ffffffffc0200db6 <best_fit_check+0x570>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200ad2:	01092783          	lw	a5,16(s2)
ffffffffc0200ad6:	2c079063          	bnez	a5,ffffffffc0200d96 <best_fit_check+0x550>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200ada:	4595                	li	a1,5
ffffffffc0200adc:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200ade:	00006797          	auipc	a5,0x6
ffffffffc0200ae2:	9777a523          	sw	s7,-1686(a5) # ffffffffc0206448 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200ae6:	00006797          	auipc	a5,0x6
ffffffffc0200aea:	9567b923          	sd	s6,-1710(a5) # ffffffffc0206438 <free_area>
ffffffffc0200aee:	00006797          	auipc	a5,0x6
ffffffffc0200af2:	9557b923          	sd	s5,-1710(a5) # ffffffffc0206440 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200af6:	74c000ef          	jal	ra,ffffffffc0201242 <free_pages>
    return listelm->next;
ffffffffc0200afa:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200afe:	01278963          	beq	a5,s2,ffffffffc0200b10 <best_fit_check+0x2ca>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200b02:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b06:	679c                	ld	a5,8(a5)
ffffffffc0200b08:	34fd                	addiw	s1,s1,-1
ffffffffc0200b0a:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b0c:	ff279be3          	bne	a5,s2,ffffffffc0200b02 <best_fit_check+0x2bc>
    }
    assert(count == 0);
ffffffffc0200b10:	26049363          	bnez	s1,ffffffffc0200d76 <best_fit_check+0x530>
    assert(total == 0);
ffffffffc0200b14:	e06d                	bnez	s0,ffffffffc0200bf6 <best_fit_check+0x3b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200b16:	60a6                	ld	ra,72(sp)
ffffffffc0200b18:	6406                	ld	s0,64(sp)
ffffffffc0200b1a:	74e2                	ld	s1,56(sp)
ffffffffc0200b1c:	7942                	ld	s2,48(sp)
ffffffffc0200b1e:	79a2                	ld	s3,40(sp)
ffffffffc0200b20:	7a02                	ld	s4,32(sp)
ffffffffc0200b22:	6ae2                	ld	s5,24(sp)
ffffffffc0200b24:	6b42                	ld	s6,16(sp)
ffffffffc0200b26:	6ba2                	ld	s7,8(sp)
ffffffffc0200b28:	6c02                	ld	s8,0(sp)
ffffffffc0200b2a:	6161                	addi	sp,sp,80
ffffffffc0200b2c:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b2e:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200b30:	4401                	li	s0,0
ffffffffc0200b32:	4481                	li	s1,0
ffffffffc0200b34:	b395                	j	ffffffffc0200898 <best_fit_check+0x52>
        assert(PageProperty(p));
ffffffffc0200b36:	00001697          	auipc	a3,0x1
ffffffffc0200b3a:	62a68693          	addi	a3,a3,1578 # ffffffffc0202160 <commands+0x638>
ffffffffc0200b3e:	00001617          	auipc	a2,0x1
ffffffffc0200b42:	63260613          	addi	a2,a2,1586 # ffffffffc0202170 <commands+0x648>
ffffffffc0200b46:	0f800593          	li	a1,248
ffffffffc0200b4a:	00001517          	auipc	a0,0x1
ffffffffc0200b4e:	63e50513          	addi	a0,a0,1598 # ffffffffc0202188 <commands+0x660>
ffffffffc0200b52:	85bff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b56:	00001697          	auipc	a3,0x1
ffffffffc0200b5a:	6ca68693          	addi	a3,a3,1738 # ffffffffc0202220 <commands+0x6f8>
ffffffffc0200b5e:	00001617          	auipc	a2,0x1
ffffffffc0200b62:	61260613          	addi	a2,a2,1554 # ffffffffc0202170 <commands+0x648>
ffffffffc0200b66:	0c400593          	li	a1,196
ffffffffc0200b6a:	00001517          	auipc	a0,0x1
ffffffffc0200b6e:	61e50513          	addi	a0,a0,1566 # ffffffffc0202188 <commands+0x660>
ffffffffc0200b72:	83bff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b76:	00001697          	auipc	a3,0x1
ffffffffc0200b7a:	6d268693          	addi	a3,a3,1746 # ffffffffc0202248 <commands+0x720>
ffffffffc0200b7e:	00001617          	auipc	a2,0x1
ffffffffc0200b82:	5f260613          	addi	a2,a2,1522 # ffffffffc0202170 <commands+0x648>
ffffffffc0200b86:	0c500593          	li	a1,197
ffffffffc0200b8a:	00001517          	auipc	a0,0x1
ffffffffc0200b8e:	5fe50513          	addi	a0,a0,1534 # ffffffffc0202188 <commands+0x660>
ffffffffc0200b92:	81bff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b96:	00001697          	auipc	a3,0x1
ffffffffc0200b9a:	6f268693          	addi	a3,a3,1778 # ffffffffc0202288 <commands+0x760>
ffffffffc0200b9e:	00001617          	auipc	a2,0x1
ffffffffc0200ba2:	5d260613          	addi	a2,a2,1490 # ffffffffc0202170 <commands+0x648>
ffffffffc0200ba6:	0c700593          	li	a1,199
ffffffffc0200baa:	00001517          	auipc	a0,0x1
ffffffffc0200bae:	5de50513          	addi	a0,a0,1502 # ffffffffc0202188 <commands+0x660>
ffffffffc0200bb2:	ffaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200bb6:	00001697          	auipc	a3,0x1
ffffffffc0200bba:	75a68693          	addi	a3,a3,1882 # ffffffffc0202310 <commands+0x7e8>
ffffffffc0200bbe:	00001617          	auipc	a2,0x1
ffffffffc0200bc2:	5b260613          	addi	a2,a2,1458 # ffffffffc0202170 <commands+0x648>
ffffffffc0200bc6:	0e000593          	li	a1,224
ffffffffc0200bca:	00001517          	auipc	a0,0x1
ffffffffc0200bce:	5be50513          	addi	a0,a0,1470 # ffffffffc0202188 <commands+0x660>
ffffffffc0200bd2:	fdaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200bd6:	00001697          	auipc	a3,0x1
ffffffffc0200bda:	62a68693          	addi	a3,a3,1578 # ffffffffc0202200 <commands+0x6d8>
ffffffffc0200bde:	00001617          	auipc	a2,0x1
ffffffffc0200be2:	59260613          	addi	a2,a2,1426 # ffffffffc0202170 <commands+0x648>
ffffffffc0200be6:	0c200593          	li	a1,194
ffffffffc0200bea:	00001517          	auipc	a0,0x1
ffffffffc0200bee:	59e50513          	addi	a0,a0,1438 # ffffffffc0202188 <commands+0x660>
ffffffffc0200bf2:	fbaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200bf6:	00002697          	auipc	a3,0x2
ffffffffc0200bfa:	84a68693          	addi	a3,a3,-1974 # ffffffffc0202440 <commands+0x918>
ffffffffc0200bfe:	00001617          	auipc	a2,0x1
ffffffffc0200c02:	57260613          	addi	a2,a2,1394 # ffffffffc0202170 <commands+0x648>
ffffffffc0200c06:	13a00593          	li	a1,314
ffffffffc0200c0a:	00001517          	auipc	a0,0x1
ffffffffc0200c0e:	57e50513          	addi	a0,a0,1406 # ffffffffc0202188 <commands+0x660>
ffffffffc0200c12:	f9aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200c16:	00001697          	auipc	a3,0x1
ffffffffc0200c1a:	58a68693          	addi	a3,a3,1418 # ffffffffc02021a0 <commands+0x678>
ffffffffc0200c1e:	00001617          	auipc	a2,0x1
ffffffffc0200c22:	55260613          	addi	a2,a2,1362 # ffffffffc0202170 <commands+0x648>
ffffffffc0200c26:	0fb00593          	li	a1,251
ffffffffc0200c2a:	00001517          	auipc	a0,0x1
ffffffffc0200c2e:	55e50513          	addi	a0,a0,1374 # ffffffffc0202188 <commands+0x660>
ffffffffc0200c32:	f7aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c36:	00001697          	auipc	a3,0x1
ffffffffc0200c3a:	5aa68693          	addi	a3,a3,1450 # ffffffffc02021e0 <commands+0x6b8>
ffffffffc0200c3e:	00001617          	auipc	a2,0x1
ffffffffc0200c42:	53260613          	addi	a2,a2,1330 # ffffffffc0202170 <commands+0x648>
ffffffffc0200c46:	0c100593          	li	a1,193
ffffffffc0200c4a:	00001517          	auipc	a0,0x1
ffffffffc0200c4e:	53e50513          	addi	a0,a0,1342 # ffffffffc0202188 <commands+0x660>
ffffffffc0200c52:	f5aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c56:	00001697          	auipc	a3,0x1
ffffffffc0200c5a:	56a68693          	addi	a3,a3,1386 # ffffffffc02021c0 <commands+0x698>
ffffffffc0200c5e:	00001617          	auipc	a2,0x1
ffffffffc0200c62:	51260613          	addi	a2,a2,1298 # ffffffffc0202170 <commands+0x648>
ffffffffc0200c66:	0c000593          	li	a1,192
ffffffffc0200c6a:	00001517          	auipc	a0,0x1
ffffffffc0200c6e:	51e50513          	addi	a0,a0,1310 # ffffffffc0202188 <commands+0x660>
ffffffffc0200c72:	f3aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200c76:	00001697          	auipc	a3,0x1
ffffffffc0200c7a:	67268693          	addi	a3,a3,1650 # ffffffffc02022e8 <commands+0x7c0>
ffffffffc0200c7e:	00001617          	auipc	a2,0x1
ffffffffc0200c82:	4f260613          	addi	a2,a2,1266 # ffffffffc0202170 <commands+0x648>
ffffffffc0200c86:	0dd00593          	li	a1,221
ffffffffc0200c8a:	00001517          	auipc	a0,0x1
ffffffffc0200c8e:	4fe50513          	addi	a0,a0,1278 # ffffffffc0202188 <commands+0x660>
ffffffffc0200c92:	f1aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c96:	00001697          	auipc	a3,0x1
ffffffffc0200c9a:	56a68693          	addi	a3,a3,1386 # ffffffffc0202200 <commands+0x6d8>
ffffffffc0200c9e:	00001617          	auipc	a2,0x1
ffffffffc0200ca2:	4d260613          	addi	a2,a2,1234 # ffffffffc0202170 <commands+0x648>
ffffffffc0200ca6:	0db00593          	li	a1,219
ffffffffc0200caa:	00001517          	auipc	a0,0x1
ffffffffc0200cae:	4de50513          	addi	a0,a0,1246 # ffffffffc0202188 <commands+0x660>
ffffffffc0200cb2:	efaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cb6:	00001697          	auipc	a3,0x1
ffffffffc0200cba:	52a68693          	addi	a3,a3,1322 # ffffffffc02021e0 <commands+0x6b8>
ffffffffc0200cbe:	00001617          	auipc	a2,0x1
ffffffffc0200cc2:	4b260613          	addi	a2,a2,1202 # ffffffffc0202170 <commands+0x648>
ffffffffc0200cc6:	0da00593          	li	a1,218
ffffffffc0200cca:	00001517          	auipc	a0,0x1
ffffffffc0200cce:	4be50513          	addi	a0,a0,1214 # ffffffffc0202188 <commands+0x660>
ffffffffc0200cd2:	edaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cd6:	00001697          	auipc	a3,0x1
ffffffffc0200cda:	4ea68693          	addi	a3,a3,1258 # ffffffffc02021c0 <commands+0x698>
ffffffffc0200cde:	00001617          	auipc	a2,0x1
ffffffffc0200ce2:	49260613          	addi	a2,a2,1170 # ffffffffc0202170 <commands+0x648>
ffffffffc0200ce6:	0d900593          	li	a1,217
ffffffffc0200cea:	00001517          	auipc	a0,0x1
ffffffffc0200cee:	49e50513          	addi	a0,a0,1182 # ffffffffc0202188 <commands+0x660>
ffffffffc0200cf2:	ebaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200cf6:	00001697          	auipc	a3,0x1
ffffffffc0200cfa:	60a68693          	addi	a3,a3,1546 # ffffffffc0202300 <commands+0x7d8>
ffffffffc0200cfe:	00001617          	auipc	a2,0x1
ffffffffc0200d02:	47260613          	addi	a2,a2,1138 # ffffffffc0202170 <commands+0x648>
ffffffffc0200d06:	0d700593          	li	a1,215
ffffffffc0200d0a:	00001517          	auipc	a0,0x1
ffffffffc0200d0e:	47e50513          	addi	a0,a0,1150 # ffffffffc0202188 <commands+0x660>
ffffffffc0200d12:	e9aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d16:	00001697          	auipc	a3,0x1
ffffffffc0200d1a:	5d268693          	addi	a3,a3,1490 # ffffffffc02022e8 <commands+0x7c0>
ffffffffc0200d1e:	00001617          	auipc	a2,0x1
ffffffffc0200d22:	45260613          	addi	a2,a2,1106 # ffffffffc0202170 <commands+0x648>
ffffffffc0200d26:	0d200593          	li	a1,210
ffffffffc0200d2a:	00001517          	auipc	a0,0x1
ffffffffc0200d2e:	45e50513          	addi	a0,a0,1118 # ffffffffc0202188 <commands+0x660>
ffffffffc0200d32:	e7aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200d36:	00001697          	auipc	a3,0x1
ffffffffc0200d3a:	59268693          	addi	a3,a3,1426 # ffffffffc02022c8 <commands+0x7a0>
ffffffffc0200d3e:	00001617          	auipc	a2,0x1
ffffffffc0200d42:	43260613          	addi	a2,a2,1074 # ffffffffc0202170 <commands+0x648>
ffffffffc0200d46:	0c900593          	li	a1,201
ffffffffc0200d4a:	00001517          	auipc	a0,0x1
ffffffffc0200d4e:	43e50513          	addi	a0,a0,1086 # ffffffffc0202188 <commands+0x660>
ffffffffc0200d52:	e5aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200d56:	00001697          	auipc	a3,0x1
ffffffffc0200d5a:	55268693          	addi	a3,a3,1362 # ffffffffc02022a8 <commands+0x780>
ffffffffc0200d5e:	00001617          	auipc	a2,0x1
ffffffffc0200d62:	41260613          	addi	a2,a2,1042 # ffffffffc0202170 <commands+0x648>
ffffffffc0200d66:	0c800593          	li	a1,200
ffffffffc0200d6a:	00001517          	auipc	a0,0x1
ffffffffc0200d6e:	41e50513          	addi	a0,a0,1054 # ffffffffc0202188 <commands+0x660>
ffffffffc0200d72:	e3aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200d76:	00001697          	auipc	a3,0x1
ffffffffc0200d7a:	6ba68693          	addi	a3,a3,1722 # ffffffffc0202430 <commands+0x908>
ffffffffc0200d7e:	00001617          	auipc	a2,0x1
ffffffffc0200d82:	3f260613          	addi	a2,a2,1010 # ffffffffc0202170 <commands+0x648>
ffffffffc0200d86:	13900593          	li	a1,313
ffffffffc0200d8a:	00001517          	auipc	a0,0x1
ffffffffc0200d8e:	3fe50513          	addi	a0,a0,1022 # ffffffffc0202188 <commands+0x660>
ffffffffc0200d92:	e1aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200d96:	00001697          	auipc	a3,0x1
ffffffffc0200d9a:	5b268693          	addi	a3,a3,1458 # ffffffffc0202348 <commands+0x820>
ffffffffc0200d9e:	00001617          	auipc	a2,0x1
ffffffffc0200da2:	3d260613          	addi	a2,a2,978 # ffffffffc0202170 <commands+0x648>
ffffffffc0200da6:	12e00593          	li	a1,302
ffffffffc0200daa:	00001517          	auipc	a0,0x1
ffffffffc0200dae:	3de50513          	addi	a0,a0,990 # ffffffffc0202188 <commands+0x660>
ffffffffc0200db2:	dfaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200db6:	00001697          	auipc	a3,0x1
ffffffffc0200dba:	53268693          	addi	a3,a3,1330 # ffffffffc02022e8 <commands+0x7c0>
ffffffffc0200dbe:	00001617          	auipc	a2,0x1
ffffffffc0200dc2:	3b260613          	addi	a2,a2,946 # ffffffffc0202170 <commands+0x648>
ffffffffc0200dc6:	12800593          	li	a1,296
ffffffffc0200dca:	00001517          	auipc	a0,0x1
ffffffffc0200dce:	3be50513          	addi	a0,a0,958 # ffffffffc0202188 <commands+0x660>
ffffffffc0200dd2:	ddaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200dd6:	00001697          	auipc	a3,0x1
ffffffffc0200dda:	63a68693          	addi	a3,a3,1594 # ffffffffc0202410 <commands+0x8e8>
ffffffffc0200dde:	00001617          	auipc	a2,0x1
ffffffffc0200de2:	39260613          	addi	a2,a2,914 # ffffffffc0202170 <commands+0x648>
ffffffffc0200de6:	12700593          	li	a1,295
ffffffffc0200dea:	00001517          	auipc	a0,0x1
ffffffffc0200dee:	39e50513          	addi	a0,a0,926 # ffffffffc0202188 <commands+0x660>
ffffffffc0200df2:	dbaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200df6:	00001697          	auipc	a3,0x1
ffffffffc0200dfa:	60a68693          	addi	a3,a3,1546 # ffffffffc0202400 <commands+0x8d8>
ffffffffc0200dfe:	00001617          	auipc	a2,0x1
ffffffffc0200e02:	37260613          	addi	a2,a2,882 # ffffffffc0202170 <commands+0x648>
ffffffffc0200e06:	11f00593          	li	a1,287
ffffffffc0200e0a:	00001517          	auipc	a0,0x1
ffffffffc0200e0e:	37e50513          	addi	a0,a0,894 # ffffffffc0202188 <commands+0x660>
ffffffffc0200e12:	d9aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200e16:	00001697          	auipc	a3,0x1
ffffffffc0200e1a:	5d268693          	addi	a3,a3,1490 # ffffffffc02023e8 <commands+0x8c0>
ffffffffc0200e1e:	00001617          	auipc	a2,0x1
ffffffffc0200e22:	35260613          	addi	a2,a2,850 # ffffffffc0202170 <commands+0x648>
ffffffffc0200e26:	11e00593          	li	a1,286
ffffffffc0200e2a:	00001517          	auipc	a0,0x1
ffffffffc0200e2e:	35e50513          	addi	a0,a0,862 # ffffffffc0202188 <commands+0x660>
ffffffffc0200e32:	d7aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200e36:	00001697          	auipc	a3,0x1
ffffffffc0200e3a:	59268693          	addi	a3,a3,1426 # ffffffffc02023c8 <commands+0x8a0>
ffffffffc0200e3e:	00001617          	auipc	a2,0x1
ffffffffc0200e42:	33260613          	addi	a2,a2,818 # ffffffffc0202170 <commands+0x648>
ffffffffc0200e46:	11d00593          	li	a1,285
ffffffffc0200e4a:	00001517          	auipc	a0,0x1
ffffffffc0200e4e:	33e50513          	addi	a0,a0,830 # ffffffffc0202188 <commands+0x660>
ffffffffc0200e52:	d5aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200e56:	00001697          	auipc	a3,0x1
ffffffffc0200e5a:	54268693          	addi	a3,a3,1346 # ffffffffc0202398 <commands+0x870>
ffffffffc0200e5e:	00001617          	auipc	a2,0x1
ffffffffc0200e62:	31260613          	addi	a2,a2,786 # ffffffffc0202170 <commands+0x648>
ffffffffc0200e66:	11b00593          	li	a1,283
ffffffffc0200e6a:	00001517          	auipc	a0,0x1
ffffffffc0200e6e:	31e50513          	addi	a0,a0,798 # ffffffffc0202188 <commands+0x660>
ffffffffc0200e72:	d3aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200e76:	00001697          	auipc	a3,0x1
ffffffffc0200e7a:	50a68693          	addi	a3,a3,1290 # ffffffffc0202380 <commands+0x858>
ffffffffc0200e7e:	00001617          	auipc	a2,0x1
ffffffffc0200e82:	2f260613          	addi	a2,a2,754 # ffffffffc0202170 <commands+0x648>
ffffffffc0200e86:	11a00593          	li	a1,282
ffffffffc0200e8a:	00001517          	auipc	a0,0x1
ffffffffc0200e8e:	2fe50513          	addi	a0,a0,766 # ffffffffc0202188 <commands+0x660>
ffffffffc0200e92:	d1aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e96:	00001697          	auipc	a3,0x1
ffffffffc0200e9a:	45268693          	addi	a3,a3,1106 # ffffffffc02022e8 <commands+0x7c0>
ffffffffc0200e9e:	00001617          	auipc	a2,0x1
ffffffffc0200ea2:	2d260613          	addi	a2,a2,722 # ffffffffc0202170 <commands+0x648>
ffffffffc0200ea6:	10e00593          	li	a1,270
ffffffffc0200eaa:	00001517          	auipc	a0,0x1
ffffffffc0200eae:	2de50513          	addi	a0,a0,734 # ffffffffc0202188 <commands+0x660>
ffffffffc0200eb2:	cfaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200eb6:	00001697          	auipc	a3,0x1
ffffffffc0200eba:	4b268693          	addi	a3,a3,1202 # ffffffffc0202368 <commands+0x840>
ffffffffc0200ebe:	00001617          	auipc	a2,0x1
ffffffffc0200ec2:	2b260613          	addi	a2,a2,690 # ffffffffc0202170 <commands+0x648>
ffffffffc0200ec6:	10500593          	li	a1,261
ffffffffc0200eca:	00001517          	auipc	a0,0x1
ffffffffc0200ece:	2be50513          	addi	a0,a0,702 # ffffffffc0202188 <commands+0x660>
ffffffffc0200ed2:	cdaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200ed6:	00001697          	auipc	a3,0x1
ffffffffc0200eda:	48268693          	addi	a3,a3,1154 # ffffffffc0202358 <commands+0x830>
ffffffffc0200ede:	00001617          	auipc	a2,0x1
ffffffffc0200ee2:	29260613          	addi	a2,a2,658 # ffffffffc0202170 <commands+0x648>
ffffffffc0200ee6:	10400593          	li	a1,260
ffffffffc0200eea:	00001517          	auipc	a0,0x1
ffffffffc0200eee:	29e50513          	addi	a0,a0,670 # ffffffffc0202188 <commands+0x660>
ffffffffc0200ef2:	cbaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200ef6:	00001697          	auipc	a3,0x1
ffffffffc0200efa:	45268693          	addi	a3,a3,1106 # ffffffffc0202348 <commands+0x820>
ffffffffc0200efe:	00001617          	auipc	a2,0x1
ffffffffc0200f02:	27260613          	addi	a2,a2,626 # ffffffffc0202170 <commands+0x648>
ffffffffc0200f06:	0e600593          	li	a1,230
ffffffffc0200f0a:	00001517          	auipc	a0,0x1
ffffffffc0200f0e:	27e50513          	addi	a0,a0,638 # ffffffffc0202188 <commands+0x660>
ffffffffc0200f12:	c9aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f16:	00001697          	auipc	a3,0x1
ffffffffc0200f1a:	3d268693          	addi	a3,a3,978 # ffffffffc02022e8 <commands+0x7c0>
ffffffffc0200f1e:	00001617          	auipc	a2,0x1
ffffffffc0200f22:	25260613          	addi	a2,a2,594 # ffffffffc0202170 <commands+0x648>
ffffffffc0200f26:	0e400593          	li	a1,228
ffffffffc0200f2a:	00001517          	auipc	a0,0x1
ffffffffc0200f2e:	25e50513          	addi	a0,a0,606 # ffffffffc0202188 <commands+0x660>
ffffffffc0200f32:	c7aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f36:	00001697          	auipc	a3,0x1
ffffffffc0200f3a:	3f268693          	addi	a3,a3,1010 # ffffffffc0202328 <commands+0x800>
ffffffffc0200f3e:	00001617          	auipc	a2,0x1
ffffffffc0200f42:	23260613          	addi	a2,a2,562 # ffffffffc0202170 <commands+0x648>
ffffffffc0200f46:	0e300593          	li	a1,227
ffffffffc0200f4a:	00001517          	auipc	a0,0x1
ffffffffc0200f4e:	23e50513          	addi	a0,a0,574 # ffffffffc0202188 <commands+0x660>
ffffffffc0200f52:	c5aff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200f56 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0200f56:	1141                	addi	sp,sp,-16
ffffffffc0200f58:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200f5a:	10058963          	beqz	a1,ffffffffc020106c <best_fit_free_pages+0x116>
    for (; p != base + n; p ++) {
ffffffffc0200f5e:	00259793          	slli	a5,a1,0x2
ffffffffc0200f62:	00b786b3          	add	a3,a5,a1
ffffffffc0200f66:	068e                	slli	a3,a3,0x3
ffffffffc0200f68:	96aa                	add	a3,a3,a0
ffffffffc0200f6a:	02d50963          	beq	a0,a3,ffffffffc0200f9c <best_fit_free_pages+0x46>
ffffffffc0200f6e:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200f70:	8b85                	andi	a5,a5,1
ffffffffc0200f72:	efe9                	bnez	a5,ffffffffc020104c <best_fit_free_pages+0xf6>
ffffffffc0200f74:	651c                	ld	a5,8(a0)
ffffffffc0200f76:	8385                	srli	a5,a5,0x1
ffffffffc0200f78:	8b85                	andi	a5,a5,1
ffffffffc0200f7a:	ebe9                	bnez	a5,ffffffffc020104c <best_fit_free_pages+0xf6>
ffffffffc0200f7c:	87aa                	mv	a5,a0
ffffffffc0200f7e:	a039                	j	ffffffffc0200f8c <best_fit_free_pages+0x36>
ffffffffc0200f80:	6798                	ld	a4,8(a5)
ffffffffc0200f82:	8b05                	andi	a4,a4,1
ffffffffc0200f84:	e761                	bnez	a4,ffffffffc020104c <best_fit_free_pages+0xf6>
ffffffffc0200f86:	6798                	ld	a4,8(a5)
ffffffffc0200f88:	8b09                	andi	a4,a4,2
ffffffffc0200f8a:	e369                	bnez	a4,ffffffffc020104c <best_fit_free_pages+0xf6>
        p->flags = 0;
ffffffffc0200f8c:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200f90:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200f94:	02878793          	addi	a5,a5,40
ffffffffc0200f98:	fed794e3          	bne	a5,a3,ffffffffc0200f80 <best_fit_free_pages+0x2a>
    return list->next == list;
ffffffffc0200f9c:	00005697          	auipc	a3,0x5
ffffffffc0200fa0:	49c68693          	addi	a3,a3,1180 # ffffffffc0206438 <free_area>
ffffffffc0200fa4:	669c                	ld	a5,8(a3)
    if (list_empty(&free_list)) {
ffffffffc0200fa6:	08d78a63          	beq	a5,a3,ffffffffc020103a <best_fit_free_pages+0xe4>
            struct Page* page = le2page(le, page_link);
ffffffffc0200faa:	fe878713          	addi	a4,a5,-24
ffffffffc0200fae:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0200fb0:	4801                	li	a6,0
ffffffffc0200fb2:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0200fb6:	00e56a63          	bltu	a0,a4,ffffffffc0200fca <best_fit_free_pages+0x74>
    return listelm->next;
ffffffffc0200fba:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0200fbc:	06d70163          	beq	a4,a3,ffffffffc020101e <best_fit_free_pages+0xc8>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200fc0:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0200fc2:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0200fc6:	fee57ae3          	bleu	a4,a0,ffffffffc0200fba <best_fit_free_pages+0x64>
ffffffffc0200fca:	00080663          	beqz	a6,ffffffffc0200fd6 <best_fit_free_pages+0x80>
ffffffffc0200fce:	00005697          	auipc	a3,0x5
ffffffffc0200fd2:	46b6b523          	sd	a1,1130(a3) # ffffffffc0206438 <free_area>
        if (base + base->property == p) {
ffffffffc0200fd6:	01052883          	lw	a7,16(a0)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200fda:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200fdc:	e390                	sd	a2,0(a5)
ffffffffc0200fde:	02089813          	slli	a6,a7,0x20
ffffffffc0200fe2:	02085813          	srli	a6,a6,0x20
ffffffffc0200fe6:	00281693          	slli	a3,a6,0x2
ffffffffc0200fea:	96c2                	add	a3,a3,a6
ffffffffc0200fec:	e590                	sd	a2,8(a1)
ffffffffc0200fee:	068e                	slli	a3,a3,0x3
    elm->next = next;
ffffffffc0200ff0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200ff2:	ed0c                	sd	a1,24(a0)
ffffffffc0200ff4:	96aa                	add	a3,a3,a0
ffffffffc0200ff6:	02d71f63          	bne	a4,a3,ffffffffc0201034 <best_fit_free_pages+0xde>
            base->property += p->property;
ffffffffc0200ffa:	ff87a703          	lw	a4,-8(a5)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200ffe:	ff078693          	addi	a3,a5,-16
ffffffffc0201002:	011708bb          	addw	a7,a4,a7
ffffffffc0201006:	01152823          	sw	a7,16(a0)
ffffffffc020100a:	5775                	li	a4,-3
ffffffffc020100c:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201010:	6398                	ld	a4,0(a5)
ffffffffc0201012:	679c                	ld	a5,8(a5)
}
ffffffffc0201014:	60a2                	ld	ra,8(sp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201016:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201018:	e398                	sd	a4,0(a5)
ffffffffc020101a:	0141                	addi	sp,sp,16
ffffffffc020101c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020101e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201020:	f114                	sd	a3,32(a0)
ffffffffc0201022:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201024:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201026:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201028:	00d70563          	beq	a4,a3,ffffffffc0201032 <best_fit_free_pages+0xdc>
ffffffffc020102c:	4805                	li	a6,1
ffffffffc020102e:	87ba                	mv	a5,a4
ffffffffc0201030:	bf49                	j	ffffffffc0200fc2 <best_fit_free_pages+0x6c>
ffffffffc0201032:	e290                	sd	a2,0(a3)
}
ffffffffc0201034:	60a2                	ld	ra,8(sp)
ffffffffc0201036:	0141                	addi	sp,sp,16
ffffffffc0201038:	8082                	ret
ffffffffc020103a:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020103c:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201040:	e398                	sd	a4,0(a5)
ffffffffc0201042:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201044:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201046:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201048:	0141                	addi	sp,sp,16
ffffffffc020104a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020104c:	00001697          	auipc	a3,0x1
ffffffffc0201050:	40468693          	addi	a3,a3,1028 # ffffffffc0202450 <commands+0x928>
ffffffffc0201054:	00001617          	auipc	a2,0x1
ffffffffc0201058:	11c60613          	addi	a2,a2,284 # ffffffffc0202170 <commands+0x648>
ffffffffc020105c:	08900593          	li	a1,137
ffffffffc0201060:	00001517          	auipc	a0,0x1
ffffffffc0201064:	12850513          	addi	a0,a0,296 # ffffffffc0202188 <commands+0x660>
ffffffffc0201068:	b44ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc020106c:	00001697          	auipc	a3,0x1
ffffffffc0201070:	40c68693          	addi	a3,a3,1036 # ffffffffc0202478 <commands+0x950>
ffffffffc0201074:	00001617          	auipc	a2,0x1
ffffffffc0201078:	0fc60613          	addi	a2,a2,252 # ffffffffc0202170 <commands+0x648>
ffffffffc020107c:	08600593          	li	a1,134
ffffffffc0201080:	00001517          	auipc	a0,0x1
ffffffffc0201084:	10850513          	addi	a0,a0,264 # ffffffffc0202188 <commands+0x660>
ffffffffc0201088:	b24ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020108c <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc020108c:	cd51                	beqz	a0,ffffffffc0201128 <best_fit_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc020108e:	00005597          	auipc	a1,0x5
ffffffffc0201092:	3aa58593          	addi	a1,a1,938 # ffffffffc0206438 <free_area>
ffffffffc0201096:	0105a803          	lw	a6,16(a1)
ffffffffc020109a:	862a                	mv	a2,a0
ffffffffc020109c:	02081793          	slli	a5,a6,0x20
ffffffffc02010a0:	9381                	srli	a5,a5,0x20
ffffffffc02010a2:	00a7ee63          	bltu	a5,a0,ffffffffc02010be <best_fit_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02010a6:	87ae                	mv	a5,a1
ffffffffc02010a8:	a801                	j	ffffffffc02010b8 <best_fit_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02010aa:	ff87a703          	lw	a4,-8(a5)
ffffffffc02010ae:	02071693          	slli	a3,a4,0x20
ffffffffc02010b2:	9281                	srli	a3,a3,0x20
ffffffffc02010b4:	00c6f763          	bleu	a2,a3,ffffffffc02010c2 <best_fit_alloc_pages+0x36>
    return listelm->next;
ffffffffc02010b8:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010ba:	feb798e3          	bne	a5,a1,ffffffffc02010aa <best_fit_alloc_pages+0x1e>
        return NULL;
ffffffffc02010be:	4501                	li	a0,0
}
ffffffffc02010c0:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02010c2:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc02010c6:	dd6d                	beqz	a0,ffffffffc02010c0 <best_fit_alloc_pages+0x34>
    return listelm->prev;
ffffffffc02010c8:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02010cc:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc02010d0:	00060e1b          	sext.w	t3,a2
ffffffffc02010d4:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02010d8:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02010dc:	02d67b63          	bleu	a3,a2,ffffffffc0201112 <best_fit_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc02010e0:	00261693          	slli	a3,a2,0x2
ffffffffc02010e4:	96b2                	add	a3,a3,a2
ffffffffc02010e6:	068e                	slli	a3,a3,0x3
ffffffffc02010e8:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02010ea:	41c7073b          	subw	a4,a4,t3
ffffffffc02010ee:	ca98                	sw	a4,16(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02010f0:	00868613          	addi	a2,a3,8
ffffffffc02010f4:	4709                	li	a4,2
ffffffffc02010f6:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02010fa:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02010fe:	01868613          	addi	a2,a3,24
    prev->next = next->prev = elm;
ffffffffc0201102:	0105a803          	lw	a6,16(a1)
ffffffffc0201106:	e310                	sd	a2,0(a4)
ffffffffc0201108:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc020110c:	f298                	sd	a4,32(a3)
    elm->prev = prev;
ffffffffc020110e:	0116bc23          	sd	a7,24(a3)
        nr_free -= n;
ffffffffc0201112:	41c8083b          	subw	a6,a6,t3
ffffffffc0201116:	00005717          	auipc	a4,0x5
ffffffffc020111a:	33072923          	sw	a6,818(a4) # ffffffffc0206448 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020111e:	5775                	li	a4,-3
ffffffffc0201120:	17c1                	addi	a5,a5,-16
ffffffffc0201122:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201126:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0201128:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020112a:	00001697          	auipc	a3,0x1
ffffffffc020112e:	34e68693          	addi	a3,a3,846 # ffffffffc0202478 <commands+0x950>
ffffffffc0201132:	00001617          	auipc	a2,0x1
ffffffffc0201136:	03e60613          	addi	a2,a2,62 # ffffffffc0202170 <commands+0x648>
ffffffffc020113a:	06200593          	li	a1,98
ffffffffc020113e:	00001517          	auipc	a0,0x1
ffffffffc0201142:	04a50513          	addi	a0,a0,74 # ffffffffc0202188 <commands+0x660>
best_fit_alloc_pages(size_t n) {
ffffffffc0201146:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201148:	a64ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020114c <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc020114c:	1141                	addi	sp,sp,-16
ffffffffc020114e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201150:	c5d9                	beqz	a1,ffffffffc02011de <best_fit_init_memmap+0x92>
    for (; p != base + n; p ++) {
ffffffffc0201152:	00259693          	slli	a3,a1,0x2
ffffffffc0201156:	96ae                	add	a3,a3,a1
ffffffffc0201158:	068e                	slli	a3,a3,0x3
ffffffffc020115a:	96aa                	add	a3,a3,a0
ffffffffc020115c:	00d50e63          	beq	a0,a3,ffffffffc0201178 <best_fit_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201160:	651c                	ld	a5,8(a0)
        assert(PageReserved(p));
ffffffffc0201162:	8b85                	andi	a5,a5,1
ffffffffc0201164:	cfa9                	beqz	a5,ffffffffc02011be <best_fit_init_memmap+0x72>
ffffffffc0201166:	87aa                	mv	a5,a0
ffffffffc0201168:	a021                	j	ffffffffc0201170 <best_fit_init_memmap+0x24>
ffffffffc020116a:	6798                	ld	a4,8(a5)
ffffffffc020116c:	8b05                	andi	a4,a4,1
ffffffffc020116e:	cb21                	beqz	a4,ffffffffc02011be <best_fit_init_memmap+0x72>
    for (; p != base + n; p ++) {
ffffffffc0201170:	02878793          	addi	a5,a5,40
ffffffffc0201174:	fed79be3          	bne	a5,a3,ffffffffc020116a <best_fit_init_memmap+0x1e>
    base->property = n;
ffffffffc0201178:	2581                	sext.w	a1,a1
ffffffffc020117a:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020117c:	4789                	li	a5,2
ffffffffc020117e:	00850713          	addi	a4,a0,8
ffffffffc0201182:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201186:	00005717          	auipc	a4,0x5
ffffffffc020118a:	2b270713          	addi	a4,a4,690 # ffffffffc0206438 <free_area>
ffffffffc020118e:	4b14                	lw	a3,16(a4)
    return list->next == list;
ffffffffc0201190:	671c                	ld	a5,8(a4)
ffffffffc0201192:	9db5                	addw	a1,a1,a3
ffffffffc0201194:	00005697          	auipc	a3,0x5
ffffffffc0201198:	2ab6aa23          	sw	a1,692(a3) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020119c:	00e78863          	beq	a5,a4,ffffffffc02011ac <best_fit_init_memmap+0x60>
ffffffffc02011a0:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02011a2:	fee79fe3          	bne	a5,a4,ffffffffc02011a0 <best_fit_init_memmap+0x54>
}
ffffffffc02011a6:	60a2                	ld	ra,8(sp)
ffffffffc02011a8:	0141                	addi	sp,sp,16
ffffffffc02011aa:	8082                	ret
ffffffffc02011ac:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02011ae:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02011b2:	e398                	sd	a4,0(a5)
ffffffffc02011b4:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02011b6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011b8:	ed1c                	sd	a5,24(a0)
}
ffffffffc02011ba:	0141                	addi	sp,sp,16
ffffffffc02011bc:	8082                	ret
        assert(PageReserved(p));
ffffffffc02011be:	00001697          	auipc	a3,0x1
ffffffffc02011c2:	2c268693          	addi	a3,a3,706 # ffffffffc0202480 <commands+0x958>
ffffffffc02011c6:	00001617          	auipc	a2,0x1
ffffffffc02011ca:	faa60613          	addi	a2,a2,-86 # ffffffffc0202170 <commands+0x648>
ffffffffc02011ce:	04a00593          	li	a1,74
ffffffffc02011d2:	00001517          	auipc	a0,0x1
ffffffffc02011d6:	fb650513          	addi	a0,a0,-74 # ffffffffc0202188 <commands+0x660>
ffffffffc02011da:	9d2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02011de:	00001697          	auipc	a3,0x1
ffffffffc02011e2:	29a68693          	addi	a3,a3,666 # ffffffffc0202478 <commands+0x950>
ffffffffc02011e6:	00001617          	auipc	a2,0x1
ffffffffc02011ea:	f8a60613          	addi	a2,a2,-118 # ffffffffc0202170 <commands+0x648>
ffffffffc02011ee:	04700593          	li	a1,71
ffffffffc02011f2:	00001517          	auipc	a0,0x1
ffffffffc02011f6:	f9650513          	addi	a0,a0,-106 # ffffffffc0202188 <commands+0x660>
ffffffffc02011fa:	9b2ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02011fe <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02011fe:	100027f3          	csrr	a5,sstatus
ffffffffc0201202:	8b89                	andi	a5,a5,2
ffffffffc0201204:	eb89                	bnez	a5,ffffffffc0201216 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201206:	00005797          	auipc	a5,0x5
ffffffffc020120a:	25278793          	addi	a5,a5,594 # ffffffffc0206458 <pmm_manager>
ffffffffc020120e:	639c                	ld	a5,0(a5)
ffffffffc0201210:	0187b303          	ld	t1,24(a5)
ffffffffc0201214:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0201216:	1141                	addi	sp,sp,-16
ffffffffc0201218:	e406                	sd	ra,8(sp)
ffffffffc020121a:	e022                	sd	s0,0(sp)
ffffffffc020121c:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020121e:	a46ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201222:	00005797          	auipc	a5,0x5
ffffffffc0201226:	23678793          	addi	a5,a5,566 # ffffffffc0206458 <pmm_manager>
ffffffffc020122a:	639c                	ld	a5,0(a5)
ffffffffc020122c:	8522                	mv	a0,s0
ffffffffc020122e:	6f9c                	ld	a5,24(a5)
ffffffffc0201230:	9782                	jalr	a5
ffffffffc0201232:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201234:	a2aff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201238:	8522                	mv	a0,s0
ffffffffc020123a:	60a2                	ld	ra,8(sp)
ffffffffc020123c:	6402                	ld	s0,0(sp)
ffffffffc020123e:	0141                	addi	sp,sp,16
ffffffffc0201240:	8082                	ret

ffffffffc0201242 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201242:	100027f3          	csrr	a5,sstatus
ffffffffc0201246:	8b89                	andi	a5,a5,2
ffffffffc0201248:	eb89                	bnez	a5,ffffffffc020125a <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc020124a:	00005797          	auipc	a5,0x5
ffffffffc020124e:	20e78793          	addi	a5,a5,526 # ffffffffc0206458 <pmm_manager>
ffffffffc0201252:	639c                	ld	a5,0(a5)
ffffffffc0201254:	0207b303          	ld	t1,32(a5)
ffffffffc0201258:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020125a:	1101                	addi	sp,sp,-32
ffffffffc020125c:	ec06                	sd	ra,24(sp)
ffffffffc020125e:	e822                	sd	s0,16(sp)
ffffffffc0201260:	e426                	sd	s1,8(sp)
ffffffffc0201262:	842a                	mv	s0,a0
ffffffffc0201264:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201266:	9feff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020126a:	00005797          	auipc	a5,0x5
ffffffffc020126e:	1ee78793          	addi	a5,a5,494 # ffffffffc0206458 <pmm_manager>
ffffffffc0201272:	639c                	ld	a5,0(a5)
ffffffffc0201274:	85a6                	mv	a1,s1
ffffffffc0201276:	8522                	mv	a0,s0
ffffffffc0201278:	739c                	ld	a5,32(a5)
ffffffffc020127a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020127c:	6442                	ld	s0,16(sp)
ffffffffc020127e:	60e2                	ld	ra,24(sp)
ffffffffc0201280:	64a2                	ld	s1,8(sp)
ffffffffc0201282:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201284:	9daff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0201288 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201288:	100027f3          	csrr	a5,sstatus
ffffffffc020128c:	8b89                	andi	a5,a5,2
ffffffffc020128e:	eb89                	bnez	a5,ffffffffc02012a0 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201290:	00005797          	auipc	a5,0x5
ffffffffc0201294:	1c878793          	addi	a5,a5,456 # ffffffffc0206458 <pmm_manager>
ffffffffc0201298:	639c                	ld	a5,0(a5)
ffffffffc020129a:	0287b303          	ld	t1,40(a5)
ffffffffc020129e:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc02012a0:	1141                	addi	sp,sp,-16
ffffffffc02012a2:	e406                	sd	ra,8(sp)
ffffffffc02012a4:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02012a6:	9beff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02012aa:	00005797          	auipc	a5,0x5
ffffffffc02012ae:	1ae78793          	addi	a5,a5,430 # ffffffffc0206458 <pmm_manager>
ffffffffc02012b2:	639c                	ld	a5,0(a5)
ffffffffc02012b4:	779c                	ld	a5,40(a5)
ffffffffc02012b6:	9782                	jalr	a5
ffffffffc02012b8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02012ba:	9a4ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02012be:	8522                	mv	a0,s0
ffffffffc02012c0:	60a2                	ld	ra,8(sp)
ffffffffc02012c2:	6402                	ld	s0,0(sp)
ffffffffc02012c4:	0141                	addi	sp,sp,16
ffffffffc02012c6:	8082                	ret

ffffffffc02012c8 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012c8:	00001797          	auipc	a5,0x1
ffffffffc02012cc:	1c878793          	addi	a5,a5,456 # ffffffffc0202490 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012d0:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02012d2:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012d4:	00001517          	auipc	a0,0x1
ffffffffc02012d8:	20c50513          	addi	a0,a0,524 # ffffffffc02024e0 <best_fit_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc02012dc:	ec06                	sd	ra,24(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012de:	00005717          	auipc	a4,0x5
ffffffffc02012e2:	16f73d23          	sd	a5,378(a4) # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc02012e6:	e822                	sd	s0,16(sp)
ffffffffc02012e8:	e426                	sd	s1,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012ea:	00005417          	auipc	s0,0x5
ffffffffc02012ee:	16e40413          	addi	s0,s0,366 # ffffffffc0206458 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012f2:	dc5fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc02012f6:	601c                	ld	a5,0(s0)
ffffffffc02012f8:	679c                	ld	a5,8(a5)
ffffffffc02012fa:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02012fc:	57f5                	li	a5,-3
ffffffffc02012fe:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201300:	00001517          	auipc	a0,0x1
ffffffffc0201304:	1f850513          	addi	a0,a0,504 # ffffffffc02024f8 <best_fit_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201308:	00005717          	auipc	a4,0x5
ffffffffc020130c:	14f73c23          	sd	a5,344(a4) # ffffffffc0206460 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0201310:	da7fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201314:	46c5                	li	a3,17
ffffffffc0201316:	06ee                	slli	a3,a3,0x1b
ffffffffc0201318:	40100613          	li	a2,1025
ffffffffc020131c:	16fd                	addi	a3,a3,-1
ffffffffc020131e:	0656                	slli	a2,a2,0x15
ffffffffc0201320:	07e005b7          	lui	a1,0x7e00
ffffffffc0201324:	00001517          	auipc	a0,0x1
ffffffffc0201328:	1ec50513          	addi	a0,a0,492 # ffffffffc0202510 <best_fit_pmm_manager+0x80>
ffffffffc020132c:	d8bfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201330:	777d                	lui	a4,0xfffff
ffffffffc0201332:	00006797          	auipc	a5,0x6
ffffffffc0201336:	13d78793          	addi	a5,a5,317 # ffffffffc020746f <end+0xfff>
ffffffffc020133a:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020133c:	00088737          	lui	a4,0x88
ffffffffc0201340:	00005697          	auipc	a3,0x5
ffffffffc0201344:	0ce6bc23          	sd	a4,216(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201348:	4601                	li	a2,0
ffffffffc020134a:	00005717          	auipc	a4,0x5
ffffffffc020134e:	10f73f23          	sd	a5,286(a4) # ffffffffc0206468 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201352:	4681                	li	a3,0
ffffffffc0201354:	00005897          	auipc	a7,0x5
ffffffffc0201358:	0c488893          	addi	a7,a7,196 # ffffffffc0206418 <npage>
ffffffffc020135c:	00005597          	auipc	a1,0x5
ffffffffc0201360:	10c58593          	addi	a1,a1,268 # ffffffffc0206468 <pages>
ffffffffc0201364:	4805                	li	a6,1
ffffffffc0201366:	fff80537          	lui	a0,0xfff80
ffffffffc020136a:	a011                	j	ffffffffc020136e <pmm_init+0xa6>
ffffffffc020136c:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc020136e:	97b2                	add	a5,a5,a2
ffffffffc0201370:	07a1                	addi	a5,a5,8
ffffffffc0201372:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201376:	0008b703          	ld	a4,0(a7)
ffffffffc020137a:	0685                	addi	a3,a3,1
ffffffffc020137c:	02860613          	addi	a2,a2,40
ffffffffc0201380:	00a707b3          	add	a5,a4,a0
ffffffffc0201384:	fef6e4e3          	bltu	a3,a5,ffffffffc020136c <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201388:	6190                	ld	a2,0(a1)
ffffffffc020138a:	00271793          	slli	a5,a4,0x2
ffffffffc020138e:	97ba                	add	a5,a5,a4
ffffffffc0201390:	fec006b7          	lui	a3,0xfec00
ffffffffc0201394:	078e                	slli	a5,a5,0x3
ffffffffc0201396:	96b2                	add	a3,a3,a2
ffffffffc0201398:	96be                	add	a3,a3,a5
ffffffffc020139a:	c02007b7          	lui	a5,0xc0200
ffffffffc020139e:	08f6e863          	bltu	a3,a5,ffffffffc020142e <pmm_init+0x166>
ffffffffc02013a2:	00005497          	auipc	s1,0x5
ffffffffc02013a6:	0be48493          	addi	s1,s1,190 # ffffffffc0206460 <va_pa_offset>
ffffffffc02013aa:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc02013ac:	45c5                	li	a1,17
ffffffffc02013ae:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02013b0:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc02013b2:	04b6e963          	bltu	a3,a1,ffffffffc0201404 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02013b6:	601c                	ld	a5,0(s0)
ffffffffc02013b8:	7b9c                	ld	a5,48(a5)
ffffffffc02013ba:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02013bc:	00001517          	auipc	a0,0x1
ffffffffc02013c0:	1ec50513          	addi	a0,a0,492 # ffffffffc02025a8 <best_fit_pmm_manager+0x118>
ffffffffc02013c4:	cf3fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02013c8:	00004697          	auipc	a3,0x4
ffffffffc02013cc:	c3868693          	addi	a3,a3,-968 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02013d0:	00005797          	auipc	a5,0x5
ffffffffc02013d4:	04d7b823          	sd	a3,80(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02013d8:	c02007b7          	lui	a5,0xc0200
ffffffffc02013dc:	06f6e563          	bltu	a3,a5,ffffffffc0201446 <pmm_init+0x17e>
ffffffffc02013e0:	609c                	ld	a5,0(s1)
}
ffffffffc02013e2:	6442                	ld	s0,16(sp)
ffffffffc02013e4:	60e2                	ld	ra,24(sp)
ffffffffc02013e6:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013e8:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02013ea:	8e9d                	sub	a3,a3,a5
ffffffffc02013ec:	00005797          	auipc	a5,0x5
ffffffffc02013f0:	06d7b223          	sd	a3,100(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013f4:	00001517          	auipc	a0,0x1
ffffffffc02013f8:	1d450513          	addi	a0,a0,468 # ffffffffc02025c8 <best_fit_pmm_manager+0x138>
ffffffffc02013fc:	8636                	mv	a2,a3
}
ffffffffc02013fe:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201400:	cb7fe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201404:	6785                	lui	a5,0x1
ffffffffc0201406:	17fd                	addi	a5,a5,-1
ffffffffc0201408:	96be                	add	a3,a3,a5
ffffffffc020140a:	77fd                	lui	a5,0xfffff
ffffffffc020140c:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020140e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201412:	04e7f663          	bleu	a4,a5,ffffffffc020145e <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0201416:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201418:	97aa                	add	a5,a5,a0
ffffffffc020141a:	00279513          	slli	a0,a5,0x2
ffffffffc020141e:	953e                	add	a0,a0,a5
ffffffffc0201420:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201422:	8d95                	sub	a1,a1,a3
ffffffffc0201424:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201426:	81b1                	srli	a1,a1,0xc
ffffffffc0201428:	9532                	add	a0,a0,a2
ffffffffc020142a:	9782                	jalr	a5
ffffffffc020142c:	b769                	j	ffffffffc02013b6 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020142e:	00001617          	auipc	a2,0x1
ffffffffc0201432:	11260613          	addi	a2,a2,274 # ffffffffc0202540 <best_fit_pmm_manager+0xb0>
ffffffffc0201436:	06e00593          	li	a1,110
ffffffffc020143a:	00001517          	auipc	a0,0x1
ffffffffc020143e:	12e50513          	addi	a0,a0,302 # ffffffffc0202568 <best_fit_pmm_manager+0xd8>
ffffffffc0201442:	f6bfe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201446:	00001617          	auipc	a2,0x1
ffffffffc020144a:	0fa60613          	addi	a2,a2,250 # ffffffffc0202540 <best_fit_pmm_manager+0xb0>
ffffffffc020144e:	08900593          	li	a1,137
ffffffffc0201452:	00001517          	auipc	a0,0x1
ffffffffc0201456:	11650513          	addi	a0,a0,278 # ffffffffc0202568 <best_fit_pmm_manager+0xd8>
ffffffffc020145a:	f53fe0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020145e:	00001617          	auipc	a2,0x1
ffffffffc0201462:	11a60613          	addi	a2,a2,282 # ffffffffc0202578 <best_fit_pmm_manager+0xe8>
ffffffffc0201466:	06b00593          	li	a1,107
ffffffffc020146a:	00001517          	auipc	a0,0x1
ffffffffc020146e:	12e50513          	addi	a0,a0,302 # ffffffffc0202598 <best_fit_pmm_manager+0x108>
ffffffffc0201472:	f3bfe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201476 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201476:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020147a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020147c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201480:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201482:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201486:	f022                	sd	s0,32(sp)
ffffffffc0201488:	ec26                	sd	s1,24(sp)
ffffffffc020148a:	e84a                	sd	s2,16(sp)
ffffffffc020148c:	f406                	sd	ra,40(sp)
ffffffffc020148e:	e44e                	sd	s3,8(sp)
ffffffffc0201490:	84aa                	mv	s1,a0
ffffffffc0201492:	892e                	mv	s2,a1
ffffffffc0201494:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201498:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020149a:	03067e63          	bleu	a6,a2,ffffffffc02014d6 <printnum+0x60>
ffffffffc020149e:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02014a0:	00805763          	blez	s0,ffffffffc02014ae <printnum+0x38>
ffffffffc02014a4:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02014a6:	85ca                	mv	a1,s2
ffffffffc02014a8:	854e                	mv	a0,s3
ffffffffc02014aa:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02014ac:	fc65                	bnez	s0,ffffffffc02014a4 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014ae:	1a02                	slli	s4,s4,0x20
ffffffffc02014b0:	020a5a13          	srli	s4,s4,0x20
ffffffffc02014b4:	00001797          	auipc	a5,0x1
ffffffffc02014b8:	2e478793          	addi	a5,a5,740 # ffffffffc0202798 <error_string+0x38>
ffffffffc02014bc:	9a3e                	add	s4,s4,a5
}
ffffffffc02014be:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014c0:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02014c4:	70a2                	ld	ra,40(sp)
ffffffffc02014c6:	69a2                	ld	s3,8(sp)
ffffffffc02014c8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014ca:	85ca                	mv	a1,s2
ffffffffc02014cc:	8326                	mv	t1,s1
}
ffffffffc02014ce:	6942                	ld	s2,16(sp)
ffffffffc02014d0:	64e2                	ld	s1,24(sp)
ffffffffc02014d2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014d4:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02014d6:	03065633          	divu	a2,a2,a6
ffffffffc02014da:	8722                	mv	a4,s0
ffffffffc02014dc:	f9bff0ef          	jal	ra,ffffffffc0201476 <printnum>
ffffffffc02014e0:	b7f9                	j	ffffffffc02014ae <printnum+0x38>

ffffffffc02014e2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02014e2:	7119                	addi	sp,sp,-128
ffffffffc02014e4:	f4a6                	sd	s1,104(sp)
ffffffffc02014e6:	f0ca                	sd	s2,96(sp)
ffffffffc02014e8:	e8d2                	sd	s4,80(sp)
ffffffffc02014ea:	e4d6                	sd	s5,72(sp)
ffffffffc02014ec:	e0da                	sd	s6,64(sp)
ffffffffc02014ee:	fc5e                	sd	s7,56(sp)
ffffffffc02014f0:	f862                	sd	s8,48(sp)
ffffffffc02014f2:	f06a                	sd	s10,32(sp)
ffffffffc02014f4:	fc86                	sd	ra,120(sp)
ffffffffc02014f6:	f8a2                	sd	s0,112(sp)
ffffffffc02014f8:	ecce                	sd	s3,88(sp)
ffffffffc02014fa:	f466                	sd	s9,40(sp)
ffffffffc02014fc:	ec6e                	sd	s11,24(sp)
ffffffffc02014fe:	892a                	mv	s2,a0
ffffffffc0201500:	84ae                	mv	s1,a1
ffffffffc0201502:	8d32                	mv	s10,a2
ffffffffc0201504:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201506:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201508:	00001a17          	auipc	s4,0x1
ffffffffc020150c:	100a0a13          	addi	s4,s4,256 # ffffffffc0202608 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201510:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201514:	00001c17          	auipc	s8,0x1
ffffffffc0201518:	24cc0c13          	addi	s8,s8,588 # ffffffffc0202760 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020151c:	000d4503          	lbu	a0,0(s10)
ffffffffc0201520:	02500793          	li	a5,37
ffffffffc0201524:	001d0413          	addi	s0,s10,1
ffffffffc0201528:	00f50e63          	beq	a0,a5,ffffffffc0201544 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc020152c:	c521                	beqz	a0,ffffffffc0201574 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020152e:	02500993          	li	s3,37
ffffffffc0201532:	a011                	j	ffffffffc0201536 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0201534:	c121                	beqz	a0,ffffffffc0201574 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201536:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201538:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020153a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020153c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201540:	ff351ae3          	bne	a0,s3,ffffffffc0201534 <vprintfmt+0x52>
ffffffffc0201544:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201548:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020154c:	4981                	li	s3,0
ffffffffc020154e:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0201550:	5cfd                	li	s9,-1
ffffffffc0201552:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201554:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201558:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020155a:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020155e:	0ff6f693          	andi	a3,a3,255
ffffffffc0201562:	00140d13          	addi	s10,s0,1
ffffffffc0201566:	20d5e563          	bltu	a1,a3,ffffffffc0201770 <vprintfmt+0x28e>
ffffffffc020156a:	068a                	slli	a3,a3,0x2
ffffffffc020156c:	96d2                	add	a3,a3,s4
ffffffffc020156e:	4294                	lw	a3,0(a3)
ffffffffc0201570:	96d2                	add	a3,a3,s4
ffffffffc0201572:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201574:	70e6                	ld	ra,120(sp)
ffffffffc0201576:	7446                	ld	s0,112(sp)
ffffffffc0201578:	74a6                	ld	s1,104(sp)
ffffffffc020157a:	7906                	ld	s2,96(sp)
ffffffffc020157c:	69e6                	ld	s3,88(sp)
ffffffffc020157e:	6a46                	ld	s4,80(sp)
ffffffffc0201580:	6aa6                	ld	s5,72(sp)
ffffffffc0201582:	6b06                	ld	s6,64(sp)
ffffffffc0201584:	7be2                	ld	s7,56(sp)
ffffffffc0201586:	7c42                	ld	s8,48(sp)
ffffffffc0201588:	7ca2                	ld	s9,40(sp)
ffffffffc020158a:	7d02                	ld	s10,32(sp)
ffffffffc020158c:	6de2                	ld	s11,24(sp)
ffffffffc020158e:	6109                	addi	sp,sp,128
ffffffffc0201590:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201592:	4705                	li	a4,1
ffffffffc0201594:	008a8593          	addi	a1,s5,8
ffffffffc0201598:	01074463          	blt	a4,a6,ffffffffc02015a0 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc020159c:	26080363          	beqz	a6,ffffffffc0201802 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02015a0:	000ab603          	ld	a2,0(s5)
ffffffffc02015a4:	46c1                	li	a3,16
ffffffffc02015a6:	8aae                	mv	s5,a1
ffffffffc02015a8:	a06d                	j	ffffffffc0201652 <vprintfmt+0x170>
            goto reswitch;
ffffffffc02015aa:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02015ae:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015b0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02015b2:	b765                	j	ffffffffc020155a <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02015b4:	000aa503          	lw	a0,0(s5)
ffffffffc02015b8:	85a6                	mv	a1,s1
ffffffffc02015ba:	0aa1                	addi	s5,s5,8
ffffffffc02015bc:	9902                	jalr	s2
            break;
ffffffffc02015be:	bfb9                	j	ffffffffc020151c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02015c0:	4705                	li	a4,1
ffffffffc02015c2:	008a8993          	addi	s3,s5,8
ffffffffc02015c6:	01074463          	blt	a4,a6,ffffffffc02015ce <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02015ca:	22080463          	beqz	a6,ffffffffc02017f2 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02015ce:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02015d2:	24044463          	bltz	s0,ffffffffc020181a <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02015d6:	8622                	mv	a2,s0
ffffffffc02015d8:	8ace                	mv	s5,s3
ffffffffc02015da:	46a9                	li	a3,10
ffffffffc02015dc:	a89d                	j	ffffffffc0201652 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02015de:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02015e2:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02015e4:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02015e6:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02015ea:	8fb5                	xor	a5,a5,a3
ffffffffc02015ec:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02015f0:	1ad74363          	blt	a4,a3,ffffffffc0201796 <vprintfmt+0x2b4>
ffffffffc02015f4:	00369793          	slli	a5,a3,0x3
ffffffffc02015f8:	97e2                	add	a5,a5,s8
ffffffffc02015fa:	639c                	ld	a5,0(a5)
ffffffffc02015fc:	18078d63          	beqz	a5,ffffffffc0201796 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201600:	86be                	mv	a3,a5
ffffffffc0201602:	00001617          	auipc	a2,0x1
ffffffffc0201606:	24660613          	addi	a2,a2,582 # ffffffffc0202848 <error_string+0xe8>
ffffffffc020160a:	85a6                	mv	a1,s1
ffffffffc020160c:	854a                	mv	a0,s2
ffffffffc020160e:	240000ef          	jal	ra,ffffffffc020184e <printfmt>
ffffffffc0201612:	b729                	j	ffffffffc020151c <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201614:	00144603          	lbu	a2,1(s0)
ffffffffc0201618:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020161a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020161c:	bf3d                	j	ffffffffc020155a <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc020161e:	4705                	li	a4,1
ffffffffc0201620:	008a8593          	addi	a1,s5,8
ffffffffc0201624:	01074463          	blt	a4,a6,ffffffffc020162c <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201628:	1e080263          	beqz	a6,ffffffffc020180c <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc020162c:	000ab603          	ld	a2,0(s5)
ffffffffc0201630:	46a1                	li	a3,8
ffffffffc0201632:	8aae                	mv	s5,a1
ffffffffc0201634:	a839                	j	ffffffffc0201652 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201636:	03000513          	li	a0,48
ffffffffc020163a:	85a6                	mv	a1,s1
ffffffffc020163c:	e03e                	sd	a5,0(sp)
ffffffffc020163e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201640:	85a6                	mv	a1,s1
ffffffffc0201642:	07800513          	li	a0,120
ffffffffc0201646:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201648:	0aa1                	addi	s5,s5,8
ffffffffc020164a:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc020164e:	6782                	ld	a5,0(sp)
ffffffffc0201650:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201652:	876e                	mv	a4,s11
ffffffffc0201654:	85a6                	mv	a1,s1
ffffffffc0201656:	854a                	mv	a0,s2
ffffffffc0201658:	e1fff0ef          	jal	ra,ffffffffc0201476 <printnum>
            break;
ffffffffc020165c:	b5c1                	j	ffffffffc020151c <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020165e:	000ab603          	ld	a2,0(s5)
ffffffffc0201662:	0aa1                	addi	s5,s5,8
ffffffffc0201664:	1c060663          	beqz	a2,ffffffffc0201830 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201668:	00160413          	addi	s0,a2,1
ffffffffc020166c:	17b05c63          	blez	s11,ffffffffc02017e4 <vprintfmt+0x302>
ffffffffc0201670:	02d00593          	li	a1,45
ffffffffc0201674:	14b79263          	bne	a5,a1,ffffffffc02017b8 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201678:	00064783          	lbu	a5,0(a2)
ffffffffc020167c:	0007851b          	sext.w	a0,a5
ffffffffc0201680:	c905                	beqz	a0,ffffffffc02016b0 <vprintfmt+0x1ce>
ffffffffc0201682:	000cc563          	bltz	s9,ffffffffc020168c <vprintfmt+0x1aa>
ffffffffc0201686:	3cfd                	addiw	s9,s9,-1
ffffffffc0201688:	036c8263          	beq	s9,s6,ffffffffc02016ac <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc020168c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020168e:	18098463          	beqz	s3,ffffffffc0201816 <vprintfmt+0x334>
ffffffffc0201692:	3781                	addiw	a5,a5,-32
ffffffffc0201694:	18fbf163          	bleu	a5,s7,ffffffffc0201816 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0201698:	03f00513          	li	a0,63
ffffffffc020169c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020169e:	0405                	addi	s0,s0,1
ffffffffc02016a0:	fff44783          	lbu	a5,-1(s0)
ffffffffc02016a4:	3dfd                	addiw	s11,s11,-1
ffffffffc02016a6:	0007851b          	sext.w	a0,a5
ffffffffc02016aa:	fd61                	bnez	a0,ffffffffc0201682 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02016ac:	e7b058e3          	blez	s11,ffffffffc020151c <vprintfmt+0x3a>
ffffffffc02016b0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02016b2:	85a6                	mv	a1,s1
ffffffffc02016b4:	02000513          	li	a0,32
ffffffffc02016b8:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02016ba:	e60d81e3          	beqz	s11,ffffffffc020151c <vprintfmt+0x3a>
ffffffffc02016be:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02016c0:	85a6                	mv	a1,s1
ffffffffc02016c2:	02000513          	li	a0,32
ffffffffc02016c6:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02016c8:	fe0d94e3          	bnez	s11,ffffffffc02016b0 <vprintfmt+0x1ce>
ffffffffc02016cc:	bd81                	j	ffffffffc020151c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02016ce:	4705                	li	a4,1
ffffffffc02016d0:	008a8593          	addi	a1,s5,8
ffffffffc02016d4:	01074463          	blt	a4,a6,ffffffffc02016dc <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02016d8:	12080063          	beqz	a6,ffffffffc02017f8 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02016dc:	000ab603          	ld	a2,0(s5)
ffffffffc02016e0:	46a9                	li	a3,10
ffffffffc02016e2:	8aae                	mv	s5,a1
ffffffffc02016e4:	b7bd                	j	ffffffffc0201652 <vprintfmt+0x170>
ffffffffc02016e6:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02016ea:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016ee:	846a                	mv	s0,s10
ffffffffc02016f0:	b5ad                	j	ffffffffc020155a <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02016f2:	85a6                	mv	a1,s1
ffffffffc02016f4:	02500513          	li	a0,37
ffffffffc02016f8:	9902                	jalr	s2
            break;
ffffffffc02016fa:	b50d                	j	ffffffffc020151c <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02016fc:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201700:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201704:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201706:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0201708:	e40dd9e3          	bgez	s11,ffffffffc020155a <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc020170c:	8de6                	mv	s11,s9
ffffffffc020170e:	5cfd                	li	s9,-1
ffffffffc0201710:	b5a9                	j	ffffffffc020155a <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201712:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0201716:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020171a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020171c:	bd3d                	j	ffffffffc020155a <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc020171e:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201722:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201726:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201728:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020172c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201730:	fcd56ce3          	bltu	a0,a3,ffffffffc0201708 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201734:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201736:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020173a:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020173e:	0196873b          	addw	a4,a3,s9
ffffffffc0201742:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201746:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020174a:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020174e:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201752:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201756:	fcd57fe3          	bleu	a3,a0,ffffffffc0201734 <vprintfmt+0x252>
ffffffffc020175a:	b77d                	j	ffffffffc0201708 <vprintfmt+0x226>
            if (width < 0)
ffffffffc020175c:	fffdc693          	not	a3,s11
ffffffffc0201760:	96fd                	srai	a3,a3,0x3f
ffffffffc0201762:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201766:	00144603          	lbu	a2,1(s0)
ffffffffc020176a:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020176c:	846a                	mv	s0,s10
ffffffffc020176e:	b3f5                	j	ffffffffc020155a <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201770:	85a6                	mv	a1,s1
ffffffffc0201772:	02500513          	li	a0,37
ffffffffc0201776:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201778:	fff44703          	lbu	a4,-1(s0)
ffffffffc020177c:	02500793          	li	a5,37
ffffffffc0201780:	8d22                	mv	s10,s0
ffffffffc0201782:	d8f70de3          	beq	a4,a5,ffffffffc020151c <vprintfmt+0x3a>
ffffffffc0201786:	02500713          	li	a4,37
ffffffffc020178a:	1d7d                	addi	s10,s10,-1
ffffffffc020178c:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201790:	fee79de3          	bne	a5,a4,ffffffffc020178a <vprintfmt+0x2a8>
ffffffffc0201794:	b361                	j	ffffffffc020151c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201796:	00001617          	auipc	a2,0x1
ffffffffc020179a:	0a260613          	addi	a2,a2,162 # ffffffffc0202838 <error_string+0xd8>
ffffffffc020179e:	85a6                	mv	a1,s1
ffffffffc02017a0:	854a                	mv	a0,s2
ffffffffc02017a2:	0ac000ef          	jal	ra,ffffffffc020184e <printfmt>
ffffffffc02017a6:	bb9d                	j	ffffffffc020151c <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02017a8:	00001617          	auipc	a2,0x1
ffffffffc02017ac:	08860613          	addi	a2,a2,136 # ffffffffc0202830 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02017b0:	00001417          	auipc	s0,0x1
ffffffffc02017b4:	08140413          	addi	s0,s0,129 # ffffffffc0202831 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017b8:	8532                	mv	a0,a2
ffffffffc02017ba:	85e6                	mv	a1,s9
ffffffffc02017bc:	e032                	sd	a2,0(sp)
ffffffffc02017be:	e43e                	sd	a5,8(sp)
ffffffffc02017c0:	1c2000ef          	jal	ra,ffffffffc0201982 <strnlen>
ffffffffc02017c4:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02017c8:	6602                	ld	a2,0(sp)
ffffffffc02017ca:	01b05d63          	blez	s11,ffffffffc02017e4 <vprintfmt+0x302>
ffffffffc02017ce:	67a2                	ld	a5,8(sp)
ffffffffc02017d0:	2781                	sext.w	a5,a5
ffffffffc02017d2:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02017d4:	6522                	ld	a0,8(sp)
ffffffffc02017d6:	85a6                	mv	a1,s1
ffffffffc02017d8:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017da:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02017dc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017de:	6602                	ld	a2,0(sp)
ffffffffc02017e0:	fe0d9ae3          	bnez	s11,ffffffffc02017d4 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017e4:	00064783          	lbu	a5,0(a2)
ffffffffc02017e8:	0007851b          	sext.w	a0,a5
ffffffffc02017ec:	e8051be3          	bnez	a0,ffffffffc0201682 <vprintfmt+0x1a0>
ffffffffc02017f0:	b335                	j	ffffffffc020151c <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02017f2:	000aa403          	lw	s0,0(s5)
ffffffffc02017f6:	bbf1                	j	ffffffffc02015d2 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02017f8:	000ae603          	lwu	a2,0(s5)
ffffffffc02017fc:	46a9                	li	a3,10
ffffffffc02017fe:	8aae                	mv	s5,a1
ffffffffc0201800:	bd89                	j	ffffffffc0201652 <vprintfmt+0x170>
ffffffffc0201802:	000ae603          	lwu	a2,0(s5)
ffffffffc0201806:	46c1                	li	a3,16
ffffffffc0201808:	8aae                	mv	s5,a1
ffffffffc020180a:	b5a1                	j	ffffffffc0201652 <vprintfmt+0x170>
ffffffffc020180c:	000ae603          	lwu	a2,0(s5)
ffffffffc0201810:	46a1                	li	a3,8
ffffffffc0201812:	8aae                	mv	s5,a1
ffffffffc0201814:	bd3d                	j	ffffffffc0201652 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0201816:	9902                	jalr	s2
ffffffffc0201818:	b559                	j	ffffffffc020169e <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc020181a:	85a6                	mv	a1,s1
ffffffffc020181c:	02d00513          	li	a0,45
ffffffffc0201820:	e03e                	sd	a5,0(sp)
ffffffffc0201822:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201824:	8ace                	mv	s5,s3
ffffffffc0201826:	40800633          	neg	a2,s0
ffffffffc020182a:	46a9                	li	a3,10
ffffffffc020182c:	6782                	ld	a5,0(sp)
ffffffffc020182e:	b515                	j	ffffffffc0201652 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201830:	01b05663          	blez	s11,ffffffffc020183c <vprintfmt+0x35a>
ffffffffc0201834:	02d00693          	li	a3,45
ffffffffc0201838:	f6d798e3          	bne	a5,a3,ffffffffc02017a8 <vprintfmt+0x2c6>
ffffffffc020183c:	00001417          	auipc	s0,0x1
ffffffffc0201840:	ff540413          	addi	s0,s0,-11 # ffffffffc0202831 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201844:	02800513          	li	a0,40
ffffffffc0201848:	02800793          	li	a5,40
ffffffffc020184c:	bd1d                	j	ffffffffc0201682 <vprintfmt+0x1a0>

ffffffffc020184e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020184e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201850:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201854:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201856:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201858:	ec06                	sd	ra,24(sp)
ffffffffc020185a:	f83a                	sd	a4,48(sp)
ffffffffc020185c:	fc3e                	sd	a5,56(sp)
ffffffffc020185e:	e0c2                	sd	a6,64(sp)
ffffffffc0201860:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201862:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201864:	c7fff0ef          	jal	ra,ffffffffc02014e2 <vprintfmt>
}
ffffffffc0201868:	60e2                	ld	ra,24(sp)
ffffffffc020186a:	6161                	addi	sp,sp,80
ffffffffc020186c:	8082                	ret

ffffffffc020186e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020186e:	715d                	addi	sp,sp,-80
ffffffffc0201870:	e486                	sd	ra,72(sp)
ffffffffc0201872:	e0a2                	sd	s0,64(sp)
ffffffffc0201874:	fc26                	sd	s1,56(sp)
ffffffffc0201876:	f84a                	sd	s2,48(sp)
ffffffffc0201878:	f44e                	sd	s3,40(sp)
ffffffffc020187a:	f052                	sd	s4,32(sp)
ffffffffc020187c:	ec56                	sd	s5,24(sp)
ffffffffc020187e:	e85a                	sd	s6,16(sp)
ffffffffc0201880:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201882:	c901                	beqz	a0,ffffffffc0201892 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201884:	85aa                	mv	a1,a0
ffffffffc0201886:	00001517          	auipc	a0,0x1
ffffffffc020188a:	fc250513          	addi	a0,a0,-62 # ffffffffc0202848 <error_string+0xe8>
ffffffffc020188e:	829fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201892:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201894:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201896:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201898:	4aa9                	li	s5,10
ffffffffc020189a:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020189c:	00004b97          	auipc	s7,0x4
ffffffffc02018a0:	774b8b93          	addi	s7,s7,1908 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018a4:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02018a8:	887fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02018ac:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02018ae:	00054b63          	bltz	a0,ffffffffc02018c4 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018b2:	00a95b63          	ble	a0,s2,ffffffffc02018c8 <readline+0x5a>
ffffffffc02018b6:	029a5463          	ble	s1,s4,ffffffffc02018de <readline+0x70>
        c = getchar();
ffffffffc02018ba:	875fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02018be:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02018c0:	fe0559e3          	bgez	a0,ffffffffc02018b2 <readline+0x44>
            return NULL;
ffffffffc02018c4:	4501                	li	a0,0
ffffffffc02018c6:	a099                	j	ffffffffc020190c <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02018c8:	03341463          	bne	s0,s3,ffffffffc02018f0 <readline+0x82>
ffffffffc02018cc:	e8b9                	bnez	s1,ffffffffc0201922 <readline+0xb4>
        c = getchar();
ffffffffc02018ce:	861fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02018d2:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02018d4:	fe0548e3          	bltz	a0,ffffffffc02018c4 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018d8:	fea958e3          	ble	a0,s2,ffffffffc02018c8 <readline+0x5a>
ffffffffc02018dc:	4481                	li	s1,0
            cputchar(c);
ffffffffc02018de:	8522                	mv	a0,s0
ffffffffc02018e0:	80bfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02018e4:	009b87b3          	add	a5,s7,s1
ffffffffc02018e8:	00878023          	sb	s0,0(a5)
ffffffffc02018ec:	2485                	addiw	s1,s1,1
ffffffffc02018ee:	bf6d                	j	ffffffffc02018a8 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02018f0:	01540463          	beq	s0,s5,ffffffffc02018f8 <readline+0x8a>
ffffffffc02018f4:	fb641ae3          	bne	s0,s6,ffffffffc02018a8 <readline+0x3a>
            cputchar(c);
ffffffffc02018f8:	8522                	mv	a0,s0
ffffffffc02018fa:	ff0fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc02018fe:	00004517          	auipc	a0,0x4
ffffffffc0201902:	71250513          	addi	a0,a0,1810 # ffffffffc0206010 <edata>
ffffffffc0201906:	94aa                	add	s1,s1,a0
ffffffffc0201908:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020190c:	60a6                	ld	ra,72(sp)
ffffffffc020190e:	6406                	ld	s0,64(sp)
ffffffffc0201910:	74e2                	ld	s1,56(sp)
ffffffffc0201912:	7942                	ld	s2,48(sp)
ffffffffc0201914:	79a2                	ld	s3,40(sp)
ffffffffc0201916:	7a02                	ld	s4,32(sp)
ffffffffc0201918:	6ae2                	ld	s5,24(sp)
ffffffffc020191a:	6b42                	ld	s6,16(sp)
ffffffffc020191c:	6ba2                	ld	s7,8(sp)
ffffffffc020191e:	6161                	addi	sp,sp,80
ffffffffc0201920:	8082                	ret
            cputchar(c);
ffffffffc0201922:	4521                	li	a0,8
ffffffffc0201924:	fc6fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201928:	34fd                	addiw	s1,s1,-1
ffffffffc020192a:	bfbd                	j	ffffffffc02018a8 <readline+0x3a>

ffffffffc020192c <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc020192c:	00004797          	auipc	a5,0x4
ffffffffc0201930:	6dc78793          	addi	a5,a5,1756 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201934:	6398                	ld	a4,0(a5)
ffffffffc0201936:	4781                	li	a5,0
ffffffffc0201938:	88ba                	mv	a7,a4
ffffffffc020193a:	852a                	mv	a0,a0
ffffffffc020193c:	85be                	mv	a1,a5
ffffffffc020193e:	863e                	mv	a2,a5
ffffffffc0201940:	00000073          	ecall
ffffffffc0201944:	87aa                	mv	a5,a0
}
ffffffffc0201946:	8082                	ret

ffffffffc0201948 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201948:	00005797          	auipc	a5,0x5
ffffffffc020194c:	ae078793          	addi	a5,a5,-1312 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201950:	6398                	ld	a4,0(a5)
ffffffffc0201952:	4781                	li	a5,0
ffffffffc0201954:	88ba                	mv	a7,a4
ffffffffc0201956:	852a                	mv	a0,a0
ffffffffc0201958:	85be                	mv	a1,a5
ffffffffc020195a:	863e                	mv	a2,a5
ffffffffc020195c:	00000073          	ecall
ffffffffc0201960:	87aa                	mv	a5,a0
}
ffffffffc0201962:	8082                	ret

ffffffffc0201964 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201964:	00004797          	auipc	a5,0x4
ffffffffc0201968:	69c78793          	addi	a5,a5,1692 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc020196c:	639c                	ld	a5,0(a5)
ffffffffc020196e:	4501                	li	a0,0
ffffffffc0201970:	88be                	mv	a7,a5
ffffffffc0201972:	852a                	mv	a0,a0
ffffffffc0201974:	85aa                	mv	a1,a0
ffffffffc0201976:	862a                	mv	a2,a0
ffffffffc0201978:	00000073          	ecall
ffffffffc020197c:	852a                	mv	a0,a0
ffffffffc020197e:	2501                	sext.w	a0,a0
ffffffffc0201980:	8082                	ret

ffffffffc0201982 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201982:	c185                	beqz	a1,ffffffffc02019a2 <strnlen+0x20>
ffffffffc0201984:	00054783          	lbu	a5,0(a0)
ffffffffc0201988:	cf89                	beqz	a5,ffffffffc02019a2 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc020198a:	4781                	li	a5,0
ffffffffc020198c:	a021                	j	ffffffffc0201994 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc020198e:	00074703          	lbu	a4,0(a4)
ffffffffc0201992:	c711                	beqz	a4,ffffffffc020199e <strnlen+0x1c>
        cnt ++;
ffffffffc0201994:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201996:	00f50733          	add	a4,a0,a5
ffffffffc020199a:	fef59ae3          	bne	a1,a5,ffffffffc020198e <strnlen+0xc>
    }
    return cnt;
}
ffffffffc020199e:	853e                	mv	a0,a5
ffffffffc02019a0:	8082                	ret
    size_t cnt = 0;
ffffffffc02019a2:	4781                	li	a5,0
}
ffffffffc02019a4:	853e                	mv	a0,a5
ffffffffc02019a6:	8082                	ret

ffffffffc02019a8 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02019a8:	00054783          	lbu	a5,0(a0)
ffffffffc02019ac:	0005c703          	lbu	a4,0(a1)
ffffffffc02019b0:	cb91                	beqz	a5,ffffffffc02019c4 <strcmp+0x1c>
ffffffffc02019b2:	00e79c63          	bne	a5,a4,ffffffffc02019ca <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02019b6:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02019b8:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02019bc:	0585                	addi	a1,a1,1
ffffffffc02019be:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02019c2:	fbe5                	bnez	a5,ffffffffc02019b2 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02019c4:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02019c6:	9d19                	subw	a0,a0,a4
ffffffffc02019c8:	8082                	ret
ffffffffc02019ca:	0007851b          	sext.w	a0,a5
ffffffffc02019ce:	9d19                	subw	a0,a0,a4
ffffffffc02019d0:	8082                	ret

ffffffffc02019d2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02019d2:	00054783          	lbu	a5,0(a0)
ffffffffc02019d6:	cb91                	beqz	a5,ffffffffc02019ea <strchr+0x18>
        if (*s == c) {
ffffffffc02019d8:	00b79563          	bne	a5,a1,ffffffffc02019e2 <strchr+0x10>
ffffffffc02019dc:	a809                	j	ffffffffc02019ee <strchr+0x1c>
ffffffffc02019de:	00b78763          	beq	a5,a1,ffffffffc02019ec <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02019e2:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02019e4:	00054783          	lbu	a5,0(a0)
ffffffffc02019e8:	fbfd                	bnez	a5,ffffffffc02019de <strchr+0xc>
    }
    return NULL;
ffffffffc02019ea:	4501                	li	a0,0
}
ffffffffc02019ec:	8082                	ret
ffffffffc02019ee:	8082                	ret

ffffffffc02019f0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02019f0:	ca01                	beqz	a2,ffffffffc0201a00 <memset+0x10>
ffffffffc02019f2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02019f4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02019f6:	0785                	addi	a5,a5,1
ffffffffc02019f8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02019fc:	fec79de3          	bne	a5,a2,ffffffffc02019f6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201a00:	8082                	ret
