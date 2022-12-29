# 第五章：逻辑、移位操作与空指令的实现
## 1、流水线数据相关问题
* 数据相关：指的是在流水线中执行的几条指令中，一条指令依赖于前面指令的执行结果。目前主要遇到的问题是 RAW 情况。
    *  RAW，即 Read After Write，假设指令 j 是在指令 i 后面执行的指令，RAW 表示指令 i 将数据写入寄存器后，指令 j 才能从这个寄存器读取数据。如果指令 j 在指令 i 写入寄存器前尝试读出该寄存器的内容，将得到不正确的数据。

        ```
        ori $1,$0,0x1100
        ori $3,$o,0xffff
        ori $4,$o,0xffff
        ori $2,$1,0x0020
        ```

<div align=center><img src=./Picture/1.png width = 80% ></div>

* 解决方法：**数据前推**，将计算结果从其产生处直接送到其他指令需要处或所有需要的功能单元处。在上面的例子中，新的 \$1 值实际上在第 1 条 ori 指令的执行阶段已经计算出来了
    * 可以直接将该值从第 1 条 ori 指令的**执行阶段**送入第 2 条 ori 指令的**译码阶段**，从而使第 2 条 ori 指令在译码阶段得到 \$1 的新值。
    * 也可以直接将该值从第 1 条 ori 指令的**访存阶段**送入第 3 条 ori 指令的译码阶段，从而使第 3 条 ori 指令在**译码阶**段也得到 \$1 的新值。

**简单说就是把后阶段的中间计算结果拉条线到译码阶段。**

与 [Chapter4](https://github.com/cpyhal3515/OpenMIPS/tree/main/Chapter4) 中的流水线示意图相比增加了下面图中红色的部分：
<div align=center><img src=./Picture/2.png width = 80% ></div>
根据上面的流水线示意图可以得到如下所示的模块连接结构示意图：
<div align=center><img src=./Picture/3.png width = 80% ></div>


## 2、逻辑、移位操作与空指令说明
### (1) and（与）、or（或）、xor（异或）、nor（或非）

<div align=center><img src=./Picture/4.png width = 80% ></div>

`XXX rd, rs, rt`，这里 `XXX` 表示指令，`rd <- rs XXX rt` 将地址为 rs 的通用寄存器的值与地址为 rt 的通用寄存器的值进行 `XXX` 运算后，将运算结果保存到地址为 rd 的通用寄存器中。

### (2) andi（与）、xori（异或）
<div align=center><img src=./Picture/5.png width = 80% ></div>

`XXX rt, rs, immediate`，这里 `XXX` 表示指令，`rt <- rs XXX zero_extended(immediate)` 将地址为 rs 的通用寄存器的值与指令中立即数进行无符号扩展后的值进行 `XXX` 运算，运算结果保存到地址为 rt 的通用寄存器中。

### (3) lui 指令
<div align=center><img src=./Picture/6.png width = 80% ></div>

`lui rt, immediate`，`rt <- {immediate, 0000_0000_0000_0000}` 将指令中的 16bit 立即数保存到地址为 rt 的通用寄存器的高 16 位，低 16 位用 0 填充。

### (4) sll（逻辑左移），sllv，sra（算术右移），srav，srl（逻辑右移），srlv 指令
<div align=center><img src=./Picture/7.png width = 80% ></div>

加 v 表示移动的位数存在寄存器中。
* `XXX rd, rt, sa`，将地址为 rt 的通用寄存器的值移动 sa 位，逻辑（空出的位置用 0 填充），算数（空出的位置用 rt[31] 填充），结果保存在地址为 rd 的寄存器中。
* `XXXv rd, rt, sa`，将地址为 rt 的通用寄存器的值移动 rs[4:0] 位，逻辑（空出的位置用 0 填充），算数（空出的位置用 rt[31] 填充），结果保存在地址为 rd 的寄存器中。

### (5) nop、ssnop、sync、pref 指令
<div align=center><img src=./Picture/8.png width = 80% ></div>

对于 OpenMIPS，将这四个指令均当做空指令来用。

指令处理顺序如下：

<div align=center><img src=./Picture/9.png width = 80% ></div>










