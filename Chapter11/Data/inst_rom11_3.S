    .org 0x0
    .set noat
    .set noreorder
    .set nomacro
    .global _start 
_start:
    # 因为低地址有异常处理例程, 所以处理器启动后, 就立即转移到0x100处
    ori $1, $0, 0x100       # $1=0x100
    jr $1
    nop

    # 中断处理例程, 在其中将$2寄存器的值加1, 这样便于观察时钟中断是否发生。
    # 另外, 增加Compare寄存器的值, 以清除时钟中断声明, 同时设置下一次时钟
    # 中断发生的时间
    .org 0x20
    addi $2, $2, 0x1    # $2寄存器的值加1
    mfc0 $1, $11, 0x0   # 读取Compare寄存器的值
    addi $1, $1, 100    # 增加100
    mtc0 $1, $11, 0x0   # 再保存回Compare寄存器
    eret 
    nop

# 主程序, 在其中初始化Compare寄存器, 并且使能时钟中断
.org 0x100
ori $2, $0, 0x0
ori $1, $0, 100
mtc0 $1, $11, 0x0   # 初始化Compare寄存器的值为100

lui $1, 0x1000
ori $1, $1, 0x401
mtc0 $1, $12, 0x0   # 设置 status 寄存器的值为 0x10000401, 表示使能时钟中断

_loop:
    j _loop 
    nop