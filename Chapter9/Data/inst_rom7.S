.org 0x0
   .set noat
   .set noreorder
   .set nomacro
   .global _start
_start:
    ori $1,$0,0x0001  #（1）$1 = 0x1
    j 0x20              # 转移到 0x20 处
    ori $1,$0,0x0002  #（2）$1 = 0x2,这是延迟槽指令
    ori $1,$0,0x1111
    ori $1,$0,0x1100

.org 0x20
    ori $1,$0,0x0003  #（3）$1 = 0x3
    jal 0x40            # 转移到0x40处,同时设置$31为0x2c
    div $zero,$31,$1  #（4）此时$31 = 0x2c,$1 = 0x3,所以得到除法结果
                        # HI = 0x2,LO= 0xe,这是延迟槽指令

    ori $1,$0,0x0005  #（6）$1 = 0x5
    ori $1,$0,0x0006  #（7）$1 = 0x6
    j 0x60              # 转移到 0x60 处
    nop

.org 0x40
    jalr $2,$31        #此时$31为0x2c,所以转移到0x2c,同时设置$2为0x48
    or $1,$2,$0       #（5）$1 = 0x48,这是延迟槽指令

    ori $1,$0,0x0009  #（10）$1 = 0x9
    ori $1,$0,0x000a  #（11）$1 = 0xa
    j 0x80              # 转移到 0×80 处
    nop

.org 0x60
    ori $1,$0,0x0007  #（8）$1 = 0x7
    jr $2               # 此时$2 为 0x48,所以转移到 0x48 处
    ori $1,$0,0x0008  #（9）$1= 0x8,这是延迟槽指令
    ori $1,$0,0x1111
    ori $1,$0,0x1100

.org 0x80
    nop


    
_loop:
   j _loop
   nop
